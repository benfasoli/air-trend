#!/usr/bin/env python3

import csv
from datetime import datetime
import json
import logging
from multiprocessing import Process, Queue
import os
import re
import string
import time
from typing import Iterator, List, Union

import serial


CONFIG = os.getenv("CONFIG", "config.json")
DATAPATH = os.getenv("DATAPATH", "data")
LOGLEVEL = os.getenv("LOGLEVEL", "INFO")


logging.basicConfig(
    level=LOGLEVEL, format="%(asctime)s | %(name)s | %(levelname)s | %(message)s"
)
logger = logging.getLogger()


with open(CONFIG, "r") as f:
    DEVICES = json.load(f)


class SerialDevicePoolError(Exception):
    pass


class SerialDevice:
    """Interfaces with serial hardware

    Objects of this class provide generator methods to stream or poll data
    from a given serial port.

    Parameters
    ----------
    name : str
        unique key for device
    port : str
        path to serial device, typically registered at /dev/serial/by-id/<id>
        for unix based systems
    variables : list
        full list of objects defining the variable set returned in a given
        response. The "name" key of each variable object is used to define the
        variable names in order and the "save" key determines whether a given
        field should be written to file
    baudrate : int
        connection speed for serial device
    delimiter : str
        string used to separate variables in serial response
    eol_delimiter : str
        string used to indicate the end of a transmitted record (end of line)
    filter_response : str
        regular expression that is executed against the response string used to
        filter and mutate the result. Response is split  by delimiter and passed
        to re.search
    init_command : str
        command to send when initializing serial connection to device
    poll_command : str
        command that becomes byte encoded and issued to serial device
    poll_interval : float
        time in seconds to pause between polling device for new data
    poll_type : str or None
        enable polling serial device for new data using associated poll_* args.
        Can be "line" for pre-formatted line data where variables are separated
        by delimiter, "batch" for processing more complicated responses with
        filter_response, or None to indicate that streaming method should be used
    timeout : float or int
        number of seconds to wait for record to be returned
    """

    def __init__(
        self,
        name: str,
        port: str,
        variables: list,
        baudrate: int = 9600,
        delimiter: str = ",",
        eol_delimiter: str = "\r\n",
        filter_response: float = None,
        init_command: str = None,
        poll_command: str = None,
        poll_interval: float = 0,
        poll_type: float = None,
        timeout: float = 60,
    ):
        self.logger = logging.getLogger(name)
        self.baudrate = baudrate
        self.delimiter = delimiter
        self.eol_delimiter = eol_delimiter
        self.filter_response = filter_response
        self.name = name.strip()
        self.poll_command = poll_command
        self.poll_interval = poll_interval
        self.timeout = timeout
        self.variables = variables
        self.n_variables = len(variables)

        self.ser = serial.Serial(port=port, baudrate=baudrate, timeout=timeout)

        if init_command:
            self.ser.write(init_command.encode("utf-8"))

        if poll_type == "line":
            self.get_data = self._poll_line
        elif poll_type == "batch":
            self.get_data = self._poll_batch
        elif poll_type is not None:
            raise ValueError("poll_type must be line or batch")
        else:
            self.get_data = self._stream

    def _format_response(
        self, timestamp: datetime, response: Union[List[str], str]
    ) -> dict:
        """Formats data record for given timestamp and observation set

        Parameters
        ----------
        timestamp : datetime
            datetime of record as returned by datetime.datetime.utcnow()
        response : list or str
            list of string formatted response lines

        Returns
        -------
        dict
            observations reformatted as key value pairs
            {
                'time': datetime.datetime(2020, 4, 29, 20, 33, 2, 11995)),
                'nox_std_ppb': '54.0',
                ...
            }
        """
        self.logger.debug(response)

        if type(response) is not list:
            response = [response]

        for i, line in enumerate(response):
            response[i] = line.strip()

        if self.filter_response:
            records = []
            for line in response:
                match = re.search(self.filter_response, line)
                if match:
                    records.append(match.group())
        else:
            records = response

        record = self.delimiter.join(records)
        record = "".join([x for x in record if x in string.printable])
        self.logger.debug(record)

        columns = re.split(self.delimiter, record)
        n_col = len(columns)
        if not n_col == self.n_variables:
            self.logger.debug(
                (f"Found {n_col} records but " f"config specifies {self.n_variables}.")
            )
            return None

        row = {"time": timestamp}
        for i in range(n_col):
            if self.variables[i]["save"]:
                row[self.variables[i]["name"]] = columns[i]

        return row

    def _poll_batch(self) -> Iterator[dict]:
        """Polls device for data returned and optionally formatted using regex

        Generator that periodically polls device, waiting poll_interval seconds
        and then reading all available bytes from the serial buffer. Optionally,
        filter_response can be used to match and filter the returned data. Yields
        list of dictionary records.
        """
        while True:
            self.ser.write(self.poll_command.encode("utf-8"))
            timestamp = datetime.utcnow()
            time.sleep(self.poll_interval)

            response = b""
            while self.ser.in_waiting:
                response = response + self.ser.read()

            try:
                response = response.decode("utf-8")
            except UnicodeDecodeError:
                continue

            response = response.split(self.delimiter)
            yield self._format_response(timestamp, response)

    def _poll_line(self) -> Iterator[dict]:
        """Polls device for preformatted line observation set

        Generator that periodically polls device then blocks until a full line
        of data is received to the serial buffer. Yields list of dictionary
        records.
        """
        while True:
            self.ser.write(self.poll_command.encode("utf-8"))
            timestamp = datetime.utcnow()
            time.sleep(self.poll_interval)

            response = self.ser.read_until(self.eol_delimiter.encode("utf-8"))

            try:
                response = response.decode("utf-8")
            except UnicodeDecodeError:
                continue

            response_parts = response.split(self.delimiter)
            yield self._format_response(timestamp, response_parts)

    def _stream(self) -> Iterator[dict]:
        """Returns data from serial buffer

        Generator that blocks until line is received in device's serial buffer
        and yields list of dictionary records.
        """
        while True:
            response = self.ser.read_until(self.eol_delimiter.encode("utf-8"))
            timestamp = datetime.utcnow()

            try:
                response = response.decode("utf-8")
            except UnicodeDecodeError:
                continue

            yield self._format_response(timestamp, response)

    def close(self):
        self.ser.close()


