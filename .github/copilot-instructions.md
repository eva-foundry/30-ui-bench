# GitHub Copilot Instructions -- UI Bench

**Last Updated**: 2026-03-15
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
3. Read `README.md`, `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`, and the latest Project 37 handoff note in `docs/`.
4. Query the cloud API for live truth before inspecting generated UI:
   - `GET /model/projects/30-ui-bench`
   - `GET /model/project_work/?project_id=30-ui-bench`
   - `GET /model/screens/`
   - `GET /model/endpoints/`
   - `GET /model/domain-views`
   - `GET /model/layer-metadata/`
5. Write a short session brief: active sprint packet, verified evidence, next task, blockers.

## Operating Boundaries

- Project 30 owns sprint framing, acceptance, route intent, handoff notes, and generation strategy.
- Project 37 owns runtime layers, API contracts, seeded data, and the active UI deployment surface.
- If a screen depends on still-empty runtime layers, raise the dependency back to Project 37 in a timestamped handoff note instead of inventing payloads.
- If ontology-category or FK-aware views are required, request them from Project 37 as a timestamped handoff artifact before building bespoke fallback logic.

## Nested D3PDCA Packet

Use the workspace deterministic-orchestration pattern with at most two forward sprints packaged at once.

`D1 Discover`
- Refresh API truth, handoff packet status, blockers, and prior evidence.

`P1 Plan`
- Keep Sprint 10 as the execution packet and Sprint 11 as the ready packet.
- Update `PLAN.md`, `STATUS.md`, and `ACCEPTANCE.md` to match the paperless record.

`D2 Do`
- Implement governance or generator changes in Project 30.
- Implement active-client UI changes in `37-data-model/ui` when the handoff requires it.

`C1 Check`
- Run only the verification that matches the changed surface.
- For Project 37 UI work, treat `npm run build` and targeted tests in `37-data-model/ui` as the primary gate.

`A1 Act`
- Record verified outcomes, blockers, and next-wave scope in Project 30 governance docs.
- Prepare the next sprint packet and keep markdown aligned to the live API state.

## Active Sprint Scaffold

- Active config: `C:\eva-foundry\30-ui-bench\sprint_10_config.json`
- Template source: `C:\eva-foundry\97-workspace-notes\scripts\sprint_config_template.json`
- Register from the workspace root:

```powershell
python 97-workspace-notes/scripts/sprint_activation.py --config 30-ui-bench/sprint_10_config.json
```

## Verification Commands

```powershell
Set-Location C:\eva-foundry\30-ui-bench
npm test

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
- Active client surface: `C:\eva-foundry\37-data-model\ui`