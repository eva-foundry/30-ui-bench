#!/usr/bin/env pwsh
<#
.SYNOPSIS
Generate all Screen components from Data Model registry (173 screens × 5 components = 865 artifacts)

.DESCRIPTION
- Loads screen registry from Cosmos DB or JSON fallback
- Invokes generate-screens-v2.ps1 for each screen
- Collects evidence at batch level
- Supports sequential execution with optional parallelization

.PARAMETER RegistrySource
Source of registry data: 'cosmos' (live API) or 'json' (file fallback)
Default: auto-detect (try cosmos, fallback to json)

.PARAMETER RegisryPath
Path to screen-registry-bulk-upload.jsonl (if RegistrySource=json)
Default: ../../37-data-model/docs/examples/screen-registry-bulk-upload.jsonl

.PARAMETER ParallelJobs
Number of parallel generation jobs (1-8). Default: 1 (sequential)

.PARAMETER DryRun
Preview mode, don't write files

.EXAMPLE
.\generate-all-screens.ps1

.\generate-all-screens.ps1 -RegistrySource json

.\generate-all-screens.ps1 -ParallelJobs 4

.LINK
https://github.com/microsoft/eva-foundry
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("cosmos", "json", "auto")]
    [string]$RegistrySource = "auto",
    
    [Parameter(Mandatory = $false)]
    [string]$RegistryPath = "",
    
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 8)]
    [int]$ParallelJobs = 1,
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function ToPascalCase {
    [CmdletBinding()]
    param([string]$Text)
    
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    
    # Split on hyphens, underscores, and spaces
    $parts = $Text -replace '[^a-zA-Z0-9]', ' ' -split '\s+' | Where-Object { $_ }
    $pascalCase = foreach ($part in $parts) {
        $part.Substring(0, 1).ToUpper() + $part.Substring(1).ToLower()
    }
    
    return ($pascalCase -join "")
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$projectRoot = Split-Path $scriptDir -Parent
$workspaceRoot = Split-Path $projectRoot -Parent

# ============================================================================
# METADATA INITIALIZATION: Fetch Layer Catalog from API
# ============================================================================
# Source of truth: /model/layers API endpoint
# Fallback: Hardcoded mapping if API unavailable (for local dev)

$ModelApiBase = "https://msub-eva-data-model.victoriousgrass-30debbd3.canadacentral.azurecontainerapps.io"
$LayerIdMap = @{}  # Will be populated from API or fallback

function Load-LayerMetadata {
    param([string]$ApiBase = $ModelApiBase)
    
    $metadata = @{}
    
    try {
        Write-Host "[MetadataInit] Fetching layer metadata from API: $ApiBase/model/layer-metadata/" -ForegroundColor Cyan
        $response = Invoke-RestMethod "$ApiBase/model/layer-metadata/" -TimeoutSec 10 -ErrorAction Stop
        
        if ($response -and $response.layers) {
            foreach ($layer in $response.layers) {
                if ($layer.id -and $layer.name) {
                    $metadata[$layer.id] = $layer.name
                }
            }
            Write-Host "[MetadataInit] Loaded $($metadata.Count) layers from API" -ForegroundColor Green
        } else {
            throw "API response empty"
        }
    }
    catch {
        Write-Host "[MetadataInit] API unavailable ($_), using authoritative mapping from SCREEN-TO-LAYER-MAPPING.md" -ForegroundColor Yellow
        # Authoritative mapping: Source = C:\eva-foundry\37-data-model\docs\SCREEN-TO-LAYER-MAPPING.md
        # Only L1-L75 are model layers. All other screen IDs (eva-faces-*, project-screen-*, etc.) are skipped.
        $metadata = @{
            # SECTION 1: Operational Layers (L1-L51)
            "L1"   = "services"
            "L2"   = "personas"
            "L3"   = "feature_flags"
            "L4"   = "containers"
            "L5"   = "endpoints"
            "L6"   = "schemas"
            "L7"   = "screens"
            "L8"   = "literals"
            "L9"   = "agents"
            "L10"  = "infrastructure"
            "L11"  = "requirements"
            "L12"  = "planes"
            "L13"  = "connections"
            "L14"  = "environments"
            "L15"  = "cp_skills"
            "L16"  = "cp_agents"
            "L17"  = "runbooks"
            "L18"  = "cp_workflows"
            "L19"  = "cp_policies"
            "L20"  = "mcp_servers"
            "L21"  = "prompts"
            "L22"  = "security_controls"
            "L23"  = "components"
            "L24"  = "hooks"
            "L25"  = "ts_types"
            "L26"  = "projects"
            "L27"  = "wbs"
            "L28"  = "sprints"
            "L29"  = "milestones"
            "L30"  = "risks"
            "L31"  = "decisions"
            "L32"  = "traces"
            "L33"  = "evidence"
            "L34"  = "workspace_config"
            "L35"  = "project_work"
            "L36"  = "agent_policies"
            "L37"  = "quality_gates"
            "L38"  = "github_rules"
            "L39"  = "deployment_policies"
            "L40"  = "testing_policies"
            "L41"  = "validation_rules"
            "L42"  = "agent_execution_history"
            "L43"  = "agent_performance_metrics"
            "L44"  = "azure_infrastructure"
            "L45"  = "compliance_audit"
            "L46"  = "deployment_quality_scores"
            "L47"  = "deployment_records"
            "L48"  = "eva_model"
            "L49"  = "infrastructure_drift"
            "L50"  = "performance_trends"
            "L51"  = "resource_costs"
            
            # SECTION 2: Phase 1 Execution (L52-L54)
            "L52"  = "work_execution_units"
            "L53"  = "work_step_events"
            "L54"  = "work_decision_records"
            
            # SECTION 3: Phases 2-6 Execution/Strategy (L55-L75)
            "L55"  = "work_obligations"
            "L56"  = "work_outcomes"
            "L57"  = "work_learning_feedback"
            "L58"  = "work_reusable_patterns"
            "L59"  = "work_pattern_applications"
            "L60"  = "work_pattern_perf_profiles"
            "L61"  = "work_factory_capabilities"
            "L62"  = "work_factory_services"
            "L63"  = "work_service_requests"
            "L64"  = "work_service_runs"
            "L65"  = "work_service_perf_profiles"
            "L66"  = "work_service_level_objs"
            "L67"  = "work_service_breaches"
            "L68"  = "work_service_remed_plans"
            "L69"  = "work_service_reval_results"
            "L70"  = "work_service_lifecycle"
            "L71"  = "work_factory_portfolio"
            "L72"  = "work_factory_roadmaps"
            "L73"  = "work_factory_investments"
            "L74"  = "work_factory_decisions"
            "L75"  = "work_factory_authorizations"
        }
    }
    
    return $metadata
}

function Resolve-ScreenGenerationParams {
    param([psobject]$Screen)

    $layerId = if ($Screen.id) { $Screen.id } elseif ($Screen.layer_id) { $Screen.layer_id } else { "UNKNOWN" }

    $layerName = $null
    if ($script:LayerIdMap.ContainsKey($layerId)) {
        $layerName = $script:LayerIdMap[$layerId]
    } elseif ($Screen.layer_name -and $Screen.layer_name -ne "null") {
        $layerName = $Screen.layer_name
    } else {
        $layerName = $layerId.ToLower()
    }

    $layerTitleForComponents = ToPascalCase -Text $layerName

    if ($Screen.entity_type -and $Screen.entity_type -ne "null" -and $Screen.entity_type -ne "") {
        $entityType = $Screen.entity_type
    } else {
        $entityType = "$layerTitleForComponents`Record"
    }

    return [pscustomobject]@{
        LayerId = $layerId
        LayerName = $layerName
        LayerTitle = $layerTitleForComponents
        EntityType = $entityType
        FieldSchema = ($Screen.fields | ConvertTo-Json -Compress)
    }
}

function New-Batches {
    param(
        [array]$Items,
        [int]$BatchSize
    )

    $batches = @()
    for ($index = 0; $index -lt $Items.Count; $index += $BatchSize) {
        $endIndex = [math]::Min($index + $BatchSize - 1, $Items.Count - 1)
        $batchItems = @($Items[$index..$endIndex])
        $batches += ,$batchItems
    }

    return $batches
}

# Initialize metadata once at startup
$script:LayerIdMap = Load-LayerMetadata -ApiBase $ModelApiBase

# ============================================================================
# LOGGING
# ============================================================================

$logsDir = Join-Path $projectRoot "logs"
$evidenceDir = Join-Path $projectRoot "evidence"
$debugDir = Join-Path $projectRoot "debug"

foreach ($directory in @($logsDir, $evidenceDir, $debugDir)) {
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
}

$logFile = Join-Path $logsDir "${timestamp}-log-generate-all-screens.log"

function Log {
    [CmdletBinding()]
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "PASS", "FAIL")]
        [string]$Level = "INFO",
        [bool]$ToConsole = $true
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $badge = switch($Level) {
        "INFO"  { "[INFO]" }
        "WARN"  { "[WARN]" }
        "ERROR" { "[ERROR]" }
        "PASS"  { "[PASS]" }
        "FAIL"  { "[FAIL]" }
        default { "[????]" }
    }
    
    $logMsg = "$timestamp $badge $Message"
    
    if ($ToConsole) {
        Write-Host $logMsg -ForegroundColor $(switch($Level) {
            "INFO"  { "Cyan" }
            "WARN"  { "Yellow" }
            "ERROR" { "Red" }
            "PASS"  { "Green" }
            "FAIL"  { "Red" }
            default { "Gray" }
        })
    }
    
    Add-Content -Path $logFile -Value $logMsg
}

