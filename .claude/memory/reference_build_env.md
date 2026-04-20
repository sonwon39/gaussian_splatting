---
name: 빌드 환경 메모 — venv / VS / Python 설치 상태
description: 2026-04-20 기준 사용자 PC 의 파이썬·Visual Studio·venv 위치 및 관련 수동 세팅 정보
type: reference
originSessionId: cdb8b550-f895-441e-8998-b7a8a3688bee
---
**Python 설치**
- `py -3.14` → `C:\Users\son97\AppData\Local\Programs\Python\Python314\python.exe` (기본)
- `py -3.10` → **launcher 엔트리만 남고 실체 제거됨** (PyTorch 필요 시 재설치 대상)
- `py -V:ContinuumAnalytics/Anaconda39-64` → Anaconda 3.9 (상태 미확인)

**프로젝트 venv**
- 경로: `C:\Users\son97\gaussian_splatting\.venv\`
- Python 버전: **3.14.2**
- 활성화: Git Bash `source .venv/Scripts/activate`, PowerShell `.venv\Scripts\Activate.ps1`
- 설치된 패키지: pybind11, setuptools, wheel, packaging

**Visual Studio**
- VS 2022 Community 설치됨 (`C:\Program Files\Microsoft Visual Studio\2022\Community\`)
- MSVC 툴체인: `14.31.31103`, `14.38.33130`, `14.44.35207`
- "Desktop development with C++" 워크로드는 **등록 안 돼 있지만** `cl.exe` 는 실제로 존재 → `vswhere` 자동탐지 실패, `vcvars64.bat` 수동 호출 필요
- vcvars64 위치: `C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat`

**How to apply:**
- setuptools 빌드가 "Unable to find a compatible Visual Studio installation" 으로 실패하면 → `vcvars64.bat` 을 호출하는 bat 스크립트로 감싸서 실행
- PyTorch 필요해지면 Python 3.10 재설치 권장 (Python 3.14 는 ML 생태계 호환성 이슈 가능)
- `.gitignore` 에 `.venv/`, `__pycache__/`, `*.pyd`, `*.so`, `build/`, `*.egg-info/` 등록됨
