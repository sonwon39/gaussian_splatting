# demo.py
#
# 1) 정합성 — 수제 CUDA 커널 결과 vs PyTorch `a + b` 가 일치하는지
# 2) 속도   — 둘을 N회 반복해 평균 실행 시간 비교
#
# 주의:
#   - CUDA 는 비동기. 정확한 시간 측정에 torch.cuda.synchronize() 필수.
#   - 첫 호출은 커널 컴파일/캐시 로딩이 끼므로 warmup 필요.

import time
import torch

import vecadd_ext  # ← setup.py 의 name 과 일치


def bench(fn, a, b, iters=200):
    # warmup
    for _ in range(5):
        fn(a, b)
    torch.cuda.synchronize()

    t0 = time.perf_counter()
    for _ in range(iters):
        out = fn(a, b)
    torch.cuda.synchronize()
    t_avg_ms = (time.perf_counter() - t0) * 1000.0 / iters
    return out, t_avg_ms


def main():
    assert torch.cuda.is_available(), "CUDA 사용 불가 — 환경 확인 필요"
    print(f"device: {torch.cuda.get_device_name(0)}")
    print(f"torch : {torch.__version__}  (cuda={torch.version.cuda})")
    print()

    n = 10_000_000  # 1천만 원소, float32 → 40MB × 3 텐서
    a = torch.rand(n, device="cuda", dtype=torch.float32)
    b = torch.rand(n, device="cuda", dtype=torch.float32)

    c_ours,  t_ours  = bench(vecadd_ext.vecadd, a, b)
    c_torch, t_torch = bench(lambda x, y: x + y, a, b)

    ok = torch.allclose(c_ours, c_torch)
    max_diff = (c_ours - c_torch).abs().max().item()

    print(f"n = {n:,}")
    print(f"ours  : {t_ours:7.3f} ms / call")
    print(f"torch : {t_torch:7.3f} ms / call")
    print(f"match : {ok}   max|diff| = {max_diff:.2e}")
    print()
    print("힌트: 결과가 torch 와 비슷하거나 약간 느려도 정상.")
    print("      torch 의 `a + b` 는 이미 고도로 최적화된 elementwise 커널.")
    print("      이 실습의 목적은 '내 손으로 커널 런치 흐름을 만들어 본다' 이다.")


if __name__ == "__main__":
    main()