# ============================================================================
# REGISTRY LOADING
# ============================================================================

Log "=====[PART 3.DO: Screen Factory Batch Generation]=====" "INFO"
Log "Loading screen registry (source: $RegistrySource, parallel: $ParallelJobs workers)..." "INFO"

function Load-RegistryFromJson {
    param([string]$Path)
    
    if ([string]::IsNullOrEmpty($Path)) {
        $Path = "$workspaceRoot\37-data-model\docs\examples\screen-registry-bulk-upload.jsonl"
    }
    
    if (-not (Test-Path $Path)) {
        throw "Registry file not found: $Path"
    }
    
    $screens = @()
    $lineNumber = 0
    foreach ($line in @(Get-Content -Path $Path)) {
        $lineNumber++
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        
        try {
            $record = $line | ConvertFrom-Json
            $screens += $record
        }
        catch {
            Log "ERROR at line $lineNumber : $_" "WARN"
        }
    }
    
    return $screens
}

function Load-RegistryFromCosmos {
    try {
        $response = Invoke-RestMethod "$ModelApiBase/model/screens/" -TimeoutSec 15 -ErrorAction Stop
        $screenData = if ($response.data) { @($response.data) } else { @($response) }

        if ($screenData.Count -eq 0) {
            throw "API returned no screen records"
        }

        $layerBackedRecords = @(
            $screenData | Where-Object {
                ($_.id -match '^L[0-9]+$') -or ($_.layer_id -match '^L[0-9]+$')
            }
        )

        if ($layerBackedRecords.Count -eq 0) {
            throw "API returned screen pages but no layer-backed screen registry records"
        }

        return $screenData
    }
    catch {
        throw "Screen API query failed: $($_.Exception.Message)"
    }
}

