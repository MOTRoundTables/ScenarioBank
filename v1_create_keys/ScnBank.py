# C:\Users\marsz\OneDrive\job\16\Models\Workgroups\Forecasts\System\dvlp\ScnBank.py
import os
import sys
import json
from qgis.core import QgsProject

# find the script location if open in console - not good ...
""" from console.console import _console
script_path = _console.console.tabEditorWidget.currentWidget().path
basedr = os.path.dirname(script_path) + "/"
"""

basedr = "C://Users/marsz/Documents/GitHub/ScenarioBank/"
dvlpdr = basedr + "v1_create_keys/" 
jsondr = basedr + "v1/"

#print(basedr)

# load modules
sys.path.append(dvlpdr)  # source code
import imp
import dialog
imp.reload(dialog)
from dialog import *
import myutils
imp.reload(myutils)
from myutils import *
#import procedures
#imp.reload(procedures)
#from procedures import *

# --------------------------------------------------------------

# load cfg
cfgfile  = "scbank.json" 
with open(jsondr+cfgfile, 'r') as f:
  cfg = json.load(f)

#cfg['basedr'] = basedr
cfg['dvlpdr'] = dvlpdr

cfg['general']['sysdir'] = basedr  # overwrite sysdir to local computer
#print(cfg['general']['sysdir'])
txt = cfg['general']['geodir']
cfg['general']['geodir'] = txt.replace("<sysdir>", cfg['general']['sysdir'])

txt = cfg['general']['scndir']
cfg['general']['scndir'] = txt.replace("<sysdir>", cfg['general']['sysdir'])

txt = cfg['general']['rsltdir']
cfg['general']['rsltdir'] = txt.replace("<sysdir>", cfg['general']['sysdir'])

cfg['scnkeys'] = list(cfg['scenarios'])    
n = len(cfg['scnkeys'])

cfg['scnlist'] = [None]*n
for i in range(0, n):
    ky = cfg['scnkeys'][i]
    cfg['scnlist'][i] = cfg['scenarios'][ky]['name']

cfg['szkeys'] = list(cfg['superzones'])    
n = len(cfg['szkeys'])

cfg['szlist'] = [None]*n
for i in range(0, n):
    ky = cfg['szkeys'][i]
    cfg['superzones'][ky]['name'] = cfg['superzones'][ky]['hname'] # set a name
    cfg['szlist'][i] = cfg['superzones'][ky]['name']

#print(cfg)

baseprj = "basemap.qgz"
cfg['baseprj'] = baseprj
# --------------------------------------------------------------

openbaseprj(dvlpdr, baseprj)

h1 = mainwindow(cfg)
h1.show()

# = End ============================================

#getyn("getit makito")
#displaymsg("hi makito kito", "kito kito")

#h = test()
#h.show()


""" import from url
import json
weather = urllib2.urlopen('url')
wjson = weather.read()
wjdata = json.loads(wjson)
print wjdata['data']['current_condition'][0]['temp_C']
"""

"""
cfg['scnkeys'] = list()
for ky in cfg['scenarios'].keys():
    cfg['scnkeys'].append(ky)

    cfg['szkeys'] = list()
for ky in cfg['superzones'].keys():
    cfg['szkeys'].append(ky) 


"""