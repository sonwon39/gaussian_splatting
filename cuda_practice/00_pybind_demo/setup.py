# setup.py
#
# 빌드 스크립트. 다음을 해 준다:
#   1) C++ 소스 my_ext.cpp 를 pybind11 포함 경로와 함께 컴파일
#   2) OS별로 Windows = my_ext.*.pyd / Linux = my_ext.*.so 로 링크
#   3) 결과물을 현재 폴더에 놓음 (pip install 없이 즉시 import 가능)
#
# 사용:
#   python setup.py build_ext --inplace
#
# --inplace 는 "빌드 산출물을 원본 소스 옆에 둔다" 는 옵션.
# 그래야 같은 폴더의 demo.py 가 바로 import 할 수 있다.

import sys

from pybind11.setup_helpers import Pybind11Extension, build_ext
from setuptools import setup

# MSVC 는 소스를 시스템 코드페이지(한국 Windows = CP949)로 읽기 때문에
# UTF-8 로 저장된 한글 주석이 깨진다. /utf-8 로 UTF-8 소스 모드를 강제.
extra_args = ["/utf-8"] if sys.platform == "win32" else []

ext_modules = [
    Pybind11Extension(
        "my_ext",           # ← 이 이름이 PYBIND11_MODULE(...) 과 일치해야 함
        ["my_ext.cpp"],
        cxx_std=17,
        extra_compile_args=extra_args,
    ),
]

setup(
    name="my_ext",
    version="0.0.1",
    ext_modules=ext_modules,
    cmdclass={"build_ext": build_ext},
)
