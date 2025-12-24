set(CMAKE_SDK_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../tl_zigbee_sdk)

# 添加源文件路径
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
    ${CMAKE_SDK_SOURCE_DIR}/platform/boot/8258/link_cfg.S
    ${CMAKE_SDK_SOURCE_DIR}/platform/boot/8258/cstartup_8258.S
    ${CMAKE_SDK_SOURCE_DIR}/platform/tc32/div_mod.S

    ${CMAKE_SDK_SOURCE_DIR}/proj/*.c
    ${CMAKE_SDK_SOURCE_DIR}/zigbee/*.c
    ${CMAKE_SDK_SOURCE_DIR}/zbhci/*.c

    ${CMAKE_SDK_SOURCE_DIR}/platform/chip_8258/*.c
    ${CMAKE_SDK_SOURCE_DIR}/platform/chip_8258/flash/*.c
    ${CMAKE_SDK_SOURCE_DIR}/platform/services/b85m/*.c
)

# foreach(ASM_FILE IN LISTS SOURCES)
#     if(ASM_FILE MATCHES "\\.S$")
#         set_source_files_properties(${ASM_FILE} PROPERTIES LANGUAGE ASM)
#     endif()
# endforeach()

# 添加静态库
add_library(tl_zigbee_sdk_static STATIC ${SOURCES})

# 添加头文库路径
set(INCLUDE_ROOTS
    ${CMAKE_SDK_SOURCE_DIR}/platform/chip_8258
    ${CMAKE_SDK_SOURCE_DIR}/proj
    ${CMAKE_SDK_SOURCE_DIR}/zigbee
    ${CMAKE_SDK_SOURCE_DIR}/zbhci
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
    ${CMAKE_SDK_SOURCE_DIR}/platform
    ${CMAKE_SDK_SOURCE_DIR}/platform/riscv
)
# 添加 include 路径到 target
target_include_directories(tl_zigbee_sdk_static PUBLIC ${ALL_INCLUDE_DIRS})

# 创建接口库
add_library(tl_zigbee_sdk INTERFACE)
# 将静态库作为接口库的依赖
target_link_libraries(tl_zigbee_sdk INTERFACE tl_zigbee_sdk_static)


cmake_minimum_required(VERSION 3.10)
project(tl_zigbee_sdk C ASM)

# ---------- 源文件 ----------
file(GLOB_RECURSE SDK_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/boot/8258/*.S
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/tc32/*.S
    ${CMAKE_CURRENT_SOURCE_DIR}/proj/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/zigbee/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/zbhci/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/chip_8258/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/chip_8258/flash/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/services/b85m/*.c
)

# 设置 ASM 文件属性
foreach(ASM_FILE IN LISTS SDK_SOURCES)
    if(ASM_FILE MATCHES "\\.S$")
        set_source_files_properties(${ASM_FILE} PROPERTIES LANGUAGE ASM)
    endif()
endforeach()

# ---------- 创建静态库 ----------
add_library(tl_zigbee_sdk_static STATIC ${SDK_SOURCES})

# ---------- include 路径 ----------
set(INCLUDE_ROOTS
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/chip_8258
    ${CMAKE_CURRENT_SOURCE_DIR}/proj
    ${CMAKE_CURRENT_SOURCE_DIR}/zigbee
    ${CMAKE_CURRENT_SOURCE_DIR}/zbhci
    ${CMAKE_CURRENT_SOURCE_DIR}/platform
    ${CMAKE_CURRENT_SOURCE_DIR}/platform/riscv
)

target_include_directories(tl_zigbee_sdk_static PUBLIC ${INCLUDE_ROOTS})

# ---------- 接口库 ----------
add_library(tl_zigbee_sdk INTERFACE)
target_link_libraries(tl_zigbee_sdk INTERFACE tl_zigbee_sdk_static)

# ---------- 编译选项（针对 TC32 移除不支持的 GCC 选项） ----------
target_compile_options(tl_zigbee_sdk_static PRIVATE
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