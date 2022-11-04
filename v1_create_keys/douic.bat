rem pyuic4 input.ui -o output.py

set d=C:\Users\marsz\OneDrive\job\16\Models\Workgroups\Forecasts\System\dvlp\
set f=uitest

set uic="C:\Program Files (x86)\Qt Designer\uic.exe"
rem %uic% %f% -g python -o uitest.py

cd "C:\Program Files (x86)\Qt Designer\"

uic %d%%f%.ui -o %d%%f%.py --generator python


pause
uic -help