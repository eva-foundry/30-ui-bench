---
project: 30-ui-bench
last_updated: 20260316 09:07 UTC
current_phase: 10 / 11
mtI_target: 70
---

# 30-ui-bench Plan

> Local cache only. Paperless source of truth is the Project 37 data model API and `project_work` records for `30-ui-bench`.

## Current Phase Summary

Project 30 is running a two-sprint packet under the deterministic-orchestration model. Sprint 10 now sits in explicit A1 Act closeout with refreshed story states, fresh Wave 2 verification evidence, and MTI 72 recorded in the live packet. Sprint 11 has moved into D1/P1 execution for FK-aware and ontology-view follow-through now that Project 37 has confirmed runtime dependencies. [EVIDENCE: 37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md](37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md)

## Sprint Manifest

- Active config: `30-ui-bench/sprint_10_config.json`
- Ready config: `30-ui-bench/sprint_11_config.json`
- Active packet record: `30-ui-bench-sprint-10-packet`
- Handoff authority: `docs/20260315_223500-project37-ui-handoff.md`
- Paperless reference: `GET /model/project_work/?project_id=30-ui-bench`
- Packet timestamp anchor: `2026-03-16 09:07 UTC`

## Phases Roadmap

| Phase | Name | Expected Duration | Status |
| --- | --- | ---: | --- |
| 9 | Handoff discovery and Wave 1 baseline | complete | done |
| 10 | Governance reset closeout and Wave 2 execution | current sprint packet | active |
| 11 | FK-aware UX and ontology-view follow-up | next sprint packet | in D1/P1 execution |
| 12 | Remaining factory backlog and automation hardening | lookahead | queued |

## Active Stories

| ID | Story | Size | Phase Gate | Status |
| --- | --- | ---: | --- | --- |
| S10-1 | Refresh Project 30 instructions, plan, status, acceptance, and execution guide for deterministic orchestration | M | Governance packet aligned to workspace rules | complete |
| S10-2 | Execute Project 37 Wave 2 routes in `37-data-model/ui` with explicit route wiring and mock-safe fallbacks | L | Targeted tests plus production build pass | complete |
| S11-1 | Promote FK-aware and ontology-view patterns from Project 37 into reusable Project 30 delivery rules | M | Project 37 confirms required views and runtime dependencies [EVIDENCE: 37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md](37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md) | in_progress |

## Nested D3PDCA Packet

### Sprint 10 Execution Packet

- `D1 Discover`: refresh live `project_work`, handoff note, and Project 37 contract endpoints before trusting local closure language.
- `P1 Plan`: keep 10.1 complete, 10.2 complete, and 11.1 ready; refresh markdown and sprint config to match the paperless packet.
- `D2 Do`: carry Wave 2 route closeout in `37-data-model/ui` only against live contracts and existing mock-safe fallbacks.
- `C1 Check`: fresh focused `vitest run` passed 6/6 tests, `npm run build` passed, and `npm run lint` exited 0 with warnings only after the `react-hooks` plugin fix.
- `A1 Act`: packet record refreshed to `Sprint 10 / A1 Act closeout, Sprint 11 ready packet`, warning-only lint baseline captured, and MTI 72 recorded while Sprint 11 remains ready-only.

### Sprint 11 Execution Packet

- `D1 Discover`: confirm Project 37 domain-view and FK-aware runtime readiness.
- `P1 Plan`: scope reusable relation-aware UI patterns without pulling Sprint 12 into execution.
- `D2 Do`: implement guidance and dependency notes only after runtime views exist.
- `C1 Check`: verify the guidance matches actual domain views rather than invented layer assumptions.
- `A1 Act`: promote Sprint 11 to execution only when Sprint 10 is checked and acted.

Sprint 11 has now moved into D1/P1 execution based on the Project 37 runtime confirmation and the Project 30 FK/ontology UX guidance, while Sprint 12 remains a queued lookahead packet.

## Blockers

- Sprint 11 is no longer blocked on FK-aware and ontology-view readiness, but the dedicated `GET /model/domain-views` route remains a follow-up runtime surface gap rather than a blocker and should be tracked separately. [EVIDENCE: 37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md](37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md)
- Project 37 still owns runtime seeding for some related layers; Project 30 must not invent payloads for unseeded data. [EVIDENCE: docs/20260315_223500-project37-ui-handoff.md]
- Workspace root and repo working trees contain unrelated dirty-state artifacts, so Project 30 governance edits must stay tightly scoped. [EVIDENCE: workspace diff review 2026-03-15]
- The Project 37 UI lint command now exits 0, but 578 warning-level findings remain across generated API and type surfaces outside the active Wave 2 page set. [EVIDENCE: `npm run lint` output, 2026-03-16 08:49 UTC]

## Success Criteria

- Project-local instructions inherit workspace bootstrap and remove stale local-first template guidance.
- README and skill-index surfaces describe the current factory-and-handoff role instead of the older standalone bench narrative.
- `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`, and `docs/EXECUTION-GUIDE.md` describe the active sprint packet accurately.
- `30-ui-bench/sprint_10_config.json` exists and the packet `30-ui-bench-sprint-10-packet` is registered in the live data model. [EVIDENCE: sprint_activation.py exit 0]
- Wave 2 delivery is marked complete only after targeted client verification succeeds in `37-data-model/ui`; that threshold is now met with 6/6 focused tests, a production build pass, and a warning-only lint run. [EVIDENCE: focused `vitest run`, `npm run build`, `npm run lint`, 2026-03-16 08:44-08:49 UTC]
- Sprint 10 closeout is represented in the live packet as `Sprint 10 / A1 Act closeout, Sprint 11 ready packet`, with MTI evidence recorded at 72. [EVIDENCE: direct `PUT /model/project_work/30-ui-bench-sprint-10-packet`, live packet readback, Veritas audit 2026-03-16 09:07 UTC]
