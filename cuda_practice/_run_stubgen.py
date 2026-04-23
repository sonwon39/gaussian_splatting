"""Stubgen wrapper that imports torch first so PyTorch's lib dir is on the
Windows DLL search path. Without this, pybind11_stubgen fails to import
torch-based extensions with 'DLL load failed'.

Usage (from build.bat):
    python _run_stubgen.py <module_name> -o <output_dir>
"""
import sys
import torch  # noqa: F401  -- side effect: registers torch/lib on DLL search path
from pybind11_stubgen import main

if __name__ == "__main__":
    sys.exit(main())
