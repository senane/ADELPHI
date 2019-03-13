import numpy as np
import pandas as pd
#import pyintan
import sys
import os
from IPython import embed
from load_intan_rhs_format import read_data
import struct

sys.path.append('C:\\Users\Senan\Codebase')
sys.path.append('C:\\Users\Senan\StimData')

os.chdir('C:\\Users\Senan\StimData')

# Disable
def blockPrint():
    sys.stdout = open(os.devnull, 'w')

# Restore
def enablePrint():
    sys.stdout = sys.__stdout__

count = 0
files = os.listdir('E:\Stim Data')

for file in files:
    if file.endswith(".rhs"):
        strfile = 'file number ' + str(count) + ' of ' + str(len(files)) + ' named ' + file
        print(strfile + ' loading' + '\n')
        blockPrint()
        enablePrint()
        dat = read_data(file);
        # dat = pyintan.core.read_rhs(file);

        ampdat = dat['amplifier_data']

        chans = ampdat.shape[0]

        for i in range ()

          embed()
        # np.save(os.path.splitext(os.path.basename(file))[0] + '.npy', dat)
        count+=1
        print(strfile + ' done' + '\n')

#we want to save .rhs data as a .bin file with
# metadata = 3 int32 (32 bit int): Fs, nchannels_analog, nchannels_digital
# datastream = 17, first time, then ch1-16 as double