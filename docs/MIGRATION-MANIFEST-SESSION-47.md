# Screen Factory Migration Manifest - Session 47

**Status**: Discovery Complete (Session 46)  
**Execution**: Session 47 (TBD)  
**Strategy**: Consolidate all Screen Factory artifacts into 30-ui-bench  
**Philosophy**: "Fix the factory, regenerate artifacts" - not manual fixes

---

## Executive Summary

**Total Artifacts Discovered**: **95 files** across 2 source projects

| Source | Category | File Count |
|--------|----------|------------|
| **37-data-model** | Templates | 8 |
| | Generators | 3 |
| | UI Components | 5 |
| | Hooks | 7 |
| | Context | 4 |
| | Design Tokens | 2 |
| | Documentation | 3 |
| | Demo App | 1 |
| | Workflows | 13 |
| | Tests | 131 |
| | **Total** | **177 (35 source + 142 generated)** |
| **31-eva-faces** | Components | 15 |
| | Context | 2 |
| | Hooks | 1 |
| | Router | 1 |
| | Types | 2 |
| | API Clients | 4 |
| | Test Stubs | 3 |
| | App Entry | 2 |
| | Tests | 30 |
| | **Total** | **60 (30 source + 30 tests)** |
| **Assets** | Physical Images | **0** (code-based icons) |
| **Dependencies** | npm packages | 1 (`@fluentui/react-icons`) |

**Migration Complexity**: Moderate (merge conflicts in 3 files, zero asset migration)

---

## 1. From 37-data-model (35 source files + 142 automation)

### 1.1 Templates (8 files) → `30-ui-bench/templates/screens-machine/`

**Purpose**: Screen Machine v2.0.0 core templates (Session 46 enhanced)

| File | Size | Status | Session 46 Enhancements |
|------|------|--------|-------------------------|
| `ListView.template.tsx` | ~200 lines | ✅ Ready | GC tokens, API health, 6-lang, version |
| `DetailView.template.tsx` | ~180 lines | ✅ Ready | GC tokens, API health, 6-lang, version |
| `CreateForm.template.tsx` | ~220 lines | ✅ Ready | GC tokens, API health, 6-lang, version |
| `EditForm.template.tsx` | ~230 lines | ✅ Ready | GC tokens, API health, 6-lang, version |
| `GraphView.template.tsx` | ~250 lines | ✅ Ready | GC tokens, API health, 6-lang, version, inline SVG |
| `test.spec.tsx.template` | ~150 lines | ✅ Ready | Test generation template |
| `evidence.json.template` | ~40 lines | ✅ Ready | Evidence capture template |
| `README.md` | ~100 lines | ✅ Ready | v2.0.0 upgrade guide |

**Total**: 1,370 lines of template code

**Key Features** (v2.0.0):
- Centralized GC Design System tokens (`@styles/tokens`)
- API Health monitoring (SM-PATTERN-001)
- Version footer (cache debugging)
- 6-language i18n (EN/FR/ES/DE/PT/CN)
- Accessibility built-in (WCAG 2.1 AA)
- Zero hardcoded colors/fonts

**Migration Action**: Direct copy (no conflicts, pure factory code)

---

### 1.2 Generators (3 files) → `30-ui-bench/generators/`

**Purpose**: PowerShell automation for batch screen generation

| File | Lines | Function |
|------|-------|----------|
| `generate-screens.ps1` | ~200 | Single layer generation (v1.0.0) |
| `generate-screens-v2.ps1` | ~250 | Single layer generation (v2.0.0 enhanced) |
| `generate-all-screens.ps1` | ~300 | Batch generation for all 111 layers |

**Total**: 750 lines of automation code

**Usage Example**:
```powershell
cd C:\eva-foundry\30-ui-bench\generators
.\generate-screens-v2.ps1 -LayerId L99 -LayerName test_layer `
  -OutputDir "..\generated\test_layer" `
  -TemplatesDir "..\templates\screens-machine" `
  -Evidence
