@echo off
REM Set up MSVC env and build the CUDA extension with the venv Python.
REM (Comments kept in ASCII because cmd.exe reads .bat files as CP949,
REM  and UTF-8 Korean text gets mojibake'd into bogus commands.)
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if errorlevel 1 goto :end
set DISTUTILS_USE_SDK=1
REM RTX 3070 is sm_86. Restricting arch makes nvcc much faster.
set TORCH_CUDA_ARCH_LIST=8.6
"%~dp0..\..\.venv\Scripts\python.exe" "%~dp0setup.py" build_ext --inplace
:end
