@echo off
REM MSVC 환경을 세팅한 뒤 venv 파이썬으로 확장 모듈 빌드
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 goto :end
set DISTUTILS_USE_SDK=1
"%~dp0..\..\.venv\Scripts\python.exe" "%~dp0setup.py" build_ext --inplace
:end
