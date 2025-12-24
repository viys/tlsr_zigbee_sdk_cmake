cmake_minimum_required(VERSION 3.10)

set(CMAKE_SDK_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/tl_zigbee_sdk)
set(CMAKE_PROJ_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/project)
set(CMAKE_SCRIPT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(${CMAKE_SCRIPT_DIR}/config.cmake)
include(${CMAKE_SCRIPT_DIR}/${TELINK_LINK_FILE})

project(tlsr C ASM)

# ---------- 源文件 ----------
file(GLOB_RECURSE SOURCES
    ${CMAKE_PROJ_SOURCE_DIR}/sampleLight/*.c
    ${CMAKE_PROJ_SOURCE_DIR}/common/*.c

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

# ---------- 创建 target ----------
add_executable(${PROJECT_NAME} ${SOURCES})

# ------ 头文件路径 ------
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
    ${CMAKE_PROJ_SOURCE_DIR}/sampleLight
    ${CMAKE_PROJ_SOURCE_DIR}/common
    ${CMAKE_SDK_SOURCE_DIR}/platform
    ${CMAKE_SDK_SOURCE_DIR}/platform/riscv
)

target_include_directories(${PROJECT_NAME} PRIVATE ${ALL_INCLUDE_DIRS})
# ---------- 编译宏 ----------
target_compile_definitions(${PROJECT_NAME} PRIVATE ${TELINK_COMPILE_DEFINITIONS})
# ---------- 链接选项 ----------
target_link_options(${PROJECT_NAME} PRIVATE -Wl,-Map=${PROJECT_NAME}.map ${TELINK_LINK_FLAGS})
# ---------- 链接库路径 ----------
target_link_libraries(${PROJECT_NAME} PRIVATE ${TELINK_LIBS})
# ---------- 生成 bin / lst ----------
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJDUMP} -D $<TARGET_FILE:${PROJECT_NAME}> > ${PROJECT_NAME}.lst
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
)