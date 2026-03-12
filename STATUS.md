# 30-ui-bench -- EVA Screen Factory Status

**Last Updated**: 2026-03-12 by AIAgentExpert (Session 46)
**Data Model**: GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench
**Veritas Trust**: Run `get_trust_score` MCP tool for current MTI score

---

<!-- eva-primed-status -->

## EVA Ecosystem Live Status

Query these endpoints to get live project state before starting any work:

```powershell
$base = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"

# Project facts
Invoke-RestMethod "$base/model/projects/30-ui-bench" | Select-Object id, maturity, phase, pbi_total, pbi_done

# Health
Invoke-RestMethod "$base/health" | Select-Object status, store, version

# One-call summary (all layer counts)
Invoke-RestMethod "$base/model/agent-summary"
```

For veritas audit:
```
MCP tool: audit_repo  repo_path=C:\eva-foundry\30-ui-bench
MCP tool: get_trust_score  repo_path=C:\eva-foundry\30-ui-bench
```

---

## Current State

### Templates v2.0.0
**Status**: ✅ COMPLETE (Session 46, Commit 3771dcf in 37-data-model repo)
**Location**: `37-data-model/scripts/templates/screens-machine/`
**Files**:
- ListView.template.tsx (v2.0.0)
- DetailView.template.tsx (v2.0.0)
- CreateForm.template.tsx (v2.0.0)
- EditForm.template.tsx (v2.0.0)
- GraphView.template.tsx (v2.0.0)
- README.md (updated)

**Enhancements**:
- ✅ Centralized GC Design tokens (@styles/tokens)
- ✅ API Health Monitoring (SM-PATTERN-001)
- ✅ Version footer for cache debugging
- ✅ 6-language i18n (EN/FR/ES/DE/PT/CN)
- ✅ WCAG 2.1 AA compliance patterns
- ✅ Chart colors from tokens (GraphView)

### Clients
**Current**: 1 active client (37-data-model UI)
**Pending**: Regeneration of 111 pages with v2.0.0 templates
**Future**: 31-eva-faces (Portal), 51-ACA

### Acceptance Criteria
**Total**: 51 gates (25 current + 26 future)
**Critical Blockers**: 14 must-pass gates
**Status**: All PENDING (awaiting regeneration)

---

## Session Log

### 2026-03-12 -- Session 46: Screen Factory Promotion

**Activity**: Project 30-ui-bench promoted from "UI playground" to "Screen Factory"

**Scope Expansion**:
- Not limited to 111 Data Model pages
- Can generate screens for ANY EVA project
- Factory pattern: improve templates → regenerate all artifacts

**Governance Updates**:
- ✅ README.md rewritten (factory vision, architecture, clients)
- ✅ PLAN.md restructured (6 features, 20+ stories)
- ✅ ACCEPTANCE.md comprehensive (51 gates, 25 current + 26 future)
- ✅ STATUS.md updated (this file)

**Templates**:
- ✅ All 5 core templates upgraded to v2.0.0
- ✅ Commit 3771dcf in 37-data-model repo
- ✅ tokens.ts enhanced with chart colors, semantic aliases

