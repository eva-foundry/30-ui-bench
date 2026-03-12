# 30-ui-bench -- EVA Screen Factory Acceptance Criteria

**Created**: 2026-03-12 by AIAgentExpert (Session 46)
**Last Updated**: 2026-03-12
**Data Model**: GET https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench
**Template Version**: v2.0.0
**Status**: 25 gates defined, pending execution

---

<!-- eva-primed-acceptance -->

## Philosophy

**"Nothing is optional"** - Every criterion must pass for factory to be production-ready.

**"World Class Enterprise & Government production ready code"** - Marco Sandbox environment, but code quality is government-grade.

---

## Summary

| Category | Criteria Count | Status |
|----------|---------------|--------|
| **Code Quality** | 5 | PENDING |
| **Functional Completeness** | 6 | PENDING |
| **Consistency** | 4 | PENDING |
| **Error Handling** | 5 | PENDING |
| **Performance** | 5 | PENDING |
| **Testing** | 5 | PENDING |
| **Cross-Browser** | 6 | PENDING |
| **Accessibility** | 5 | PENDING |
| **Evidence** | 5 | PENDING |
| **Integration** | 5 | PENDING |
| **TOTAL** | **25 Gates** | **0 PASS** |

---

## Code Quality (5 Gates)

### AC-1: TypeScript Compilation Passes
**Criteria**: `npm run build` exits 0, zero TypeScript errors, zero warnings
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui
npm run build
# Expected: vite v5.4.21 building for production...
# Expected: ✓ 499+ modules transformed
# Expected: Build successful. Exit code 0.
```
**Blocker**: YES - Cannot deploy with TypeScript errors
**Status**: PENDING

---

### AC-2: ESLint Passes
**Criteria**: `npm run lint` exits 0, zero linting errors
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui
npm run lint
# Expected: ✓ 0 problems (0 errors, 0 warnings)
```
**Blocker**: NO - Can deploy with warnings, must fix errors
**Status**: PENDING

---

### AC-3: No Circular Dependencies
**Criteria**: Import graph is clean, no circular dependencies detected
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui
npx madge --circular --extensions ts,tsx src/
# Expected: "No circular dependencies found!"
```
**Blocker**: YES - Circular dependencies cause runtime issues
**Status**: PENDING

---

### AC-4: Centralized Design Tokens Used
**Criteria**: Zero inline color constants, all pages import from @styles/tokens
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui\src\pages
Select-String -Pattern "const GC_" -Recurse
# Expected: 0 matches (all moved to tokens.ts)
```
**Blocker**: NO - But technical debt if not fixed
**Status**: PENDING

---

