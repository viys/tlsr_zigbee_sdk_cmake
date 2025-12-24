cmake_minimum_required(VERSION 3.10)

# ---------- 工具链 ----------
set(TOOLPATH "${CMAKE_CURRENT_SOURCE_DIR}/toolchain/tc32/bin/tc32-elf-")

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_C_COMPILER     ${TOOLPATH}gcc.exe)
set(CMAKE_ASM_COMPILER   ${TOOLPATH}gcc.exe)
set(CMAKE_AR             ${TOOLPATH}ar.exe)
set(CMAKE_OBJCOPY        ${TOOLPATH}objcopy.exe)
set(CMAKE_OBJDUMP        ${TOOLPATH}objdump.exe)
set(CMAKE_SIZE           ${TOOLPATH}size.exe)
set(CMAKE_STRIP          ${TOOLPATH}strip.exe)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

# ---------- 避免自动链接 stdlib ----------
set(CMAKE_C_STANDARD_LIBRARIES "")
set(CMAKE_CXX_STANDARD_LIBRARIES "")
set(CMAKE_C_STANDARD 99)

project(tlsr C ASM)

# ---------- 源文件 ----------
file(GLOB_RECURSE SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/boot/8258/link_cfg.S
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/boot/8258/cstartup_8258.S
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/tc32/div_mod.S

    ${CMAKE_CURRENT_SOURCE_DIR}/apps/sampleLight/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/apps/common/*.c

    ${CMAKE_CURRENT_SOURCE_DIR}/proj/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/zigbee/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/zbhci/*.c

    ${CMAKE_CURRENT_SOURCE_DIR}/platform/chip_8258/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/chip_8258/flash/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/services/b85m/*.c
)

foreach(ASM_FILE IN LISTS SOURCES)
    if(ASM_FILE MATCHES "\\.S$")
        set_source_files_properties(${ASM_FILE} PROPERTIES LANGUAGE ASM)
    endif()
endforeach()

# ---------- 创建 target ----------
add_executable(${PROJECT_NAME} ${SOURCES})

# ------ 头文件路径 ------
set(INCLUDE_ROOTS
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/chip_8258
    ${CMAKE_CURRENT_SOURCE_DIR}/proj
    ${CMAKE_CURRENT_SOURCE_DIR}/zigbee
    ${CMAKE_CURRENT_SOURCE_DIR}/zbhci
)

# 遍历每个根目录，递归添加所有子目录到 include
set(ALL_INCLUDE_DIRS "")
foreach(root ${INCLUDE_ROOTS})
    # 先添加根目录本身
    list(APPEND ALL_INCLUDE_DIRS ${root})

    # 再递归子目录
    file(GLOB_RECURSE DIRS LIST_DIRECTORIES true "${root}/*")
    foreach(d ${DIRS})
        if(IS_DIRECTORY ${d})
            list(APPEND ALL_INCLUDE_DIRS ${d})
        endif()
    endforeach()
endforeach()

list(APPEND ALL_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/apps/sampleLight
    ${CMAKE_CURRENT_SOURCE_DIR}/apps/common
    ${CMAKE_CURRENT_SOURCE_DIR}/platform
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/riscv
)
# 添加 include 路径到 target
target_include_directories(${PROJECT_NAME} PRIVATE ${ALL_INCLUDE_DIRS})

# ---------- 编译宏 ----------
target_compile_definitions(${PROJECT_NAME} PRIVATE
    MCU_CORE_8258=1
    MCU_STARTUP_8258=1
    ROUTER=1
    __PROJECT_TL_DIMMABLE_LIGHT__=1
)

# ---------- 编译选项 ----------
target_compile_options(${PROJECT_NAME} PRIVATE
    -Wall
    -O2
    -fpack-struct
    -fshort-enums
    -finline-small-functions
    -fshort-wchar
    -fms-extensions
    -std=gnu99
    $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
)

# ---------- 链接选项 ----------
# BootLoader
# set(TELINK_BOOTLOADER_IMAGE 1)      # IS_BOOT_LOADER_IMAGE
# set(TELINK_RAMCODE_MAX 0x2000)      # RESV_FOR_APP_RAM_CODE_SIZE
# set(TELINK_FW_OFFSET 0x8000)        # APP_IMAGE_ADDR
# Application
set(TELINK_BOOTLOADER_IMAGE 0)      # IS_BOOT_LOADER_IMAGE
set(TELINK_RAMCODE_MAX 0)           # RESV_FOR_APP_RAM_CODE_SIZE
set(TELINK_FW_OFFSET 0x0000)        # APP_IMAGE_ADDR

target_link_options(${PROJECT_NAME} PRIVATE
    # -T${CMAKE_CURRENT_SOURCE_DIR}/boot.link
    -T${CMAKE_CURRENT_SOURCE_DIR}/platform/boot/8258/boot_8258.link
    -nostdlib -nostartfiles -nodefaultlibs
    -Wl,-Map=${PROJECT_NAME}.map
    -Wl,--gc-sections
    -static
    -Wl,--cref
    -Wl,-defsym=__BOOT_LOADER_IMAGE=${TELINK_BOOTLOADER_IMAGE}
    -Wl,-defsym=__FW_RAMCODE_SIZE_MAX=${TELINK_RAMCODE_MAX}
    -Wl,-defsym=__FW_OFFSET=${TELINK_FW_OFFSET}
)

# ---------- 链接库路径 ----------
link_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/zigbee/lib/tc32
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/lib
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/riscv
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/tc32/libsoft-fp.a
    ${CMAKE_CURRENT_SOURCE_DIR}/zigbee/lib/tc32/libzb_router.a
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/lib/libdrivers_8258.a
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/riscv/libfirmware_encrypt.a
)

# ---------- 生成 bin / lst ----------
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJDUMP} -D $<TARGET_FILE:${PROJECT_NAME}> > ${PROJECT_NAME}.lst
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
)