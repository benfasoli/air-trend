#!/usr/bin/env python

from datetime import datetime
import os
import string

import serial


class SerialInstrument:
    '''Interface to RS232 serial analyzer'''

    def __init__(self, device: str, baudrate: int, path: str,
                 file_name: str = '%Y_%m_%d.dat'):
        self.path = os.path.join(os.path.expanduser(path), file_name)
        self.ser = serial.Serial(device, baudrate)
        self.record = None
    
    def __exit__(self, *args):
        self.ser.flush()
        self.ser.close()

    def read_record(self, delimiter: str = None):
        record = self.ser.readline()
        record_time = datetime.utcnow()
        record = record.replace('\r', '').replace('\n', '')
        record = ''.join([x for x in list(record) if x in set(string.printable)])
        self.record = (
            ','.join([record_time.isoformat()] + record.split(delimiter)) + '\n')

    def save_record(self):
        with open(self.path, 'a+') as f:
            f.write(self.record)


