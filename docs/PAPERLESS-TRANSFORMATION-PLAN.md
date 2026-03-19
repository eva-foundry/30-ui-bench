# 30-ui-bench Paperless Transformation Plan (Session 45 Part 13)

**Date**: 2026-03-13 08:00 AM ET  
**Methodology**: Nested DPDCA v2.0-enhanced (8 tasks)  
**Objective**: Convert 30-ui-bench from 30% paperless-ready to 100% paperless governance

---

## Current State Assessment

### File-Based Governance (100%)
```
PLAN.md             → F30-01 (complete), F30-02 (3/4), F30-03 (planned) [LOCAL]
STATUS.md           → Session 45 Part 11 snapshot (7:25 AM ET) [LOCAL]
ACCEPTANCE.md       → 25 acceptance gates (0/25 passing) [LOCAL]
Evidence/           → JSON reports + logs [LOCAL]
```

### API Awareness (Structure Only)
```
copilot-instructions.md  → References /model, API bootstrap pattern documented
Templates                → Built for @eva/data-model-ui imports
Generators               → No write-back to API yet
MCP tools referenced     → audit_repo, get_trust_score, sync_repo (not called)
```

---

## Paperless Architecture (Target State)

### Single Source of Truth: Data Model API
```
QUERY PATH:                          WRITE PATH:
GET /model/projects/30-ui-bench      PUT /model/project_work/{id}
GET /model/project_work              PUT /model/verification_records/{id}
GET /model/quality_gates             PUT /model/deployment_audit/{id}
GET /model/deployment_audit
```

### Layered Governance (API-First with Fallback)
```
Layer 1 (API):      Query /model/projects/30-ui-bench for current state
Layer 2 (Cache):    Local files become "generated from API" (marked read-only)
Layer 3 (Evidence): JSON evidence published to /model/verification_records
```

---

## Transformation Tasks (8 DPDCA)

### DO PHASE Tasks (4 implementation items)

**Task 3: Bootstrap Integration**
- ✅ Add API bootstrap section to copilot-instructions.md PART 2
- ✅ Query `/model/projects/30-ui-bench` before reading local PLAN.md
- ✅ Fallback: If API unreachable, use local PLAN.md (hybrid mode)

**Task 4: Write-Back Pattern**
- ✅ Implement in `generate-all-screens.ps1` after successful generation
- ✅ Create write-back JSON for:
  - L46 (project_work): Story status + metrics
  - L45 (verification_records): Build verification + test results
  - L47 (deployment_audit): Generation timestamp + version
  - L51 (cost_metrics): Component count + generation latency
- ✅ Add error handling (fail-closed on API unreachable)

**Task 5: Session Sync Script**
- ✅ Create `SYNC-TO-MODEL.ps1` (PowerShell automation)
- ✅ At session close: audit_repo + sync_repo + export evidence
- ✅ Two modes:
  - Automatic (runs at session close)
  - Manual (run via `sync_repo` MCP tool)

**Task 6: API-Sourced Templates**
- ✅ Update PLAN.md header: "⚠️ GENERATED FROM API - DO NOT EDIT DIRECTLY"
- ✅ Update STATUS.md header: "⚠️ READ-ONLY CACHE FROM L46 - See API for live state"
- ✅ Add `# Refresh this document` instructions for next session
- ✅ ACCEPTANCE.md remains local (reference, not source of truth)

---

## Execution Strategy

### Phase 2: PLAN (This File)
- ✅ Document architecture (API-first, hybrid fallback)
- ✅ Define 4 tasks + 4 sub-tasks each = 16 total work items
- ✅ Estimate effort: ~3 hours total

### Phase 3: DO (Multiple Tasks)
**Task 3** (30 min): Update copilot-instructions.md
- PLAN.md section heading change
- Add API bootstrap pseudo-code

**Task 4** (60 min): Implement write-back in generators
- Modify `generate-all-screens.ps1` (lines 420-450)
- Create `Build-ProjectWorkObject` function
- Test write-back with sample JSON

**Task 5** (45 min): Create SYNC-TO-MODEL.ps1
- Orchestrate `audit_repo` → `sync_repo` → `export_to_model`
- Error handling (fail-closed on API error)
- Evidence logging

**Task 6** (30 min): Mark files as API-sourced
- Add header warnings to PLAN.md, STATUS.md
- Create "REFRESH-FROM-API.md" instructions
- Add timestamps + API endpoint references

### Phase 4: CHECK (30 min)
- Execute all 4 tasks with dry-run flags
- Verify API connectivity
- Validate JSON write-back structures
- Test fallback (API down scenario)

### Phase 5: ACT (30 min)
- Document lessons learned
- Create `SESSION_45_PART_13_PAPERLESS_COMPLETE.md`
- Sign off on 100% paperless readiness

---

## Success Criteria

| Criterion | Current | Target | Status |
|-----------|---------|--------|--------|
| **API queries** | 0 active | ≥5 queries per session | ⏳ TO-DO |
| **Write-back** | 0 objects/session | ≥5 objects/session | ⏳ TO-DO |
| **Sync cycle** | Manual only | Automatic + manual | ⏳ TO-DO |
| **File governance** | 100% source-of-truth | 0% (read-only cache) | ⏳ TO-DO |
| **Paperless score** | 30% | 100% | ⏳ TO-DO |

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| **API unreachable** | Hybrid fallback: Local files stay valid; writes buffered |
| **Write-back fails** | Evidence file saved locally + manual export available |
| **Old files cached** | Timestamp + "Generated from API" headers prevent stale assumptions |
| **Teams don't adopt** | MCP tools (sync_repo) + automated calls reduce friction |

---

## Deliverables (After All Tasks)

1. ✅ Updated copilot-instructions.md (API bootstrap section)
2. ✅ Modified generate-all-screens.ps1 (write-back function)
3. ✅ New SYNC-TO-MODEL.ps1 script
4. ✅ Updated PLAN.md/STATUS.md (API-sourced headers)
5. ✅ Evidence: PAPERLESS-TRANSFORMATION-COMPLETE.json
6. ✅ Documentation: SESSION_45_PART_13_SUMMARY.md

---

## Next Steps (After Paperless Complete)

- Option A: Deploy to Project 51 (ACA) as reference paperless implementation
- Option B: Integrate with workspace-wide governance sync (all 57 projects)
- Option C: Extend to other projects (01-documentation-generator, 02-poc-agent-skills, etc.)

---

**PLAN PHASE READY FOR EXECUTION** ✅
