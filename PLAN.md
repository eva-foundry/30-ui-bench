<!-- eva-primed-plan -->

## EVA Ecosystem Tools

- Data model: GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench
- 48-eva-veritas audit: run audit_repo MCP tool

---

# 30-ui-bench -- EVA Screen Factory

**Vision**: Code generation factory that produces production-ready UI screens at scale for ANY EVA project.

**Not limited by client count or screen count** - this is a manufacturing system, not a single-purpose tool.

---

## Feature: Template System v2.0.0 [ID=F30-01]

**Status**: ✅ COMPLETE (Session 46, Commit 3771dcf)

### Story: Centralized design tokens [ID=F30-01-001] - ✅ DONE
- Replace inline GC Design constants with @styles/tokens imports
- Enable theme switching (light/dark mode preparation)
- Result: 7 constants × 111 files = 777 constants eliminated

### Story: API health monitoring pattern [ID=F30-01-002] - ✅ DONE
- SM-PATTERN-001: ApiHealthBanner component
- useApiHealth hook
- Applied to all ListView templates

### Story: Version footer for cache debugging [ID=F30-01-003] - ✅ DONE
- VersionFooter component showing build timestamp
- Helps users verify which build is loaded
- Applied to all ListView templates

### Story: 6-language i18n upgrade [ID=F30-01-004] - ✅ DONE
- Upgraded from bilingual (EN/FR) to 6 languages (EN/FR/ES/DE/PT/CN)
- Updated all template headers
- LanguageSelector component (reusable)

### Story: WCAG 2.1 AA compliance patterns [ID=F30-01-005] - ✅ DONE
- Focus indicators (GC_FOCUS)
- Keyboard navigation patterns
- ARIA labels and roles
- Skip links

---

## Feature: Batch Regeneration Pipeline [ID=F30-02]

**Status**: 🔄 IN PROGRESS (Session 46)

### Story: Regenerate 111 Data Model pages [ID=F30-02-001] - ⏸️ PENDING
- Run generate-all-screens.ps1 with v2.0.0 templates
- Target: 37-data-model/ui/src/pages/
- Expected: 5 components × 111 layers = 555 files
- Time: ~9 minutes

### Story: Verify build succeeds [ID=F30-02-002] - ⏸️ PENDING
- npm run build (TypeScript + Vite)
- Expected: 0 errors, 0 warnings
- Bundle size: <2MB gzipped

### Story: Deploy to Azure [ID=F30-02-003] - ⏸️ PENDING
- Target: msub-sandbox-aca-frontend.azurewebsites.net
- Build #15+
- Health check: All 128 routes accessible

### Story: Validate acceptance criteria [ID=F30-02-004] - ⏸️ PENDING
- Run all 25 acceptance criteria tests
- Document results in evidence/
- Update ACCEPTANCE.md with PASS/FAIL

---

## Feature: Multi-Client Support [ID=F30-03]

**Status**: 📋 PLANNED (v2.2.0+)

### Story: EVA Portal templates [ID=F30-03-001] - 📋 PLANNED
- Copy v2.0.0 templates to portal-specific variants
- Customize for Project 31 (eva-faces) patterns
- Dashboard, Admin, Reports screens

### Story: ACA templates [ID=F30-03-002] - 📋 PLANNED
- Copy v2.0.0 templates to ACA-specific variants
- Customize for Project 51 (ACA) domain
- Monitoring, Admin, Config screens

### Story: Template inheritance system [ID=F30-03-003] - 📋 PLANNED
- Base templates (v2.0.0)
- Client-specific overrides
- Merge strategy (base + override)

### Story: Client discovery [ID=F30-03-004] - 📋 PLANNED
- Scan EVA workspace for projects needing screens
- Read layer definitions from data model
- Generate manifests (project → layers → screens)

---

## Feature: Test Generation [ID=F30-04]

**Status**: 📋 PLANNED (v3.0.0)

### Story: Jest unit test templates [ID=F30-04-001] - 📋 PLANNED
- Generate .spec.tsx for each component
- Test: rendering, props, user interactions
- Target: 80%+ code coverage

### Story: E2E test templates [ID=F30-04-002] - 📋 PLANNED
- Generate Playwright tests
- Test: navigation, CRUD operations, error handling
- Smoke tests for all routes

### Story: Visual regression templates [ID=F30-04-003] - 📋 PLANNED
- Generate Percy/Chromatic snapshots
- Test: layout, responsive design, theme switching

### Story: Accessibility test templates [ID=F30-04-004] - 📋 PLANNED
- Generate axe-core tests
- Test: WCAG 2.1 AA compliance
- Automated keyboard navigation tests

---

## Feature: Quality Gates Automation [ID=F30-05]

**Status**: 📋 PLANNED (v2.3.0)

### Story: Pre-generation validation [ID=F30-05-001] - 📋 PLANNED
- Verify templates exist and are valid
- Verify layer definitions complete
- Verify dependencies installed
- Exit early if prerequisites not met

### Story: Post-generation validation [ID=F30-05-002] - 📋 PLANNED
- TypeScript compilation check
- ESLint check
- Import path validation
- File naming convention check

### Story: Rollback on failure [ID=F30-05-003] - 📋 PLANNED
- Backup existing files before regeneration
- Restore backup if validation fails
- Evidence trail (what failed, why)

### Story: 25-criteria audit [ID=F30-05-004] - 📋 PLANNED
- Automated script to run all acceptance criteria
- Generate report with PASS/FAIL/SKIP
- Update ACCEPTANCE.md automatically

---

## Feature: Evidence & Observability [ID=F30-06]

**Status**: 📋 PLANNED (v2.4.0)

### Story: Generation evidence logging [ID=F30-06-001] - 📋 PLANNED
- JSON evidence file per generation run
- Fields: timestamp, generator_version, layers_processed, files_created, duration, errors
- Store in evidence/ directory

### Story: Build metrics tracking [ID=F30-06-002] - 📋 PLANNED
- Bundle size over time
- Build duration over time
- Module count over time
- Alert if regression detected

### Story: Quality metrics dashboard [ID=F30-06-003] - 📋 PLANNED
- Acceptance criteria pass rate
- Code coverage trend
- WCAG compliance score
- Performance metrics (LCP, FID, CLS)

---

## Risks

| Risk | Mitigation | Status |
|------|------------|--------|
| Breaking changes in templates cause 111 pages to fail | Incremental rollout (3-5 pages first), rollback plan | MITIGATED |
| Bundle size increases with health monitoring | Tree-shaking, code splitting, lazy loading | MONITORED |
| 6-language support increases bundle size | Dynamic imports for translations, lazy load languages | MONITORED |
| Regeneration overwrites manual fixes | Discourage manual edits, improve templates instead | DOCUMENTED |
| TypeScript compilation errors after regeneration | Pre-generation validation, post-generation checks | PLANNED |

---

## Dependencies

- **37-data-model**: Layer definitions (111 layers)
- **31-eva-faces**: Portal patterns (NavHeader, LanguageSelector)
- **Project 07 (Foundation)**: Governance standards
- **Project 48 (Veritas)**: Quality gates and MTI scoring
- **Azure infrastructure**: Deployment target (msub-sandbox-aca-frontend)

---

**Last Updated**: March 12, 2026 (Session 46)  
**Template Version**: v2.0.0  
**Status**: Templates ready, awaiting batch regeneration approval
