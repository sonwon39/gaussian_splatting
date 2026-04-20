// 01_vector_add.cu
//
// 목표: "CUDA로 Hello World". 두 배열을 더해 결과 배열에 쓴다.
// 배울 것:
//   1) 호스트(CPU) ↔ 디바이스(GPU) 메모리 이동: cudaMalloc / cudaMemcpy / cudaFree
//   2) 커널 런치 문법: kernel<<<grid, block>>>(...)
//   3) 전역 thread id 계산: blockIdx * blockDim + threadIdx
//   4) 경계 체크 (배열 크기가 block 크기의 배수가 아닐 때)

#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

// -------- 유틸: CUDA 호출 에러 확인 --------
// 모든 CUDA 런타임 API는 cudaError_t 를 돌려준다. 무시하지 말 것.
#define CUDA_CHECK(call)                                                     \
    do {                                                                     \
        cudaError_t err = (call);                                            \
        if (err != cudaSuccess) {                                            \
            fprintf(stderr, "CUDA error %s:%d: %s\n", __FILE__, __LINE__,    \
                    cudaGetErrorString(err));                                \
            exit(EXIT_FAILURE);                                              \
        }                                                                    \
    } while (0)

// -------- 커널 --------
// __global__  : 호스트에서 호출되고 디바이스에서 실행되는 함수.
//               HLSL 컴퓨트 셰이더 진입점과 같은 역할.
// 모든 스레드가 같은 코드를 실행하고, 자기 id에 해당하는 원소만 처리한다(SPMD).
__global__ void vector_add(const float* a, const float* b, float* c, int n) {
    // 전역 thread id — HLSL의 SV_DispatchThreadID.x 와 동일
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    // 경계 체크: n 이 blockDim 의 배수가 아닐 수 있으므로 반드시 필요
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    const int N = 1 << 20;              // 1M 원소
    const size_t bytes = N * sizeof(float);

    // -------- 호스트 메모리 준비 --------
    float* h_a = (float*)malloc(bytes);
    float* h_b = (float*)malloc(bytes);
    float* h_c = (float*)malloc(bytes);
    for (int i = 0; i < N; ++i) {
        h_a[i] = (float)i;
        h_b[i] = (float)(2 * i);
    }

    // -------- 디바이스 메모리 할당 --------
    // HLSL 에서 CreateCommittedResource 로 UAV 버퍼를 만드는 단계에 해당.
    float *d_a = nullptr, *d_b = nullptr, *d_c = nullptr;
    CUDA_CHECK(cudaMalloc(&d_a, bytes));
    CUDA_CHECK(cudaMalloc(&d_b, bytes));
    CUDA_CHECK(cudaMalloc(&d_c, bytes));

    // -------- 호스트 → 디바이스 복사 --------
    CUDA_CHECK(cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice));

    // -------- 런치 구성 --------
    // HLSL 의 [numthreads(256,1,1)] 와 Dispatch(gx,1,1) 를 런타임에 지정하는 것과 같다.
    int threads_per_block = 256;
    int blocks_per_grid   = (N + threads_per_block - 1) / threads_per_block;

    // -------- 커널 실행 --------
    vector_add<<<blocks_per_grid, threads_per_block>>>(d_a, d_b, d_c, N);

    // 런치 자체의 구성 오류(잘못된 block 크기 등)는 바로, 커널 내부 오류는
    // cudaDeviceSynchronize 이후에 확인된다.
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    // -------- 디바이스 → 호스트 복사 --------
    CUDA_CHECK(cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost));

    // -------- 검증 --------
    int errors = 0;
    for (int i = 0; i < N; ++i) {
        float expected = h_a[i] + h_b[i];
        if (h_c[i] != expected) {
            if (errors < 5) {
                fprintf(stderr, "mismatch at %d: got %f expected %f\n",
                        i, h_c[i], expected);
            }
            ++errors;
        }
    }
    printf("N = %d, errors = %d\n", N, errors);
    printf("sample: c[0]=%.1f  c[%d]=%.1f\n", h_c[0], N - 1, h_c[N - 1]);

    // -------- 정리 --------
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);
    return 0;
}
