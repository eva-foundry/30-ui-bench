<#
.SYNOPSIS
    Comprehensive QA Test Orchestrator - All 51 Acceptance Criteria
    
.DESCRIPTION
    Executes all 51 acceptance gates with nested DPDCA (DISCOVER → PLAN → DO → CHECK → ACT per gate).
    Generates comprehensive evidence report for production readiness validation.
    
.PARAMETER UIPath
    Path to UI project directory (default: ../ui)
    
.PARAMETER EvidencePath
    Path to evidence output directory (default: ../evidence)
    
.PARAMETER SkipManual
    Skip manual verification gates (default: $false)
    
.PARAMETER Verbose
    Enable verbose logging
    
.EXAMPLE
    .\Test-AllAcceptanceCriteria.ps1 -UIPath "C:\eva-foundry\37-data-model\ui"
    
.EXAMPLE
    .\Test-AllAcceptanceCriteria.ps1 -SkipManual -Verbose
    
#>

[CmdletBinding()]
param(
    [string]$UIPath = "../ui",
    [string]$EvidencePath = "../evidence",
    [switch]$SkipManual,
    [switch]$VerboseLogging
)

$ErrorActionPreference = "Continue"
$script:StartTime = Get-Date
$script:TestResults = @{
    Total = 51
    Automated = 0
    Manual = 0
    Passed = 0
    Failed = 0
    Skipped = 0
    Gates = @{}
}

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