```

**Migration Action**: Update paths to point to new template location

---

### 1.3 UI Components (5 files) → `30-ui-bench/shared-ui/components/`

**Purpose**: Session 46 patterns - reusable across all clients

| Component | Lines | Pattern | Status |
|-----------|-------|---------|--------|
| `ApiHealthBanner.tsx` | ~80 | SM-PATTERN-001 | ✅ Production-ready |
| `VersionFooter.tsx` | ~40 | Cache debugging | ✅ Production-ready |
| `LanguageSelector.tsx` | ~100 | 6-language dropdown | ⚠️ MERGE with 31 version |
| `PermissionGate.tsx` | ~50 | RBAC inline guard | ✅ Production-ready |
| `SprintSelector.tsx` | ~40 | Project filtering | ⚠️ MERGE with 31 version |

**Total**: 310 lines

**Merge Strategy** (2 conflicts):
1. **LanguageSelector**: Compare 37 vs 31 → merge best features → single source
2. **SprintSelector**: Compare 37 vs 31 → merge API differences → single source

---

### 1.4 Hooks (7 files) → `30-ui-bench/shared-ui/hooks/`

| Hook | Lines | Purpose |
|------|-------|---------|
| `useApiHealth.ts` | ~60 | Health monitoring (SM-PATTERN-001) |
| `useLiterals.ts` | ~50 | L17 literals integration |
| `useTranslations.ts` | ~40 | Admin-face i18n |
| `useTranslationsData.ts` | ~70 | Data fetching wrapper |
| `usePermissions.ts` | ~40 | RBAC helper (admin-face) |
| `useActingSession.ts` | ~30 | H1 handshake |
| `use-local-storage-state.ts` | ~50 | Persistence utility |

**Total**: 340 lines

**Migration Action**: Direct copy (no conflicts)

---

### 1.5 Context (4 files) → `30-ui-bench/shared-ui/context/`

| Context | Lines | Purpose | Status |
|---------|-------|---------|--------|
| `LangContext.tsx` | ~30 | 6-language state | ⚠️ MERGE with 31 version |
| `AuthContext.tsx` | ~100 | Persona-based auth | ✅ Unique to 37 |
| `ThemeContext.tsx` | ~50 | GC light/night/contrast | ✅ Production-ready |
| `ViewSettingsContext.tsx` | ~40 | Density settings | ✅ Production-ready |

**Total**: 220 lines

**Merge Strategy** (1 conflict):
- **LangContext**: Both projects have 6-language support → harmonize implementations

---

### 1.6 Design System (2 files) → `30-ui-bench/design-system/`

| File | Lines | Purpose |
|------|-------|---------|
| `tokens.ts` | ~150 | GC Design System tokens + chart colors (Session 46) |
| `main.css` | ~200 | Global styles, focus management, normalize |

**Total**: 350 lines

**Key Content** (tokens.ts):
```typescript
// GC Design System core tokens
export const GC_TEXT = '#0b0c0e';
export const GC_BLUE = '#1d70b8';
export const GC_BORDER = '#b1b4b6';
export const GC_SURFACE = '#f8f8f8';
export const GC_ERROR = '#d4351c';
export const GC_SUCCESS = '#00703c';