def worker(q: Queue, device_args: dict):
    """Instantiates and indefinitely reads from serial device"""
    is_active = device_args.get("is_active", True)
    name = device_args.get("name", None)

    if is_active:
        logger.info(f"Starting device worker: {device_args}")
    else:
        logger.info(f"Device {name} currently disabled: {device_args}")
        return None

    device = None
    while True:
        try:
            device = SerialDevice(**device_args)
            for row in device.get_data():
                if row:
                    q.put({"name": name, "row": row})

        except (OSError, KeyboardInterrupt, SystemExit) as e:
            q.put({"service_exit": True})
            raise e

        except BaseException as e:
            logger.exception(e)
            time.sleep(1)

        if device is not None:
            device.close()
            device = None


def writer(q: Queue):
    """Receives messages from queue and writes to file"""
    while True:
        try:
            data = q.get()
            logger.info(data)

            if data.get("service_exit", False):
                raise SerialDevicePoolError("Restarting device pool")

            name = data["name"]
            row = data["row"]
            row["time"] = row["time"].isoformat()

            date = row["time"][0:10]
            path = os.path.join(DATAPATH, name, f"{date}.csv")
            should_write_header = not os.path.exists(path)

            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "a") as f:
                writer = csv.DictWriter(f, fieldnames=row.keys())
                if should_write_header:
                    writer.writeheader()
                writer.writerow(row)

        except (SerialDevicePoolError, KeyboardInterrupt, SystemExit):
            raise


def main():
    q = Queue()

    for device_args in DEVICES:
        p = Process(target=worker, kwargs={"q": q, "device_args": device_args})
        p.daemon = True
        p.start()

    p = Process(target=writer, kwargs={"q": q})
    p.start()
    p.join()


if __name__ == "__main__":
    main()
