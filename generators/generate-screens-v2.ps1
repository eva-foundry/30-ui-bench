#!/usr/bin/env pwsh
<#
.SYNOPSIS
Generate Screen components for a single Data Model layer

.DESCRIPTION
Produces 5 TypeScript React components from Mustache-style templates:
- ListView, DetailDrawer, CreateForm, EditForm, GraphView

Implements DPDCA v2.0 with evidence logging and error handling

.PARAMETER LayerId
Layer ID (e.g., L25, L35)

.PARAMETER LayerName
Layer name snake_case (e.g., projects, sprints)

.PARAMETER LayerTitle  
Human-readable title (e.g., Projects, Sprints)

.PARAMETER EntityType
TypeScript interface name (e.g., ProjectRecord)

.PARAMETER FieldSchema
JSON array of field definitions [{name, type, required, pk}]

.PARAMETER OutputPath
Base directory for generated files (default: parent/../ui/src/pages/)

.PARAMETER TemplateDir
Template directory (default: 30-ui-bench/templates/)

.PARAMETER DryRun
Preview mode, don't write files

.EXAMPLE
.\generate-screens-v2.ps1 -LayerId "L25" -LayerName "projects" -LayerTitle "Projects"

.LINK
https://github.com/microsoft/eva-foundry
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LayerId,
    
    [Parameter(Mandatory = $true)]
    [string]$LayerName,
    
    [Parameter(Mandatory = $true)]
    [string]$LayerTitle,
    
    [Parameter(Mandatory = $false)]
    [string]$EntityType = "$($LayerTitle)Record",
    
    [Parameter(Mandatory = $false)]
    [string]$FieldSchema = '[]',
    
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = "",
    
    [Parameter(Mandatory = $false)]
    [string]$TemplateDir = "C:\eva-foundry\30-ui-bench\templates",
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

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

# ============================================================================
# INITIALIZATION
# ============================================================================

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$scriptName = "generate-screens-v2"
$projectRoot = Split-Path $PSScriptRoot -Parent

# Logging and evidence infrastructure
$logsDir = Join-Path $projectRoot "logs"
$evidenceDir = Join-Path $projectRoot "evidence"
$debugDir = Join-Path $projectRoot "debug"

foreach ($directory in @($logsDir, $evidenceDir, $debugDir)) {
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }
}

$logFile = Join-Path $logsDir "${timestamp}-log-${scriptName}.log"
$evidenceFile = Join-Path $evidenceDir "${timestamp}-evidence-screen-generation-${LayerId}.json"

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
# VALIDATION
# ============================================================================

Log "Starting generation for layer $LayerId ($LayerName)" "INFO"

# Verify templates exist
$requiredTemplates = @(
    "ListView.template.tsx",
    "DetailView.template.tsx",
    "CreateForm.template.tsx",
    "EditForm.template.tsx",
    "GraphView.template.tsx",
    "test.spec.tsx.template",
    "evidence.json.template"
)

$missingTemplates = @()
foreach ($tmpl in $requiredTemplates) {
    $tmplPath = "$TemplateDir\$tmpl"
    if (-not (Test-Path $tmplPath)) {
        $missingTemplates += $tmpl
        Log "Template missing: $tmpl" "ERROR"
    }
}

if ($missingTemplates.Count -gt 0) {
    Log "FAIL: $($missingTemplates.Count) templates missing. Cannot proceed." "FAIL"
    exit 2
}

Log "PASS: All $($requiredTemplates.Count) templates verified" "PASS"

# Determine output path
if ([string]::IsNullOrEmpty($OutputPath)) {
    $OutputPath = (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) + "\37-data-model\ui\src\pages"
}

Log "Output path: $OutputPath" "INFO"

# Verify output directory  
if (-not (Test-Path $OutputPath)) {
    Log "ERROR: Output path not found: $OutputPath" "ERROR"
    exit 2
}

# Normalize layer name (use as directory, fall back to layer ID if empty/unknown)
$normalizedLayerName = $LayerName
if ([string]::IsNullOrWhiteSpace($normalizedLayerName) -or $normalizedLayerName -eq "unknown") {
    $normalizedLayerName = $LayerId.ToLower()
}

