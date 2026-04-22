#include <cuda_runtime.h>
#include "c10/cuda/CUDAException.h"
#include <torch/extension.h>



__global__ void addvector_kernel(const float* a, const float* b, float* c, int n)
{
    int idx = blockDim.x * blockIdx.x + threadIdx.x;
    if(idx < n)
    {
        c[idx] = a[idx] + b[idx];
    }
}   

torch::Tensor addvector_cuda(const torch::Tensor & a, const torch::Tensor & b)
{
    auto c = torch::empty_like(a);
    const int64_t n = a.numel();

    constexpr int threads = 256;
    const int64_t blocks = (n+threads-1) / threads;

    addvector_kernel<<<blocks, threads>>>(a.data_ptr<float>(),
            b.data_ptr<float>(),
            c.data_ptr<float>(),
            static_cast<int>(n));
    return c;
}