---
name: git-push
description: Stage all changes, create a commit with a message describing the work, and push to the origin remote on the current branch. Use when the user asks to "commit and push", "push to GitHub", "깃에 올려", "커밋하고 푸시", or similar.
---

# git-push

로컬 변경사항을 스테이징 → 커밋 → origin으로 푸시하는 스킬.

## 실행 절차

1. **상태 확인 (병렬)**:
   - `git status` — 변경된 파일 파악
   - `git diff` + `git diff --staged` — 변경 내용 파악
   - `git log --oneline -5` — 최근 커밋 스타일 참고
   - `git branch --show-current` — 현재 브랜치 확인

2. **변경 없으면 중단**: 스테이징할 것도 커밋할 것도 없으면 "변경사항 없음"을 알리고 종료.

3. **민감 파일 제외**: `.env`, 자격증명 파일, 큰 바이너리 등은 추가하지 않고 사용자에게 경고. `git add -A` / `git add .` 대신 파일명을 명시해서 추가하기.

4. **커밋 메시지 작성**:
   - 1–2문장, "왜"에 초점
   - 이 레포의 최근 커밋 스타일을 따를 것
   - 학습용 레포이므로 해당 커밋에서 다룬 3DGS 개념/실습 주제가 있으면 메시지에 자연스럽게 녹여 쓰기

5. **커밋 + 푸시**:
   - 커밋 메시지는 HEREDOC으로 전달 (포매팅 유지)
   - 푸시 전에 업스트림 추적 여부 확인 → 없으면 `git push -u origin <branch>`, 있으면 `git push`

6. **결과 확인**: `git status`로 워킹 트리 깨끗한지, 푸시 성공했는지 확인해 사용자에게 1–2줄로 요약.

## 주의

- `--force` / `--no-verify` 는 사용자가 명시적으로 요청할 때만.
- 커밋 훅이 실패하면 **amend 하지 말고** 문제를 고친 뒤 새 커밋 만들기.
- `main` 브랜치에 force push는 절대 금지, 요청받아도 한 번 더 확인.
- 원격 인증 실패 시 (HTTPS 자격증명 만료 등) 사용자가 해결하도록 명확히 알리기.
