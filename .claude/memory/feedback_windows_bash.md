---
name: Windows Git Bash — HEREDOC 사용 금지
description: 이 PC의 Git Bash에서 HEREDOC은 TMPDIR 문제로 항상 실패하므로 대체 방식을 사용해야 함
type: feedback
---

이 작업 환경(Windows 11 + Git Bash)에서 `$(cat <<'EOF' ... EOF)` HEREDOC 패턴은 `cannot create temp file for here-document: No such file or directory` 오류로 실패한다.

**Why:** Git Bash의 `TMPDIR` 환경변수가 유효한 Windows 경로로 해석되지 않아 임시파일 생성에 실패. 2026-04-20 git 초기 커밋 시 재현됨.

**How to apply:** 커밋 메시지처럼 여러 줄 문자열을 bash로 전달해야 할 때 HEREDOC 대신:
- 커밋: `git commit -m "제목" -m "본문 줄1" -m "본문 줄2" -m "Co-Authored-By: ..."` (각 `-m`이 단락을 만듦)
- PR body 등 긴 텍스트: 파일에 `Write`로 쓴 뒤 `gh pr create --body-file ...` 또는 `git commit -F file.txt` 사용
