// cuda vector add 실습

#include <cstdio>
#include <cstdlib>
#include <cuda_runtime.h>

#define CUDA_CHECK(call)                                                    \
    do{                                                                     \
        cudaError_t error = (call);                                         \
        if(error!=cudaSuccess) {                                            \
            fprintf(stderr, "CUDA error %s : %d : %s", __FILE__, __LINE__,  \
                    cudaGetErrorString(error));                             \
            exit(EXIT_FAILURE);                                             \
        }                                                                   \
                                                                            \
    }while(0)


__global__ void vector_add(const float* a, const float* b, float* c , int n)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if(idx < n)
    {
        c[idx] = a[idx] + b[idx];
    }
}

int main()
{
    const int N = 1<<9; 
    int bytes = sizeof(float) * N;
    
    // 호스트 메모리 할당
    float* h_a = (float*)malloc(bytes);
    float* h_b = (float*)malloc(bytes);
    float* h_c = (float*)malloc(bytes);

    // 호스트 값 할당
    for (size_t i = 0; i < N; i++)
    {
        h_a[i] = i;
        h_b[i] = N-i;
    }
    
    // 디바이스 메모리 할당
    float* d_a = nullptr, *d_b = nullptr, *d_c = nullptr;
    CUDA_CHECK(cudaMalloc(&d_a, bytes));
    CUDA_CHECK(cudaMalloc(&d_b, bytes));
    CUDA_CHECK(cudaMalloc(&d_c, bytes));

    CUDA_CHECK(cudaMemcpy(d_a, h_a, bytes , cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_b, h_b, bytes , cudaMemcpyHostToDevice));

    int thread_count = 256;
    int block_count = (N+thread_count-1) / thread_count;

    // 연산
    vector_add<<<block_count, thread_count>>>(d_a, d_b, d_c, N);

    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());

    CUDA_CHECK(cudaMemcpy(h_c, d_c, bytes , cudaMemcpyDeviceToHost));

    for (int i = 0; i < 100; i++)
    {
        printf("%d 번째 %.1f + %.1f = %.1f ", i, h_a[i], h_b[i], h_c[i]);
    }
    
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);

    return 0;
}