# Detect registry source
if ($RegistrySource -eq "auto" -or $RegistrySource -eq "cosmos") {
    try {
        $screens = Load-RegistryFromCosmos
        Log "PASS: Loaded registry from Cosmos DB ($($screens.Count) screens)" "PASS"
    }
    catch {
        Log "Cosmos unavailable, falling back to JSON..." "WARN"
        try {
            $screens = Load-RegistryFromJson -Path $RegistryPath
            Log "PASS: Loaded registry from JSON ($($screens.Count) screens)" "PASS"
        }
        catch {
            Log "FAIL: Could not load registry from any source" "FAIL"
            exit 1
        }
    }
} else {
    try {
        $screens = Load-RegistryFromJson -Path $RegistryPath
        Log "PASS: Loaded registry from JSON ($($screens.Count) screens)" "PASS"
    }
    catch {
        Log "FAIL: Could not load registry: $_" "FAIL"
        exit 1
    }
}

# ============================================================================
# GENERATION EXECUTION
# ============================================================================

Log "Generating components for $($screens.Count) screens ($($screens.Count * 5) total components)..." "INFO"

$generationStart = Get-Date
$successCount = 0
$failCount = 0
$skippedCount = 0
$generatedFiles = @()
$failedScreens = @()
$skippedScreens = @()

