import os
import sys
import csv
#from os.path import exists as file_exists

from dialog import *
import myutils
imp.reload(myutils)
from myutils import *

from qgis.core import (
    QgsProject, QgsVectorLayer,
    QgsSymbol, QgsRendererCategory, QgsStyle, QgsCategorizedSymbolRenderer
    )
from qgis import processing
from qgis.utils import iface


"""from qgis.core import QgsProcessing
from qgis.core import QgsProcessingAlgorithm
from qgis.core import QgsProcessingMultiStepFeedback
from qgis.core import QgsProcessingParameterVectorLayer
from qgis.core import QgsProcessingParameterFeatureSink """

# ---------------------------------------------------------

def openbaseprj(basedr, baseprj):
    project = QgsProject.instance()
    project.clear()   # closes all layers
    project.read(basedr + baseprj)
    # print(project.fileName())

# ---------------------------------------------------------

class scb_procedures:
    def __init__(self, cfg):
        self.cfg = cfg
        self.clear()

    # ---------------------------------------------------------------------------------

    def clear(self):   # reset values
        self.qtazlyr = None
        self.qszlyr = None
        self.joinf = None

    def setdlg(self, dlg):
        self.setscndlg(dlg)
        self.setszdlg(dlg)
        self.keyfilename = self.scndir + "key_" + self.scnkey + "_" + self.szkey + '.csv'

    def setscndlg(self, dlg):
        self.scnkey = dlg["sckey"]
        self.scn = self.cfg["scenarios"][self.scnkey]
        self.scndir = self.cfg["general"]["scndir"] + self.scn["dir"] + "\\"
        self.tazlyr = self.scn["tazlyr"]
        self.tazvar = self.scn["tazvar"] # 'TAZV41'

    def setszdlg(self, dlg):
        self.szkey = dlg["szkey"]
        self.sz = self.cfg["superzones"][dlg["szkey"]]
        self.szlyr = self.sz["lyr"]
        self.szvar = self.sz["zvar"]
        self.szname =  self.sz["zname"]  

    #def geykeyfilename(self):
    #    f = self.cfg["general"]["scndir"] + self.scnkey + "\\" + self.scnkey + "_" + self.szkey + '.csv'
    #    reutn(f)

    def setScn(self, dlg):   # load & set scn
        if self.qtazlyr!=None:
            removelyr(self.qtazlyr)
        self.setdlg(dlg)
        lyrpath = self.scndir + self.scn["tazfile"]
        self.qtazlyr = addlyr(lyrpath, self.tazlyr, 1)
        setlayernofill(self.qtazlyr)
        zoom2lyr(self.qtazlyr)

    def setSZ(self, dlg):   # load sz lyr
        if self.qszlyr!=None:
            removelyr(self.qszlyr)
        self.setszdlg(dlg)
        lyrpath = self.cfg["general"]["geodir"] + self.sz["file"]
        #lyrpath = self.geodir + self.sz["file"]
        self.qszlyr = addlyr(lyrpath, self.szlyr, 0)
        setlayernofill0(self.qszlyr)

    # ---------------------------------------------------------------------------------

    def do1(self, dlg):   # create a key 1st time
        self.setdlg(dlg)
        if os.path.exists(self.keyfilename):
            ret = getyn("the key file exists - press yes to overwrite or cancel")
            if not(ret):
                displaymsg("pressed cancel")
                return()
        joinf = self.makeszjoin()
        self.savekey(joinf)
        QgsProject.instance().removeMapLayer(joinf.id())
        iface.mapCanvas().refresh()  
        #print('done')
        #joinf = QgsProject.instance().mapLayersByName("Joined layer")[0]
        displaymsg('key created - please load')

    def do2(self, dlg):       # load saved key
        self.setdlg(dlg)
        self.joinf = self.makekeyjoin()
        self.makemap(self.joinf)
        #print('done')

    def do3(self, dlg):         # save key
        self.setdlg(dlg)
        self.savekey(self.joinf)
        displaymsg('key saved')

    def do4(self, dlg):         # aggre
        self.setdlg(dlg)
        self.makeAg()
        displaymsg('aggregated saved')

    # ---------------------------------------------------------------------------------

    def makekeyjoin(self):
        #print('makekeyjoin', 'hi', self.tazlyr)
        inp2 = "delimitedtext://file:///" + self.keyfilename + "?encoding=hebrew&type=csv&maxFields=10000&detectTypes=yes&geomType=none&subsetIndex=no&watchFile=no"

        params = {
            'DISCARD_NONMATCHING' : False, 
            'INPUT' : self.tazlyr,  # 'C:/Users/marsz/OneDrive/job/16/Models/Workgroups/Forecasts/System/Scn_lib/TA2016/TAZ_v41.Geojson', 
            'FIELD' : self.tazvar, 
            'INPUT_2' : inp2, 
            'FIELD_2' : self.tazvar, 
            'FIELDS_TO_COPY' : [], 
            'METHOD' : 1, 
            'OUTPUT' : 'TEMPORARY_OUTPUT', 
            'PREFIX' : '' }

        result = processing.run('native:joinattributestable', params)   #  , context=context, feedback=feedback, is_child_algorithm=True
        print(result)
        outputlayer = result['OUTPUT']
        layer = QgsProject.instance().addMapLayer(outputlayer, False)
        setlayerposition(layer, 1)

        return layer
        # https://www.qgistutorials.com/en/docs/3/processing_algorithms_pyqgis.html

    # create spacial join ----------------------------------------
    def makeszjoin(self):
        #print('makejoin', 'hi', self.tazlyr)
        # https://docs.qgis.org/3.22/en/docs/user_manual/processing_algs/qgis/vectorgeneral.html?highlight=join%20attributes%20location#join-attributes-by-location
        params = {
            'INPUT' : self.tazlyr,
            'JOIN' : self.szlyr,
            'JOIN_FIELDS' : [self.szvar, self.szname ], 
            'METHOD' : 2, 
            'PREDICATE' : [0], 
            'DISCARD_NONMATCHING' : False, 
            'OUTPUT' : 'TEMPORARY_OUTPUT', 
            'PREFIX' : '' }

        """  # this did not work:
        # allow Invalid features filtering  https://coder-question.com/cq-blog/585075
        from processing.tools import dataobjects
        from qgis.core import QgsFeatureRequest
        context = dataobjects.createContext()
        context.setInvalidGeometryCheck(QgsFeatureRequest.GeometryNoCheck)
        # InvalidGeometryCheck { GeometryNoCheck = 0 , GeometrySkipInvalid = 1 , GeometryAbortOnInvalid = 2 }
        """

        result = processing.run('native:joinattributesbylocation', params)
      
        #result = {'JOINED_COUNT': 1310, 'OUTPUT': <QgsVectorLayer: 'Joined layer' (memory)>}
        outputlayer = result['OUTPUT']
        layer = QgsProject.instance().addMapLayer(outputlayer)
        return(layer)

    # print key  -------------------------------------
    def savekey(self, layer):
        n = layer.featureCount() 
        kdata = [None]*n
        szvar = self.szvar
        features = layer.getFeatures()
        i = 0
        for feature in features:
            x = feature[szvar]
            if x==None: x = 0
            kdata[i] = [feature[self.tazvar], x] 
            i = i + 1

        # https://www.pythontutorial.net/python-basics/python-write-csv-file/
        kheader = [self.tazvar, self.szvar]
        filename = self.keyfilename 
        f = open(filename, 'w', newline='')
        writer = csv.writer(f)
        writer.writerow(kheader)
        writer.writerows(kdata)
        f.close()

    def readkey(self):
        self.keydict = {}
        with open(self.keyfilename, newline='') as csvfile:
            reader = csv.reader(csvfile)  # csv.reader(csvfile, delimiter=',', quotechar='"')
            self.keydict = {rows[0]:rows[1] for rows in reader}                    
            #for row in reader:
                #print(', '.join(row))
                #print(row)
        #print(self.keydict)
        #print("done")                

    def makemap(self, layer):
        fni = layer.fields().indexFromName(self.szvar)
        unique_values = layer.uniqueValues(fni)

        categories = []
        for value in unique_values:
            symbol = QgsSymbol.defaultSymbol(layer.geometryType())
            category = QgsRendererCategory(value, symbol, str(value))
            categories.append(category)
            
        myStyle = QgsStyle().defaultStyle()
        ramp = myStyle.colorRamp('Spectral') # pass any color ramp name e.g. 'Spectral'
            
        renderer = QgsCategorizedSymbolRenderer(self.szvar, categories)
        renderer.updateColorRamp(ramp)
        layer.setRenderer(renderer)
        layer.triggerRepaint()

    def makeAg(self):
        self.readkey()  # -> self.keydict

        fls = self.scn["files"]
        nscn = len(fls)
       
        filename = self.scndir + "ag_" + self.scnkey + "_" + self.szkey + '.csv' 
        f = open(filename, 'w', newline='')
        writer = csv.writer(f)
        kheader = self.scn["agvars"].copy()
        kheader.insert(0, "year")
        kheader.insert(1, "code")
        kheader.insert(2, self.szvar)
        writer.writerow(kheader)

        for i in range(0, nscn):
            scn = fls[i]
            code = scn[1]   #codes[i]
            y    = str(scn[0])   # years[i]

            file1 = self.scndir + scn[2]
            vrs   = scn[3]

            header, rows = getcsvdata(file1)  # read the yearly file
            #print(header)

            vrspos = [None]*len(vrs)
            for j in range(0, len(vrs)):  # find agvars location
                if vrs[j] in header:
                    pos = header.index(vrs[j])
                    vrspos[j] = pos
                else: vrspos[j] = 0
                #print(vrs[j], vrspos[j])
            vls = [None]*len(vrs)

            agvals = dict()
            for j in range(0, len(rows)):
                zn = rows[j][vrspos[0]]
                agzn = self.keydict[zn]
                vls[0] = y
                for k in range(1, len(vrs)): # make vals array with year first
                    if vrspos[k]>0:
                        vls[k] = float(rows[j][vrspos[k]])  # make it int() or float()
                        #vls[k] = int(rows[j][vrspos[k]])  # make it int() or float()
                    else: vls[k] = 0    # var not in file
                if agzn in agvals.keys():
                    for k in range(1, len(vrs)):
                        agvals[agzn][k] = agvals[agzn][k] + vls[k]
                else: agvals[agzn] = vls.copy()  # new entry

            # write result
            vls = [None]*(len(vrs)+2)
            agzns = agvals.keys()
            rows = [None]*len(agzns)
            i = 0
            for agzn in agzns:
                vls1 = agvals[agzn]
                vls[0] = vls1[0]
                vls[1] = code
                vls[2] = agzn
                for k in range (1, len(vrs)):
                    vls[k+2] = vls1[k]
                rows[i] = vls.copy()
                i = i + 1
            writer.writerows(rows)

        f.close()

    # ----------------------------------------------------------------------

    def combine(self):
        scn = self.cfg["scenarios"]

        sz = 0
        dlg = dict()
        dlg["szkey"] = self.cfg['szkeys'][sz]

        self.szkey = dlg["szkey"]
        self.sz = self.cfg["superzones"][dlg["szkey"]]
        self.szvar = self.sz["var"]   
        #self.szname =  self.sz["zname"]  
        #self.szlyr = self.sz["lyr"]

        filename = self.cfg['general']['rsltdir'] + "ag_" + self.szkey + '.csv' 
        f = open(filename, 'w', newline='')
        writer = csv.writer(f)
        agvars = [ "population", "employment" ]
        kheader = agvars.copy()
        kheader.insert(0, "set")
        kheader.insert(1, "code")
        kheader.insert(2, "year")
        kheader.insert(3, self.szvar)
        writer.writerow(kheader)

        i = 0
        for sc in scn:
            dlg["sckey"] = self.cfg['scnkeys'][i]
            self.setdlg(dlg)
            print(i, self.scnkey, self.szkey)

            filename2 = self.scndir + "ag_" + self.scnkey + "_" + self.szkey + '.csv' 
            header, rows = getcsvdata(filename2)
            for row in rows:
                row.insert(0, self.scnkey)
            writer.writerows(rows)
            i = i + 1

        f.close()
        print("done")

