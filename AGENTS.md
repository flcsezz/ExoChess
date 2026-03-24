# Agent Workflow

All agents must read [docs/PLAN.md](/home/flcsezz/mobile/docs/PLAN.md) and [CURRENT_TASK.md](/home/flcsezz/mobile/CURRENT_TASK.md) before making changes.

## Rules
- Work only on one assigned task at a time from `docs/PLAN.md`.
- Claim the task first by updating `CURRENT_TASK.md`.
- Keep changes inside the claimed scope. Do not expand scope silently.
- Preserve all features listed as keepers in `docs/PLAN.md`.
- If a task uncovers a blocker, stop, document it in `CURRENT_TASK.md`, and do not improvise a broad refactor.
- When a task is complete, update both `CURRENT_TASK.md` and the matching checkbox in `docs/PLAN.md`.

## Required Update Steps
1. Read `docs/PLAN.md`.
2. Open `CURRENT_TASK.md` and claim an unassigned task.
3. Implement only that task.
4. Run the relevant verification for that task.
5. Record:
   - task id
   - owner
   - files changed
   - verification run
   - blockers or follow-ups
6. Mark the task complete in `docs/PLAN.md` only after verification.

## Coordination Format
- Task IDs must stay exactly as written in `docs/PLAN.md`.
- If multiple agents work in parallel, they must choose non-overlapping files when possible.
- If a file is already being modified by another agent, do not overwrite their work. Rebase your task scope or wait.

## Completion Standard
A task is not complete because code was written. It is complete only when the task-specific verification in `docs/PLAN.md` has been run and recorded.
