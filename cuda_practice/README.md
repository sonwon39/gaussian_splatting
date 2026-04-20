# CUDA 실습

3DGS 래스터라이저 코드를 읽기 위한 **최소한의 CUDA 기초**를 HLSL Compute Shader 경험을 지렛대 삼아 쌓는다.

## 실습 순서

| # | 주제 | 핵심 개념 | HLSL 대응 |
|---|---|---|---|
| 1 | `01_vector_add.cu` | 커널 런치, `cudaMalloc/Memcpy` | 첫 `Dispatch` 체험 |
| 2 | `02_grayscale.cu` | 2D 스레드 그리드 | `SV_DispatchThreadID.xy` 활용 |
| 3 | `03_reduction.cu` | `__shared__`, `__syncthreads()` | `groupshared` + `GroupMemoryBarrierWithGroupSync` |
| 4 | `04_tiled_matmul.cu` | 타일링 (3DGS 래스터라이저의 핵심 패턴) | 타일 기반 컴퓨트 셰이더 |

## 빌드 (CUDA PC에서)

### Windows + MSVC (x64 Native Tools 프롬프트에서)

```bat
nvcc -O2 -o 01_vector_add.exe 01_vector_add.cu
01_vector_add.exe
```

### Linux

```bash
nvcc -O2 -o 01_vector_add 01_vector_add.cu
./01_vector_add
```

특별한 라이브러리 필요 없음. `nvcc`만 있으면 된다.

## 참고 — CUDA ↔ HLSL 개념 매핑

| HLSL Compute | CUDA |
|---|---|
| `[numthreads(X,Y,Z)]` | `dim3 block(X,Y,Z)` (런치 시 지정) |
| `Dispatch(gx,gy,gz)` | `kernel<<<grid, block>>>(...)` |
| `SV_DispatchThreadID` | `blockIdx * blockDim + threadIdx` |
| `SV_GroupID` | `blockIdx` |
| `SV_GroupThreadID` | `threadIdx` |
| `groupshared` | `__shared__` |
| `GroupMemoryBarrierWithGroupSync()` | `__syncthreads()` |
| `RWStructuredBuffer<T>` | `T*` (device pointer) |
| `InterlockedAdd` | `atomicAdd` |
| Wave intrinsics | `__shfl_sync`, cooperative groups |
