---
project: 30-ui-bench
sprint: 11
role: fk-and-ontology-ux-guidance
last_updated: 20260317 14:05 UTC
source_project: 37-data-model
status: in_progress
---

# Sprint 11 FK-Aware and Ontology-View UX Guidance

## 1. Purpose and Anchors

This document turns the Project 37 runtime confirmation and ontology model into concrete UX guidance for Project 30 Sprint 11.

Authoritative anchors:
- Runtime dependency confirmation: `../../37-data-model/evidence/20260316_133100-project30-fk-ontology-runtime-confirmation.md`
- Ontology background: `../../37-data-model/docs/library/98-model-ontology-for-agents.md`
- Handoff packet: `20260315_223500-project37-ui-handoff.md`

Sprint 11 work must treat these three documents plus the live data model API as the governing sources of truth.

## 2. FK-Aware UX Patterns

When screens surface relations between objects (projects, sprints, agents, workflows, evidence, etc.), follow these rules:

1. Prefer human-readable labels over raw IDs
   - Use data from layer metadata and domain views to display names, titles, and short descriptions instead of exposing GUIDs or internal keys.
   - Only show raw IDs in secondary diagnostic zones (for operators or engineers), never as the primary user-facing identifier.

2. Make relations navigable, not opaque
   - Represent related entities (for example, workflow runs, agent memory records, work-factory views, service endpoints) as clickable or drill-down elements.
   - From any FK-backed relation, the user should be able to jump to a screen that explains the related object in its own context.

3. Keep relation context visible
   - When a screen is reached via a relation, clearly show both:
     - "You are here": the current entity and its primary role.
     - "You came from": the relation that led to this view (for example, from a specific sprint, project, or evidence record).
   - Avoid orphan views that hide how a user arrived at the current entity.

4. Avoid duplicated or conflicting FK surfaces
   - Do not show the same relation twice using different labels or categories.
   - If multiple paths can reach the same related entity, consolidate them into a single, well-named relation.

## 3. Ontology-View UX Patterns

The Project 37 ontology organizes the system into domains (for example, governance, projects, evidence, operations). Sprint 11 UX work should:

1. Use domain language rather than table language
   - Name screens and navigation items after ontology domains and concepts (for example, "Project Work Packet", "Verification Records", "Evidence Timeline") instead of low-level storage details.

2. Group screens by domain intent
   - Within navigation, group screens according to the ontology view (governance and policy, project and product management, observability and evidence, etc.).
   - Avoid mixing unrelated domains on the same page unless the intent is explicitly cross-cutting (for example, an overview dashboard).

3. Align with domain views exposed by the API
   - When the data model exposes structured domain views (or equivalent aggregates via `/model/layer-metadata` and related endpoints), design the screen around those views instead of composing ad-hoc query shapes.

4. Make domain boundaries visible to operators
   - For operator-facing screens, show which ontology domain the user is currently working in and where cross-domain jumps occur.

## 4. Screen Design Checklist for Sprint 11

For each Sprint 11 screen or guidance example:

- [ ] The primary entity is labeled with human-friendly names and summaries, not raw IDs.
- [ ] All FK-backed relations are presented as navigable elements leading to dedicated context views.
- [ ] The path from the source entity to each related view is clear (breadcrumbs or equivalent context).
- [ ] Screen naming and navigation placement use ontology domain language.
- [ ] The design is compatible with the runtime patterns confirmed in the Project 37 evidence note.

When in doubt, defer to the handoff packet and the runtime confirmation note, and raise any new FK or ontology-view gaps back to Project 37 instead of patching around them in UI-only code.