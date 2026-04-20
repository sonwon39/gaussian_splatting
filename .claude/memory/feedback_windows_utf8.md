---
name: Windows 한글 로케일 + UTF-8 소스 빌드/실행 주의점
description: MSVC 와 cmd/bash 가 기본 CP949 라 UTF-8 소스·출력이 깨짐. 컴파일 플래그와 환경변수 필요
type: feedback
originSessionId: cdb8b550-f895-441e-8998-b7a8a3688bee
---
한국 Windows 에서 UTF-8 소스(한글 주석 포함 `.cpp`, `.cu`) 빌드/실행 시 반드시 챙길 것:

1. **MSVC 컴파일 시 `/utf-8` 플래그 필요**
   - 없으면 `warning C4819` → `error C2001` 체인으로 빌드 실패
   - `setup.py` 에서: `extra_compile_args=["/utf-8"] if sys.platform == "win32" else []`

2. **파이썬 출력 시 `PYTHONUTF8=1` 환경변수**
   - 없으면 `UnicodeEncodeError: 'cp949' codec can't encode ...` (특히 em-dash `—`, 한글)
   - 실행: `PYTHONUTF8=1 python demo.py`
   - 또는 사용자 환경에 영구 설정 가능 (`setx PYTHONUTF8 1`)

**Why:** 2026-04-20 pybind11 데모 빌드 시 두 문제 모두 발생. 한국 Windows 기본 코드페이지가 CP949 라서 MSVC 도 파이썬 stdout 도 UTF-8 을 자동으로 못 읽음.

**How to apply:**
- Windows 대상 C++/CUDA 확장 `setup.py` 작성 시 `/utf-8` 자동 추가
- Windows 에서 파이썬 스크립트 실행 커맨드 제시할 때 `PYTHONUTF8=1` 프리픽스 또는 `-X utf8` 플래그 포함
- CMake/bat 스크립트도 동일하게 반영
