# ============================================================
# Agentic LLM Compression System - Service Launcher
# ============================================================
# This script starts all microservices and the Django dashboard.
# Usage: .\start_services.ps1
# Stop:  Stop-Process -Name python
# ============================================================

$repoRoot = Get-Location

# Set PYTHONPATH to include all source directories
$env:PYTHONPATH = @(
    "$repoRoot",
    "$repoRoot/libs",
    "$repoRoot/microservices/orchestrator/src",
    "$repoRoot/microservices/distillation/src",
    "$repoRoot/microservices/pruning/src",
    "$repoRoot/microservices/quantization/src"
) -join ";"

$env:PYTHONDONTWRITEBYTECODE = "1"

# Load .env file if it exists
$envFile = Join-Path $repoRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
    Write-Host "[ENV] Loaded environment variables from .env" -ForegroundColor Gray
}

# Set Service URLs for Local Development
$env:ORCHESTRATOR_SERVICE_URL = "http://localhost:8000"
$env:DISTILLATION_SERVICE_URL = "http://localhost:8001"
$env:PRUNING_SERVICE_URL = "http://localhost:8004"
$env:QUANTIZATION_SERVICE_URL = "http://localhost:8005"
$env:REDIS_URL = "redis://localhost:6379/0"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   AGENTIC LLM COMPRESSION SYSTEM - SERVICE LAUNCHER   " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Start Redis (Optional - Fallback to in-memory if not available)
Write-Host "[1/6] REDIS INFRASTRUCTURE" -ForegroundColor Yellow
$redisProcess = Get-Process redis-server -ErrorAction SilentlyContinue
if ($null -eq $redisProcess) {
    if (Get-Command "redis-server.exe" -ErrorAction SilentlyContinue) {
        Start-Process "redis-server.exe" -WindowStyle Hidden
        Write-Host "   [OK] Redis Server started." -ForegroundColor Green
    } else {
        Write-Host "   [SKIP] Redis not found. Using in-memory fallback." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "   [OK] Redis is already running." -ForegroundColor Green
}

# 2. Start Microservices
Write-Host ""
Write-Host "[2-5] STARTING MICROSERVICES" -ForegroundColor Yellow

$logsDir = Join-Path $repoRoot "logs"
if (!(Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir }

$services = @(
    @("Orchestrator",   "microservices/orchestrator/src/main.py",    "8000"),
    @("Distillation",   "microservices/distillation/src/app.py",     "8001"),
    @("Pruning",        "microservices/pruning/src/app.py",          "8004"),
    @("Quantization",   "microservices/quantization/src/app.py",     "8005")
)

$pids = @()

try {
    foreach ($s in $services) {
        $name = $s[0]
        $path = $s[1]
        $port = $s[2]
        $logFile = Join-Path $logsDir "$($name.ToLower()).log"
        Write-Host "   [STARTING] $name on PORT $port (Logs: logs/$($name.ToLower()).log)..." -ForegroundColor Gray
        
        $proc = Start-Process python -ArgumentList $path -WorkingDirectory $repoRoot -RedirectStandardOutput $logFile -RedirectStandardError $logFile -WindowStyle Hidden -PassThru
        $pids += $proc.Id
    }

    Start-Sleep -Seconds 3

    # 3. Start Web UI (Django)
    Write-Host ""
    Write-Host "[6/6] DJANGO DASHBOARD" -ForegroundColor Yellow
    $djangoPath = Join-Path $repoRoot "microservices/web_ui"
    $uiProc = Start-Process python -ArgumentList "manage.py","runserver","8003" -WorkingDirectory $djangoPath -PassThru
    $pids += $uiProc.Id
    Write-Host "   [OK] Dashboard launched on http://localhost:8003" -ForegroundColor Green

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "   SYSTEM IS RUNNING. PRESS 'CTRL+C' TO STOP ALL.       " -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Dashboard:     http://localhost:8003"
    Write-Host "   Orchestrator:  http://localhost:8000/docs"
    Write-Host ""

    # Keep script alive to manage children
    while($true) { Start-Sleep -Seconds 1 }

} finally {
    Write-Host "`nStopping all services..." -ForegroundColor Red
    foreach ($pid in $pids) {
        try {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
            Write-Host "   Stopped process $pid" -ForegroundColor Gray
        } catch {}
    }
    Write-Host "All services stopped." -ForegroundColor Green
}
