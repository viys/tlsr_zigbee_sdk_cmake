param (
    [Parameter(Position = 0, Mandatory)]
    [ValidateSet("all", "cmake", "make", "delete", "clean")]
    [string]$Action
)

function Run-CMake {
    # 注意：这里可以更改主 CMakeLists.txt 中的 config.cmake 路径，通过 -C 参数来灵活适配编译
    $cmakeCmd = "cmake -G `"Unix Makefiles`" .."
    Invoke-Expression $cmakeCmd
}

function Run-Make {
    param (
        [string]$Target,
        [int]$Jobs = [Environment]::ProcessorCount
    )
    # $cmd = "cmake --build ."
    # if ($Target) { $cmd += " --target $Target" }
    # Invoke-Expression $cmd

    # 由于 tc32 编译器不支持颜色输出，这里手动添加输出颜色
    $cmd = @("cmake", "--build", ".", "--parallel", $Jobs)
    if ($Target) {
        $cmd += @("--target", $Target)
    }

    & $cmd[0] $cmd[1..($cmd.Count - 1)] 2>&1 |
    ForEach-Object {
        $line = $_

        if ($line -match "(?i)\berror\b") {
            Write-Host $line -ForegroundColor Red
        }
        elseif ($line -match "(?i)\bwarning\b") {
            Write-Host $line -ForegroundColor Yellow
        }
        else {
            Write-Host $line
        }
    }

    if (-not $Target) {
        Write-Host "Build time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
}

function Run-MergenBin {
    param (
        [string]$BootLoader,
        [string]$Target,
        [string]$Offset,
        [string]$OutFile
    )

    if ($OutFile -eq "") {
        Write-Host "No firmware splicing is required."
        return
    }

    $cmd = @($srecodCat, $BootLoader, "-binary", $Target, "-binary", "-offset", $Offset, "-o", $OutFile, "-binary")
    # Write-Host $cmd
    & $cmd[0] $cmd[1..($cmd.Count - 1)]

    # 输出提示
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Merged bin created: $OutFile"
    } else {
        Write-Host "Failed to merge bin" -ForegroundColor Red
    }
}

function Assert-ToolInPath {
    param([Parameter(Mandatory)][string]$ToolName)
    $cmd = Get-Command $ToolName -ErrorAction SilentlyContinue
    if (-not $cmd) {
        Write-Host "$ToolName not found. Please ensure it is installed and added to PATH." -ForegroundColor Red
        exit 1
    }
    # Write-Host "$ToolName detected at $($cmd.Source)"
}

function Get-CMakeLiteralVariable {
    param (
        [Parameter(Mandatory)]
        [string]$CMakeListsPath,

        [Parameter(Mandatory)]
        [string]$VariableName
    )

    if (-not (Test-Path $CMakeListsPath)) {
        throw "CMakeLists file not found: $CMakeListsPath"
    }

    $content = Get-Content $CMakeListsPath -Raw

    # 匹配
    $pattern = @"
set\s*\(\s*$VariableName\s+([A-Za-z0-9_.-]+)\s*\)
"@

    $match = [regex]::Match($content, $pattern)

    if (-not $match.Success) {
        return $null
    }

    $value = $match.Groups[1].Value

    # 如果值里包含 ${}，直接拒绝
    if ($value -match '\$\{') {
        return $null
    }

    return $value
}

Push-Location

$rootPath = $PSScriptRoot
$buildPath = Join-Path $rootPath "build"
$srecodCat = Join-Path $rootPath "tools/srecord/srec_cat.exe"
$projCfgPath = "$rootPath/cmake/config.cmake"
$bootLoaderPath = "$rootPath/bootloader/" + (Get-CMakeLiteralVariable "$projCfgPath" "TELINK_BOOTLOADER_FILE")
$projBinPath = (Get-CMakeLiteralVariable "$projCfgPath" "TELINK_PROJECT_NAME") + ".bin"
$projMergePath = if (($n = (Get-CMakeLiteralVariable $projCfgPath "TELINK_MERGEN_NAME")) -and ($n = $n.Trim())) { "$n.bin" }
$toolChainName = (Get-CMakeLiteralVariable "$projCfgPath" "TELINK_TOOLCHAIN_NAME")
$offsetStr = (Get-CMakeLiteralVariable "$projCfgPath" "TELINK_FW_OFFSET")

Assert-ToolInPath -ToolName "cmake"
Assert-ToolInPath -ToolName "${toolChainName}gcc"

if (-Not (Test-Path $buildPath)) {
    New-Item -Path $buildPath -ItemType Directory | Out-Null
}

Set-Location $buildPath

try {
    switch ($Action) {
        "all" {
            Run-CMake
            Run-Make
            Run-MergenBin $bootLoaderPath $projBinPath $offsetStr $projMergePath
        }
        "cmake" {
            Run-CMake
        }
        "make" {
            Run-Make -Jobs 8
            Run-MergenBin $bootLoaderPath $projBinPath $offsetStr $projMergePath
        }
        "clean" {
            Run-Make -Target "clean"
        }
        "delete" {
            Pop-Location
            if (Test-Path $buildPath) {
                Remove-Item -Path $buildPath -Recurse -Force
            }
        }
    }
} finally {
    Pop-Location
}
