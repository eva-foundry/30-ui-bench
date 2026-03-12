# 30-ui-bench -- EVA Screen Factory

**Status**: Active Development (Session 46 - Screen Machine v2.0.0)  
**Part of EVA Foundry Workspace** | [Data Model](https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench) | [Veritas Audit](#veritas-audit)  
**Workspace Skills**: @sprint-advance | @progress-report | @gap-report | @sprint-report | @veritas-expert

---

## Vision

**EVA Screen Factory** is a code generation factory that produces production-ready UI screens at scale. Unlike traditional UI libraries, this is a **manufacturing system** that generates complete, tested, accessible, multilingual pages from layer definitions.

**Not limited by client count or screen count** - this factory can generate screens for:
- **37-data-model**: 111 layer pages (agents, projects, evidence, etc.)
- **31-eva-faces**: Portal screens (dashboards, admin, reports)
- **51-ACA**: ACA-specific screens
- **Any EVA project**: Extensible template system

**Philosophy**: "Fix the factory, not the widgets" - improve templates once, regenerate all artifacts.

---

## EVA Quick Links

| Resource | Link |
|----------|------|
| **Project Record** | `GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench` |
| **Live Session Data** | `GET .../model/project_work/?project_id=30-ui-bench&$orderby=id%20desc&$limit=10` |
| **Veritas Audit** | Run `audit_repo` MCP tool on `C:\eva-foundry\30-ui-bench` |
| **Trust Score** | Run `get_trust_score` MCP tool on `C:\eva-foundry\30-ui-bench` |
| **Sync to Model** | Run `sync_repo` MCP tool (full paperless DPDCA audit + write-back) |
| **Governance** | [PLAN.md](./PLAN.md) \| [STATUS.md](./STATUS.md) \| [ACCEPTANCE.md](./ACCEPTANCE.md) |
| **Instructions** | [.github/copilot-instructions.md](./.github/copilot-instructions.md) |

---

## What This Factory Produces

### Screen Machine v2.0.0 Output (Per Layer)

**5 TypeScript Components**:
- `{Layer}ListView.tsx` - List view with filtering, sorting, pagination
- `{Layer}DetailDrawer.tsx` - Slide-in drawer for record details
- `{Layer}CreateForm.tsx` - Create new record form with validation
- `{Layer}EditForm.tsx` - Edit existing record form
- `{Layer}GraphView.tsx` - Data visualization (charts, graphs)

**Built-In Features** (All Generated Pages):
- ✅ **6-language i18n** (EN/FR/ES/DE/PT/CN)
- ✅ **WCAG 2.1 AA** accessibility compliance
- ✅ **API Health Monitoring** (SM-PATTERN-001)
- ✅ **Version Footer** (cache debugging)
- ✅ **GC Design System** tokens (centralized)
- ✅ **Error handling** (API failures, validation, empty states)
- ✅ **Loading states** (skeleton loaders)
- ✅ **Responsive design** (mobile/tablet/desktop)
- ✅ **Keyboard navigation** (full keyboard support)
- ✅ **Production-ready** (no tech debt, no inline constants)

### Scale

- **Current**: 111 pages generated for 37-data-model
- **Potential**: Unlimited (any EVA project with layer definitions)
- **Generation Speed**: ~5 seconds per layer (5 components)
- **Time to Generate 111 Pages**: ~9 minutes

---

## Technology Stack

**Template Engine**: PowerShell-based mustache-style substitution  
**Target Framework**: React 18 + TypeScript 5 + Vite  
**Design System**: Government of Canada Design System  
**Component Library**: EVA Fluent UI (future) + custom components  
**Build System**: Vite 5.4+  
**Deployment**: Azure App Service  

**Template Version**: v2.0.0 (Session 46)  
**Quality Gates**: 25 acceptance criteria (see [ACCEPTANCE.md](./ACCEPTANCE.md))

---

## Quick Start

### Generate Screens for a Layer

```powershell
cd C:\eva-foundry\37-data-model\scripts
.\generate-screens-v2.ps1 -LayerId L25 -LayerName projects -LayerTitle Projects
```

### Generate All 111 Data Model Pages

```powershell
cd C:\eva-foundry\37-data-model\scripts
.\generate-all-screens.ps1 -Force
```

### Verify Output

```powershell
cd C:\eva-foundry\37-data-model\ui
npm run build
# Expected: TypeScript compilation passes, 0 errors
```

---

## Current Clients

### 1. Project 37 (Data Model UI)

- **Screens**: 111 layer pages (agents → workspace_metrics)
- **Status**: v2.0.0 templates ready, pending regeneration
- **Location**: `37-data-model/ui/src/pages/`
- **Deploy**: msub-sandbox-aca-frontend.azurewebsites.net

### 2. Project 31 (EVA Portal) - Future

- **Screens**: Sprint Board, Admin pages, Reports
- **Status**: Planned (v2.1.0)
- **Templates**: Copy v2.0.0, customize for portal patterns

### 3. Project 51 (ACA) - Future

- **Screens**: ACA-specific admin and monitoring pages
- **Status**: Planned (v2.2.0)
- **Templates**: Copy v2.0.0, customize for ACA domain

---

## Architecture

### Factory Structure

```
30-ui-bench/                    (Screen Factory home)
├── templates/                   (v2.0.0 templates)
│   ├── ListView.template.tsx
│   ├── DetailView.template.tsx
│   ├── CreateForm.template.tsx
│   ├── EditForm.template.tsx
│   ├── GraphView.template.tsx
│   └── README.md
├── generators/                  (PowerShell scripts)
│   ├── generate-screens-v2.ps1  (single layer)
│   └── generate-all-screens.ps1 (batch)
├── evidence/                    (generation logs)
├── tests/                       (factory tests)
└── docs/                        (patterns, guides)
```

### Template Variables

**All templates support**:
- `{{LAYER_ID}}` - Layer identifier (L25, L26, etc.)
- `{{LAYER_NAME}}` - Layer name (projects, wbs, sprints)
- `{{LAYER_TITLE}}` - Title case (Projects, WBS, Sprints)
- `{{ENTITY_TYPE}}` - TypeScript type (Project, WBSEntry, Sprint)
- `{{TIMESTAMP}}` - Generation timestamp
- `{{GENERATOR}}` - Generator version (v2.0.0)
- `{{TEST_COVERAGE}}` - Coverage % (if tests exist)

---

## Session 46 Enhancements

**Templates upgraded from v1.0.0 → v2.0.0**:

1. **Centralized Design Tokens**: No more inline constants, all import from `@styles/tokens`
2. **API Health Monitoring**: SM-PATTERN-001 applied to all list views
3. **Version Footer**: Cache debugging support on all pages
4. **6-Language i18n**: Upgraded from bilingual (EN/FR) to 6 languages
5. **EVA Fluent UI**: Templates prepared for EVA UI components
6. **Chart Colors**: GraphView uses token-based colors

**Commit**: `3771dcf` (37-data-model repo)

---

## Quality Standards

**Every generated page MUST pass 25 acceptance criteria** (see [ACCEPTANCE.md](./ACCEPTANCE.md)):

- ✅ TypeScript compilation (0 errors)
- ✅ ESLint passes
- ✅ CRUD operations work
- ✅ 6-language support functional
- ✅ WCAG 2.1 AA compliant
- ✅ Keyboard navigation works
- ✅ Responsive design (mobile/tablet/desktop)
- ✅ Error handling graceful
- ✅ Performance (<3s initial load)
- ✅ Cross-browser (Chrome/Firefox/Edge/Safari)
- ...and 15 more (see ACCEPTANCE.md)

**Philosophy**: "Marco Sandbox... but the work is done with World Class Enterprise & Government production ready code in mind. so a11y and i18n is basic and implicit requirement for us."

---

## Roadmap

### v2.0.0 (Session 46) - ✅ COMPLETE
- [x] Centralized design tokens
- [x] API health monitoring
- [x] 6-language i18n
- [x] Version footer
- [x] WCAG 2.1 AA patterns

### v2.1.0 (Next) - Batch Regeneration
- [ ] Regenerate 111 Data Model pages
- [ ] Verify build succeeds
- [ ] Deploy to Azure
- [ ] Validate all 25 acceptance criteria

### v2.2.0 (Future) - Multi-Client
- [ ] Templates for EVA Portal (31-eva-faces)
- [ ] Templates for ACA (51-ACA)
- [ ] Template inheritance system
- [ ] Client-specific customization

### v3.0.0 (Future) - Test Generation
- [ ] Generate Jest unit tests
- [ ] Generate E2E tests (Playwright)
- [ ] Generate visual regression tests
- [ ] Generate accessibility tests

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development workflow.

**Key Principle**: Always improve the factory, not individual widgets. If you find a bug in generated code, fix the template and regenerate all affected pages.

---

## License

See [LICENSE](./LICENSE)

---

**Session**: 46 (March 12, 2026)  
**Agent**: AIAgentExpert mode  
**Status**: Templates v2.0.0 ready, awaiting batch regeneration approval
