# toolchain.cmake
# 用于设置编译器工具链

# 系统类型
set(CMAKE_SYSTEM_NAME Generic)

# 拼接编译器路径
set(CMAKE_C_COMPILER     "${TELINK_TOOLCHAIN_PATH}gcc.exe")
set(CMAKE_ASM_COMPILER   "${TELINK_TOOLCHAIN_PATH}gcc.exe")
set(CMAKE_AR             "${TELINK_TOOLCHAIN_PATH}ar.exe")
set(CMAKE_OBJCOPY        "${TELINK_TOOLCHAIN_PATH}objcopy.exe")
set(CMAKE_OBJDUMP        "${TELINK_TOOLCHAIN_PATH}objdump.exe")
set(CMAKE_SIZE           "${TELINK_TOOLCHAIN_PATH}size.exe")
set(CMAKE_STRIP          "${TELINK_TOOLCHAIN_PATH}strip.exe")

# 设置 C 标准和避免自动链接 libc
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_LIBRARIES "")
set(CMAKE_CXX_STANDARD_LIBRARIES "")

# 编译选项
set(DEFAULT_COMPILE_OPTIONS
    -Wall
    -O2
    -fpack-struct
    -fshort-enums
    -finline-small-functions
    -fshort-wchar
    -fms-extensions
    -std=gnu99
    -ffunction-sections
    -fdata-sections
)

# 设置默认生成静态库
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# 全局添加编译选项
add_compile_options(${DEFAULT_COMPILE_OPTIONS})
