@echo off
SET confirmhome=
SET apppath=
SET restart=
SET curdir=%CD%
set /p appname="Enter app name: "
cd C:/Bitnami
for /f "tokens=2" %%i in ('robocopy .  . /L /S /LEV:3 ^| findstr apache2') do cd %%i..\apps 
set homedir=%CD%

set /p apppath="Enter app path [%homedir%\%appname%\htdocs\]: "
IF "%apppath%"=="" (SET apppath=%homedir%\%appname%\htdocs\)

set /p confirmhome="Is '%homedir%' the correct Bitnami home for %appname% ? [N] "

IF "%confirmhome%"=="" (SET confirmhome=N)
IF "%confirmhome%"=="N" (
exit /b 1
)


echo Creating directory %appname%
mkdir %appname%
cd %appname%
echo Creating directory %appname%\conf
mkdir htdocs
mkdir conf
cd conf

echo Creating httpd-app.conf
REM The first line in this file doesn't handle Windows backslashes well; reverse them
set "revpath=%apppath:\=/%"

@echo off
echo ^<Directory "%revpath%"^> ^

  Options ^+MultiViews ^

  AllowOverride None ^

  ^<IfVersion ^< 2.3 ^> ^

      Order allow,deny ^

      Allow from all ^

  ^</IfVersion^> ^

  ^<IfVersion ^>= 2.3^> ^

      Require all granted ^

  ^</IfVersion^>  ^

^</Directory^> ^

 > httpd-app.conf


echo creating  httpd-prefix.conf
@echo off
echo Alias /%appname%/ "%revpath%" ^

Alias /%appname% "%revpath%" ^

Include "%homedir%\%appname%\conf\httpd-app.conf" ^

> httpd-prefix.conf

echo appending "%homedir%\%appname%\conf\httpd-prefix.conf" to "%homedir%\..\apache2\conf\bitnami\bitnami-apps-prefix.conf"
echo Include "%homedir%\%appname%\conf\httpd-prefix.conf" >> "%homedir%\..\apache2\conf\bitnami\bitnami-apps-prefix.conf"

set /p restart="Restart apache? [N] "

IF "%restart%"=="" (SET restart=N)
IF "%restart%"=="N" (
exit /b 1
)


echo Setting environment
CALL "%homedir%\..\scripts\setenv.bat"
echo Stopping Apache
%homedir%\..\apache2\scripts\servicerun.bat STOP
echo Starting Apache
%homedir%\..\apache2\scripts\servicerun.bat START
cd %curdir%

pause
cmd /k