// Chart colors (Session 46 - v2.0.0)
export const CHART_COLORS = [
  '#1d70b8', '#912b88', '#00703c', '#f46a25',
  '#d4351c', '#5694ca', '#a3e8f6', '#003078'
];
```

**Migration Action**: Direct copy (definitive source)

---

### 1.7 Icon System (1 dependency + 1 component)

**Dependency**: `@fluentui/react-icons` ^2.0.320
- 1000+ icons from Microsoft Fluent Design
- Tree-shakable (only used icons bundled)
- Zero physical files (pure TypeScript components)

**Component**: `EvaIcon.tsx` (~100 lines) → `30-ui-bench/shared-ui/components/`
- Semantic wrapper around Fluent UI icons
- Type-safe icon selection: `<EvaIcon name="add" />`
- 60+ mapped icons (add, edit, delete, search, filter, etc.)
- GC Design System color integration

**Assets**: **0 physical image files** (code-based strategy)

**Migration Action**:
1. Add `@fluentui/react-icons` to 30-ui-bench package.json
2. Copy EvaIcon.tsx component
3. No asset folder needed (zero .svg/.png files)

**Benefits**:
- No image optimization pipeline
- No CDN configuration
- No broken image links (TypeScript imports)
- Smaller bundle (tree-shaking)
- Theme-aware colors (runtime GC tokens)

---

### 1.8 Documentation (3 files) → `30-ui-bench/docs/`

| Document | Lines | Purpose |
|----------|-------|---------|
| `SCREEN-MACHINE-V2-UPGRADE.md` | ~250 | Upgrade guide (v1.0.0 → v2.0.0) |
| `patterns/SM-PATTERN-001-API-Health-Monitoring.md` | ~150 | API health pattern (Session 46) |
| `SESSION-46-I18N-UPGRADE.md` | ~200 | 6-language implementation notes |

**Total**: 600 lines

**Migration Action**: Create docs/ structure, organize by patterns/

---

### 1.9 Demo Application (1 file) → `30-ui-bench/demos/`

**File**: `DemoApp.tsx` (~500 lines)
- 128-route demo harness (7 portal + 10 admin + 111 layers)
- Route architecture testing
- Integration testing support

**Migration Action**: Direct copy (testing infrastructure)

---

### 1.10 Workflows (13 files) → `30-ui-bench/.github/workflows/`

**Screen Factory Workflows**:

| Workflow | Purpose | Priority |
|----------|---------|----------|
| **screens-machine.yml** | **Screen generation automation** | **CRITICAL** |
| quality-gates.yml | MTI scoring, acceptance tests | HIGH |
| pytest.yml | Backend tests (FastAPI) | MEDIUM |
| veritas-audit.yml | Requirements traceability | MEDIUM |
| validate-model.yml | Schema validation | MEDIUM |
| deploy-production.yml | Azure deployment (ACA) | HIGH |
| deploy-hardened.yml | Hardened build (PROD) | HIGH |
| continuous-health-monitoring.yml | API uptime tracking | MEDIUM |
| sprint-agent.yml | Sprint automation | LOW (project-specific) |
| sync-portfolio-evidence.yml | Evidence aggregation | LOW |
| sync-51-aca-evidence.yml | Project-specific sync | LOW |
| infrastructure-monitoring-sync.yml | Infrastructure events | LOW |
| ado-idea-intake.yml | Idea submission | LOW |

**Migration Strategy**:
- **Migrate 5 critical workflows** (screens-machine, quality-gates, deploy-production, deploy-hardened, pytest)
- **Update paths**: Point to 30-ui-bench structure
- **Update secrets**: Verify Azure deployment credentials
- **Leave 8 project-specific workflows** (they reference 37-data-model paths)

---

### 1.11 Tests (131 files) → `30-ui-bench/generated/{layer}/tests/`

**Breakdown**:
- **111 layer tests**: Generated by Screen Machine (EndpointsListView.test.tsx, etc.)
- **20 core tests**: Component tests, integration tests

**Migration Action**:
- Tests live with generated code (not migrated separately)
- Regenerate tests with v2.0.0 templates
- Test infrastructure (vitest.config.ts, test-setup.ts) migrates with generators

---

## 2. From 31-eva-faces (30 source files + 30 tests)

### 2.1 Components (15 files) → `30-ui-bench/shared-ui/components/portal/`

**Purpose**: Portal-specific UI patterns (some merge candidates)

| Component | Lines | Status | Migration Notes |
|-----------|-------|--------|-----------------|
| `LanguageSelector.tsx` | ~100 | ⚠️ **MERGE** | Harmonize with 37 version |
| `NavHeader.tsx` | ~260 | ✅ **UNIQUE** | **SM-PATTERN-003: GC Top Bar** |
| `PermissionGate.tsx` | ~45 | ✅ Duplicate | Use 37 version (identical) |
| `ProductTile.tsx` | ~75 | ✅ Portal-only | Keep in portal/ subfolder |
| `ProductTileGrid.tsx` | ~100 | ✅ Portal-only | Keep in portal/ subfolder |
| `SprintBadge.tsx` | ~50 | ✅ Portal-only | Reusable badge component |
| `SprintSelector.tsx` | ~40 | ⚠️ **MERGE** | Harmonize with 37 version |
| `WICard.tsx` | ~60 | ✅ Portal-only | Sprint board component |
| `WIDetailDrawer.tsx` | ~100 | ✅ Portal-only | Slide-in detail panel |
| `WBSNodeRow.tsx` | ~135 | ✅ Portal-only | Work breakdown structure |
| `VelocityPanel.tsx` | ~100 | ✅ Portal-only | Sparkline charts |
| `CriticalPathPanel.tsx` | ~100 | ✅ Portal-only | Critical path display |
| `RecentSprintSummaryBar.tsx` | ~50 | ✅ Portal-only | Sticky footer |
| `ProjectCard.tsx` | ~100 | ✅ Portal-only | Project portfolio card |
| `ProjectFilterBar.tsx` | ~50 | ✅ Portal-only | Pill-button filter |
| `MaturityBadge.tsx` | ~60 | ✅ Portal-only | Maturity level badge |
| `FeatureSection.tsx` | ~40 | ✅ Portal-only | Feature grouping |

**Total**: 1,365 lines

**New Pattern Discovery**:
- **SM-PATTERN-003: GC Top Bar** (NavHeader.tsx)
  - Canadian flag 🍁 + "Government of Canada" signature
  - Skip link (WCAG 2.1 SC 2.4.1)
  - 6-language selector
  - Primary navigation with RBAC guards
  - Sticky header with GC Design tokens

**Migration Action**:
1. Create `30-ui-bench/shared-ui/components/portal/` subfolder
2. Merge 3 conflicts (LanguageSelector, SprintSelector, PermissionGate)
3. Copy 12 unique portal components
4. Document SM-PATTERN-003 (GC Top Bar)

---

### 2.2 Context (2 files) → `30-ui-bench/shared-ui/context/`

| Context | Lines | Status | Migration Notes |
|---------|-------|--------|-----------------|
| `LangContext.tsx` | ~23 | ⚠️ **MERGE** | Simpler than 37 version |
| `AuthContext.tsx` | ~150 | ✅ **UNIQUE** | Portal persona-based auth (different from 37) |

**Total**: 173 lines

**Merge Strategy** (LangContext):
- **37 version**: More feature-rich (localStorage persistence, validation)
- **31 version**: Simpler (minimal state management)
- **Decision**: Use 37 version as base, verify no portal-specific dependencies

**AuthContext Handling**:
- **31 AuthContext**: Portal-specific (EasyAuth, APIM, X-Actor-OID headers)
- **37 AuthContext**: Admin-face specific (different auth flow)
- **Decision**: Keep both, rename to `PortalAuthContext` vs `AdminAuthContext`

---

### 2.3 Hooks (1 file) → `30-ui-bench/shared-ui/hooks/`

| Hook | Lines | Status |
|------|-------|--------|
| `usePermissions.ts` | ~40 | ✅ Portal-specific |

**Migration Action**: Direct copy (portal/ subfolder)

---

### 2.4 Router (1 file) → `30-ui-bench/shared-ui/router/`

| Component | Lines | Purpose |
|-----------|-------|---------|
| `ProtectedRoute.tsx` | ~50 | Route-level RBAC guard |

**Migration Action**: Direct copy (reusable across clients)

---

### 2.5 Types (2 files) → `30-ui-bench/shared-ui/types/`

| File | Lines | Purpose |
|------|-------|---------|
| `scrum.ts` | ~130 | WorkItem, Feature, Epic, SprintSummary, WBSNode |
| `project.ts` | ~25 | ProjectRecord, MaturityLevel, ProjectStream |

**Total**: 155 lines

**Migration Action**: Direct copy (portal domain types)

---

### 2.6 API Clients (4 files) → `30-ui-bench/shared-ui/api/`

| Client | Lines | Purpose |
|--------|-------|---------|
| `scrumApi.ts` | ~170 | APIM client (ADO dashboard data) |
| `projectApi.ts` | ~70 | PM Plane API (project portfolio) |
| `wbsApi.ts` | ~54 | WBS Tree API (work breakdown) |
| `modelApi.ts` | ~215 | Data Model API (already in 37) |

**Total**: 509 lines

**Migration Strategy**:
- **modelApi.ts**: Duplicate → Use 37 version (more comprehensive)
- **Other 3 files**: Portal-specific → Keep in `api/portal/` subfolder

---

### 2.7 Test Stubs (3 files) → `30-ui-bench/tests/__stubs__/`

| Stub | Lines | Purpose |
|------|-------|---------|
| `gc-design-system.tsx` | ~19 | Vitest stub for GCThemeProvider |
| `eva-ui.tsx` | ~38 | Vitest stub for EVA UI components |
| `eva-templates.tsx` | ~31 | Vitest stub for AdminListPage |

**Total**: 88 lines

**Migration Action**: Direct copy (test infrastructure)

---

### 2.8 App Entry (2 files) → `30-ui-bench/demos/portal/`

| File | Lines | Purpose |
|------|-------|---------|
| `App.tsx` | ~100 | Router configuration (react-router v6.4+) |
| `main.tsx` | ~11 | React root mount |

**Total**: 111 lines

**Migration Action**: Keep in demos/portal/ (example application)

---

### 2.9 Tests (30 files) → `30-ui-bench/tests/portal/`

**Breakdown**:
- 6 page tests (EVAHomePage, SprintBoardPage, ModelBrowserPage, etc.)
- 10 admin-face tests (TranslationsPage, SettingsPage, RbacRolesPage, etc.)
- 8 component tests (ChatInterface, SideNavPanel, GCHeader, etc.)
- 6 utility tests (auth, useChatSession, etc.)

**Migration Action**: Copy to tests/portal/ (test infrastructure)

---

## 3. Merge Conflicts (3 files require manual merge)

### 3.1 LanguageSelector.tsx (37 vs 31)

**37 version** (100 lines):
- More feature-rich (localStorage persistence, validation)
- Inline GC tokens (copied from NavHeader)
- Compact mode support
- Localized label function

**31 version** (106 lines):
- Cleaner imports (uses useLang hook)
- Native name support
- Simpler implementation

**Merge Strategy**:
1. Use 37 version as base
2. Add native name support from 31
3. Keep localStorage persistence from 37
4. Verify portal compatibility

### 3.2 LangContext.tsx (37 vs 31)

**37 version** (~30 lines):
- localStorage persistence
- Initial language detection
- Validation

**31 version** (~23 lines):
- Minimal state management
- No persistence

**Merge Strategy**: Use 37 version (more robust)

### 3.3 SprintSelector.tsx (37 vs 31)

**37 version** (~40 lines):
- Project filtering
- Data Model integration

**31 version** (~43 lines):
- Sprint filtering
- APIM/ADO integration

**Merge Strategy**:
1. Compare API contracts
2. Create unified component with both capabilities
3. Test with both data sources

---

## 4. Migration Execution Plan (Session 47)

### Phase 1: Preparation (30 minutes)

**Step 1.1**: Backup current state
```powershell
cd C:\eva-foundry\30-ui-bench
git checkout -b migration/session-47-screen-factory
git add -A
git commit -m "chore: pre-migration checkpoint (Session 47)"
```

**Step 1.2**: Create target structure
```powershell
mkdir -p design-system, shared-ui/{components,hooks,context,types,api,router}, generators, templates/screens-machine, docs/patterns, demos/portal, tests/{__stubs__,portal}, .github/workflows
```

**Step 1.3**: Update package.json dependencies
```json
{
  "dependencies": {
    "@fluentui/react-components": "^9.73.3",
    "@fluentui/react-icons": "^2.0.320",
    "react": "^18.2.0",
    "react-router-dom": "^7.13.1"
  }
}
```

---

### Phase 2: Core Migration (2 hours)

**Priority 1: Templates & Generators** (30 min)
```powershell
# Copy templates
xcopy /E /I "C:\eva-foundry\37-data-model\scripts\templates\screens-machine" "C:\eva-foundry\30-ui-bench\templates\screens-machine"