Log "Using directory: $normalizedLayerName" "INFO"

# ============================================================================
# TEMPLATE SUBSTITUTION
# ============================================================================

$componentTypes = @("ListView", "DetailView", "CreateForm", "EditForm", "GraphView")
$generatedFiles = @()
$errors = @()

# Create layer directory once
$layerOutputDir = Join-Path $OutputPath $normalizedLayerName
if (-not (Test-Path $layerOutputDir)) {
    New-Item -ItemType Directory -Path $layerOutputDir -Force | Out-Null
    Log "Created directory: $normalizedLayerName" "INFO"
}

Log "Substituting templates for $($componentTypes.Count) components..." "INFO"

foreach ($componentType in $componentTypes) {
    try {
        # Load template
        $templateFile = Join-Path $TemplateDir "$componentType.template.tsx"
        if (-not (Test-Path $templateFile)) {
            throw "Template not found: $templateFile"
        }
        
        $template = Get-Content -Path $templateFile -Raw
        
        # Transform layer title to PascalCase for component names
        $PascalCaseLayerTitle = ToPascalCase -Text $LayerTitle
        
        # Perform substitutions (use PascalCase for component names)
        $output = $template `
            -replace '{{LAYER_ID}}', $LayerId `
            -replace '{{LAYER_NAME}}', $LayerName `
            -replace '{{LAYER_TITLE}}', $PascalCaseLayerTitle `
            -replace '{{ENTITY_TYPE}}', $EntityType `
            -replace '{{TIMESTAMP}}', (Get-Date -Format "o") `
            -replace '{{GENERATOR}}', "screens-machine-v2.0.0"
        
        # Generate component name
        $componentName = switch($componentType) {
            "ListView" { "List" }
            "DetailView" { "Detail" }
            "CreateForm" { "Create" }
            "EditForm" { "Edit" }
            "GraphView" { "Graph" }
            default { $componentType }
        }
        
        # Generate output filename using PascalCase component title
        $outputFileName = "$PascalCaseLayerTitle${componentName}.tsx"
        
        # Construct full path safely using Join-Path
        $outputFilePath = Join-Path $layerOutputDir $outputFileName
        
        # Write file
        if (-not $DryRun) {
            $output | Out-File -FilePath $outputFilePath -Encoding UTF8 -Force -ErrorAction Stop
            $generatedFiles += @{
                component = $componentType
                file = $outputFileName
                path = $outputFilePath
                bytes = $output.Length
                status = "GENERATED"
            }
            Log "Generated: $outputFileName" "INFO"
        } else {
            Log "DRY_RUN: Would generate $outputFileName" "INFO"
            $generatedFiles += @{
                component = $componentType
                file = $outputFileName
                path = $outputFilePath
                status = "DRY_RUN"
            }
        }
    }
    catch {
        $errorMsg = "Failed to generate $componentType : $_"
        Log $errorMsg "ERROR"
        $errors += $errorMsg
    }
}

# ============================================================================
# EVIDENCE COLLECTION
# ============================================================================

$evidence = @{
    phase = "DO"
    operation = "screen_generation"
    layer_id = $LayerId
    layer_name = $LayerName
    entity_type = $EntityType
    components_planned = $componentTypes.Count
    components_generated = $generatedFiles.Count
    components_failed = $errors.Count
    success_rate = if ($componentTypes.Count -gt 0) { ($generatedFiles.Count / $componentTypes.Count * 100) } else { 0 }
    generated_files = $generatedFiles
    errors = $errors
    timestamp = Get-Date -Format "o"
    generator = "generate-screens-v2.ps1"
    version = "1.0.0"
    dry_run = $DryRun
}

if (-not $DryRun) {
    $evidence | ConvertTo-Json -Depth 5 | Out-File -FilePath $evidenceFile -Encoding UTF8 -Force
    Log "Evidence written to: $evidenceFile" "INFO"
}

# ============================================================================
# SUMMARY
# ============================================================================

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
Log "Generation complete: $($generatedFiles.Count)/$($componentTypes.Count) components - $status" $status

if ($errors.Count -gt 0) {
    exit 1
} else {
    exit 0
}
