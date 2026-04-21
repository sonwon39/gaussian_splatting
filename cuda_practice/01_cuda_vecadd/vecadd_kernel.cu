// vecadd_kernel.cu
//
// 디바이스(GPU) 쪽 코드. nvcc 로 컴파일된다.
// 구성:
//   1) __global__ vecadd_kernel — 각 스레드가 한 원소씩 더함
//   2) vecadd_cuda (호스트 함수) — grid/block 계산 후 <<<...>>> 로 커널 런치
//
// 포인트:
//   - torch::Tensor 는 파이썬 ↔ C++ ↔ CUDA 간에 메모리 복사 없이 공유됨
//   - .data_ptr<float>() 로 raw device pointer 를 꺼내 커널에 전달
//   - grid = ceil(n / threads) — 모든 원소를 덮도록 블록 수를 올림

#include <torch/extension.h>
#include <cuda_runtime.h>
#include <c10/cuda/CUDAException.h>  // C10_CUDA_KERNEL_LAUNCH_CHECK

// --- 디바이스 커널 --------------------------------------------------
// __global__ = "CPU에서 호출, GPU에서 실행" 표식.
// __restrict__ = "이 포인터들은 서로 안 겹침" 힌트 → 컴파일러 최적화 여지.
__global__ void vecadd_kernel(
    const float* __restrict__ a,
    const float* __restrict__ b,
    float* __restrict__ c,
    int64_t n
) {
    // 전역 스레드 인덱스. blockIdx.x 는 현재 블록 번호,
    // blockDim.x 는 블록당 스레드 수, threadIdx.x 는 블록 내 스레드 번호.
    int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;

    // n 이 threads 의 배수가 아닐 수 있으므로 out-of-range 방어.
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

// --- 호스트 런처 ----------------------------------------------------
// ext.cpp 에서 호출된다. 출력 텐서를 만들고 커널을 런치한다.
torch::Tensor vecadd_cuda(torch::Tensor a, torch::Tensor b) {
    // 입력과 같은 shape/dtype/device 로 빈 출력 할당.
    auto c = torch::empty_like(a);
    const int64_t n = a.numel();

    // block 당 스레드 수. 일반적으로 128 / 256 / 512 중에 고름.
    // 256 은 대부분 GPU에서 무난한 기본값.
    constexpr int threads = 256;
    const int64_t blocks = (n + threads - 1) / threads;

    // <<<blocks, threads>>> — CUDA 런치 문법. nvcc 만 이해.
    vecadd_kernel<<<blocks, threads>>>(
        a.data_ptr<float>(),
        b.data_ptr<float>(),
        c.data_ptr<float>(),
        n
    );

    // 런치 에러 체크 (커널 실행 중 에러는 다음 동기화 때까지 안 보임).
    // 디버깅용으로 켜두면 좋음. 릴리즈에선 제거해도 됨.
    C10_CUDA_KERNEL_LAUNCH_CHECK();

    return c;
}
