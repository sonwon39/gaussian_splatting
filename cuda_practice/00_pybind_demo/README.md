# 00 — pybind11 으로 C++ 을 파이썬에서 호출하기

**이 PC(NVIDIA GPU 없음)에서도 그대로 동작.** 3DGS 래스터라이저가 파이썬과 CUDA 를 묶는 방식과 구조가 동일하지만, 여기서는 CPU 만 써서 개념만 먼저 확인한다.

## 파일 구성

| 파일 | 역할 |
|---|---|
| `my_ext.cpp` | 파이썬에 노출할 C++ 함수들 + `PYBIND11_MODULE` 진입점 |
| `setup.py` | 빌드 스크립트. 내부적으로 C++ 컴파일러를 호출 |
| `demo.py` | 빌드된 `my_ext` 모듈을 import 해서 호출해 보는 파이썬 스크립트 |

## 사전 준비

### 1. pybind11 설치

```bash
pip install pybind11 setuptools
```

### 2. C++ 컴파일러

- **Windows**: Visual Studio 2019 이상의 **"Desktop development with C++"** 워크로드. 또는 Visual Studio Build Tools 만 따로 설치해도 됨. 설치 후 **"x64 Native Tools Command Prompt for VS 2022"** 를 띄워서 아래 명령을 실행하면 `cl.exe` 경로가 자동으로 잡힌다.
- **Linux**: `g++` 또는 `clang++`.

## 빌드

```bash
python setup.py build_ext --inplace
```

성공하면 이 폴더에 다음과 같은 파일이 생긴다:

- Windows: `my_ext.cp310-win_amd64.pyd`
- Linux  : `my_ext.cpython-310-x86_64-linux-gnu.so`

파일명에 파이썬 버전·플랫폼이 박히는 이유: **파이썬 ABI 호환성 보장**을 위해서. 다른 파이썬 버전에서는 다시 빌드해야 한다.

## 실행

```bash
python demo.py
```

기대 출력:

```
모듈 타입 : <class 'module'>
설명      : pybind11 데모 — C++ 함수를 파이썬에 노출
노출 함수 : ['add', 'add_vector', 'greet']

add(3, 5)          = 8
greet('Hyeongwon') = Hello, Hyeongwon! (from C++)
add_vector(a, b)   = [11.0, 22.0, 33.0, 44.0]
예상된 예외 잡힘 : add_vector: size mismatch
add 의 내부 표현   : <built-in method add of PyCapsule object at 0x...>
```

## 지금 일어난 일 정리

```
my_ext.cpp
   │  [ setup.py 가 cl.exe / g++ 호출 ]
   ▼
my_ext.cp310-win_amd64.pyd      ← 실체는 일반 공유 라이브러리
   │  [ import my_ext ]
   ▼
파이썬 코드에서 my_ext.add(...) 처럼 호출
```

**`.pyd` 는 파이썬이 알아볼 수 있는 진입점이 박힌 DLL 이다.** 진입점을 박아주는 것이 `PYBIND11_MODULE(my_ext, m)` 매크로 한 줄.

## 3DGS 와의 연결고리

이 구조에서 딱 두 가지만 바뀌면 3DGS 의 `diff-gaussian-rasterization` 이 된다:

1. **`my_ext.cpp` 안의 for-루프 → CUDA 커널 런치** (`.cu` 파일로 분리, `nvcc` 가 컴파일)
2. **`pybind11.setup_helpers.Pybind11Extension` → `torch.utils.cpp_extension.CUDAExtension`**
   - 차이: 후자는 nvcc 호출 자동화 + `torch::Tensor` 를 인자 타입으로 받을 수 있게 해 줌

그 외 뼈대(PYBIND11_MODULE, setup.py, import, 함수 호출)는 **글자 한 자까지 동일**하다.

## 문제 해결

- `error: Microsoft Visual C++ 14.0 or greater is required` — VS Build Tools 미설치. 위 "사전 준비" 참고.
- `ImportError: DLL load failed` — 파이썬 버전과 빌드된 `.pyd` 의 파이썬 버전이 다름. `python --version` 확인 후 재빌드.
- 빌드는 되는데 `import my_ext` 실패 — `demo.py` 를 이 폴더 안에서 실행했는지 확인. `--inplace` 옵션으로 빌드해야 같은 폴더에 산출물이 생긴다.
