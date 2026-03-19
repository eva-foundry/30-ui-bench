# Project 30 Execution Guide

**Project**: 30-ui-bench  
**Date**: 2026-03-16 09:07 UTC  
**Scope**: Deterministic-orchestration execution guide for Project 30 as the screen-factory governance repo and Project 37 as the active client runtime.

---

## Overview

Project 30 does not currently ship the runtime UI by itself. It owns the sprint packet, generation patterns, acceptance framing, and handoff notes. For the current mission, implementation and verification may land in `37-data-model/ui`, and this guide exists to keep the split explicit.

## Operating Model

- Source of truth for governance: Project 37 data model API and `project_work`
- Source of truth for current UI scope: `docs/20260315_223500-project37-ui-handoff.md`
- Active sprint packet: Sprint 10 execution, Sprint 11 ready packet
- Live packet anchor: `30-ui-bench-sprint-10-packet` at `2026-03-16 09:07 UTC`
- Execution rule: do not mark client delivery complete until `37-data-model/ui` evidence exists

## Nested D3PDCA Flow

### D1 Discover

1. Complete the workspace bootstrap and API health check.
2. Read Project 30 governance docs and the latest handoff note.
3. Query the live Project 30 packet before trusting local status language.
4. Query Project 37 runtime contracts before reading generated UI files:
   - `GET /model/screens/`
   - `GET /model/endpoints/`
   - `GET /model/domain-views`
   - `GET /model/layer-metadata/`

### P1 Plan

1. Keep only two forward packets active:
   - Sprint 10: governance reset closeout plus Wave 2 execution
   - Sprint 11: FK-aware and ontology-view follow-up
2. Register or refresh the sprint config from the workspace root:

```powershell
python 97-workspace-notes/scripts/sprint_activation.py --config 30-ui-bench/sprint_10_config.json
```

1. If Project 37 needs a new dependency request, write a timestamped handoff note in `docs/`.

Packet posture for this session:

- Story 10.1: complete
- Story 10.2: complete
- Story 11.1: ready

### D2 Do

1. Make governance, generation, and acceptance changes in Project 30.
2. Make active Wave 2 client changes in `37-data-model/ui` until the route set is freshly verified; after that, move the packet into act-only closeout.
3. Keep fixed routes explicit and mock-safe.
4. Never fabricate FK-heavy or ontology-heavy payloads when the runtime layer is still empty.
5. Do not advance Sprint 11 work into execution until Sprint 10 has a checked-and-acted packet state.

### C1 Check

Run only the checks that match the changed surface.

```powershell
Set-Location C:\eva-foundry\30-ui-bench
npm test

Set-Location C:\eva-foundry\37-data-model\ui
npm run build
npm run lint
```

Record the exact command and outcome in `STATUS.md` and `ACCEPTANCE.md`.

Fresh Sprint 10 proof now exists for the Wave 2 route set: 6/6 focused tests passed, `npm run build` passed, `npm run lint` exits 0 with warnings only after the `react-hooks` plugin/config fix, and Veritas recorded MTI 72 before the live packet moved to `Sprint 10 / A1 Act closeout, Sprint 11 ready packet`. Treat the remaining warnings as baseline backlog, not as hidden route regressions.

### A1 Act

1. Update `PLAN.md`, `STATUS.md`, and `ACCEPTANCE.md`.
2. Refresh the `project_work` record through the workspace scrum tool so the paperless packet matches local truth.
3. Capture blockers and next packet scope.
4. If a dependency remains on Project 37, leave a timestamped handoff note rather than closing the item optimistically.

## Active Wave Scope

### Sprint 10 Execution Packet

- Governance reset closeout in Project 30
- Wave 2 routes in `37-data-model/ui`
  - `/login`
  - `/my-eva`
  - `/admin/rbac/act-as`
  - `/admin/rbac/responsibilities`
  - `/admin/a11y/themes`

### Sprint 11 Ready Packet

- FK-aware and ontology-view patterns promoted into reusable factory guidance
- Follow-up dependency requests to Project 37 for still-empty related layers

## Evidence Rules

- Keep evidence claims specific and current.
- Carry-forward evidence must be labeled as carry-forward, not fresh proof.
- A doc-only refresh can close governance items, but it cannot close client delivery items.
- If a build or test was not rerun in the active packet, leave the acceptance item open or explicitly mark the existing proof as carry-forward.

## Legacy QA Suite

The broader comprehensive QA suite remains available, but it is not the controlling workflow for the current restart. Use it after the active sprint packet is fully aligned and the client surface is ready for broader audit.
