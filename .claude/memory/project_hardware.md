---
name: 작업 PC에 NVIDIA GPU 없음 (Intel Iris Xe only)
description: 2026-04-20 확인. CUDA/3DGS 학습·렌더는 클라우드 GPU 필요, DirectX12는 로컬 가능
type: project
originSessionId: cdb8b550-f895-441e-8998-b7a8a3688bee
---
작업 PC(Windows 11) 하드웨어: **Intel Iris Xe Graphics 통합 그래픽만** 있음. NVIDIA GPU·드라이버·CUDA toolkit 없음.

**Why:** 2026-04-20 `Get-CimInstance Win32_VideoController` 결과 확인. `nvcc`, `nvidia-smi` 모두 없음.

**How to apply:**
- CUDA 커널 실습, 3DGS 공식 학습, `diff-gaussian-rasterization` 기반 렌더링은 **로컬 불가** → Google Colab / Kaggle / 클라우드 GPU 사용
- **DirectX 12 기반 렌더링은 로컬 가능** (Intel Xe는 D3D12 지원)
- 사용자가 CUDA 실습·학습을 언급하면 어디서 실행할지(Colab vs 다른 장비) 먼저 확인할 것
- PyTorch CPU도 설치는 가능하지만 3DGS 규모에서는 실질적으로 의미 없음
