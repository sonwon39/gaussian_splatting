// ext.cpp
//
// 호스트(CPU) 쪽 glue 파일. nvcc 가 아닌 MSVC 로 컴파일된다.
// 하는 일:
//   1) 파이썬에서 넘어온 torch::Tensor 를 검증 (dtype, device, contiguous, shape)
//   2) 실제 커널 런치는 vecadd_cuda() 로 위임 (.cu 쪽에 정의)
//   3) PYBIND11_MODULE 로 파이썬 모듈 엔트리 노출
//
// .cu 와 .cpp 를 왜 분리했나:
//   - pybind11 의 템플릿 폭탄은 MSVC 가 처리하는 편이 훨씬 빠르고 안정적
//   - __global__ / <<<>>> 같은 CUDA 문법은 nvcc 만 이해
//   → 호스트 glue = .cpp, 디바이스 커널 + 런처 = .cu

#include <torch/extension.h>

// .cu 에 정의된 런처. 여기선 "있다" 선언만 한다.
torch::Tensor vecadd_cuda(torch::Tensor a, torch::Tensor b);

// 호스트 래퍼: 입력 유효성 검사 후 디바이스 런처 호출.
torch::Tensor vecadd(torch::Tensor a, torch::Tensor b) {
    TORCH_CHECK(a.is_cuda(),                    "a must be a CUDA tensor");
    TORCH_CHECK(b.is_cuda(),                    "b must be a CUDA tensor");
    TORCH_CHECK(a.scalar_type() == torch::kFloat32, "a must be float32");
    TORCH_CHECK(b.scalar_type() == torch::kFloat32, "b must be float32");
    TORCH_CHECK(a.sizes() == b.sizes(),         "a and b must have the same shape");
    TORCH_CHECK(a.is_contiguous(),              "a must be contiguous");
    TORCH_CHECK(b.is_contiguous(),              "b must be contiguous");
    return vecadd_cuda(a, b);
}

// PYBIND11_MODULE 의 첫 인자는 모듈 이름.
// CUDAExtension 을 쓸 때는 TORCH_EXTENSION_NAME 매크로를 쓰면
// setup.py 의 name 과 자동으로 일치시켜 준다.
PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    m.doc() = "CUDA vector add — pybind11 + torch::Tensor 실습";
    m.def("vecadd", &vecadd, "Element-wise add on CUDA (float32, contiguous)");
}
