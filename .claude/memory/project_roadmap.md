---
name: 3DGS 학습 로드맵 (렌더링 먼저 → DirectX12)
description: 사용자가 정한 실습 순서. 렌더링 → 학습, Python → DirectX12 단계별 진행
type: project
originSessionId: cdb8b550-f895-441e-8998-b7a8a3688bee
---
사용자의 3DGS 실습 순서(2026-04-20 확정):

1. **Python으로 렌더링 실습** — 사전 학습된 `.ply` 모델을 Python + CUDA 래스터라이저로 불러와 렌더링
2. **DirectX 12로 렌더링 실습** — C++ + DirectX12 Compute Shader로 자체 래스터라이저 구현해 동일한 `.ply` 재생
3. **학습(training) 실습** — 위 단계를 마친 뒤에 진행

**Why:** 사용자가 원하는 최종 결과물은 DirectX12 기반 실시간 뷰어. 학습은 CUDA 생태계가 훨씬 유리하다는 합의 완료 → 학습은 CUDA로, 뷰어/렌더는 DirectX12로 역할 분리.

**How to apply:**
- 현재 단계는 **Python 렌더링**이므로, 제안·코드 예시는 이 단계에 집중
- DirectX12 제안을 너무 일찍 꺼내지 말 것. 사용자가 "이제 DirectX로 넘어가자"고 말할 때 전환
- 학습 관련 코드(옵티마이저, densification 등)는 현재 범위 밖 — 요청 없으면 건드리지 않기
- Python 렌더링 단계에서는 `diff-gaussian-rasterization`, `gsplat` 등 기존 래스터라이저 활용 추천