**Next Steps**:
1. Regenerate 111 Data Model pages
2. Execute 25 acceptance criteria tests
3. Deploy to Azure (Build #15+)
4. Validate quality gates

---

### 2026-03-03 -- Initial Prime by agent:copilot

**Activity**: Project primed by foundation-primer workflow.
**Template**: copilot-instructions-template.md v3.1.0
**Governance docs created**: PLAN.md, STATUS.md, ACCEPTANCE.md, README (placeholder)

---

## Feature Status

| Feature | Status | Stories Complete | Notes |
|---------|--------|------------------|-------|
| F30-01: Template System v2.0.0 | ✅ COMPLETE | 5/5 | All enhancements done |
| F30-02: Batch Regeneration | 🔄 IN PROGRESS | 0/4 | Awaiting user approval |
| F30-03: Multi-Client Support | 📋 PLANNED | 0/4 | v2.2.0+ |
| F30-04: Test Generation | 📋 PLANNED | 0/4 | v3.0.0 |
| F30-05: Quality Gates Automation | 📋 PLANNED | 0/4 | v2.3.0 |
| F30-06: Evidence & Observability | 📋 PLANNED | 0/3 | v2.4.0 |

---

## Quality Metrics

### Templates
- **Version**: v2.0.0
- **Files**: 5 core + 1 README
- **Lines of Code**: ~2,500 (templates + docs)
- **Token Usage**: Centralized (@styles/tokens)
- **Languages**: 6 (EN/FR/ES/DE/PT/CN)

### Generated Code (Future)
- **Target**: 111 layers × 5 components = 555 files
- **Estimated LOC**: ~110,000 lines
- **Bundle Size Target**: < 2MB gzipped
- **Performance Target**: < 3s initial load

### Acceptance Criteria
- **Total Gates**: 51 (25 current + 26 future)
- **Critical Blockers**: 14
- **Passed**: 0 (pending regeneration)
- **Failed**: 0
- **Skipped**: 26 (future features)

---

## Blockers

**None** - Templates complete, awaiting user approval for batch regeneration.

---

## Risks

| Risk | Mitigation | Status |
|------|------------|--------|
| Breaking changes in templates | Incremental rollout (3-5 pages first) | MITIGATED |
| Bundle size increases | Tree-shaking, code splitting | MONITORED |
| TypeScript errors after regen | Pre/post-generation validation | PLANNED |
| Manual fixes overwritten | Discourage manual edits, improve templates | DOCUMENTED |

---

## Next Steps

1. **User Approval**: Choose regeneration strategy (full 111 pages vs incremental)
2. **Regeneration**: Run generate-all-screens.ps1 with v2.0.0 templates (~9 minutes)
3. **Build Verification**: npm run build (expect 0 errors)
4. **Acceptance Testing**: Execute 25 current acceptance criteria
5. **Deployment**: Deploy to Azure (Build #15+)
6. **Quality Gate**: Validate WCAG 2.1 AA, 6-language support, performance
7. **Evidence**: Document results in evidence/ directory
8. **Commit**: Git commit with comprehensive message

---

## Test / Build State

> Update this section after each test run.

| Command | Status | Last Run | Result |
|---------|--------|----------|--------|
| npm run build (37-data-model/ui) | ✅ PASS | 2026-03-12 (Build #14) | 499 modules, i18n upgrade |
| npm run lint | PENDING | (not run) | - |
| TypeScript compilation | PENDING | (after regeneration) | - |
| 25 Acceptance Criteria | PENDING | (after regeneration) | - |

---

## Evidence Trail

### Session 46 Commits
- **3771dcf** (37-data-model): feat(screens-machine): upgrade templates to v2.0.0
  - 7 files changed, 305 insertions, 225 deletions
  - All 5 templates upgraded
  - tokens.ts enhanced
  - README.md updated

### Documentation
- SCREEN-MACHINE-V2-UPGRADE.md (37-data-model/docs/)
- Complete upgrade guide with before/after examples

---

**Philosophy**: "Marco Sandbox... but the work is done with World Class Enterprise & Government production ready code in mind. so a11y and i18n is basic and implicit requirement for us."

**Status**: Templates ready, governance updated, awaiting batch regeneration approval.

---

<!-- eva-primed-status -->

## EVA Ecosystem Live Status

Query these endpoints to get live project state before starting any work:

```powershell
$base = "http://localhost:8010"

# Project facts
Invoke-RestMethod "$base/model/projects/30-ui-bench" | Select-Object id, maturity, phase, pbi_total, pbi_done

# Health
Invoke-RestMethod "$base/health" | Select-Object status, store, version

# One-call summary (all layer counts)
Invoke-RestMethod "$base/model/agent-summary"
```

For 29-foundry agent assistance:
```python
import sys
from pathlib import Path
foundry_path = Path("C:/eva-foundry/eva-foundation/29-foundry")
sys.path.insert(0, str(foundry_path))
from tools.search import EVASearchClient
```

For veritas audit:
```
MCP tool: audit_repo  repo_path=C:\eva-foundry\30-ui-bench
MCP tool: get_trust_score  repo_path=C:\eva-foundry\30-ui-bench
```

---

## Session Log

### 2026-03-03 -- Initial Prime by agent:copilot

**Activity**: Project primed by foundation-primer workflow.
**Template**: copilot-instructions-template.md v3.1.0
**Governance docs created**: PLAN.md, STATUS.md, ACCEPTANCE.md, README (updated)
**Data model record**: http://localhost:8010/model/projects/30-ui-bench
**Veritas audit**: pending (run audit_repo to establish baseline)

---

## Test / Build State

> Update this section after each test run.

| Command | Status | Last Run |
|---------|--------|----------|
| (add project test command here) | PENDING | (date) |

---

## Blockers

> Log any blockers here with discovery date and resolution.

(none at prime time)

---

## Next Steps

1. Run veritas audit: `audit_repo` MCP tool, repo_path = C:\eva-foundry\30-ui-bench
2. Check data model record: GET /model/projects/30-ui-bench
3. Update PLAN.md with actual sprint stories
4. Fill ACCEPTANCE.md gate table with project-specific criteria
5. Commit first evidence: PUT /model/projects/30-ui-bench with updated notes
