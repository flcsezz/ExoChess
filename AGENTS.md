# Agent Workflow

All agents must read [docs/PLAN.md](/home/flcsezz/mobile/docs/PLAN.md), [CURRENT_TASK.md](/home/flcsezz/mobile/CURRENT_TASK.md), and the active plan in [docs/plans/](/home/flcsezz/mobile/docs/plans) before making changes.

## Package Manager
Use **Flutter**: `flutter pub get`, `dart run build_runner watch`, `flutter analyze`, `flutter test`.

## File-Scoped Commands
| Task | Command |
|------|---------|
| Format | `dart format --output=none --set-exit-if-changed path/to/file.dart` |
| Analyze | `flutter analyze` |
| Test | `flutter test test/path/to/file_test.dart` |

## Rules
- Work only on one assigned task at a time from `docs/PLAN.md`.
- Claim the task first by updating `CURRENT_TASK.md`.
- Keep changes inside the claimed scope.
- Preserve keeper features listed in `docs/PLAN.md`.
- If blocked, record the blocker in `CURRENT_TASK.md` and stop.
- Mark the task complete in `docs/PLAN.md` only after verification.

## Coordination
- Task IDs must stay exactly as written in `docs/PLAN.md`.
- If multiple agents work in parallel, choose non-overlapping files when possible.
- If a file is already being modified by another agent, do not overwrite their work.

## Commit Attribution
AI commits MUST include:
`Co-Authored-By: <agent model and byline>`