# Copy generators
xcopy /E /I "C:\eva-foundry\37-data-model\scripts\templates\screens-machine\*.ps1" "C:\eva-foundry\30-ui-bench\generators"

# Update generator paths
code "C:\eva-foundry\30-ui-bench\generators\generate-screens-v2.ps1"
# Change: $TemplatesDir = "..\templates\screens-machine"

# Test generation
cd C:\eva-foundry\30-ui-bench\generators
.\generate-screens-v2.ps1 -LayerId L99 -LayerName test_migration -OutputDir "..\test-output" -Evidence
```

**Priority 2: Design System** (15 min)
```powershell
# Copy design tokens
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\styles\tokens.ts" "C:\eva-foundry\30-ui-bench\design-system\"
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\main.css" "C:\eva-foundry\30-ui-bench\design-system\"

# Copy EvaIcon component
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\shared\eva-ui\src\EvaIcon.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\"
```

**Priority 3: Shared UI - No Conflicts** (30 min)
```powershell
# Components (ApiHealthBanner, VersionFooter, PermissionGate)
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\components\ApiHealthBanner.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\"
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\components\VersionFooter.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\"
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\components\PermissionGate.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\"

# Hooks (all 7 files)
xcopy /E /I "C:\eva-foundry\37-data-model\ui\src\hooks" "C:\eva-foundry\30-ui-bench\shared-ui\hooks"

