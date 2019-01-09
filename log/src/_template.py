#!/usr/bin/env python
# Ben Fasoli

from SerialInstrument import SerialInstrument

DEVICE = '/dev/serial/by-id/UNIQUE_ID_STRING'
BAUDRATE = 9600
PATH = '/home/uataq/air-trend/log/data/metone-es642/'

ser = SerialInstrument(DEVICE, BAUDRATE, PATH)

while True:
    ser.read_record()
    ser.save_record()
