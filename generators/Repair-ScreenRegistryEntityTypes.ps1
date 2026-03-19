#!/usr/bin/env pwsh
<#
.SYNOPSIS
Repair registry entity_type values using LayerId-based identifier generation

.DESCRIPTION
This script:
1. Loads screen registry (173 records)
2. Generates valid TypeScript entity types from LayerId
3. Validates all generated types are valid identifiers
4. Writes corrected registry back to JSONL
5. Creates evidence of transformations

.EXAMPLE
.\Repair-ScreenRegistryEntityTypes.ps1
#>

param(
    [string]$RegistryPath = "C:\eva-foundry\37-data-model\docs\examples\screen-registry-bulk-upload.jsonl",
    [switch]$DryRun
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$scriptLog = "C:\eva-foundry\logs\registry-repair_${timestamp}.log"
$evidencePath = "C:\eva-foundry\37-data-model\evidence\registry-repair-${timestamp}.json"

function Log {
    param([string]$Message, [ValidateSet("INFO", "WARN", "ERROR", "PASS", "FAIL")][string]$Level = "INFO")
    $badge = switch($Level) { "INFO" { "[INFO]" }; "WARN" { "[WARN]" }; "ERROR" { "[ERROR]" }; "PASS" { "[PASS]" }; "FAIL" { "[FAIL]" }; default { "[????]" } }
    $msg = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $badge $Message"
    Write-Host $msg -ForegroundColor $(switch($Level) { "PASS" { "Green" }; "FAIL" { "Red" }; "ERROR" { "Red" }; "WARN" { "Yellow" }; default { "Cyan" } })
    Add-Content -Path $scriptLog -Value $msg
}

function ToPascalCase {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    $parts = $Text -replace '[^a-zA-Z0-9]', ' ' -split '\s+' | Where-Object { $_ }
    $pascalCase = foreach ($part in $parts) { $part.Substring(0, 1).ToUpper() + $part.Substring(1).ToLower() }
    return ($pascalCase -join "")
}

function IsValidTypeIdentifier {
    param([string]$TypeName)
    # Valid: starts with letter/underscore, contains alphanumeric + underscore
    return $TypeName -match '^[a-zA-Z_][a-zA-Z0-9_]*$'
}

# ============================================================================
# DISCOVER: Load and Analyze Registry
# ============================================================================

Log "Loading registry from: $RegistryPath" "INFO"
if (-not (Test-Path $RegistryPath)) {
    Log "ERROR: Registry file not found" "ERROR"
    exit 1
}

$records = @(Get-Content $RegistryPath | ConvertFrom-Json)
Log "Loaded $($records.Count) records" "PASS"

# Analyze current state
$emptyEntityTypes = @($records | Where-Object { -not $_.entity_type -or $_.entity_type -eq "" })
$invalidEntityTypes = @($records | Where-Object { $_.entity_type -and -not (IsValidTypeIdentifier $_.entity_type) })

Log "Current state: $($emptyEntityTypes.Count) empty, $($invalidEntityTypes.Count) invalid entity_type values" "WARN"

# ============================================================================
# PLAN: Generate Repair Strategy
# ============================================================================

Log "Planning repairs..." "INFO"

$repairs = @()
foreach ($record in $records) {
    $layerId = $record.id
    if ([string]::IsNullOrWhiteSpace($layerId)) { continue }
    
    # Generate new entity_type from LayerId
    $newEntityType = "$(ToPascalCase -Text $layerId)Record"
    
    # Validate new type
    if (-not (IsValidTypeIdentifier $newEntityType)) {
        Log "WARN: Generated invalid type for $layerId : '$newEntityType'" "WARN"
        $newEntityType = "UnknownRecord"
    }
    
    # Track repair only if entity_type needs updating
    if (-not $record.entity_type -or $record.entity_type -eq "" -or $record.entity_type -ne $newEntityType) {
        $repairs += @{
            id = $layerId
            old_entity_type = $record.entity_type
            new_entity_type = $newEntityType
            name_display = $record.name
            category = $record.category
        }
    }
}

Log "Planned $($repairs.Count) repairs" "PASS"

# ============================================================================
# DO: Apply Repairs
# ============================================================================

Log "Applying repairs to registry..." "INFO"

# Create repair lookup for performance
$repairLookup = @{}
foreach ($repair in $repairs) {
    $repairLookup[$repair.id] = $repair.new_entity_type
}

$repairedRecords = @()
$repairSuccess = 0

foreach ($record in $records) {
    $layerId = $record.id
    if ($repairLookup.ContainsKey($layerId)) {
        # Create a new hashtable with all original properties + updated entity_type
        $repairedRecord = @{
            id = $record.id
            name = $record.name
            source = $record.source
            category = $record.category
            tags = $record.tags
            version = $record.version
            fields = $record.fields
            entity_type = $repairLookup[$layerId]  # Updated value
        }
        $repairedRecords += [PSCustomObject]$repairedRecord
        $repairSuccess++
        if ($repairSuccess -le 10 -or $repairSuccess % 30 -eq 0) {
            Log "Fixed $layerId → '$($repairLookup[$layerId])'" "INFO"
        }
    } else {
        $repairedRecords += $record
    }
}

Log "Repairs applied: $repairSuccess/$($repairs.Count)" "PASS"

# ============================================================================
# CHECK: Validate Repairs
# ============================================================================

Log "Validating repairs..." "INFO"

$validationIssues = @()
foreach ($record in $repairedRecords) {
    if (-not $record.entity_type -or $record.entity_type -eq "") {
        $validationIssues += "Empty entity_type for $($record.id)"
    }
    elseif (-not (IsValidTypeIdentifier $record.entity_type)) {
        $validationIssues += "Invalid type name '$($record.entity_type)' for $($record.id)"
    }
}

if ($validationIssues.Count -eq 0) {
    Log "Validation PASSED: All entity_types are valid TypeScript identifiers" "PASS"
} else {
    Log "Validation FAILED: $($validationIssues.Count) issues found" "FAIL"
    $validationIssues | ForEach-Object { Log "  - $_" "ERROR" }
    exit 1
}

# ============================================================================
# ACT: Write Back Registry
# ============================================================================

if ($DryRun) {
    Log "DRY RUN MODE: Registry not modified" "WARN"
} else {
    Log "Writing repaired registry..." "INFO"
    
    # Backup original
    $backupPath = "${RegistryPath}.backup.${timestamp}"
    Copy-Item -Path $RegistryPath -Destination $backupPath
    Log "Backup created: $backupPath" "INFO"
    
    # Write repaired records
    $jsonLines = foreach ($record in $repairedRecords) { $record | ConvertTo-Json -Compress }
    $repairedRecordsJson = $jsonLines -join "`n"
    Set-Content -Path $RegistryPath -Value $repairedRecordsJson -Encoding UTF8
    Log "Registry updated: $RegistryPath" "PASS"
}

# ============================================================================
# EVIDENCE
# ============================================================================

$evidenceData = @{
    phase = "CHECK"
    operation = "Registry entity_type repair"
    timestamp = Get-Date -Format "o"
    dpdca_level = "nested - registry audit"
    
    discovery = @{
        total_records = $records.Count
        empty_entity_types = $emptyEntityTypes.Count
        invalid_entity_types = $invalidEntityTypes.Count
    }
    
    plan = @{
        repair_strategy = "Generate entity_type from LayerId using ToPascalCase"
        records_to_repair = $repairs.Count
        validation_method = "IsValidTypeIdentifier (regex: ^[a-zA-Z_][a-zA-Z0-9_]*$)"
    }
    
    do_phase = @{
        repairs_applied = $repairSuccess
        repairs_total_planned = $repairs.Count
    }
    
    check_phase = @{
        validation_result = if ($validationIssues.Count -eq 0) { "PASS" } else { "FAIL" }
        issues_found = $validationIssues.Count
        issues = $validationIssues
    }
    
    act_phase = @{
        dry_run = $DryRun
        backup_path = if (-not $DryRun) { $backupPath } else { "N/A" }
        registry_updated = if (-not $DryRun) { $true } else { $false }
    }
    
    sample_repairs = @($repairs | Select-Object -First 5)
}

$evidenceData | ConvertTo-Json -Depth 10 | Set-Content -Path $evidencePath
Log "Evidence written: $evidencePath" "PASS"

Log "=== REGISTRY REPAIR COMPLETE ===" "PASS"
exit 0
