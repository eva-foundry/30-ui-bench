# 30-ui-bench

Project 30 is the screen-factory governance repo for the current Project 37 UI handoff. It owns sprint framing, acceptance rules, route intent, handoff notes, and reusable delivery guidance. It is not the authoritative runtime for the active wave of work.

For the current mission, runtime implementation and verification may land in `37-data-model/ui`, while Project 30 stays authoritative for packet scope, operator expectations, and evidence language.

## Current Operating Model

- Governance truth lives in the Project 37 data model API and the `project_work` packet records for `30-ui-bench`.
- Active handoff authority is the Project 37 provider packet in `../37-data-model/docs/20260316_112700-ws06d-provider-handoff-kernel-engine.md`, with local UI guidance retained in `docs/20260315_223500-project37-ui-handoff.md`.
- Active execution packet: Sprint 10 closeout with Sprint 11 execution follow-through.
- Sprint 11 is now execution-active against the published Project 37 query-first handoff contract.
- Runtime owner: `37-data-model/ui`.

## Current Sprint Packet

Sprint 10 is the active execution packet for two workstreams:

1. Reset Project 30 governance and instruction surfaces so they match the paperless, deterministic-orchestration model.
2. Deliver and verify the Wave 2 Project 37 routes in `37-data-model/ui` without inventing runtime payloads for unseeded layers.

Sprint 11 now executes FK-aware and ontology-view follow-up against the published Project 37 handoff packet, without inventing runtime payloads or assuming unpublished direct collection routes.

## Active Wave Scope

Wave 2 routes for the current handoff:

- `/login`
- `/my-eva`
- `/admin/rbac/act-as`
- `/admin/rbac/responsibilities`
- `/admin/a11y/themes`

These routes are only considered delivered when the client-surface checks pass in `37-data-model/ui`.

## Repo Responsibilities

Project 30 owns:

- sprint packet definition
- acceptance framing
- route intent and delivery order
- reusable screen-factory guidance
- dependency notes back to Project 37

Project 37 owns:

- runtime data and seeded layers
- API and query contracts
- route wiring and client behavior for the active handoff
- build and test proof for the client surface

## Quick References

- Project record: `GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench`
- Active packet: `GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/project_work/30-ui-bench-sprint-10-packet`
- Governance docs: `PLAN.md`, `STATUS.md`, `ACCEPTANCE.md`
- Project instructions: `.github/copilot-instructions.md`
- Skill index: `.github/copilot-skills/00-skill-index.skill.md`

## Sprint Execution Commands

Register the packet from the workspace root:

```powershell
python 97-workspace-notes/scripts/sprint_activation.py --config 30-ui-bench/sprint_10_config.json
```

Run the relevant checks for the changed surface:

```powershell
Set-Location C:\eva-foundry\30-ui-bench
npm test

Set-Location C:\eva-foundry\37-data-model\ui
npm run build
npm run lint
```

## Working Rules

- Query the live API and current handoff packet before trusting generated files.
- Do not mark Project 37 delivery complete from Project 30 alone.
- If a screen depends on an unseeded runtime layer, raise a timestamped dependency note instead of mocking fake production data.
- Label carry-forward evidence as carry-forward; do not present it as fresh proof.

## Related Files

- `docs/20260315_223500-project37-ui-handoff.md`
- `docs/EXECUTION-GUIDE.md`
- `sprint_10_config.json`
- `.github/copilot-instructions.md`