### AC-5: Bundle Size Acceptable
**Criteria**: Total bundle size < 2MB gzipped
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui\dist
Get-ChildItem -Recurse | Measure-Object -Property Length -Sum
# Expected: < 2,097,152 bytes (2MB) gzipped
```
**Blocker**: NO - But impacts user experience
**Status**: PENDING

---

## Functional Completeness (6 Gates)

### AC-6: All CRUD Operations Work
**Criteria**: Create, Read, Update, Delete functional on all 111 pages
**Verification**: Manual smoke test on 3 representative layers
```
1. Open msub-sandbox-aca-frontend.azurewebsites.net/model/projects
2. List view renders (Read)
3. Click "Create" → form appears (Create UI)
4. Click card → detail drawer opens (Read detail)
5. Click "Edit" → form appears with populated data (Update UI)
6. Click "Delete" → confirmation dialog (Delete UI)
```
**Blocker**: YES - Core functionality
**Status**: PENDING

---

### AC-7: Filtering Works
**Criteria**: Search bar filters records, no console errors
**Verification**: Type in search box on any list view
```
Expected: Filtered results appear instantly
Expected: No "undefined" or console errors
```
**Blocker**: NO - But degrades UX
**Status**: PENDING

---

### AC-8: Sorting Works
**Criteria**: Click column headers, records re-sort
**Verification**: Click name/date/status columns
```
Expected: Ascending → Descending → Original order
Expected: Visual indicator (arrow icon)
```
**Blocker**: NO - But expected feature
**Status**: PENDING

---

### AC-9: Detail Drawer Opens/Closes
**Criteria**: Smooth slide-in transition, no layout shift
**Verification**: Click any card → drawer slides in from right
```
Expected: 300ms transition
Expected: Close button (X) top-right
Expected: ESC key closes drawer
```
**Blocker**: NO - But core navigation pattern
**Status**: PENDING

---

### AC-10: Form Validation Works
**Criteria**: Required fields enforced, format validation works
**Verification**: Try submitting empty create/edit form
```
Expected: Red border on required fields
Expected: Error message "This field is required"
Expected: Submit button disabled until valid
```
**Blocker**: YES - Data integrity
**Status**: PENDING

---

### AC-11: Empty State UI Shows
**Criteria**: When layer has 0 records, friendly message appears
**Verification**: Navigate to layer with no data
```
Expected: "No {LayerName} found" message
Expected: "Create your first {LayerName}" CTA button
Expected: Not blank white page
```
**Blocker**: NO - But better UX
**Status**: PENDING

---

## Consistency Across 111 Pages (4 Gates)

### AC-12: Identical Component Structure
**Criteria**: All pages use same hooks in same order
**Verification**: Compare 3 random ListView files
```powershell
cd C:\eva-foundry\37-data-model\ui\src\pages
$files = Get-ChildItem -Filter "*ListView.tsx" | Get-Random -Count 3
$files | ForEach-Object { Select-String -Path $_ -Pattern "const.*= use" }
# Expected: Same hook order (useLang → useApiHealth → useLiterals → useState)
```
**Blocker**: NO - But maintainability
**Status**: PENDING

---

### AC-13: Identical Error Handling
**Criteria**: All pages handle API errors the same way
**Verification**: Check for try/catch patterns
```powershell
Select-String -Path *ListView.tsx -Pattern "catch.*error"
# Expected: All use same error boundary pattern
```
**Blocker**: NO - But consistency
**Status**: PENDING

---

### AC-14: Same File Naming Convention
**Criteria**: No deviations from {LayerName}ListView.tsx pattern
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui\src\pages
Get-ChildItem -Recurse -Filter "*.tsx" | Where-Object { $_.Name -notmatch "^[A-Z][a-zA-Z]+(ListView|DetailDrawer|CreateForm|EditForm|GraphView)\.tsx$" }
# Expected: 0 matches (all follow pattern)
```
**Blocker**: NO - But confusing if inconsistent
**Status**: PENDING

---

### AC-15: Same Import Paths
**Criteria**: All pages use '@components', '@hooks', '@styles' aliases
**Verification**:
```powershell
Select-String -Path *.tsx -Pattern "import.*from '\.\./\.\."
# Expected: 0 matches (no relative imports escaping directory)
```
**Blocker**: NO - But maintainability
**Status**: PENDING

---

## Error Handling & Resilience (5 Gates)

### AC-16: API Failure Graceful Degradation
**Criteria**: When API returns 500, app falls back to mock data with banner
**Verification**: Stop Data Model API, reload page
```
Expected: ApiHealthBanner shows "API unavailable"
Expected: Page renders with demo data
Expected: No white screen of death
```
**Blocker**: YES - Resilience requirement
**Status**: PENDING

---

### AC-17: Network Timeout Handling
**Criteria**: 30-second timeout shows user-friendly message
**Verification**: Throttle network to 3G, test slow endpoint
```
Expected: Loading spinner for <30s
Expected: After 30s: "Request timed out. Please try again."
Expected: Retry button appears
```
**Blocker**: NO - But better UX
**Status**: PENDING

---

### AC-18: Validation Errors Clear
**Criteria**: Error messages actionable, not technical
**Verification**: Submit invalid form data
```
Expected: "Email must contain @" (not "Regex failed")
Expected: "Date must be in future" (not "Invalid ISO8601")
```
**Blocker**: NO - But UX quality
**Status**: PENDING

---

### AC-19: 404 Handling
**Criteria**: Navigate to /model/invalid-layer → friendly 404 page
**Verification**: msub-sandbox-aca-frontend.azurewebsites.net/model/nonexistent
```
Expected: "Page not found" message
Expected: Link back to home
Expected: Not browser default 404
```
**Blocker**: NO - Edge case
**Status**: PENDING

---

### AC-20: Console Clean
**Criteria**: Zero console errors/warnings in production build
**Verification**: Open DevTools, navigate through 5 pages
```
Expected: 0 red errors
Expected: < 3 yellow warnings (acceptable: React dev mode warnings)
```
**Blocker**: NO - But professional polish
**Status**: PENDING

---

## Performance (5 Gates)

### AC-21: Initial Page Load < 3 Seconds
**Criteria**: First Contentful Paint < 3s on 4G connection
**Verification**: Chrome DevTools → Network → Fast 3G
```
Expected: FCP < 3000ms
Expected: LCP < 4000ms
```
**Blocker**: NO - But UX quality
**Status**: PENDING

