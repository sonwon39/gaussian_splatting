---
name: Auto-memory 위치 — 레포 내부 공유 설정
description: 이 레포의 메모리는 .claude/memory/ 에 커밋되고, 개별 PC는 settings.local.json에서 autoMemoryDirectory를 설정해야 함
type: reference
---

이 레포의 auto-memory는 `<repo>/.claude/memory/` 에 있고 git으로 공유된다.

- `autoMemoryDirectory` 설정은 보안상 **커밋되는 `.claude/settings.json`에서는 무시**됨 → 반드시 `.claude/settings.local.json` 또는 `~/.claude/settings.json`에 설정해야 함.
- `.claude/settings.local.json`은 `.gitignore`에 등록되어 있음 (PC마다 절대경로가 다르므로).
- 새 PC에서 clone 후 해당 PC의 실제 절대경로로 `autoMemoryDirectory` 값을 수정한 뒤 Claude Code 재시작 필요.