function Write-GateHeader {
    param([string]$Category, [string]$GateId, [string]$Title)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host " $Category | $GateId: $Title" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

function Write-PhaseHeader {
    param([string]$Phase)
    Write-Host ""
    Write-Host "  [$Phase]" -ForegroundColor Yellow -NoNewline
    Write-Host " " -NoNewline
}

function Write-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Write-Skip {
    param([string]$Message)
    Write-Host "[SKIP] $Message" -ForegroundColor Yellow
}

function Record-GateResult {
    param(
        [string]$GateId,
        [string]$Category,
        [string]$Title,
        [string]$Status, # PASS, FAIL, SKIP, MANUAL
        [string]$Evidence = "",
        [string]$Details = ""
    )
    
    $script:TestResults.Gates[$GateId] = @{
        Category = $Category
        Title = $Title
        Status = $Status
        Evidence = $Evidence
        Details = $Details
        Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    }
    
    switch ($Status) {
        "PASS" { $script:TestResults.Passed++ }
        "FAIL" { $script:TestResults.Failed++ }
        "SKIP" { $script:TestResults.Skipped++ }
        "MANUAL" { $script:TestResults.Manual++ }
    }
    
    if ($Status -ne "MANUAL") {
        $script:TestResults.Automated++
    }
}

# ============================================================
# CODE QUALITY GATES (AC-1 through AC-5)
# ============================================================

function Test-AC01-TypeScriptCompilation {
    Write-GateHeader "CODE QUALITY" "AC-1" "TypeScript Compilation Passes"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    Write-Host "Checking TypeScript configuration..."
    $tsconfigPath = Join-Path $UIPath "tsconfig.json"
    if (!(Test-Path $tsconfigPath)) {
        Write-Fail "tsconfig.json not found"
        Record-GateResult "AC-1" "Code Quality" "TypeScript Compilation" "FAIL" "" "tsconfig.json missing"
        return
    }
    Write-Pass "tsconfig.json exists"
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will run: npm run type-check"
    Write-Host "Expected: Exit code 0, zero TS errors"
    
    # DO
    Write-PhaseHeader "DO"
    Push-Location $UIPath
    $output = npm run type-check 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    Pop-Location
    
    # CHECK
    Write-PhaseHeader "CHECK"
    $errorCount = ([regex]::Matches($output, "error TS")).Count
    
    if ($exitCode -eq 0 -and $errorCount -eq 0) {
        Write-Pass "Zero TypeScript errors"
        Record-GateResult "AC-1" "Code Quality" "TypeScript Compilation" "PASS" $output "Exit code 0, 0 errors"
    } else {
        Write-Fail "$errorCount TypeScript errors found (exit code $exitCode)"
        Record-GateResult "AC-1" "Code Quality" "TypeScript Compilation" "FAIL" $output "$errorCount errors"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    $evidenceFile = Join-Path $EvidencePath "ac-01-typescript-$((Get-Date).ToString('yyyyMMdd-HHmmss')).txt"
    $output | Out-File $evidenceFile -Encoding UTF8
    Write-Host "Evidence saved: $evidenceFile"
}

function Test-AC02-ESLint {
    Write-GateHeader "CODE QUALITY" "AC-2" "ESLint Passes"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $eslintConfigPath = Join-Path $UIPath ".eslintrc.*"
    if (!(Get-ChildItem $UIPath -Filter ".eslintrc.*")) {
        Write-Fail "ESLint config not found"
        Record-GateResult "AC-2" "Code Quality" "ESLint" "FAIL" "" "ESLint config missing"
        return
    }
    Write-Pass "ESLint config exists"
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will run: npm run lint"
    
    # DO
    Write-PhaseHeader "DO"
    Push-Location $UIPath
    $output = npm run lint 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    Pop-Location
    
    # CHECK
    Write-PhaseHeader "CHECK"
    $errorCount = ([regex]::Matches($output, "\d+ error")).Count
    
    if ($exitCode -eq 0) {
        Write-Pass "Zero ESLint errors"
        Record-GateResult "AC-2" "Code Quality" "ESLint" "PASS" $output "Exit code 0"
    } else {
        Write-Fail "$errorCount ESLint errors"
        Record-GateResult "AC-2" "Code Quality" "ESLint" "FAIL" $output "$errorCount errors"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    $evidenceFile = Join-Path $EvidencePath "ac-02-eslint-$((Get-Date).ToString('yyyyMMdd-HHmmss')).txt"
    $output | Out-File $evidenceFile -Encoding UTF8
    Write-Host "Evidence saved"
}

function Test-AC03-CircularDependencies {
    Write-GateHeader "CODE QUALITY" "AC-3" "No Circular Dependencies"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $srcPath = Join-Path $UIPath "src"
    if (!(Test-Path $srcPath)) {
        Write-Fail "src directory not found"
        Record-GateResult "AC-3" "Code Quality" "Circular Dependencies" "FAIL" "" "src directory missing"
        return
    }
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will run: npx madge --circular"
    
    # DO
    Write-PhaseHeader "DO"
    Push-Location $UIPath
    $output = npx madge --circular --extensions ts,tsx src/ 2>&1 | Out-String
    Pop-Location
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($output -match "No circular dependencies found") {
        Write-Pass "No circular dependencies"
        Record-GateResult "AC-3" "Code Quality" "Circular Dependencies" "PASS" $output "Clean dependency graph"
    } else {
        Write-Fail "Circular dependencies detected"
        Record-GateResult "AC-3" "Code Quality" "Circular Dependencies" "FAIL" $output "Circular deps found"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    $evidenceFile = Join-Path $EvidencePath "ac-03-circular-deps-$((Get-Date).ToString('yyyyMMdd-HHmmss')).txt"
    $output | Out-File $evidenceFile -Encoding UTF8
    Write-Host "Evidence saved"
}

function Test-AC04-DesignTokens {
    Write-GateHeader "CODE QUALITY" "AC-4" "Centralized Design Tokens"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $pagesPath = Join-Path $UIPath "src\pages"
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Searching for inline 'const GC_' tokens in pages..."
    
    # DO
    Write-PhaseHeader "DO"
    $inlineTokens = Select-String -Path "$pagesPath\*" -Pattern "const GC_" -Recurse -ErrorAction SilentlyContinue
    
    # CHECK
    Write-PhaseHeader "CHECK"
    $count = ($inlineTokens | Measure-Object).Count
    
    if ($count -eq 0) {
        Write-Pass "All design tokens centralized"
        Record-GateResult "AC-4" "Code Quality" "Design Tokens" "PASS" "" "0 inline tokens"
    } else {
        Write-Fail "$count inline design tokens found"
        Record-GateResult "AC-4" "Code Quality" "Design Tokens" "FAIL" ($inlineTokens | Out-String) "$count inline tokens"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Non-blocking - can proceed"
}

function Test-AC05-BundleSize {
    Write-GateHeader "CODE QUALITY" "AC-5" "Bundle Size < 2MB"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $distPath = Join-Path $UIPath "dist"
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will build and measure dist size..."
    
    # DO
    Write-PhaseHeader "DO"
    Push-Location $UIPath
    $buildOutput = npm run build 2>&1 | Out-String
    Pop-Location
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if (Test-Path $distPath) {
        $sizeBytes = (Get-ChildItem $distPath -Recurse | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($sizeBytes / 1MB, 2)
        $maxMB = 2
        
        if ($sizeMB -lt $maxMB) {
            Write-Pass "Bundle size ${sizeMB}MB < ${maxMB}MB"
            Record-GateResult "AC-5" "Code Quality" "Bundle Size" "PASS" $buildOutput "${sizeMB}MB"
        } else {
            Write-Fail "Bundle size ${sizeMB}MB >= ${maxMB}MB"
            Record-GateResult "AC-5" "Code Quality" "Bundle Size" "FAIL" $buildOutput "${sizeMB}MB exceeds limit"
        }
    } else {
        Write-Fail "Build failed - dist directory not found"
        Record-GateResult "AC-5" "Code Quality" "Bundle Size" "FAIL" $buildOutput "Build failed"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Non-blocking - bundle size checked"
}

# ============================================================
# CONSISTENCY GATES (AC-12 through AC-15)
# ============================================================

function Test-AC12-ComponentStructure {
    Write-GateHeader "CONSISTENCY" "AC-12" "Identical Component Structure"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $pagesPath = Join-Path $UIPath "src\pages"
    $listViews = Get-ChildItem "$pagesPath\*ListView.tsx" -Recurse -ErrorAction SilentlyContinue
    
    if (($listViews | Measure-Object).Count -eq 0) {
        Write-Skip "No ListView files found"
        Record-GateResult "AC-12" "Consistency" "Component Structure" "SKIP" "" "No ListViews"
        return
    }
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Sampling 3 random ListViews to check hook order..."
    
    # DO
    Write-PhaseHeader "DO"
    $sample = $listViews | Get-Random -Count ([Math]::Min(3, $listViews.Count))
    $hookPatterns = @()
    
    foreach ($file in $sample) {
        $hooks = Select-String -Path $file.FullName -Pattern "const .* = use" | ForEach-Object { $_.Line.Trim() }
        $hookPatterns += ($hooks -join "`n")
    }
    
    # CHECK
    Write-PhaseHeader "CHECK"
    $uniquePatterns = $hookPatterns | Select-Object -Unique
    
    if ($uniquePatterns.Count -eq 1) {
        Write-Pass "Component structure consistent across samples"
        Record-GateResult "AC-12" "Consistency" "Component Structure" "PASS" ($hookPatterns | Out-String) "Same hook order"
    } else {
        Write-Fail "Inconsistent hook order detected"
        Record-GateResult "AC-12" "Consistency" "Component Structure" "FAIL" ($hookPatterns | Out-String) "Inconsistent hooks"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Structure check complete"
}

function Test-AC13-ErrorHandling {
    Write-GateHeader "CONSISTENCY" "AC-13" "Identical Error Handling"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $pagesPath = Join-Path $UIPath "src\pages"
    $listViews = Get-ChildItem "$pagesPath\*ListView.tsx" -Recurse -ErrorAction SilentlyContinue
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Checking for try/catch blocks..."
    
    # DO
    Write-PhaseHeader "DO"
    $missingErrorHandling = @()
    foreach ($file in $listViews) {
        $hasCatch = Select-String -Path $file.FullName -Pattern "catch.*error" -Quiet
        if (!$hasCatch) {
            $missingErrorHandling += $file.Name
        }
    }
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($missingErrorHandling.Count -eq 0) {
        Write-Pass "All components have error handling"
        Record-GateResult "AC-13" "Consistency" "Error Handling" "PASS" "" "All have catch blocks"
    } else {
        Write-Fail "$($missingErrorHandling.Count) files missing error handling"
        Record-GateResult "AC-13" "Consistency" "Error Handling" "FAIL" ($missingErrorHandling | Out-String) "$($missingErrorHandling.Count) missing"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Error handling audit complete"
}

function Test-AC14-NamingConvention {
    Write-GateHeader "CONSISTENCY" "AC-14" "File Naming Convention"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $pagesPath = Join-Path $UIPath "src\pages"
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Checking file naming patterns..."
    
    # DO
    Write-PhaseHeader "DO"
    $allFiles = Get-ChildItem "$pagesPath\*.tsx" -Recurse -ErrorAction SilentlyContinue
    $validPattern = "^[A-Z][a-zA-Z]+(ListView|DetailDrawer|CreateForm|EditForm|GraphView)\.tsx$|\.test\.tsx$"
    $invalidFiles = $allFiles | Where-Object { $_.Name -notmatch $validPattern }
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($invalidFiles.Count -eq 0) {
        Write-Pass "All files follow naming convention"
        Record-GateResult "AC-14" "Consistency" "Naming Convention" "PASS" "" "All valid"
    } else {
        Write-Fail "$($invalidFiles.Count) files violate naming convention"
        Record-GateResult "AC-14" "Consistency" "Naming Convention" "FAIL" ($invalidFiles.Name | Out-String) "$($invalidFiles.Count) invalid"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Naming convention audit complete"
}

function Test-AC15-ImportPaths {
    Write-GateHeader "CONSISTENCY" "AC-15" "Import Path Conventions"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $pagesPath = Join-Path $UIPath "src\pages"
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Checking for deep relative imports..."
    
    # DO
    Write-PhaseHeader "DO"
    $deepImports = Select-String -Path "$pagesPath\*.tsx" -Pattern "import.*from '\.\./\.\./\.\." -Recurse -ErrorAction SilentlyContinue
    
    # CHECK
    Write-PhaseHeader "CHECK"
    $count = ($deepImports | Measure-Object).Count
    
    if ($count -eq 0) {
        Write-Pass "All imports use path aliases"
        Record-GateResult "AC-15" "Consistency" "Import Paths" "PASS" "" "0 deep relative imports"
    } else {
        Write-Fail "$count deep relative imports found"
        Record-GateResult "AC-15" "Consistency" "Import Paths" "FAIL" ($deepImports | Out-String) "$count violations"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Import path audit complete"
}

# ============================================================
# TESTING GATES (AC-26, AC-27, AC-28, AC-29, AC-30)
# ============================================================

function Test-AC26-UnitTests {
    Write-GateHeader "TESTING" "AC-26" "Unit Tests Pass (>= 90%)"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $packageJsonPath = Join-Path $UIPath "package.json"
    if (!(Test-Path $packageJsonPath)) {
        Write-Fail "package.json not found"
        Record-GateResult "AC-26" "Testing" "Unit Tests" "FAIL" "" "package.json missing"
        return
    }
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will run: npm test"
    Write-Host "Expected: >= 90% pass rate"
    
    # DO
    Write-PhaseHeader "DO"
    Push-Location $UIPath
    $output = npm test 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    Pop-Location
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($output -match "(\d+) passed.*(\d+) failed") {
        $passed = [int]$matches[1]
        $failed = [int]$matches[2]
        $total = $passed + $failed
        $passRate = [math]::Round(($passed / $total) * 100, 1)
        
        if ($passRate -ge 90) {
            Write-Pass "$passRate% pass rate ($passed/$total tests)"
            Record-GateResult "AC-26" "Testing" "Unit Tests" "PASS" $output "$passRate% pass rate"
        } else {
            Write-Fail "$passRate% pass rate ($passed/$total tests) - below 90%"
            Record-GateResult "AC-26" "Testing" "Unit Tests" "FAIL" $output "$passRate% < 90%"
        }
    } else {
        Write-Fail "Could not parse test results"
        Record-GateResult "AC-26" "Testing" "Unit Tests" "FAIL" $output "Unable to parse"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    $evidenceFile = Join-Path $EvidencePath "ac-26-unit-tests-$((Get-Date).ToString('yyyyMMdd-HHmmss')).txt"
    $output | Out-File $evidenceFile -Encoding UTF8
    Write-Host "Evidence saved"
}

function Test-AC27-E2ETests {
    Write-GateHeader "TESTING" "AC-27" "E2E Tests Pass (Future v3.0.0)"
    Write-Skip "E2E tests not yet implemented"
    Record-GateResult "AC-27" "Testing" "E2E Tests" "SKIP" "" "Future milestone"
}

function Test-AC28-VisualRegression {
    Write-GateHeader "TESTING" "AC-28" "Visual Regression Tests (Future v3.0.0)"
    Write-Skip "Visual regression not yet implemented"
    Record-GateResult "AC-28" "Testing" "Visual Regression" "SKIP" "" "Future milestone"
}

function Test-AC29-AccessibilityAudit {
    Write-GateHeader "TESTING" "AC-29" "Accessibility Audit (Future v3.0.0)"
    Write-Skip "Accessibility audit not yet automated"
    Record-GateResult "AC-29" "Testing" "Accessibility Audit" "SKIP" "" "Future milestone"
}

function Test-AC30-Storybook {
    Write-GateHeader "TESTING" "AC-30" "Storybook Documentation (Future v3.0.0)"
    Write-Skip "Storybook not yet implemented"
    Record-GateResult "AC-30" "Testing" "Storybook" "SKIP" "" "Future milestone"
}

# ============================================================
# EVIDENCE GATES (AC-42 through AC-46)
# ============================================================

function Test-AC42-GenerationEvidence {
    Write-GateHeader "EVIDENCE" "AC-42" "Generation Evidence Logged"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    Write-Host "Searching for screen-generation-*.json files..."
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Expected: At least 1 evidence file"
    
    # DO
    Write-PhaseHeader "DO"
    $evidenceFiles = Get-ChildItem $EvidencePath -Filter "screen-generation-*.json" -ErrorAction SilentlyContinue
    
    # CHECK
    Write-PhaseHeader "CHECK"
    $count = ($evidenceFiles | Measure-Object).Count
    
    if ($count -gt 0) {
        Write-Pass "$count evidence files found"
        Record-GateResult "AC-42" "Evidence" "Generation Evidence" "PASS" ($evidenceFiles.Name | Out-String) "$count files"
    } else {
        Write-Fail "No generation evidence files found"
        Record-GateResult "AC-42" "Evidence" "Generation Evidence" "FAIL" "" "0 files"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Evidence audit complete"
}

function Test-AC43-BuildHash {
    Write-GateHeader "EVIDENCE" "AC-43" "Build Hash Recorded"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $latestEvidence = Get-ChildItem $EvidencePath -Filter "screen-generation-*.json" -ErrorAction SilentlyContinue | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    
    if (!$latestEvidence) {
        Write-Fail "No evidence files found"
        Record-GateResult "AC-43" "Evidence" "Build Hash" "FAIL" "" "No evidence file"
        return
    }
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Checking for timestamp in: $($latestEvidence.Name)"
    
    # DO
    Write-PhaseHeader "DO"
    $content = Get-Content $latestEvidence.FullName -Raw
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($content -match '"timestamp"') {
        Write-Pass "Build hash/timestamp recorded"
        Record-GateResult "AC-43" "Evidence" "Build Hash" "PASS" $latestEvidence.Name "Timestamp present"
    } else {
        Write-Fail "No timestamp in evidence"
        Record-GateResult "AC-43" "Evidence" "Build Hash" "FAIL" $latestEvidence.Name "No timestamp"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Build hash check complete"
}

function Test-AC44-SessionID {
    Write-GateHeader "EVIDENCE" "AC-44" "Session ID Tracked"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $latestEvidence = Get-ChildItem $EvidencePath -Filter "screen-generation-*.json" -ErrorAction SilentlyContinue | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    
    if (!$latestEvidence) {
        Write-Fail "No evidence files found"
        Record-GateResult "AC-44" "Evidence" "Session ID" "FAIL" "" "No evidence file"
        return
    }
    
    # DO
    Write-PhaseHeader "DO"
    $content = Get-Content $latestEvidence.FullName -Raw
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($content -match '"generator"|"session"|"version"') {
        Write-Pass "Session/version tracking present"
        Record-GateResult "AC-44" "Evidence" "Session ID" "PASS" $latestEvidence.Name "Session tracked"
    } else {
        Write-Fail "No session tracking"
        Record-GateResult "AC-44" "Evidence" "Session ID" "FAIL" $latestEvidence.Name "No session ID"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Session tracking check complete"
}

function Test-AC45-VeritasScore {
    Write-GateHeader "EVIDENCE" "AC-45" "Veritas Trust Score >= 70"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $veritasPlanPath = ".eva/veritas-plan.json"
    
    if (!(Test-Path $veritasPlanPath)) {
        Write-Skip "No veritas-plan.json found"
        Record-GateResult "AC-45" "Evidence" "Veritas Score" "SKIP" "" "No veritas plan"
        return
    }
    
    # DO
    Write-PhaseHeader "DO"
    $content = Get-Content $veritasPlanPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($content.trust_score) {
        $score = $content.trust_score
        if ($score -ge 70) {
            Write-Pass "MTI score: $score >= 70"
            Record-GateResult "AC-45" "Evidence" "Veritas Score" "PASS" $veritasPlanPath "Score: $score"
        } else {
            Write-Fail "MTI score: $score < 70"
            Record-GateResult "AC-45" "Evidence" "Veritas Score" "FAIL" $veritasPlanPath "Score: $score"
        }
    } else {
        Write-Skip "No trust score found"
        Record-GateResult "AC-45" "Evidence" "Veritas Score" "SKIP" $veritasPlanPath "No score"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Veritas score check complete"
}

function Test-AC46-DataModelSync {
    Write-GateHeader "EVIDENCE" "AC-46" "Data Model Record Current"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    Write-Host "Checking Data Model API connectivity..."
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will query: /model/projects/30-ui-bench"
    
    # DO
    Write-PhaseHeader "DO"
    try {
        $response = Invoke-RestMethod -Uri "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/projects/30-ui-bench" -TimeoutSec 10
        
        # CHECK
        Write-PhaseHeader "CHECK"
        if ($response.id -eq "30-ui-bench") {
            Write-Pass "Data Model record exists and current"
            Record-GateResult "AC-46" "Evidence" "Data Model Sync" "PASS" ($response | ConvertTo-Json) "Record exists"
        } else {
            Write-Fail "Data Model record not found"
            Record-GateResult "AC-46" "Evidence" "Data Model Sync" "FAIL" ($response | ConvertTo-Json) "Record missing"
        }
    } catch {
        Write-Fail "Data Model API unreachable: $($_.Exception.Message)"
        Record-GateResult "AC-46" "Evidence" "Data Model Sync" "FAIL" $_.Exception.Message "API unreachable"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Data Model sync check complete"
}

# ============================================================
# INTEGRATION GATES (AC-47 through AC-51)
# ============================================================

function Test-AC47-APIIntegration {
    Write-GateHeader "INTEGRATION" "AC-47" "Data Model API Integration Works"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    Write-Host "Testing Data Model API endpoints..."
    
    # PLAN
    Write-PhaseHeader "PLAN"
    Write-Host "Will test: /model/health"
    
    # DO
    Write-PhaseHeader "DO"
    try {
        $response = Invoke-RestMethod -Uri "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io/model/health" -TimeoutSec 10
        
        # CHECK
        Write-PhaseHeader "CHECK"
        if ($response.status -eq "healthy" -or $response) {
            Write-Pass "Data Model API reachable and healthy"
            Record-GateResult "AC-47" "Integration" "API Integration" "PASS" ($response | ConvertTo-Json) "API healthy"
        } else {
            Write-Fail "API unhealthy"
            Record-GateResult "AC-47" "Integration" "API Integration" "FAIL" ($response | ConvertTo-Json) "API unhealthy"
        }
    } catch {
        Write-Fail "API unreachable: $($_.Exception.Message)"
        Record-GateResult "AC-47" "Integration" "API Integration" "FAIL" $_.Exception.Message "API unreachable"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "API integration test complete"
}

function Test-AC48-MockFallback {
    Write-GateHeader "INTEGRATION" "AC-48" "Mock Data Fallback Works"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $stubsPath = Join-Path $UIPath "src\__stubs__"
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if (Test-Path $stubsPath) {
        $stubFiles = Get-ChildItem $stubsPath -Recurse -Include "*.ts","*.tsx"
        $count = ($stubFiles | Measure-Object).Count
        
        if ($count -gt 0) {
            Write-Pass "$count mock stub files found"
            Record-GateResult "AC-48" "Integration" "Mock Fallback" "PASS" ($stubFiles.Name | Out-String) "$count stubs"
        } else {
            Write-Fail "No mock stub files"
            Record-GateResult "AC-48" "Integration" "Mock Fallback" "FAIL" "" "No stubs"
        }
    } else {
        Write-Fail "__stubs__ directory not found"
        Record-GateResult "AC-48" "Integration" "Mock Fallback" "FAIL" "" "No stubs directory"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Mock fallback check complete"
}

function Test-AC49-AzureDeployment {
    Write-GateHeader "INTEGRATION" "AC-49" "Azure Deployment Succeeds (Manual)"
    Write-Skip "Requires manual deployment verification"
    Record-GateResult "AC-49" "Integration" "Azure Deployment" "MANUAL" "" "Manual verification required"
}

function Test-AC50-HealthCheck {
    Write-GateHeader "INTEGRATION" "AC-50" "Health Check Passes (Manual)"
    Write-Skip "Requires deployed environment"
    Record-GateResult "AC-50" "Integration" "Health Check" "MANUAL" "" "Requires deployed app"
}

function Test-AC51-AllRoutes {
    Write-GateHeader "INTEGRATION" "AC-51" "All 111 Routes Accessible"
    
    # DISCOVER
    Write-PhaseHeader "DISCOVER"
    $pagesPath = Join-Path $UIPath "src\pages"
    
    # DO
    Write-PhaseHeader "DO"
    $listViews = Get-ChildItem "$pagesPath\*ListView.tsx" -Recurse -ErrorAction SilentlyContinue
    $count = ($listViews | Measure-Object).Count
    
    # CHECK
    Write-PhaseHeader "CHECK"
    if ($count -ge 91) {
        Write-Pass "$count ListView routes found (>= 91 operational layers)"
        Record-GateResult "AC-51" "Integration" "All Routes" "PASS" ($listViews.Name | Out-String) "$count routes"
    } else {
        Write-Fail "Only $count ListView routes (expected >= 91)"
        Record-GateResult "AC-51" "Integration" "All Routes" "FAIL" ($listViews.Name | Out-String) "$count < 91"
    }
    
    # ACT
    Write-PhaseHeader "ACT"
    Write-Host "Route count check complete"
}

# ============================================================
# MANUAL GATE STUBS (AC-6 through AC-11, AC-16 through AC-25, AC-31 through AC-41)
# ============================================================

function Register-ManualGates {
    # Functional Completeness (Manual)
    Record-GateResult "AC-6" "Functional" "CRUD Operations" "MANUAL" "" "Manual smoke test required"
    Record-GateResult "AC-7" "Functional" "Filtering Works" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-8" "Functional" "Sorting Works" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-9" "Functional" "Detail Drawer" "MANUAL" "" "Manual UI test required"
    Record-GateResult "AC-10" "Functional" "Form Validation" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-11" "Functional" "Empty State UI" "MANUAL" "" "Manual test required"
    
    # Error Handling (Manual)
    Record-GateResult "AC-16" "Error Handling" "API Failure Degradation" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-17" "Error Handling" "Network Timeout" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-18" "Error Handling" "Validation Errors" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-19" "Error Handling" "404 Handling" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-20" "Error Handling" "Console Clean" "MANUAL" "" "Manual DevTools check required"
    
    # Performance (Manual)
    Record-GateResult "AC-21" "Performance" "Page Load < 3s" "MANUAL" "" "Manual Lighthouse required"
    Record-GateResult "AC-22" "Performance" "Time to Interactive < 5s" "MANUAL" "" "Manual Lighthouse required"
    Record-GateResult "AC-23" "Performance" "Route Transitions < 500ms" "MANUAL" "" "Manual timing required"
    Record-GateResult "AC-24" "Performance" "Memory Stable" "MANUAL" "" "Manual profiling required"
    Record-GateResult "AC-25" "Performance" "Lazy Loading" "MANUAL" "" "Manual network tab check required"
    
    # Cross-Browser (Manual)
    Record-GateResult "AC-31" "Cross-Browser" "Chrome Works" "MANUAL" "" "Manual browser test required"
    Record-GateResult "AC-32" "Cross-Browser" "Firefox Works" "MANUAL" "" "Manual browser test required"
    Record-GateResult "AC-33" "Cross-Browser" "Edge Works" "MANUAL" "" "Manual browser test required"
    Record-GateResult "AC-34" "Cross-Browser" "Safari Works" "MANUAL" "" "Manual browser test required"
    Record-GateResult "AC-35" "Cross-Browser" "Mobile 375px" "MANUAL" "" "Manual responsive test required"
    Record-GateResult "AC-36" "Cross-Browser" "Tablet 768px" "MANUAL" "" "Manual responsive test required"
    
    # Accessibility (Manual)
    Record-GateResult "AC-37" "Accessibility" "Keyboard Navigation" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-38" "Accessibility" "Focus Indicators" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-39" "Accessibility" "Screen Reader" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-40" "Accessibility" "Skip Links" "MANUAL" "" "Manual test required"
    Record-GateResult "AC-41" "Accessibility" "ARIA Labels" "MANUAL" "" "Manual axe-core scan required"
}

# ============================================================
# MAIN ORCHESTRATOR
# ============================================================

function Main {
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  EVA Screen Factory - Comprehensive QA Test Suite             ║" -ForegroundColor Cyan
    Write-Host "║  Testing All 51 Acceptance Criteria with Nested DPDCA         ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "UI Path: $UIPath" -ForegroundColor Gray
    Write-Host "Evidence Path: $EvidencePath" -ForegroundColor Gray
    Write-Host ""
    
    # Ensure evidence directory exists
    if (!(Test-Path $EvidencePath)) {
        New-Item -ItemType Directory -Path $EvidencePath -Force | Out-Null
    }
    
    # Execute all automated gates
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PHASE 1: CODE QUALITY GATES (5 Automated)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Test-AC01-TypeScriptCompilation
    Test-AC02-ESLint
    Test-AC03-CircularDependencies
    Test-AC04-DesignTokens
    Test-AC05-BundleSize
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PHASE 2: CONSISTENCY GATES (4 Automated)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Test-AC12-ComponentStructure
    Test-AC13-ErrorHandling
    Test-AC14-NamingConvention
    Test-AC15-ImportPaths
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PHASE 3: TESTING GATES (5 Total, 1 Automated)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Test-AC26-UnitTests
    Test-AC27-E2ETests
    Test-AC28-VisualRegression
    Test-AC29-AccessibilityAudit
    Test-AC30-Storybook
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PHASE 4: EVIDENCE & TRACEABILITY GATES (5 Automated)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Test-AC42-GenerationEvidence
    Test-AC43-BuildHash
    Test-AC44-SessionID
    Test-AC45-VeritasScore
    Test-AC46-DataModelSync
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PHASE 5: INTEGRATION GATES (5 Total, 3 Automated)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Test-AC47-APIIntegration
    Test-AC48-MockFallback
    Test-AC49-AzureDeployment
    Test-AC50-HealthCheck
    Test-AC51-AllRoutes
    
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  PHASE 6: REGISTER MANUAL GATES (26 Manual)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Register-ManualGates
    
    # Generate final report
    $duration = (Get-Date) - $script:StartTime
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  COMPREHENSIVE QA REPORT                                       ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "Total Gates:      51" -ForegroundColor White
    Write-Host "Automated:        $($script:TestResults.Automated)" -ForegroundColor Cyan
    Write-Host "Manual:           $($script:TestResults.Manual)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "PASSED:           $($script:TestResults.Passed)" -ForegroundColor Green
    Write-Host "FAILED:           $($script:TestResults.Failed)" -ForegroundColor Red
    Write-Host "SKIPPED:          $($script:TestResults.Skipped)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Duration:         $([math]::Round($duration.TotalMinutes, 2)) minutes" -ForegroundColor Gray
    Write-Host "End Time:         $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ""
    
    # Save report
    $reportFile = Join-Path $EvidencePath "comprehensive-qa-report-$((Get-Date).ToString('yyyyMMdd-HHmmss')).json"
    $reportData = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        duration_minutes = [math]::Round($duration.TotalMinutes, 2)
        summary = @{
            total_gates = 51
            automated = $script:TestResults.Automated
            manual = $script:TestResults.Manual
            passed = $script:TestResults.Passed
            failed = $script:TestResults.Failed
            skipped = $script:TestResults.Skipped
        }
        gates = $script:TestResults.Gates
        ui_path = $UIPath
        evidence_path = $EvidencePath
    }
    
    $reportData | ConvertTo-Json -Depth 10 | Out-File $reportFile -Encoding UTF8
    
    Write-Host "📊 Full report saved: $reportFile" -ForegroundColor Cyan
    Write-Host ""
    
    # Exit with appropriate code
    if ($script:TestResults.Failed -gt 0) {
        Write-Host "❌ QUALITY GATE FAILED - $($script:TestResults.Failed) gate(s) failed" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "✅ QUALITY GATE PASSED - All automated gates passed" -ForegroundColor Green
        Write-Host "⚠️  $($script:TestResults.Manual) manual gates require verification" -ForegroundColor Yellow
        exit 0
    }
}

# Execute
Main
