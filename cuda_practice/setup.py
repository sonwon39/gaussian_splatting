import sys
from torch.utils.cpp_extension import BuildExtension, CUDAExtension
from setuptools import setup

is_win32 = sys.platform == "win32"
cxx_args = []
nvcc_args = ["-O2"]
if is_win32:
    nvcc_args += ["-Xcompiler", "/utf-8"]
    cxx_args +=["/utf-8"]
ext_modules = [
    CUDAExtension(
        name ="math_ext",
        sources = ["MathUtils.cpp", "MathUtilsKernel.cu"],
        extra_compile_args ={
            "cxx":cxx_args,
            "nvcc":nvcc_args,
        },
    ),
]

setup(
    name="math_ext",
    version="0.0.1",
    ext_modules=ext_modules,
    cmdclass={"build_ext":BuildExtension},
)