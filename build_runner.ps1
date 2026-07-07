Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$engineDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $engineDir
$pythonExe = Join-Path $repoRoot '.venv\Scripts\python.exe'
$entryScript = Join-Path $engineDir 'run_web_gui.py'
$iconPath = Join-Path $engineDir 'assets\kinetic.ico'
# If the runner icon is missing, attempt to generate it from the canonical final 256 PNG using ImageMagick (if available).
$iconSourcePng = Join-Path $repoRoot 'WEB\static\images\final_ico\final_256.png'
if (-not (Test-Path $iconPath)) {
    if (Test-Path $iconSourcePng) {
        $magickCmd = Get-Command magick -ErrorAction SilentlyContinue
        if ($magickCmd) {
            Write-Host "Generating $iconPath from $iconSourcePng using ImageMagick..."
            try {
                & magick $iconSourcePng -background none -define icon:auto-resize=256,48,32,16 $iconPath
                if (-not (Test-Path $iconPath)) {
                    Write-Warning "ImageMagick ran but did not produce $iconPath"
                }
            } catch {
                Write-Warning "ImageMagick conversion failed: $_"
            }
        } else {
            Write-Warning "Runner icon $iconPath not found and ImageMagick 'magick' command not available to generate it from $iconSourcePng."
        }
    } else {
        Write-Warning "PNG source for generating runner icon not found at $iconSourcePng"
    }
}
$distDir = Join-Path $engineDir 'dist'
$workDir = Join-Path $engineDir 'build'

if (-not (Test-Path $pythonExe)) {
    throw "Virtual environment Python not found at $pythonExe"
}

if (-not (Test-Path $entryScript)) {
    throw "Runner entry script not found at $entryScript"
}

if (-not (Test-Path $iconPath)) {
    throw "Runner icon not found at $iconPath"
}

$hasPyInstaller = (& $pythonExe -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('PyInstaller') else 1)")
if ($LASTEXITCODE -ne 0) {
    throw "PyInstaller is not installed in the workspace virtual environment. Run: $pythonExe -m pip install pyinstaller"
}

$previousErrorActionPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    & $pythonExe -m PyInstaller `
        --noconfirm `
        --clean `
        --windowed `
        --onedir `
        --name Kinetic `
        --icon $iconPath `
        --distpath $distDir `
        --workpath $workDir `
        --specpath $engineDir `
        --hidden-import pynput.keyboard._win32 `
        --collect-submodules pynput.keyboard `
        --collect-submodules pynput.mouse `
        $entryScript

    if ($LASTEXITCODE -ne 0) {
        throw "PyInstaller build failed with exit code $LASTEXITCODE"
    }
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}

$exePath = Join-Path $distDir 'Kinetic\Kinetic.exe'
if (Test-Path $exePath) {
    Write-Host "Built executable: $exePath"
} else {
    throw "Build completed without producing $exePath"
}