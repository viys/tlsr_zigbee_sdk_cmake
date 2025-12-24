# Gather sources and include directories for the Telink Zigbee SDK.

if(TELINK_MCU_CORE STREQUAL "8258")
    set(MCU_ARCH "8258")
elseif(TELINK_MCU_CORE STREQUAL "b91")
    set(MCU_ARCH "b91")
else()
    message(FATAL_ERROR "Unknown MCU ARCH")
endif()

file(GLOB_RECURSE SDK_SOURCES_VAR
    "${CMAKE_SDK_SOURCE_DIR}/platform/boot/${MCU_ARCH}/link_cfg.S"
    "${CMAKE_SDK_SOURCE_DIR}/platform/boot/${MCU_ARCH}/cstartup_${MCU_ARCH}.S"
    "${CMAKE_SDK_SOURCE_DIR}/platform/tc32/div_mod.S"

    "${CMAKE_SDK_SOURCE_DIR}/proj/*.c"
    "${CMAKE_SDK_SOURCE_DIR}/zigbee/*.c"
    "${CMAKE_SDK_SOURCE_DIR}/zbhci/*.c"

    "${CMAKE_SDK_SOURCE_DIR}/platform/chip_${MCU_ARCH}/*.c"
    "${CMAKE_SDK_SOURCE_DIR}/platform/chip_${MCU_ARCH}/flash/*.c"
    "${CMAKE_SDK_SOURCE_DIR}/platform/services/b85m/*.c"
)

set(INCLUDE_ROOTS
    ${CMAKE_SDK_SOURCE_DIR}/platform/chip_8258
    ${CMAKE_SDK_SOURCE_DIR}/proj
    ${CMAKE_SDK_SOURCE_DIR}/zigbee
    ${CMAKE_SDK_SOURCE_DIR}/zbhci
)

# 遍历每个根目录，递归添加所有子目录到 include
set(ALL_SDK_INCLUDES "")
foreach(root ${INCLUDE_ROOTS})
    # 先添加根目录本身
    list(APPEND ALL_SDK_INCLUDES ${root})

    # 再递归子目录
    file(GLOB_RECURSE DIRS LIST_DIRECTORIES true "${root}/*")
    foreach(d ${DIRS})
        if(IS_DIRECTORY ${d})
            list(APPEND ALL_SDK_INCLUDES ${d})
        endif()
    endforeach()
endforeach()

set(SDK_INCLUDES_VAR
    ${ALL_SDK_INCLUDES}
    ${CMAKE_SDK_SOURCE_DIR}/platform
    ${CMAKE_SDK_SOURCE_DIR}/platform/riscv
)

# Propagate these variables to the parent scope.
set(SDK_SOURCES ${SDK_SOURCES_VAR} PARENT_SCOPE)
set(SDK_INCLUDES ${SDK_INCLUDES_VAR} PARENT_SCOPE)