---
project: 30-ui-bench
current_gate: 10 / 11
last_audit: 20260316
---

# 30-ui-bench Acceptance Criteria

## Quality Gate Checklist

- [x] All active client-surface tests pass with exit code 0
- [x] Linting passes for the changed surface with no new violations
- [ ] Code coverage meets the active threshold for any newly added tests
- [x] MTI score is audited before sprint close
- [x] Data model updated when runtime records or governance state change
- [x] Documentation updated for the active sprint packet
- [x] No encoding violations introduced in new governance artifacts

## Evidence Requirements

- Handoff authority: `docs/20260315_223500-project37-ui-handoff.md`
- Sprint scaffold: `sprint_10_config.json`
- Ready-packet scaffold: `sprint_11_config.json`
- FK/ontology runtime confirmation: `../../37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md`
- FK/ontology UX guidance: `docs/20260317_140500-guidance-fk-ontology-ux.md`
- Governance refresh proof: repo diff for `README.md`, `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`, `docs/EXECUTION-GUIDE.md`, `.github/copilot-instructions.md`, and `.github/copilot-skills/00-skill-index.skill.md`
- Paperless packet proof: `30-ui-bench-sprint-10-packet` registered by `97-workspace-notes/scripts/sprint_activation.py`
- Client verification proof: fresh focused `vitest run` pass for the five Wave 2 pages and fresh `npm run build` pass in `37-data-model/ui` on 2026-03-16 08:44-08:45 UTC
- Lint baseline proof: `npm run lint` output in `37-data-model/ui` showing 0 errors and 578 warnings after the `react-hooks` plugin/config fix on 2026-03-16 08:49 UTC
- MTI reference: Veritas audit recorded trust score 72 for `30-ui-bench` on 2026-03-16 09:00 UTC
- Packet drift proof: `GET /model/project_work/30-ui-bench-sprint-10-packet` showing D1/P1 state before the 08:26 UTC refresh
- Packet closeout proof: direct `PUT /model/project_work/30-ui-bench-sprint-10-packet` updated the live phase to `Sprint 10 / A1 Act closeout, Sprint 11 ready packet` on 2026-03-16 09:07 UTC

## Manual Gate Criteria

- Reviewer verifies that Project 30 no longer claims standalone runtime ownership for the active Project 37 handoff.
- Reviewer verifies that Wave 2 pages are only marked complete after client-surface evidence exists and the paperless packet state is advanced to match that evidence.
- Reviewer verifies that any FK-aware or ontology-view dependency is raised back to Project 37 instead of being mocked into fake production data.
- Reviewer verifies that the Sprint 11 ready packet remains smaller than the active execution packet and does not include speculative completion claims.

## Sprint 10 Execution Gate

- [x] Project-local instructions reflect the current repo role and active client surface.
- [x] README and skill index reflect the current repo role and active client surface.
- [x] Project 30 governance artifacts align with workspace bootstrap and deterministic orchestration.
- [x] Sprint activation config exists for Project 30.
- [x] Sprint packet is registered in the live data model.
- [x] Paperless packet updated to reflect 10.1 complete and 10.2 complete.
- [x] Wave 2 route wiring closeout confirmed in `37-data-model/ui` for this packet state.
- [x] Wave 2 focused tests recorded.
- [x] Project 37 production build recorded for the active route set.
- [x] Live packet phase advanced beyond the default D1/P1 scaffold.

## Sprint 11 Ready Gate

- [x] Project 37 confirms required ontology and FK-aware views for the next packet.
- [x] Reusable Project 30 guidance exists for relation-aware UI patterns.
- [ ] Any remaining factory backlog is separated from the active operator-screen packet.