# Filter: Only process screens with layer IDs (L1-L999, not eva-faces-*, project-screen-*, etc.)
$layerScreens = @(
    $screens | Where-Object {
        ($_.id -match '^L[0-9]+$') -or ($_.layer_id -match '^L[0-9]+$')
    }
)
$skippedScreens = @(
    $screens | Where-Object {
        ($_.id -notmatch '^L[0-9]+$') -and ($_.layer_id -notmatch '^L[0-9]+$')
    }
)
$resolvedLayerScreens = @($layerScreens | ForEach-Object { Resolve-ScreenGenerationParams -Screen $_ })

Log "Screen filter: $($layerScreens.Count) layer screens (L[0-9]+) | $($skippedScreens.Count) non-layer screens (skipped)" "INFO"

if ($ParallelJobs -eq 1) {
    # Sequential execution
    for ($index = 0; $index -lt $resolvedLayerScreens.Count; $index++) {
        $screen = $resolvedLayerScreens[$index]

        Log "[$($index + 1)/$($resolvedLayerScreens.Count)] Generating $($screen.LayerId) ($($screen.LayerName))..." "INFO"
        
        try {
            $result = & "$scriptDir\generate-screens-v2.ps1" `
                -LayerId $screen.LayerId `
                -LayerName $screen.LayerName `
                -LayerTitle $screen.LayerTitle `
                -EntityType $screen.EntityType `
                -FieldSchema $screen.FieldSchema `
                -TemplateDir "$projectRoot\templates" `
                -DryRun:$DryRun
            
            if ($LASTEXITCODE -eq 0) {
                $successCount++
                Log "PASS: $($screen.LayerId)" "PASS"
            } else {
                $failCount++
                $failedScreens += $screen.LayerId
                Log "FAIL: $($screen.LayerId) (exit code $LASTEXITCODE)" "FAIL"
            }
        }
        catch {
            $failCount++
            $failedScreens += $screen.LayerId
            Log "ERROR: $($screen.LayerId) : $_" "ERROR"
        }
    }
} else {
    # Parallel execution with job management
    $jobs = @()
    $jobBatchSize = [math]::Ceiling($resolvedLayerScreens.Count / $ParallelJobs)
    
    Log "Starting $ParallelJobs parallel jobs (batch size: ~$jobBatchSize layer screens/job)..." "INFO"
    
    $batches = New-Batches -Items $resolvedLayerScreens -BatchSize $jobBatchSize
    
    foreach ($batch in $batches) {
        $batchJson = $batch | ConvertTo-Json -Depth 6 -Compress
        $job = Start-Job -ScriptBlock {
            param($batchJson, $scriptDir, $projectRoot, $DryRun)

            $screens = @($batchJson | ConvertFrom-Json)
            
            $results = @{ success = 0; fail = 0; errors = @() }
            foreach ($screen in $screens) {
                & "$scriptDir\generate-screens-v2.ps1" `
                    -LayerId $screen.LayerId `
                    -LayerName $screen.LayerName `
                    -LayerTitle $screen.LayerTitle `
                    -EntityType $screen.EntityType `
                    -FieldSchema $screen.FieldSchema `
                    -TemplateDir "$projectRoot\templates" `
                    -DryRun:$DryRun | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    $results.success++
                } else {
                    $results.fail++
                    $results.errors += $screen.LayerId
                }
            }
            return $results
        } -ArgumentList $batchJson, $scriptDir, $projectRoot, $DryRun
        
        $jobs += $job
    }
    
    # Collect results
    Log "Waiting for $($jobs.Count) jobs to complete..." "INFO"
    $results = $jobs | Wait-Job | Receive-Job
    
    foreach ($result in $results) {
        $successCount += $result.success
        $failCount += $result.fail
        $failedScreens += $result.errors
    }
}

