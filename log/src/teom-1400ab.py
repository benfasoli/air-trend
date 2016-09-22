#!/usr/bin/python
# Ben Fasoli

import datetime
import os
import serial as ser
import string
from time import sleep

def saveLine(tobj, line, loc, name):
    fname = loc + tobj.strftime(name)
    with (open(fname, 'a+')) as f:
        f.write(line)

class serialDevice:
    def __init__(self, device, baud=9600, loc='~/', name='%Y_%m_%d_data.dat'):
        self.allowed = set(string.printable)
        self.loc     = loc
        self.name    = name
        self.s       = ser.Serial(device, baud)
    def read(self):
        line = self.s.readline()
      	tc   = datetime.datetime.utcnow()
      	line = line.replace('\r', '').replace('\n', '')
      	line = filter(lambda x: x in self.allowed, line)
        line = line.replace('=', ' ').split(' ')
        save = ','.join([str(tc)] + [line[x] for x in [6, 10, 14]]) + '\n'
      	saveLine(tc, save, self.loc, self.name)
      	print(save)
    def end(self):
        print('\n\nStopping data collection...\n\n')
        self.s.flush()
        self.s.close()

if __name__ == '__main__':
    device = '/dev/serial/by-id/usb-UTEK_USB__-__Serial_Cable_FT0EG25Q-if01-port0'
    baud   = 9600
    loc    = '/home/uataq/air-trend/log/data/teom-1400ab/'
    name   = '%Y_%m_%d.dat'
    dev = serialDevice(device, baud, loc, name)
    while True:
        try:
            dev.read()
        except (KeyboardInterrupt, SystemExit):
            raise
    dev.end()
