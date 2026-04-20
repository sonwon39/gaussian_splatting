// my_ext.cpp
//
// Python 에서 `import my_ext` 로 부를 수 있게 되는 C++ 코드.
// 핵심은 맨 아래 PYBIND11_MODULE 블록 — "이 C++ 함수를 파이썬 이름 XX 로 노출"
// 이라는 선언을 모아 두는 곳이다.

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>   // std::vector <-> Python list 자동 변환

#include <stdexcept>
#include <string>
#include <vector>

// -------- 평범한 C++ 함수들 (파이썬 전혀 몰라도 됨) --------

int add(int a, int b) {
    return a + b;
}

std::string greet(const std::string& name) {
    return "Hello, " + name + "! (from C++)";
}

// 벡터 덧셈 — 이번 CUDA 실습의 CPU 버전.
// 나중에 이 함수 내부를 CUDA 커널 런치로 바꾸면 그게 바로 3DGS 래스터라이저 구조.
std::vector<float> add_vector(const std::vector<float>& a,
                              const std::vector<float>& b) {
    if (a.size() != b.size()) {
        throw std::runtime_error("add_vector: size mismatch");
    }
    std::vector<float> c(a.size());
    for (size_t i = 0; i < a.size(); ++i) {
        c[i] = a[i] + b[i];
    }
    return c;
}

// -------- 파이썬 모듈 진입점 --------
// PYBIND11_MODULE(모듈이름, 핸들) — 파이썬이 `import my_ext` 할 때 호출됨.
// 모듈 이름은 setup.py 의 Extension 이름 및 결과 파일명과 정확히 일치해야 한다.
PYBIND11_MODULE(my_ext, m) {
    m.doc() = "pybind11 데모 — C++ 함수를 파이썬에 노출";

    m.def("add",        &add,        "두 정수를 더한다");
    m.def("greet",      &greet,      "인사 문자열을 반환한다");
    m.def("add_vector", &add_vector, "두 float 리스트를 원소별로 더한다");
}
