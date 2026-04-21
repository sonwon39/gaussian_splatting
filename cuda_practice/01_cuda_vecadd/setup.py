# setup.py
#
# CUDAExtension = Pybind11Extension 의 CUDA 버전.
# PyTorch 가 nvcc 를 자동으로 호출하고, PyTorch C++ ABI 로 링크해 준다.
# ext.cpp 는 MSVC, vecadd_kernel.cu 는 nvcc 가 컴파일.
#
# 사용:
#   python setup.py build_ext --inplace
#
# 결과물: vecadd_ext.cp310-win_amd64.pyd (같은 폴더)
#   → demo.py 에서 `import vecadd_ext` 로 바로 사용.

import sys

from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension

# MSVC 한글 Windows 대응:
#   /utf-8  : 소스 UTF-8 로 해석
#   /wd4819 : CP949 외 문자 경고(C4819) 끄기 — pybind11 헤더에 종종 발생
is_win = sys.platform == "win32"
cxx_args = ["/utf-8", "/wd4819"] if is_win else []
# nvcc 가 내부적으로 MSVC 를 호출할 때도 같은 플래그 전달.
nvcc_args = ["-O2"]
if is_win:
    nvcc_args += ["-Xcompiler", "/utf-8", "-Xcompiler", "/wd4819"]

setup(
    name="vecadd_ext",
    version="0.0.1",
    ext_modules=[
        CUDAExtension(
            name="vecadd_ext",  # ← import vecadd_ext 와 일치해야 함
            sources=["ext.cpp", "vecadd_kernel.cu"],
            extra_compile_args={
                "cxx": cxx_args,
                "nvcc": nvcc_args,
            },
        ),
    ],
    cmdclass={"build_ext": BuildExtension},
)
