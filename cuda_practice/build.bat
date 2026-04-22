@echo off
set MODULE_NAME=%1
if "%MODULE_NAME%"=="" set MODULE_NAME=math_ext

cd /d "%~dp0"
set PYTHON="%~dp0\..\.venv\Scripts\python.exe"

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 goto :end

set DISTUTILS_USE_SDK=1
set PYTHONUTF8=1

%PYTHON% -m pip install . --no-build-isolation
%PYTHON% -m pybind11_stubgen %MODULE_NAME% -o .
:end