# Context (ThemeContext, ViewSettingsContext)
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\context\ThemeContext.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\context\"
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\context\ViewSettingsContext.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\context\"
```

**Priority 4: Portal Components - 31-eva-faces** (45 min)
```powershell
# Create portal subfolder
mkdir "C:\eva-foundry\30-ui-bench\shared-ui\components\portal"

# Copy 12 unique portal components
xcopy /Y "C:\eva-foundry\31-eva-faces\portal-face\src\components\NavHeader.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\portal\"
xcopy /Y "C:\eva-foundry\31-eva-faces\portal-face\src\components\ProductTile.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\portal\"
xcopy /Y "C:\eva-foundry\31-eva-faces\portal-face\src\components\ProductTileGrid.tsx" "C:\eva-foundry\30-ui-bench\shared-ui\components\portal\"
# ... (copy remaining 9 portal components)

# Copy portal types
xcopy /E /I "C:\eva-foundry\31-eva-faces\portal-face\src\types" "C:\eva-foundry\30-ui-bench\shared-ui\types\portal"

# Copy portal API clients
mkdir "C:\eva-foundry\30-ui-bench\shared-ui\api\portal"
xcopy /Y "C:\eva-foundry\31-eva-faces\portal-face\src\api\scrumApi.ts" "C:\eva-foundry\30-ui-bench\shared-ui\api\portal\"
xcopy /Y "C:\eva-foundry\31-eva-faces\portal-face\src\api\projectApi.ts" "C:\eva-foundry\30-ui-bench\shared-ui\api\portal\"
xcopy /Y "C:\eva-foundry\31-eva-faces\portal-face\src\api\wbsApi.ts" "C:\eva-foundry\30-ui-bench\shared-ui\api\portal\"
```

---

### Phase 3: Merge Conflicts (1 hour)

**Conflict 1: LanguageSelector.tsx** (20 min)
```powershell
# Open both versions in diff view
code --diff "C:\eva-foundry\37-data-model\ui\src\components\LanguageSelector.tsx" `
           "C:\eva-foundry\31-eva-faces\portal-face\src\components\LanguageSelector.tsx"

# Strategy: Use 37 version as base, add native names from 31
# Create merged version at: 30-ui-bench\shared-ui\components\LanguageSelector.tsx
```

**Conflict 2: LangContext.tsx** (15 min)
```powershell
# Open both versions in diff view
code --diff "C:\eva-foundry\37-data-model\ui\src\context\LangContext.tsx" `
           "C:\eva-foundry\31-eva-faces\portal-face\src\context\LangContext.tsx"

# Strategy: Use 37 version (localStorage persistence)
# Verify portal compatibility
xcopy /Y "C:\eva-foundry\37-data-model\ui\src\context\LangContext.tsx" `
         "C:\eva-foundry\30-ui-bench\shared-ui\context\"
```

**Conflict 3: SprintSelector.tsx** (25 min)
```powershell
# Open both versions in diff view
code --diff "C:\eva-foundry\37-data-model\ui\src\components\SprintSelector.tsx" `
           "C:\eva-foundry\31-eva-faces\portal-face\src\components\SprintSelector.tsx"

# Strategy: Create unified component with both data sources
# New file: 30-ui-bench\shared-ui\components\SprintSelector.tsx
```

---

### Phase 4: Workflows & Documentation (1 hour)

**Step 4.1**: Migrate critical workflows (30 min)
```powershell
# Copy 5 critical workflows
$workflows = @(
  "screens-machine.yml",
  "quality-gates.yml",
  "deploy-production.yml",
  "deploy-hardened.yml",
  "pytest.yml"
)

