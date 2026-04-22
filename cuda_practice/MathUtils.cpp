#include <torch/extension.h>
#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

void cuda_check(const torch::Tensor & t)
{
    TORCH_CHECK(t.is_cuda(), "it's not a CUDA tensor\n");
    TORCH_CHECK(t.scalar_type() == torch::kFloat32, "it's not a Float32 tensor\n");
    TORCH_CHECK(t.is_contiguous(), "it's not a contiguous tensor\n");
}

torch::Tensor addvector_cuda(const torch::Tensor & a, const torch::Tensor & b);

torch::Tensor addvec(const torch::Tensor & a, const torch::Tensor & b)
{
    cuda_check(a);
    cuda_check(b);
    TORCH_CHECK(a.sizes() == b.sizes(), "add vector must have the same size");

    return addvector_cuda(a,b);
}


PYBIND11_MODULE(TORCH_EXTENSION_NAME, m)
{
    m.doc() = "벡터 연산 함수 집합 모듈";
    m.def("addvec", &addvec, "벡터 합 연산", pybind11::arg("tensor1"),pybind11::arg("tensor2"));
}