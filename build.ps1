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
    $cmakeCmd = "cmake -G `"Unix Makefiles`" -DCMAKE_TOOLCHAIN_FILE=`"$toolChainFile`" .."
    Invoke-Expression $cmakeCmd
}

function Run-Make {
    param (
        [string]$Target
    )
    $cmd = "cmake --build ."
    if ($Target) { $cmd += " --target $Target" }
    Invoke-Expression $cmd
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
    if (Test-Path $buildPath) { Pop-Location }
}
