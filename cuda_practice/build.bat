@echo off
REM Build a CUDA extension via pip + generate type stubs.
REM Logs everything to build.log in plain ASCII (no PowerShell -> no UTF-16 BOM).

set MODULE_NAME=%1
if "%MODULE_NAME%"=="" set MODULE_NAME=math_ext

cd /d "%~dp0"
set PYTHON="%~dp0\..\.venv\Scripts\python.exe"
set LOG=%~dp0build.log

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" > nul
if errorlevel 1 (
    echo [build.bat] vcvars64 failed
    goto :end
)

set DISTUTILS_USE_SDK=1
set PYTHONUTF8=1

echo === build started at %DATE% %TIME% === > "%LOG%"

REM Run pip install. Output goes to log AND console (via cmd echo of last line).
REM Use plain redirection — readable text, no encoding surprises.
%PYTHON% -m pip install . --no-build-isolation -v >> "%LOG%" 2>&1
set PIP_RC=%ERRORLEVEL%

REM Always show the tail of the log so the user sees what happened.
echo.
echo --- last 40 lines of build.log ---
powershell -NoProfile -Command "Get-Content '%LOG%' -Tail 40"
echo --- end of log tail ---
echo.

if not %PIP_RC%==0 (
    echo [build.bat] pip install FAILED (exit %PIP_RC%). Full log: %LOG%
    echo            Search for the first 'error:' line:
    echo                findstr /N /C:"error" "%LOG%"
    goto :end
)

echo [build.bat] pip install OK. Generating stubs for %MODULE_NAME%...
REM Use helper that does `import torch` first so DLL search path is set.
REM Emit stubs next to the installed .pyd so Pylance picks them up automatically.
set STUB_DIR=%~dp0..\.venv\Lib\site-packages
echo [build.bat] stubs -^> %STUB_DIR%
%PYTHON% _run_stubgen.py %MODULE_NAME% -o "%STUB_DIR%" >> "%LOG%" 2>&1
if errorlevel 1 (
    echo [build.bat] stubgen FAILED. See %LOG%.
    goto :end
)

echo [build.bat] DONE.

:end
