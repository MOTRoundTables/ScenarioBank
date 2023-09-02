# dialog.py

from PyQt5.QtCore import (Qt, QRect
    )
# QUrl, QObject, QPropertyAnimation, QPoint, QEasingCurve, QAbstractAnimation, QTime, QTimer, QRegExp, QRectF

from PyQt5.QtWidgets import (QWidget, QPushButton, QMessageBox, QDialog, QDialogButtonBox, QVBoxLayout, QLineEdit,
    QCheckBox, QComboBox, QDateEdit, QDateTimeEdit, QDial, QDoubleSpinBox, QLabel, QInputDialog
    )
#QAction, QAbstractItemView,  QFrame, QHBoxLayout, QLabel, QMenu, QSlider, QTableWidget, QTableWidgetItem,  QApplication

#from PyQt5.QtGui import QBrush, QColor, QCursor, QPixmap, QFont, QPainter, QPen, QLinearGradient
#, QFont

import imp, procedures
imp.reload(procedures)
from procedures import *
import imp, analisys
imp.reload(analisys)
from analisys import *

QString = str
QStringLiteral = QString

# -------------------------------------------------------
#https://docs.qgis.org/3.22/en/docs/pyqgis_developer_cookbook/communicating.html?highlight=communicating%20user

def getyn(txt=None):
    mb = QMessageBox()
    # print(type(mb))
    # print(dir(mb))

    if txt != None:
        mb.setText(txt)
    else:    
        mb.setText('Click OK to confirm')
    mb.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
    return_value = mb.exec()
    if return_value == QMessageBox.Ok:
        ret = True
        #print('You pressed OK')
    elif return_value == QMessageBox.Cancel:
        ret = False
        #print('You pressed Cancel')
    return(ret)

# https://www.tutorialspoint.com/pyqt/pyqt_qmessagebox.htm
def displaymsg(txt, txt2=None):
    mb = QMessageBox()
    mb.setWindowTitle("message")
    mb.setText(txt)
    mb.setStandardButtons(QMessageBox.Ok)

    mb.setIcon(QMessageBox.Information)
    if txt2 != None:
        mb.setInformativeText(txt2)

    return_value = mb.exec()
    return(return_value)


#get textDialog 
def gettext(atitle, aprompt=None, txt2=None):
    qid1 = QInputDialog()
    title = atitle #"Write the URL"
    label = aprompt
    mode = QLineEdit.Normal
    default = txt2 # "write here"
    snapUrl, ok = QInputDialog.getText(qid1, title, label,mode, default)
    return(snapUrl)

# -------------------------------------------------------------------

