"""C++ 확장 모듈 my_ext 를 파이썬에서 호출하는 데모."""

import my_ext   # ← 이게 되면 C++ → 파이썬 바인딩이 성공한 것

print("모듈 타입 :", type(my_ext))
print("설명      :", my_ext.__doc__)
print("노출 함수 :", [name for name in dir(my_ext) if not name.startswith("_")])
print()

# 1) 정수 덧셈
print("add(3, 5)          =", my_ext.add(3, 5))

# 2) 문자열 왕복 (파이썬 str <-> std::string 자동 변환)
print("greet('Hyeongwon') =", my_ext.greet("Hyeongwon"))

# 3) 리스트 왕복 (파이썬 list[float] <-> std::vector<float> 자동 변환)
a = [1.0, 2.0, 3.0, 4.0]
b = [10.0, 20.0, 30.0, 40.0]
print("add_vector(a, b)   =", my_ext.add_vector(a, b))

# 4) 예외 처리 — C++ 에서 throw 한 예외가 파이썬 예외로 전파된다
try:
    my_ext.add_vector([1.0, 2.0], [1.0, 2.0, 3.0])
except RuntimeError as e:
    print("예상된 예외 잡힘 :", e)

# 5) "진짜로 C++ 함수인가" 확인
print("add 의 내부 표현   :", repr(my_ext.add))