# ============================================================================
# EVIDENCE COLLECTION
# ============================================================================

$generationEnd = Get-Date
$durationSeconds = ($generationEnd - $generationStart).TotalSeconds

$evidence = @{
    phase = "DO"
    operation = "screen_generation_batch"
    timestamp = Get-Date -Format "o"
    duration_seconds = [int]$durationSeconds
    batch_stats = @{
        total_screens = $screens.Count
        total_components_planned = $screens.Count * 5
        screens_generated = $successCount
        components_generated = $successCount * 5
        screens_failed = $failCount
        generation_speed_sec_per_screen = if ($successCount -gt 0) { [math]::Round($durationSeconds / $successCount, 2) } else { 0 }
        estimated_remaining_time = if ($failCount -eq 0 -and $successCount -gt 0) { "COMPLETE" } else { "ERROR RECOVERY NEEDED" }
    }
    execution_mode = if ($ParallelJobs -gt 1) { "parallel ($ParallelJobs workers)" } else { "sequential" }
    failed_screens = $failedScreens
    success_rate = if ($screens.Count -gt 0) { [math]::Round(($successCount / $screens.Count * 100), 2) } else { 0 }
    generator = "generate-all-screens.ps1"
    version = "1.0.0"
    dry_run = $DryRun
}

$evidenceFile = Join-Path $evidenceDir "${timestamp}-evidence-screen-generation-batch.json"
$evidence | ConvertTo-Json -Depth 5 | Out-File -FilePath $evidenceFile -Encoding UTF8 -Force

Log "Evidence file: $evidenceFile" "INFO"

# ============================================================================
# SUMMARY
# ============================================================================

Log "" "INFO"
Log "=== Generation Summary ===" "INFO"
Log "Total registry entries: $($screens.Count)" "INFO"
Log "Layer screens (L[0-9]+): $($layerScreens.Count) | Non-layer screens (skipped): $($skippedScreens.Count)" "INFO"
Log "Total components target: $($layerScreens.Count * 5)" "INFO"
Log "Generated: $($successCount * 5) components | Failed: $($failCount * 5) components" "INFO"
Log "Success rate: $(if ($layerScreens.Count -gt 0) { [math]::Round($successCount / $layerScreens.Count * 100, 1) } else { 0 })% (excluding skipped)" "INFO"
Log "Duration: $([int]$durationSeconds)s (~$([math]::Round($durationSeconds / 60, 1)) minutes)" "INFO"
Log "Speed: $(if ($layerScreens.Count -gt 0) { [math]::Round($durationSeconds / $layerScreens.Count, 2) } else { 0 })s per layer screen" "INFO"
Log "" "INFO"

if ($skippedScreens.Count -gt 0) {
    Log "INFO: Skipped $($skippedScreens.Count) non-layer screens (not L[0-9]+ format):" "INFO"
    $skippedScreens | Select-Object -ExpandProperty id | Sort-Object -Unique | ForEach-Object { Log "  - $_" "INFO" }
    Log "" "INFO"
}

if ($failCount -eq 0) {
    Log "PASS: All layer screens generated successfully" "PASS"
    exit 0
} else {
    Log "FAIL: $failCount layer screens failed (see evidence for details)" "FAIL"
    exit 1
}