class test(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("clase de prueba")
        layout = QVBoxLayout()
        widgets = [QCheckBox,
            QComboBox,
            QDateEdit,
            QDateTimeEdit,
            QDial,
            QDoubleSpinBox]
        for w in widgets:
            layout.addWidget(w())
        self.setLayout(layout)
        self.setFocus()

#h = test()
#h.show()

# -------------------------------------------------------------------

class mainwindow(QWidget):
    def __init__(self, cfg):
        #print(cfg)
        self.cfg = cfg
        super().__init__()
        #w = QWidget()
        self.resize(375, 612)

        self.p1 = scb_procedures(self.cfg)  # activate procedures
        self.setWindowTitle("Scenarios Bank")

        # ---------------------------------------------------------
        label = QLabel(self)
        label.setObjectName(QStringLiteral("label"))
        label.setGeometry(QRect(40, 30, 68, 19))
        label.setText("Scenario:")
        self.comboBox = QComboBox(self)      # count, currentData, currentIndex, currentText, 
        self.comboBox.setObjectName(QStringLiteral("comboBox"))
        self.comboBox.setGeometry(QRect(130, 30, 171, 25))
        for x in self.cfg['scnlist']:
            self.comboBox.addItem(x);
        self.comboBox.setCurrentIndex(-1)
        self.comboBox.currentIndexChanged.connect(self.Scenario_changed)

        #font = QFont
        #font.setBold(True)
        #font.setWeight(75)
        
        label_2 = QLabel(self)
        label_2.setObjectName(QStringLiteral("label_2"))
        label_2.setGeometry(QRect(17, 80, 91, 20))
        #label_2.setFont(font)
        #label_2.setFrameShadow(QFrame.Plain)
        label_2.setText("Super zone:")
        self.comboBox_2 = QComboBox(self)
        self.comboBox_2.setObjectName(QStringLiteral("comboBox_2"))
        self.comboBox_2.setGeometry(QRect(130, 80, 171, 25))
        for x in self.cfg['szlist']:
            self.comboBox_2.addItem(x);
        #self.comboBox.setCurrentIndex(-1)
        self.comboBox.currentIndexChanged.connect(self.SZ_changed)

        # ---------------------------------------------------------
        verticalLayoutWidget = QWidget(self)
        verticalLayoutWidget.setObjectName(QStringLiteral("verticalLayoutWidget"))
        verticalLayoutWidget.setGeometry(QRect(40, 120, 281, 161))

        verticalLayout = QVBoxLayout(verticalLayoutWidget)
        verticalLayout.setObjectName(QStringLiteral("verticalLayout"))
        verticalLayout.setContentsMargins(0, 0, 0, 0)

        pushButton = QPushButton(verticalLayoutWidget)
        pushButton.setObjectName(QStringLiteral("pushButton"))
        pushButton.setText("Create empty key")
        pushButton.clicked.connect(self.b1)
        verticalLayout.addWidget(pushButton)

        pushButton_2 = QPushButton(verticalLayoutWidget)
        pushButton_2.setObjectName(QStringLiteral("pushButton_2"))
        pushButton_2.setText("Load and edit key")
        pushButton_2.clicked.connect(self.b2)
        verticalLayout.addWidget(pushButton_2)

        pushButton_3 = QPushButton(verticalLayoutWidget)
        pushButton_3.setObjectName(QStringLiteral("pushButton_3"))
        pushButton_3.setText("save key")
        pushButton_3.clicked.connect(self.b3)
        verticalLayout.addWidget(pushButton_3)

        pushButton_4 = QPushButton(verticalLayoutWidget)
        pushButton_4.setObjectName(QStringLiteral("pushButton_4"))
        pushButton_4.setText("make aggregate")
        pushButton_4.clicked.connect(self.b4)
        verticalLayout.addWidget(pushButton_4)

        # ---------------------------------------------------------

        b = QPushButton(self)
        b.setText("reset")
        b.move(50,560)
        b.clicked.connect(self.reset)

        b = QPushButton(self)
        b.setText("test")
        b.move(150,560)
        b.clicked.connect(self.qtest)

        b = QPushButton(self)
        b.setText("Cancel")
        b.move(250,560)
        b.clicked.connect(self.exitdialog)

        # ---------------------------------------------------------
        """
        buttonBox = QDialogButtonBox(self)
        buttonBox.setObjectName(QStringLiteral("buttonBox"))
        buttonBox.setGeometry(QRect(10, 540, 341, 32))
        buttonBox.setOrientation(Qt.Horizontal)
        buttonBox.setStandardButtons(QDialogButtonBox.Cancel|QDialogButtonBox.Ok)  """

        self.initmap()
        self.setFocus()
        #self.closeEvent(closeEvent)
    # ---------------------------------------------------------

    def initmap(self):  # initialize mapo
        i = self.cfg['general']['initialsz']
        self.comboBox_2.setCurrentIndex(i)
        dlg = dict()
        dlg["sznum"] = i
        dlg["szkey"] = self.cfg['szkeys'][i]
        self.p1.setSZ(dlg)

    def setdlg(self):  # create key
        #print(self.comboBox.currentIndex(),self.comboBox.currentText())
        #print(self.comboBox_2.currentIndex(), self.comboBox_2.currentText())
        #print("hahaha")
        dlg = dict()
        i = self.comboBox.currentIndex()
        if i>=0:
            dlg["scnum"] = i
            dlg["sckey"] = self.cfg['scnkeys'][i]
        i = self.comboBox_2.currentIndex()
        if i>=0:
            dlg["sznum"] = i
            dlg["szkey"] = self.cfg['szkeys'][i]
        return(dlg)

    def Scenario_changed(self):
        if (self.comboBox.currentIndex()>=0) and (self.comboBox_2.currentIndex()>=0): 
            self.p1.setScn(self.setdlg())

    def SZ_changed(self):
        self.p1.setSZ(self.setdlg())

    def b1(self):  # create key
        self.p1.do1(self.setdlg()) 

    def b2(self):  # load key
        self.p1.do2(self.setdlg()) 

    def b3(self):  # save key
        self.p1.do3(self.setdlg()) 

    def b4(self):  # aggregate
        self.p1.do4(self.setdlg()) 

    # -------------------------------------------

    def reset(self):
        self.p1.clear()
        openbaseprj(self.cfg['dvlpdr'], self.cfg['baseprj'])
        self.comboBox.setCurrentIndex(-1)

    def qtest(self):
        self.p1.combine()
        print("testing")
        displaymsg('test done')

    def exitdialog(self):
        print("leaving")
        super().close()
        # QPushButton *closeButton = new QPushButton(tr("Close"));
        # connect(closeButton, SIGNAL(clicked()), this, SLOT(close()));

#h1 = mainwindow()
#h1.show()

# = End ========================================

"""
def showdialog():
   msg = QMessageBox()
   msg.setIcon(QMessageBox.Information)

   msg.setText("This is a message box")
   msg.setInformativeText("This is additional information")
   msg.setWindowTitle("MessageBox demo")
   msg.setDetailedText("The details are as follows:")
   msg.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
   msg.buttonClicked.connect(msgbtn)
	
   retval = msg.exec_()
   print("value of pressed message box button:", retval)
	
def msgbtn(i):
   print("Button pressed is:",i.text())

def closeEvent(self, event):
    print("ay")
    if maybeSave():
        writeSettings()
        event.accept()
    else:
        event.ignore()

"""
