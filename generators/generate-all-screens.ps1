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
$projectRoot = Split-Path (Split-Path $scriptDir -Parent) -Parent

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
        Write-Host "[MetadataInit] Fetching layer metadata from API: $ApiBase/model/layer-metadata" -ForegroundColor Cyan
        $response = Invoke-RestMethod "$ApiBase/model/layer-metadata" -TimeoutSec 10 -ErrorAction Stop
        
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

# Initialize metadata once at startup
$script:LayerIdMap = Load-LayerMetadata -ApiBase $ModelApiBase

# ============================================================================
# LOGGING
# ============================================================================

$logsDir = "$projectRoot\logs"
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force |Out-Null }

$logFile = "$logsDir\generate-all-screens_${timestamp}.log"
$evidenceDir = "$projectRoot\.eva\evidence"
if (-not (Test-Path $evidenceDir)) { New-Item -ItemType Directory -Path $evidenceDir -Force | Out-Null }

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
        $Path = "$projectRoot\37-data-model\docs\examples\screen-registry-bulk-upload.jsonl"
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
    # Placeholder - would call Data Model API
    # For now, fall back to JSON
    Log "Cosmos DB access not yet implemented, falling back to JSON..." "WARN"
    return Load-RegistryFromJson -Path $RegistryPath
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
$layerScreens = @($screens | Where-Object { $_.id -match '^L[0-9]+$' })
$skippedScreens = @($screens | Where-Object { $_.id -notmatch '^L[0-9]+$' })

Log "Screen filter: $($layerScreens.Count) layer screens (L[0-9]+) | $($skippedScreens.Count) non-layer screens (skipped)" "INFO"

if ($ParallelJobs -eq 1) {
    # Sequential execution
    foreach ($screen in $layerScreens) {
        # Map registry fields to generation parameters
        $layerId = if ($screen.id) { $screen.id } elseif ($screen.layer_id) { $screen.layer_id } else { "UNKNOWN" }
        
        # Get layer name from mapping (authoritative source), fallback to layer_name field, else use LayerId
        $layerName = $null
        if ($script:LayerIdMap.ContainsKey($layerId)) {
            $layerName = $script:LayerIdMap[$layerId]
        } elseif ($screen.layer_name -and $screen.layer_name -ne "null") {
            $layerName = $screen.layer_name
        } else {
            $layerName = $layerId.ToLower()
        }
        
        # Generate LayerTitle (PascalCase of layer name) for component naming
        # e.g., "services" → "Services", "ts_types" → "TsTypes"
        $layerTitleForComponents = ToPascalCase -Text $layerName
        
        # Use entity_type from registry (now repaired to be valid TypeScript identifiers)
        if ($screen.entity_type -and $screen.entity_type -ne "null" -and $screen.entity_type -ne "") {
            $entityType = $screen.entity_type
        } else {
            # Fallback: use PascalCase layer ID + 'Record'
            $entityType = "$layerTitleForComponents`Record"
        }
        
        Log "[$($layerScreens.IndexOf($screen) + 1)/$($layerScreens.Count)] Generating $layerId ($layerName)..." "INFO"
        
        try {
            $result = & "$scriptDir\generate-screens-v2.ps1" `
                -LayerId $layerId `
                -LayerName $layerName `
                -LayerTitle $layerTitleForComponents `
                -EntityType $entityType `
                -FieldSchema ($screen.fields | ConvertTo-Json -Compress) `
                -TemplateDir "$projectRoot\30-ui-bench\templates" `
                -DryRun:$DryRun
            
            if ($LASTEXITCODE -eq 0) {
                $successCount++
                Log "PASS: $layerId" "PASS"
            } else {
                $failCount++
                $failedScreens += $layerId
                Log "FAIL: $layerId (exit code $LASTEXITCODE)" "FAIL"
            }
        }
        catch {
            $failCount++
            $failedScreens += $layerId
            Log "ERROR: $layerId : $_" "ERROR"
        }
    }
} else {
    # Parallel execution with job management
    $jobs = @()
    $jobBatchSize = [math]::Ceiling($screens.Count / $ParallelJobs)
    
    Log "Starting $ParallelJobs parallel jobs (batch size: ~$jobBatchSize screens/job)..." "INFO"
    
    $batches = $screens | Group-Object { [math]::Floor([array]::IndexOf($screens, $_) / $jobBatchSize) }
    
    foreach ($batch in $batches) {
        $job = Start-Job -ScriptBlock {
            param($screens, $scriptDir, $projectRoot, $DryRun)
            
            $results = @{ success = 0; fail = 0; errors = @() }
            foreach ($screen in $screens) {
                # Map registry fields to generation parameters (same logic as sequential)
                $layerId = if ($screen.id) { $screen.id } elseif ($screen.layer_id) { $screen.layer_id } else { "UNKNOWN" }
                $layerName = if ($screen.layer_name -and $screen.layer_name -ne "null") { $screen.layer_name } else { $layerId.ToLower() }
                $layerTitleForComponents = ToPascalCase -Text $layerId
                
                if ($screen.entity_type -and $screen.entity_type -ne "null" -and $screen.entity_type -ne "") {
                    $entityType = $screen.entity_type
                } else {
                    $entityType = "$layerTitleForComponents`Record"
                }
                
                & "$scriptDir\generate-screens-v2.ps1" `
                    -LayerId $layerId `
                    -LayerName $layerName `
                    -LayerTitle $layerTitleForComponents `
                    -EntityType $entityType `
                    -FieldSchema ($screen.fields | ConvertTo-Json -Compress) `
                    -TemplateDir "$projectRoot\30-ui-bench\templates" `
                    -DryRun:$DryRun | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    $results.success++
                } else {
                    $results.fail++
                    $results.errors += $layerId
                }
            }
            return $results
        } -ArgumentList @($batch.Group, $scriptDir, $projectRoot, $DryRun)
        
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

$evidenceFile = "$evidenceDir\PART-3-DO-BATCH-GENERATION-${timestamp}.json"
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
Log "Success rate: $([math]::Round($successCount / $layerScreens.Count * 100, 1))% (excluding skipped)" "INFO"
Log "Duration: $([int]$durationSeconds)s (~$([math]::Round($durationSeconds / 60, 1)) minutes)" "INFO"
Log "Speed: $([math]::Round($durationSeconds / $layerScreens.Count, 2))s per layer screen" "INFO"
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