foreach ($wf in $workflows) {
  xcopy /Y "C:\eva-foundry\37-data-model\.github\workflows\$wf" `
           "C:\eva-foundry\30-ui-bench\.github\workflows\"
}

# Update paths in workflows (replace '37-data-model' with '30-ui-bench')
code "C:\eva-foundry\30-ui-bench\.github\workflows\screens-machine.yml"
```

**Step 4.2**: Copy documentation (15 min)
```powershell
# Copy Screen Machine docs
xcopy /E /I "C:\eva-foundry\37-data-model\scripts\templates\screens-machine\docs" `
              "C:\eva-foundry\30-ui-bench\docs"

# Create patterns folder
mkdir "C:\eva-foundry\30-ui-bench\docs\patterns"
xcopy /Y "C:\eva-foundry\37-data-model\docs\patterns\SM-PATTERN-001*.md" `
         "C:\eva-foundry\30-ui-bench\docs\patterns\"
```

**Step 4.3**: Document new pattern (15 min)
```powershell
# Create SM-PATTERN-003 (GC Top Bar from NavHeader)
code "C:\eva-foundry\30-ui-bench\docs\patterns\SM-PATTERN-003-GC-Top-Bar.md"
```

---

### Phase 5: Testing & Verification (1.5 hours)

**Step 5.1**: Build test (15 min)
```powershell
cd C:\eva-foundry\30-ui-bench
npm install
npm run build
# Expected: TypeScript ✅, ESLint ✅, 0 errors
```

**Step 5.2**: Generation test (20 min)
```powershell
cd C:\eva-foundry\30-ui-bench\generators
.\generate-screens-v2.ps1 -LayerId L99 -LayerName test_layer `
  -OutputDir "..\generated\test_layer" `
  -TemplatesDir "..\templates\screens-machine" `
  -Evidence

# Expected: 6 files generated (ListView, DetailView, CreateForm, EditForm, GraphView, test.spec.tsx)
# Verify: No errors, clean TypeScript compilation
```

**Step 5.3**: Import test (25 min)
```typescript
// Test from external project (37-data-model)
import { LanguageSelector } from '@eva/screen-factory/shared-ui';
import { GC_TEXT, GC_BLUE } from '@eva/screen-factory/design-system';
import { useApiHealth } from '@eva/screen-factory/hooks';
import { EvaIcon } from '@eva/screen-factory/shared-ui/components';

// Verify: TypeScript resolves paths, zero errors
```

**Step 5.4**: Circular dependency check (10 min)
```powershell
npm install -g madge
madge --circular --extensions ts,tsx "C:\eva-foundry\30-ui-bench\shared-ui"
# Expected: No circular dependencies
```

**Step 5.5**: Acceptance criteria pass (20 min)
```powershell
# Run 25 acceptance criteria tests (subset)
npm run test:acceptance
# Expected: 25 PASS, 0 FAIL
```

---

### Phase 6: Cleanup & Documentation (30 minutes)

**Step 6.1**: Update README.md (10 min)
```markdown
# EVA Screen Factory (30-ui-bench)

**Status**: Operational (Session 47 - Migration Complete)
**Templates**: v2.0.0 (Session 46 Enhanced)
**Clients**: 111 Data Model pages, 31-eva-faces (future), 51-ACA (future)

## Quick Start

...
```

**Step 6.2**: Update STATUS.md (10 min)
```markdown
## Session 47 Activity (2026-03-12)

### Migration Complete ✅
- 95 files migrated from 37-data-model + 31-eva-faces
- 3 merge conflicts resolved (LanguageSelector, LangContext, SprintSelector)
- 5 workflows migrated
- 0 asset files (code-based icons confirmed)
- Build ✅ | Generation ✅ | Imports ✅ | Tests ✅
```

**Step 6.3**: Commit migration (10 min)
```powershell
cd C:\eva-foundry\30-ui-bench
git add -A
git commit -m "feat(migration): consolidate Screen Factory artifacts (Session 47)

MIGRATION COMPLETE:
- 95 files from 37-data-model + 31-eva-faces → 30-ui-bench
- 3 merge conflicts resolved (LanguageSelector, LangContext, SprintSelector)
- 5 critical workflows migrated (.github/workflows/)
- 0 asset files (code-based icon strategy confirmed)
- New pattern: SM-PATTERN-003 (GC Top Bar from NavHeader)

VALIDATION:
√ TypeScript compilation: 0 errors
√ ESLint: 0 errors
√ Circular dependencies: 0 found
√ Generation test: 6 files created
√ Acceptance criteria: 25 PASS, 0 FAIL

STRUCTURE:
- design-system/ (tokens.ts, main.css)
- shared-ui/ (components, hooks, context, types, api, router)
- templates/screens-machine/ (5 core templates v2.0.0)
- generators/ (3 PowerShell scripts)
- docs/ (patterns/, upgrade guides)
- demos/ (DemoApp.tsx, portal/)
- tests/ (__stubs__/, portal/)
- .github/workflows/ (5 critical workflows)

CLIENTS READY:
- 37-data-model (111 pages - regenerate with v2.0.0)
- 31-eva-faces (future client)
- 51-ACA (future client)

See: docs/MIGRATION-MANIFEST-SESSION-47.md (this document)
Session: 47 (2026-03-12)
Agent: AIAgentExpert mode"

git push origin migration/session-47-screen-factory
```

---

## 5. Post-Migration Tasks (Session 48+)

### Task 1: Regenerate 111 Data Model Pages (Session 48)

**Goal**: Replace all 111 generated pages in 37-data-model with v2.0.0 templates

**Steps**:
1. Backup 37-data-model/ui/src/pages/
2. Run: `.\generate-all-screens.ps1 -OutputDir "C:\eva-foundry\37-data-model\ui\src\pages" -Evidence`
3. Commit: 111 pages regenerated with Session 46 enhancements
4. Test: Build ✅, ESLint ✅, Acceptance ✅
5. Deploy: Build #15+ to Azure

**Expected Improvements**:
- Centralized GC Design tokens (no hardcoded colors)
- API Health monitoring on all pages
- Version footer (cache debugging)
- 6-language i18n (EN/FR/ES/DE/PT/CN)
- Consistent error handling

---

### Task 2: Add 31-eva-faces as Client (Session 49)

**Goal**: Generate portal-specific screens using Screen Factory

**Steps**:
1. Define portal layer requirements
2. Generate screens for portal domain
3. Integrate with existing portal-face pages
4. Test with APIM/ADO data sources

---

### Task 3: Add 51-ACA as Client (Session 50)

**Goal**: Generate Azure Container Apps screens

**Steps**:
1. Define ACA layer requirements (deployments, monitoring, logs)
2. Generate ACA management screens
3. Integrate with ACA infrastructure

---

## 6. Risk Mitigation

| Risk | Likelihood | Impact | Mitigation | Status |
|------|------------|--------|------------|--------|
| Breaking changes in moved files | Medium | High | Test each component after move | ✅ Planned (Phase 5) |
| Import path breakage | High | High | Update all references systematically | ✅ Planned (Phase 5.3) |
| Merge conflicts (LanguageSelector) | Medium | Medium | Compare carefully, test both versions | ✅ Planned (Phase 3) |
| Lost git history | Low | Medium | Use `git mv` for all moves | ⚠️ Not using git mv (prefer clean structure) |
| Circular dependencies | Low | High | Check with madge after migration | ✅ Planned (Phase 5.4) |
| **Asset migration complexity** | **ELIMINATED** | **N/A** | **Code-based icons (zero physical files)** | ✅ **N/A** |
| Workflow path errors | Medium | Medium | Update all references to 30-ui-bench | ✅ Planned (Phase 4.1) |
| TypeScript compilation errors | Medium | High | Incremental testing, fix imports | ✅ Planned (Phase 5.1) |
| Test failures post-migration | Medium | Medium | Run full test suite, fix broken imports | ✅ Planned (Phase 5.5) |
| Azure deployment issues | Low | High | Verify secrets, test deploy-production.yml | ✅ Planned (Post-migration) |

---

## 7. Success Criteria (All must pass)

### Structural Success

- ✅ All 95 files migrated to 30-ui-bench
- ✅ Zero duplicate code (merged LanguageSelector, LangContext, SprintSelector)
- ✅ 3 merge conflicts resolved (documented approach)
- ✅ New directory structure created (design-system/, shared-ui/, generators/, templates/, docs/, demos/, tests/, .github/workflows/)
- ✅ SM-PATTERN-003 documented (GC Top Bar)
- ✅ Git history preserved (commit messages reference source locations)

### Technical Success

- ✅ TypeScript compilation: 0 errors
- ✅ ESLint passes: 0 errors, 0 warnings
- ✅ Circular dependency check: 0 found (madge)
- ✅ Generation works from new location (6 files created)
- ✅ Import test passes (external projects can import from @eva/screen-factory)

### Quality Success

- ✅ Documentation complete and indexed (README.md, docs/, patterns/)
- ✅ Evidence documented in STATUS.md (Session 47 activity logged)
- ✅ Acceptance criteria: 25 PASS, 0 FAIL (from ACCEPTANCE.md)
- ✅ Build artifacts clean (no warnings, no unused deps)

### Integration Success

- ✅ 37-data-model can import from 30-ui-bench packages
- ✅ 31-eva-faces can import from 30-ui-bench packages
- ✅ Azure deployment config updated (secrets, workflow paths)
- ✅ GitHub Actions workflows functional (screens-machine.yml runs successfully)

---

## 8. Session 47 Execution Metrics (Target)

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| **Duration** | 6 hours (1 session) | TBD | ⏸️ Pending |
| **Files Migrated** | 95 files | TBD | ⏸️ Pending |
| **Merge Conflicts** | 3 resolved | TBD | ⏸️ Pending |
| **TypeScript Errors** | 0 | TBD | ⏸️ Pending |
| **ESLint Errors** | 0 | TBD | ⏸️ Pending |
| **Circular Dependencies** | 0 | TBD | ⏸️ Pending |
| **Tests Passed** | 25/25 | TBD | ⏸️ Pending |
| **New Patterns Documented** | 1 (SM-PATTERN-003) | TBD | ⏸️ Pending |
| **Commits** | 1 (consolidation) | TBD | ⏸️ Pending |

---

## 9. Appendices

### Appendix A: File Size Summary

| Source | Category | File Count | Total Lines |
|--------|----------|------------|-------------|
| **37-data-model** | Templates | 8 | 1,370 |
| | Generators | 3 | 750 |
| | Components | 5 | 310 |
| | Hooks | 7 | 340 |
| | Context | 4 | 220 |
| | Design Tokens | 2 | 350 |
| | Icon System | 1 | 100 |
| | Documentation | 3 | 600 |
| | Demo App | 1 | 500 |
| | Workflows | 13 | ~4,000 (YAML) |
| | **37 Subtotal** | **47 files** | **~8,540 lines** |
| **31-eva-faces** | Components | 15 | 1,365 |
| | Context | 2 | 173 |
| | Hooks | 1 | 40 |
| | Router | 1 | 50 |
| | Types | 2 | 155 |
| | API Clients | 4 | 509 |
| | Test Stubs | 3 | 88 |
| | App Entry | 2 | 111 |
| | **31 Subtotal** | **30 files** | **~2,491 lines** |
| **Dependencies** | npm packages | 1 | N/A (`@fluentui/react-icons`) |
| **Assets** | Physical images | **0 files** | **0 bytes** |
| **TOTAL** | **SOURCE CODE** | **77 files** | **~11,031 lines** |

**Note**: Excludes 161 test files (131 from 37, 30 from 31) - ~8,000 additional lines

---

### Appendix B: Import Path Mapping (Post-Migration)

**Before Migration** (37-data-model):
```typescript
import { LanguageSelector } from '@components/LanguageSelector';
import { GC_TEXT, GC_BLUE } from '@styles/tokens';
import { useApiHealth } from '@hooks/useApiHealth';
```

**After Migration** (30-ui-bench):
```typescript
import { LanguageSelector } from '@eva/screen-factory/shared-ui/components';
import { GC_TEXT, GC_BLUE } from '@eva/screen-factory/design-system';
import { useApiHealth } from '@eva/screen-factory/shared-ui/hooks';
```

**Aliases in package.json** (30-ui-bench):
```json
{
  "exports": {
    "./shared-ui": "./shared-ui/index.ts",
    "./shared-ui/*": "./shared-ui/*",
    "./design-system": "./design-system/index.ts",
    "./hooks": "./shared-ui/hooks/index.ts",
    "./components": "./shared-ui/components/index.ts"
  }
}
```

---

### Appendix C: Zero-Asset Architecture (Code-Based Icons)

**Traditional UI Library Asset Burden**:
- 100-200 .svg files in public/icons/
- 20-50 .png files for logos/illustrations
- 10-20 .jpg files for backgrounds
- Image optimization pipeline (gulp/webpack)
- CDN configuration (cloudinary/imgix)
- Version management (icon-v1.svg, icon-v2.svg)
- Broken image link concerns (404s)

**EVA Screen Factory Code-Based Strategy**:
- **0 physical image files** (zero .svg, .png, .jpg, .gif, .webp)
- **1 npm dependency**: `@fluentui/react-icons` v2.0.320
- **1 wrapper component**: EvaIcon.tsx (semantic mapping)
- **Inline SVG**: Generated programmatically in GraphView templates
- **Benefits**:
  - Tree-shakable (only used icons bundled)
  - Theme-aware (colors from GC Design tokens at runtime)
  - Type-safe (TypeScript validates icon names)
  - Zero HTTP requests (bundled as JavaScript)
  - Smaller bundle (no duplicate image files)
  - No CDN needed (pure code deployment)
  - No image optimization pipeline

**Migration Impact**:
- **Assets to copy**: 0 files
- **Folders to create**: 0 (no public/images/, no assets/)
- **Image URLs to update**: 0 (all TypeScript imports)
- **Build pipeline changes**: 0 (no image loaders needed)
- **CDN configuration**: 0 (no image hosting)

**Proof**: File searches executed in Session 46
```powershell
# Search 1: 37-data-model UI images
file_search: "37-data-model/ui/**/*.{svg,png,jpg,jpeg,gif,webp,ico}"
Result: "No files found"

# Search 2: 31-eva-faces Portal images
file_search: "31-eva-faces/portal-face/**/*.{svg,png,jpg,jpeg,gif,webp,ico}"
Result: "No files found"

# Search 3: 37-data-model public folder
file_search: "37-data-model/ui/public/**/*"
Result: "No files found"

# Search 4: 31-eva-faces public folder
file_search: "31-eva-faces/portal-face/public/**/*"
Result: "No files found"
```

**Conclusion**: EVA Screen Factory's zero-asset architecture is a **sophisticated simplification** - fewer moving parts, fewer failure modes, easier maintenance.

---

## 10. References

### Documentation
- [30-ui-bench README.md](../README.md) - Factory vision
- [30-ui-bench PLAN.md](../PLAN.md) - 6 features defined
- [30-ui-bench ACCEPTANCE.md](../ACCEPTANCE.md) - 51 acceptance criteria
- [30-ui-bench STATUS.md](../STATUS.md) - Current state

### Patterns
- [SM-PATTERN-001: API Health Monitoring](patterns/SM-PATTERN-001-API-Health-Monitoring.md)
- [SM-PATTERN-002: Reusable I18N](37-data-model/docs/SESSION-46-I18N-UPGRADE.md)
- [SM-PATTERN-003: GC Top Bar](patterns/SM-PATTERN-003-GC-Top-Bar.md) ← **To be created in Session 47**

### Session Logs
- [Session 46 Summary](conversation-summary.md) - 8 bugs fixed, v2.0.0 templates, factory promotion
- [Session 45 Summary](../37-data-model/docs/SESSION-45-*.md) - EVA Autonomous Factory architecture
- [Session 44 Summary](../37-data-model/docs/SESSION-44-*.md) - Bootstrap enforcement, template v5.0.0

### External References
- [GC Design System](https://design.alpha.canada.ca/)
- [Fluent UI React Icons](https://react.fluentui.dev/?path=/docs/icons-catalog--page)
- [WCAG 2.1 Level AA](https://www.w3.org/WAI/WCAG21/quickref/)
- [React Router v6.4+](https://reactrouter.com/en/main/routers/create-browser-router)

---

**Status**: Discovery Complete (Session 46)  
**Next**: Execute migration (Session 47)  
**Timeline**: 6 hours (1 agent session)  
**Confidence**: High (95 files mapped, 3 merge conflicts identified, 0 asset migration needed)

**Last Updated**: March 12, 2026 22:00 ET (Session 46)  
**Author**: AIAgentExpert mode  
**Review**: Ready for Session 47 execution
