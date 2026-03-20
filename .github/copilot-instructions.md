# GitHub Copilot Instructions -- UI Bench

**Last Updated**: 2026-03-19
**Project**: UI Bench
**Path**: `C:\eva-foundry\30-ui-bench\`
**Role**: Screen-factory governance and handoff authority for EVA UI work
**Primary Client Surface**: `C:\eva-foundry\37-data-model\ui`

This repo is not the runtime app for the current mission. Project 30 owns the sprint packet, governance, acceptance framing, and generation patterns. For the active Project 37 handoff, implementation work may land in `37-data-model/ui` while this repo stays authoritative for scope, evidence, and next-wave planning.

## Session Bootstrap

1. Complete the workspace bootstrap in `C:\eva-foundry\.github\copilot-instructions.md` first. Do not reintroduce localhost, `C:\AICOE\...`, or disk-fallback guidance here.
2. Acknowledge the workspace skills and scrum tools before sprint planning:
   - `@eva-factory-guide`, `@foundation-expert`, `@scrum-master`, `@workflow-forensics-expert`
   - `97-workspace-notes/scripts/sprint_activation.py`, `sprint_progress.py`, `velocity_tracker.py`, `sprint_retrospective.py`
3. Read `README.md`, `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`, the active Project 37 handoff note in `docs/`, and the Sprint 11 FK/ontology guidance note.
4. Query the cloud API for live truth before inspecting generated UI:
   - `GET /model/projects/30-ui-bench`
   - `GET /model/project_work/?project_id=30-ui-bench`
   - `GET /model/screens/`
   - `GET /model/endpoints/`
   - `GET /model/domain-views`
   - `GET /model/layer-metadata/`
5. Write a short session brief: active packet id, active story, verified evidence, next task, blockers.

## Operating Boundaries

- Project 30 owns sprint framing, acceptance, route intent, handoff notes, and generation strategy.
- Project 37 owns runtime layers, API contracts, seeded data, and the active UI deployment surface.
- The active execution item is Story 11.1 inside `30-ui-bench-sprint-10-packet`; do not rewrite the packet as a standalone Sprint 11 artifact unless the live `project_work` record changes first.
- If a screen depends on still-empty runtime layers, raise the dependency back to Project 37 in a timestamped handoff note instead of inventing payloads.
- If ontology-category or FK-aware views are required, request them from Project 37 as a timestamped handoff artifact before building bespoke fallback logic.
- Treat the explicit Project 37 six-screen handoff package as the current closure dependency for Sprint 11 work.

## Nested D3PDCA Packet

Use the workspace deterministic-orchestration pattern with at most two forward sprints packaged at once.

`D1 Discover`
- Refresh API truth, handoff packet status, blockers, and prior evidence.

`P1 Plan`
- Keep Story 11.1 as the active execution item inside `30-ui-bench-sprint-10-packet` and keep Sprint 12 as lookahead-only unless the live packet changes.
- Update `PLAN.md`, `STATUS.md`, and `ACCEPTANCE.md` to match the paperless record.

`D2 Do`
- Implement governance or generator changes in Project 30.
- Implement active-client UI changes in `37-data-model/ui` only when the handoff requires it and the live Project 37 runtime contract supports the change.

`C1 Check`
- Run only the verification that matches the changed surface.
- For Project 37 UI work, treat `npm run build` and targeted tests in `37-data-model/ui` as the primary gate, and treat warning-only lint as carry-forward evidence unless the changed surface introduces new errors.

`A1 Act`
- Record verified outcomes, blockers, and next-wave scope in Project 30 governance docs.
- Do not claim Sprint 11 closure until the explicit six-screen handoff package is published and the guidance matches the live Project 37 semantics.

## Active Packet Scaffold

- Active packet id: `30-ui-bench-sprint-10-packet`
- Active execution story: `11.1 Prepare FK-aware and ontology-view follow-up`
- Active config: `C:\eva-foundry\30-ui-bench\sprint_10_config.json`
- Ready config: `C:\eva-foundry\30-ui-bench\sprint_11_config.json`
- Template source: `C:\eva-foundry\97-workspace-notes\scripts\sprint_config_template.json`
- Register from the workspace root:

```powershell
python 97-workspace-notes/scripts/sprint_activation.py --config 30-ui-bench/sprint_10_config.json
```

Keep the config and packet id aligned with the live `project_work` record. Do not promote `sprint_11_config.json` to the active registration target until the live packet changes.

## Verification Commands

```powershell
Set-Location C:\eva-foundry\30-ui-bench
npm test
pwsh scripts/Test-AllAcceptanceCriteria.ps1

Set-Location C:\eva-foundry\37-data-model\ui
npm run build
npm run lint
pwsh scripts/generate-layer-routes.ps1
```

## Anti-Patterns

| Do not | Do instead |
|---|---|
| Treat Project 30 as a standalone UI runtime | Treat it as the factory and governance repo while targeting the client surface explicitly |
| Trust old generated files over live contracts | Query the cloud model and handoff packet first |
| Mark UI delivery complete without client-surface verification | Record the exact Project 37 build and test evidence that passed |
| Leave template placeholders in repo guidance | Replace them with current sprint-packet facts or remove them |

## Skills In This Repo

Only `00-skill-index.skill.md` is currently published. If repeated screen-factory workflows emerge, add real skill files and update the index in the same change.

## References

- Workspace authority: `C:\eva-foundry\.github\copilot-instructions.md`
- Workspace skills registry: `C:\eva-foundry\97-workspace-notes\scripts\WORKSPACE-SKILLS-REGISTRY.md`
- Workspace tools registry: `C:\eva-foundry\97-workspace-notes\scripts\WORKSPACE-TOOLS-REGISTRY.md`
- Active handoff packet: `C:\eva-foundry\30-ui-bench\docs\20260315_223500-project37-ui-handoff.md`
- Active Sprint 11 guidance: `C:\eva-foundry\30-ui-bench\docs\20260317_140500-guidance-fk-ontology-ux.md`
- Active client surface: `C:\eva-foundry\37-data-model\ui`