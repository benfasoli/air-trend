# Air Trend

Minimal declarative data logging which supports parallel serial workloads, poll and stream I/O via RS232, and REGEX response parsing.

- [Installation](#installation)
- [Configuration](#configuration)
- [Starting the service](#starting-the-service)
- [Data format](#data-format)

## Installation

This library minimizes resource consumption for use on low cost single board linux computers (e.g. Raspberry Pi), although there is nothing to stop you from using this on other systems.

The system will need the following dependencies.

- `git`
- `docker` ([Install](https://docs.docker.com/engine/install/))
- `docker-compose` ([Install](https://docs.docker.com/compose/install/))

For Raspberry Pi OS systems, you can install the relevant dependencies as follows.

```bash
# Update package index and install dependencies
sudo apt update -y
sudo apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  git \
  gnupg-agent \
  python3 \
  python3-pip \
  software-properties-common

# Install docker
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh

# Add the pi user to the docker group
sudo usermod -aG docker pi

# Install docker-compose
sudo pip3 install docker-compose
```

Once the dependencies are installed, restart the system. The next step is to clone this repository.

```bash
git clone --depth=1 https://github.com/benfasoli/air-trend /home/pi/air-trend
```

> This clones the repository to `/home/pi/air-trend` but any path will do.

## Configuration

The `docker-compose.yml` file defines the path used for storing logged data (defaults to `/home/pi/data/<device_id>`).

If you cloned the repository to a location other than `/home/pi/air-trend` or wish to store logged data in a location other than `/home/pi/data`, you'll need to update the volume mount source for the `/home/pi/air-trend/config.json` file and the `/home/pi/data` directory.

Devices are declared using `config.json` using keys that map to arguments passed to [SerialDevice](./devices/main.py). For example configuration blocks, refer to [`examples/`](./examples/).

> You can use [`systemd`](https://systemd.io) to manage daemons if you're more comfortable with `systemd` than docker. `systemd` configuration is out of scope for this documentation but you can reference [`devices/Dockerfile`](devices/Dockerfile) for dependency installation steps and [`docker-compose.yml`](docker-compose.yml) for setting required environment variables.

### Basic logging

For devices which stream data continuously, you'll need to configure the device `name`, the `baudrate` and path to the serial `port`, a list of `variables` in the order they are returned by the device that define the `name` and whether to `save` each variable to the output file, and the `delimiter` that separates variables in the return string.

```json
[
  {
    "name": "metone_es642",
    "baudrate": 9600,
    "port": "/dev/serial/by-id/usb-UTEK_USB__-__Serial_Cable_FT0EG25Q-if01-port0",
    "delimiter": ",",
    "variables": [
      { "name": "pm25_mgm3", "save": true },
      { "name": "flow_lpm", "save": true },
      { "name": "t_c", "save": true },
      { "name": "rh_pct", "save": true },
      { "name": "pres_hpa", "save": true },
      { "name": "status", "save": true },
      { "name": "checksum", "save": true }
    ]
  }
]
```

> Responses that do not match the defined `variables` declaration are discarded.

See [data format](#data-format) for an example of how these data are written to flat files.

### Filtering responses

Some devices expect a command to be issued over the serial connection prior to returning data. The `poll_command` can be specified to prompt the device to return the defined variables on a periodic `poll_interval`.

The `poll_type` differentiates between the response structure. Using `line` indicates pre-formatted data returned as a single line with variables separated by a delimiter. Using `batch` along with `filter_response` can be used to parse more complex multi-line responses into a machine readable format. The `filter_response` REGEX is applied to each line of the returned response, although you can use another `eol_delimiter` to specify the breaks between the returned variables.

You can also set an `init_command` which is issued a single time when establishing a connection to the device. This can be used for devices which expect to receive configuration details on startup.

```json
[
  {
    "name": "gps",
    "baudrate": 4800,
    "delimiter": ",",
    "filter_response": "\\$GPGGA.*$",
    "port": "/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_D-if00-port0",
    "variables": [
      { "name": "nmea_class", "save": false },
      { "name": "timestamp", "save": true },
      { "name": "latitude_dm", "save": true },
      { "name": "latitude_ns", "save": true },
      { "name": "longitude_dm", "save": true },
      { "name": "longitude_ew", "save": true },
      { "name": "fix_quality", "save": true },
      { "name": "n_sat", "save": true },
      { "name": "horizontal_dilution", "save": false },
      { "name": "altitude_amsl", "save": true },
      { "name": "altitude_amsl_unit", "save": false },
      { "name": "geoidal_separation", "save": false },
      { "name": "time_last_update", "save": false },
      { "name": "time_last_update_unit", "save": false },
      { "name": "stid_and_checksum", "save": false }
    ]
  }
]
```

> Responses that do not match the defined `variables` after applying `filter_response` are discarded.

### Polling for responses

Some devices expect a command to be issued over the serial connection prior to returning data. The `poll_command` can be specified to prompt the device to return the defined variables on a periodic `poll_interval`.

The `poll_type` differentiates between the response structure. Using `line` indicates pre-formatted data returned as a single line with variables separated by a delimiter. Using `batch` along with `filter_response` can be used to parse more complex multi-line responses into a machine readable format.

You can also set an `init_command` which is issued a single time when establishing a connection to the device. This can be used for devices which expect to receive configuration details on startup.

```json
[
  {
    "name": "vaisala_wxt536",
    "baudrate": 19200,
    "port": "/dev/serial/by-id/usb-Silicon_Labs_Vaisala_USB_Instrument_Cable_N3710055-if00-port0",
    "eol_delimiter": "\r\n",
    "filter_response": "(?<==)-?[0-9.]+",
    "init_command": "0XU,C=2,I=0,M=P\r\n",
    "poll_command": "0R0\r\n",
    "poll_interval": 1,
    "poll_type": "line",
    "variables": [
      { "name": "wind_dir_deg", "save": true },
      { "name": "wind_spd_ms", "save": true },
      { "name": "t_c", "save": true },
      { "name": "rh_pct", "save": true },
      { "name": "p_hpa", "save": true },
      { "name": "rain_mm", "save": true },
      { "name": "heater_t_c", "save": true },
      { "name": "heater_v", "save": false }
    ]
  },
  {
    "name": "teledyne_t500u",
    "baudrate": 115200,
    "delimiter": "\n",
    "filter_response": "(?<==)[^\\s]+",
    "poll_command": "t list all\r\n",
    "poll_interval": 2,
    "poll_type": "batch",
    "port": "/dev/serial/by-id/usb-UTEK_USB__-__Serial_Cable_FT2QWEFA-if00-port0",
    "variables": [
      { "name": "range_ppb", "save": false },
      { "name": "range1_ppb", "save": false },
      { "name": "range2_ppb", "save": false },
      { "name": "phase_t_c", "save": true },
      { "name": "bench_phase_s", "save": true },
      { "name": "meas_l_mm", "save": true },
      { "name": "aref_l_mm", "save": true },
      { "name": "samp_pres_inhga", "save": true },
      { "name": "samp_temp_c", "save": true },
      { "name": "bench_t_c", "save": true },
      { "name": "box_t_c", "save": true },
      { "name": "no2_slope", "save": true },
      { "name": "no2_offset_mv", "save": true },
      { "name": "no2_ppb", "save": true },
      { "name": "bench_no2_s", "save": false },
      { "name": "no2_std_ppb", "save": true },
      { "name": "mf_t_c", "save": true },
      { "name": "ics_t_c", "save": false },
      { "name": "sig_mv", "save": false },
      { "name": "sin", "save": false },
      { "name": "sin_1", "save": false },
      { "name": "cos_1", "save": false },
      { "name": "sin_2", "save": false },
      { "name": "cos_2", "save": false },
      { "name": "sin_ovp", "save": false },
      { "name": "cos_ovp", "save": false },
      { "name": "accum", "save": false },
      { "name": "test_mv", "save": true },
      { "name": "xin1_v", "save": false },
      { "name": "xin2_v", "save": false },
      { "name": "xin3_v", "save": false },
      { "name": "xin4_v", "save": false },
      { "name": "xin5_v", "save": false },
      { "name": "xin6_v", "save": false },
      { "name": "xin7_v", "save": false },
      { "name": "xin8_v", "save": false },
      { "name": "time_of_day", "save": false }
    ]
  }
]
```

### Disabling devices

Each device can be enabled or disabled by setting the `is_active` configuration key.

If a device is disabled, it will be ignored until the next time the service is restarted.

```json
[
  {
    "name": "2b_205",
    "is_active": false,
    "baudrate": 4800,
    "delimiter": ",",
    "port": "/dev/serial/by-id/usb-UTEK_USB__-__Serial_Cable_FT2QWEFA-if02-port0",
    "variables": [
      { "name": "o3_ppb", "save": true },
      { "name": "t_c", "save": true },
      { "name": "p_hpa", "save": true },
      { "name": "flow_ccpm", "save": true },
      { "name": "inst_date", "save": false },
      { "name": "inst_time", "save": false }
    ]
  }
]
```

## Starting the service

To start the service, run

```bash
docker-compose up --build -d
```

> `up` starts the services defined in `docker-compose.yml`, `--build` indicates the containers should be rebuilt if necessary, and `-d` indicates the service should run in the background on startup.

You can verify the service is running with

```bash
docker-compose ps
```

### Stopping the service

To stop the service, run

```bash
docker-compose down
```

## Data format

Data is output to daily CSV files with a `time` column prepended to the list of `variables`. Time is stored in the ISO 8601 format in the UTC timezone.

For example, let's specify `config.json` using the first example.

```json
[
  {
    "name": "metone_es642",
    "baudrate": 9600,
    "port": "/dev/serial/by-id/usb-UTEK_USB__-__Serial_Cable_FT0EG25Q-if01-port0",
    "delimiter": ",",
    "variables": [
      { "name": "pm25_mgm3", "save": true },
      { "name": "flow_lpm", "save": true },
      { "name": "t_c", "save": true },
      { "name": "rh_pct", "save": true },
      { "name": "pres_hpa", "save": true },
      { "name": "status", "save": true },
      { "name": "checksum", "save": true }
    ]
  }
]
```

Using `/home/pi/data` for storage, this creates `/home/pi/data/metone_es642/YYYY-mm-dd.csv` files.

```bash
> head /home/pi/data/metone_es642/2020-12-01.csv
time,pm25_mgm3,flow_lpm,t_c,rh_pct,pres_hpa,status,checksum
2020-12-01T00:00:01.278086,000.015,2.0,+05.4,017,0857.8,00,*01552
2020-12-01T00:00:02.272085,000.015,2.0,+05.4,017,0857.6,00,*01550
2020-12-01T00:00:03.278219,000.015,2.0,+05.4,017,0858.0,00,*01545
2020-12-01T00:00:04.271922,000.015,2.0,+05.4,017,0857.5,00,*01549
2020-12-01T00:00:05.277756,000.014,2.0,+05.4,017,0857.5,00,*01548
2020-12-01T00:00:06.271161,000.015,2.0,+05.4,017,0857.8,00,*01552
2020-12-01T00:00:07.454191,000.015,2.0,+05.4,017,0857.9,00,*01553
2020-12-01T00:00:09.277855,000.015,2.0,+05.4,017,0857.7,00,*01551
2020-12-01T00:00:10.270850,000.015,2.0,+05.4,017,0857.7,00,*01551
```
