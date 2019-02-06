import sys
import os
from IPython import embed
from load_intan_rhs_format import read_data
sys.path.append('C:\Users\Senan\Downloads\load_intan_rhs_format')
sys.path.append(
    '\\\\Phsvcefbdl1isimgt.partners.org\MGH-NEURO-CASHLAB\Projects\ADELPHI_Senan\Stim Data\Stim Data 190119\Data')

os.chdir('\\\\Phsvcefbdl1isimgt.partners.org\MGH-NEURO-CASHLAB\Projects\ADELPHI_Senan\Stim Data\Stim Data 190119\Data')
dat = read_data('fKS01_190118_190118_190202.rhs')
embed()
