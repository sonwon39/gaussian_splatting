@echo off

set MODULE_NAME=%1
if "%MODULE_NAME%"=="" set MODULE_NAME=math_ext

cd /d "%~dp0"
set PYTHON="%~dp0\..\.venv\Scripts\python.exe"
set LOG=%~dp0build.log

echo [stubgen.bat] Generating stubs for %MODULE_NAME%...
REM Use helper that does `import torch` first so DLL search path is set.
REM Emit stubs next to the installed .pyd so Pylance picks them up automatically.
set STUB_DIR=%~dp0..\.venv\Lib\site-packages
echo [stubgen.bat] stubs -^> %STUB_DIR%
%PYTHON% _run_stubgen.py %MODULE_NAME% -o "%STUB_DIR%" >> "%LOG%" 2>&1
if errorlevel 1 (
    echo [build.bat] stubgen FAILED. See %LOG%.
    goto :end
)

echo [build.bat] DONE.

:end