---

### AC-22: Time to Interactive < 5 Seconds
**Criteria**: Page fully interactive < 5s on 4G
**Verification**: Lighthouse audit
```powershell
npx lighthouse https://msub-sandbox-aca-frontend.azurewebsites.net --view
# Expected: Performance score > 80
```
**Blocker**: NO - But UX quality
**Status**: PENDING

---

### AC-23: Route Transitions < 500ms
**Criteria**: Navigate between pages feels instant
**Verification**: Click 10 random nav links, measure time
```
Expected: Each transition < 500ms
Expected: No visible lag
```
**Blocker**: NO - But UX quality
**Status**: PENDING

---

### AC-24: Memory Stable After 50 Routes
**Criteria**: No memory leaks during navigation
**Verification**: DevTools → Memory → Record, navigate 50 times, stop
```
Expected: Heap size increase < 50MB
Expected: No continuous growth pattern
```
**Blocker**: NO - But prevents crashes
**Status**: PENDING

---

### AC-25: Lazy Loading Works
**Criteria**: Only visited routes loaded in bundle
**Verification**: DevTools → Network, visit 1 page
```
Expected: < 500KB initial bundle
Expected: Additional chunks load on navigation
Expected: Not all 111 pages loaded upfront
```
**Blocker**: NO - But performance optimization
**Status**: PENDING

---

## Testing & Quality (5 Gates - Future)

### AC-26: Unit Tests Pass (Future v3.0.0)
**Criteria**: Jest tests exit 0, coverage > 80%
**Status**: PLANNED (test generation not yet implemented)

### AC-27: E2E Tests Pass (Future v3.0.0)
**Criteria**: Playwright smoke tests all 111 routes
**Status**: PLANNED

### AC-28: Visual Regression Tests Pass (Future v3.0.0)
**Criteria**: Percy snapshots match baseline
**Status**: PLANNED

### AC-29: Accessibility Audit Passes (Future v3.0.0)
**Criteria**: axe-core reports 0 violations
**Status**: PLANNED

### AC-30: Storybook Documentation (Future v3.0.0)
**Criteria**: All components documented with examples
**Status**: PLANNED

---

## Cross-Browser & Device (6 Gates)

### AC-31: Chrome Works
**Criteria**: Full functionality on Chrome 120+
**Verification**: Manual test on Windows 11 Chrome
**Status**: PENDING

### AC-32: Firefox Works
**Criteria**: Full functionality on Firefox 120+
**Verification**: Manual test on Windows 11 Firefox
**Status**: PENDING

### AC-33: Edge Works
**Criteria**: Full functionality on Edge 120+
**Verification**: Manual test on Windows 11 Edge
**Status**: PENDING

### AC-34: Safari Works (Future)
**Criteria**: Full functionality on Safari 17+ (macOS)
**Status**: PLANNED (requires macOS test device)

### AC-35: Mobile Responsive (375px)
**Criteria**: Mobile viewport renders correctly
**Verification**: DevTools → Device: iPhone SE
```
Expected: No horizontal scroll
Expected: Tap targets > 44px
Expected: Text readable without zoom
```
**Status**: PENDING

### AC-36: Tablet Responsive (768px)
**Criteria**: Tablet viewport renders correctly
**Verification**: DevTools → Device: iPad
**Status**: PENDING

---

## Keyboard & Assistive Tech (5 Gates)

### AC-37: Keyboard Navigation Works
**Criteria**: Tab/Shift+Tab, Enter, Esc, Arrow keys
**Verification**: Unplug mouse, navigate entire app
```
Expected: Visible focus ring (GC_FOCUS blue)
Expected: Enter activates buttons/links
Expected: Esc closes modals
Expected: Tab order logical
```
**Blocker**: YES - WCAG 2.1 AA requirement
**Status**: PENDING

### AC-38: Focus Indicators Visible
**Criteria**: 3px GC_FOCUS ring on all interactive elements
**Verification**: Tab through page, verify blue outline
**Blocker**: YES - WCAG 2.1 AA requirement
**Status**: PENDING

### AC-39: Screen Reader Compatible (Future)
**Criteria**: NVDA/JAWS announce all content correctly
**Verification**: NVDA on Windows, read page aloud
**Status**: PLANNED (requires NVDA training)

### AC-40: Skip Links Work
**Criteria**: "Skip to main content" link functional
**Verification**: Tab once → Enter → focus jumps to main
**Status**: PENDING