# -------------------------------------------------------------

#print('start')
#joinf = makejoin()
#makekey(joinf)

#joinf = QgsProject.instance().mapLayersByName("Joined layer")[0]
#makemap(joinf)

#print('done')


# = end ======================================


        #self.addParameter(QgsProcessingParameterFeatureSink('Output_layer', 'output_layer', optional=True, type=QgsProcessing.TypeVectorAnyGeometry, createByDefault=True, defaultValue=None))
        #outputs['Join_attributes_by_field_value'] = processing.run('native:joinattributestable', alg_params, context=context, feedback=feedback, is_child_algorithm=True)
        #results['Output_layer'] = outputs['Join_attributes_by_field_value']['OUTPUT']
        #'delimitedtext://file:///C:/Users/marsz/OneDrive/job/16/Models/Workgroups/Forecasts/System/Scn_lib/TA2016/TA2016_napot.csv?encoding=hebrew&type=csv&maxFields=10000&detectTypes=yes&geomType=none&subsetIndex=no&watchFile=no'

"""

        commonvars = False
        if "agvars" in self.scn.keys():  # all files have a common var names
            vrs  = self.scn["agvars"]
            commonvars = True


# open the key file
csvtable = QgsVectorLayer(self.keyfilename, 'tazkeyfile', 'delimitedtext')
iface.addVectorLayer('tazkeyfile', "key", "ogr")
#QgsProject.instance().addMapLayer(csvtable)
return()

# join_attributes_by_field_value
params = {
'INPUT': self.tazlyr,
'FIELD': self.tazvar, #'join_field_layer_1',
'INPUT_2': csvtable,
'FIELD_2': self.tazvar, #'join_field_layer_2',
'DISCARD_NONMATCHING': False,
'FIELDS_TO_COPY': self.szvar,
'METHOD': 1,
'PREFIX': 'ky',
'OUTPUT': 'TEMPORARY_OUTPUT',  # parameters['Output_layer']
}
"""


"""
{'INPUT':'C:/Users/marsz/OneDrive/job/16/Models/Workgroups/Forecasts/System/Scn_lib/TA2016/TAZ_v41.Geojson',
'FIELD':'TAZV41',
'INPUT_2':'delimitedtext://file:///C:/Users/marsz/OneDrive/job/16/Models/Workgroups/Forecasts/System/Scn_lib/TA2016/TA2016_napot.csv?encoding=hebrew&type=csv&maxFields=10000&detectTypes=yes&geomType=none&subsetIndex=no&watchFile=no',
'FIELD_2':'TAZV41',
'FIELDS_TO_COPY':[],
'METHOD':1,
'DISCARD_NONMATCHING':False,
'PREFIX':'x',
'OUTPUT':'TEMPORARY_OUTPUT'}

"""
