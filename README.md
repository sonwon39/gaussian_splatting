# gaussian_splatting

**3D Gaussian Splatting (3DGS)** 을 학습·실습하기 위한 개인 레포입니다. 원전 논문 [3D Gaussian Splatting for Real-Time Radiance Field Rendering (Kerbl et al., 2023)](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/) 구현을 이해하고, 직접 렌더러·학습 파이프라인을 쌓아 올리는 것이 목표.

## 학습 로드맵

1. **Python 렌더링** — 사전 학습된 `.ply` 모델을 파이썬 + CUDA 래스터라이저로 재생
2. **DirectX 12 렌더링** — C++ + D3D12 Compute Shader 로 자체 실시간 뷰어 구현
3. **학습(training) 실습** — 원전 코드 기반 최적화 루프 재구성

## 폴더 구성

| 경로 | 내용 |
|---|---|
| [cuda_practice/](cuda_practice/) | PyTorch C++/CUDA 확장 작성 실습 (pybind11, CUDAExtension) |
| [theory/](theory/) | 수학·신호처리 개념 학습 노트북 (Fourier transform 등) |
| `requirements.txt` | Python 의존성 |

## 환경 세팅

- **Python 3.10+** (현재 로컬: 3.14, PyTorch 쓸 단계에선 3.10 권장)
- **Visual Studio 2022** (Community) + C++ 워크로드 또는 MSVC Build Tools
- **NVIDIA GPU + CUDA Toolkit** (로컬에 없으면 Google Colab / 클라우드 GPU 대체)

## 참고 자료

- [INRIA 공식 구현](https://github.com/graphdeco-inria/gaussian-splatting)
- [diff-gaussian-rasterization](https://github.com/graphdeco-inria/diff-gaussian-rasterization)
- [gsplat (Nerfstudio)](https://github.com/nerfstudio-project/gsplat)