### AC-41: ARIA Labels Complete
**Criteria**: All buttons, forms, regions have ARIA labels
**Verification**: axe DevTools → Scan page
**Blocker**: YES - WCAG 2.1 AA requirement
**Status**: PENDING

---

## Evidence & Traceability (5 Gates)

### AC-42: Generation Evidence Logged
**Criteria**: JSON file created per generation run
**Verification**: ls evidence/screen-generation-*.json
```
Expected: Timestamp, layers processed, files created, duration
```
**Status**: PENDING

### AC-43: Build Hash Recorded
**Criteria**: VersionFooter shows commit hash + timestamp
**Verification**: Check footer on deployed page
```
Expected: "Build: 3771dcf | 2026-03-12 14:35:22 UTC"
```
**Status**: PENDING

### AC-44: Session ID Tracked
**Criteria**: All generated files have "Session 46" marker
**Verification**:
```powershell
Select-String -Path *.tsx -Pattern "Session 46"
# Expected: All 555 generated files
```
**Status**: PENDING

### AC-45: Veritas Trust Score > 70
**Criteria**: MTI score >= 0.70 after implementation
**Verification**:
```powershell
MCP tool: get_trust_score repo_path=C:\eva-foundry\30-ui-bench
# Expected: trust_index >= 0.70
```
**Status**: PENDING

### AC-46: Data Model Record Current
**Criteria**: Project 30-ui-bench record in data model API
**Verification**:
```powershell
Invoke-RestMethod "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench"
```
**Status**: PENDING

---

## Integration & Deployment (5 Gates)

### AC-47: Data Model API Integration Works
**Criteria**: All 111 layer endpoints responding
**Verification**: Test 3 random endpoints
```
GET /model/agents → 200 OK
GET /model/projects → 200 OK
GET /model/evidence → 200 OK
```
**Blocker**: YES - Core functionality
**Status**: PENDING

### AC-48: Mock Data Fallback Works
**Criteria**: Demo mode functional without API
**Verification**: Block API in firewall, reload app
```
Expected: ApiHealthBanner shows "Unavailable"
Expected: Mock data renders
Expected: All pages load
```
**Blocker**: YES - Resilience requirement
**Status**: PENDING

### AC-49: Azure Deployment Succeeds
**Criteria**: az webapp deploy exits 0
**Verification**:
```powershell
cd C:\eva-foundry\37-data-model\ui
npm run build
az webapp deploy --resource-group msub-sandbox-rg --name msub-sandbox-aca-frontend --src-path dist
# Expected: Exit code 0
```
**Blocker**: YES - Cannot release without deployment
**Status**: PENDING

### AC-50: Health Check Passes
**Criteria**: /health endpoint returns 200
**Verification**:
```powershell
Invoke-RestMethod "https://msub-sandbox-aca-frontend.azurewebsites.net/health"
# Expected: { "status": "healthy" }
```
**Blocker**: YES - Production readiness
**Status**: PENDING

### AC-51: All 128 Routes Accessible
**Criteria**: No 404s on any route
**Verification**: Script to test all routes
```powershell
$routes = 1..111 | ForEach-Object { "/model/layer-$_" }
$routes | ForEach-Object {
    $response = Invoke-WebRequest "https://msub-sandbox-aca-frontend.azurewebsites.net$_" -UseBasicParsing
    if ($response.StatusCode -ne 200) { Write-Error "404: $_" }
}
# Expected: 0 errors
```
**Blocker**: YES - Core functionality
**Status**: PENDING

---

## Execution Plan

**Phase 1 - Critical Blockers** (MUST PASS):
- AC-1: TypeScript compilation
- AC-6: CRUD operations
- AC-10: Form validation
- AC-16: API failure handling
- AC-37, AC-38, AC-41: Keyboard + WCAG
- AC-47, AC-49, AC-50, AC-51: Integration

**Phase 2 - Quality Gates** (SHOULD PASS):
- AC-2 through AC-5: Code quality
- AC-12 through AC-15: Consistency
- AC-21 through AC-25: Performance
- AC-31 through AC-36: Cross-browser

**Phase 3 - Nice to Have** (COULD DEFER):
- AC-7 through AC-9, AC-11: Enhanced UX
- AC-17 through AC-20: Edge cases
- Future test generation (AC-26 through AC-30)

---

**Last Updated**: March 12, 2026 (Session 46)  
**Template Version**: v2.0.0  
**Total Gates**: 51 (25 current + 26 future)  
**Critical Blockers**: 14  
**Status**: Templates ready, pending batch regeneration and validation
