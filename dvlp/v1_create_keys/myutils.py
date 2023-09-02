# utils

import csv
from qgis.core import (
    QgsProject, QgsVectorLayer, QgsLayerTreeLayer, QgsFillSymbol, QgsCoordinateTransform
    #QgsSymbol, QgsRendererCategory, QgsStyle, QgsCategorizedSymbolRenderer
    )
from qgis.utils import iface
# check https://api.qgis.org/api/api_break.html for changes in api

# -------------------------------------------------------

# https://docs.qgis.org/3.22/en/docs/pyqgis_developer_cookbook/loadlayer.html
# The format is:  # vlayer = QgsVectorLayer(data_source, layer_name, provider_name)
def addlyr(lyrpath, lyrnam, position=None):
    vlayer = QgsVectorLayer(lyrpath, lyrnam, "ogr")
    if not vlayer.isValid():
        print("Layer failed to load!")
    else:
        if position==None:
            lyr = QgsProject.instance().addMapLayer(vlayer)
        else:
            lyr = QgsProject.instance().addMapLayer(vlayer, False)  # add the layer without showing it
            layerTree = iface.layerTreeCanvasBridge().rootGroup() # obtain the layer tree of the top-level group in the project
            layerTree.insertChildNode(position, QgsLayerTreeLayer(vlayer))  # the position is a number starting from 0, with -1 an alias for the end
    return(lyr)

def removelyr(lyr):
    QgsProject.instance().removeMapLayer(lyr.id())

def removealllyrs():
    QgsProject.instance().clear()
    # project.removeAllMapLayers() - seem not to work
    # QgsProject.instance().clear()  resets your project to a completely blank state.
    # Or iterate all layers in your project using a for loop and then remove them using QgsProject.instance().removeMapLayer()
    #p = QgsProject.instance()
    #root = p.layerTreeRoot()
    #for lyr in root.children():
    #    p.removeMapLayer(lyr.id())


def islyr(lyr):
    root = QgsProject.instance().layerTreeRoot()
    for layer in root.children():
        if (layer.name()==lyr.name()): ret = True
        else: ret = False
    return(ret)    

def islyrname(lyrname):
    lyr = QgsProject.instance().mapLayersByName(lyrname)[0]
    return(islyr(lyr))    

def setlayerposition(lyr, position=None):
    if position!=None:
        layerTree = iface.layerTreeCanvasBridge().rootGroup() # obtain the layer tree of the top-level group in the project
        layerTree.insertChildNode(position, QgsLayerTreeLayer(lyr))  # the position is a number starting from 0, with -1 an alias for the end
    return(lyr)    

def listoflayers():
    root = QgsProject.instance().layerTreeRoot()
    for layer in root.children():
        print(layer.name())

def numoflayers():
    #n = len(QgsProject.instance().mapLayers())
    root = QgsProject.instance().layerTreeRoot()
    n = len(root.children())
    #print(n)
    return(n)
    #project = QgsProject.instance()
    #layers = project.mapLayers()
    #print(layers)
    #print(len(layers))
    #print(len(project.mapLayers()))

# -------------------------------------------------------

def zoom2lyr(layer):   # https://gis.stackexchange.com/questions/301904/zooming-to-specific-loaded-layer-using-pyqgis
    ex    = layer.extent()

    # Add a small space/border on each side of the layer
    hborder = ex.height() / 100
    wborder = ex.width() / 100
    ex.set(ex.xMinimum() - wborder, 
        ex.yMinimum() - hborder, 
        ex.xMaximum() + wborder, 
        ex.yMaximum() + hborder  )

    # Find out if we need to transform coordinates
    proj = QgsProject.instance()
    if layer.crs().authid() != proj.crs().authid():
        print("Layer has not the same CRS as proj", 
            layer.crs().authid(), 
            proj.crs().authid()  )
        tr = QgsCoordinateTransform(layer.crs(), proj.crs(), proj)
        ex = tr.transform(ex)  

    iface.mapCanvas().setExtent(ex)
    iface.mapCanvas().refresh()

# -------------------------------------------------------

def setlayernofill0(layer):
    mySymbol1 = QgsFillSymbol.createSimple({'color':'#000000',
                                            'color_border':'#000000',
                                            'width_border':'1.2',
                                            'style':'no'})
    myRenderer = layer.renderer()
    myRenderer.setSymbol(mySymbol1)
    layer.triggerRepaint()

def setlayernofill(layer):
    mySymbol1 = QgsFillSymbol.createSimple({'color':'#d7191c',
                                            'color_border':'#d7191c',
                                            'width_border':'0.4',
                                            'style':'no'})
    myRenderer = layer.renderer()
    myRenderer.setSymbol(mySymbol1)
    layer.triggerRepaint()

# -------------------------------------------------------

def saveas_image():
    from qgis.utils import iface 
    import datetime 
    c = iface.mapCanvas() 
    t = '{:%Y%m%d%H%M%S}'.format(datetime.datetime.now()) 
    img_path = '<output directory>/map{}.png' 
    c.saveAsImage(img_path.format(t), None, 'PNG') 


# -------------------------------------------------------

# header, rows = getcsvdata(fil)
def getcsvdata(fil):
    file = open(fil)
    csvreader = csv.reader(file)
    header = next(csvreader)
    #print(header)
    rows = []
    for row in csvreader:
        rows.append(row)
    #print(rows)
    file.close()
    return(header, rows)

"""
syspath in QGIS
from console.console import _console
script_path = _console.console.tabEditorWidget.currentWidget().path
print(os.path.dirname(script_path))


print(os.path.dirname(os.path.abspath("__file__")))
print("1", os.getcwd())
print("2", sys.argv[0])
print("2a", sys.argv)
print("3", os.path.dirname(os.path.realpath('__file__')))

basedr = os.path.abspath("__file__")
print(basedr)
"""


# = End =================================================
