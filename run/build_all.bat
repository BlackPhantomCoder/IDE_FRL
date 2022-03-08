@ECHO OFF
set "qtdir=%1"
set "wdqt=%qtdir%\windeployqt.exe"
if ""=="%wdqt%" (
	echo input error 
	exit 0
)
start %wdqt% IDE_FRL_release.exe
start %wdqt% fw/ForisWrapperQt_release.exe

copy %qtdir%\Qt5PrintSupport.dll .
copy %qtdir%\Qt5PrintSupport.dll fw