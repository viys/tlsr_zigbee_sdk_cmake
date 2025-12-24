param (
    [Parameter(Position = 0, Mandatory)]
    [ValidateSet("all", "cmake", "make", "delete", "clean")]
    [string]$Action
)

$buildPath = "./build"
$toolChainFile = "../cmake/toolchain_tc32.cmake"

function Ensure-BuildDirectory {
    if (-Not (Test-Path $buildPath)) {
        New-Item -Path $buildPath -ItemType Directory | Out-Null
    }
}

function Run-CMake {
    # 注意：这里可以更改主 CMakeLists.txt 中的 config.cmake 路径，通过 -C 参数来灵活适配编译
    $cmakeCmd = "cmake -G `"Unix Makefiles`" .."
    Invoke-Expression $cmakeCmd
}

function Run-Make {
    param (
        [string]$Target
    )
    $cmd = "cmake --build ."
    if ($Target) { $cmd += " --target $Target" }
    Invoke-Expression $cmd

    if (-not $Target) {
        $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "Build time: $now"
    }
}

Push-Location
try {
    switch ($Action) {
        "all" {
            Ensure-BuildDirectory
            Set-Location $buildPath
            Run-CMake
            Run-Make
        }
        "cmake" {
            Ensure-BuildDirectory
            Set-Location $buildPath
            Run-CMake
        }
        "make" {
            Set-Location $buildPath
            Run-Make
        }
        "clean" {
            Set-Location $buildPath
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
