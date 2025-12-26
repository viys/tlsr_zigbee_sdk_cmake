# 用于链接相关配置

set(TELINK_LINK_FLAGS
    -T${TELINK_LINKER_SCRIPT}
    -nostdlib -nostartfiles -nodefaultlibs
    -Wl,--gc-sections
    -static
    -Wl,--cref
    -Wl,-defsym=__BOOT_LOADER_IMAGE=${TELINK_BOOTLOADER_IMAGE}
    -Wl,-defsym=__FW_RAMCODE_SIZE_MAX=${TELINK_RAMCODE_MAX}
    -Wl,-defsym=__FW_OFFSET=${TELINK_FW_OFFSET}
)

# 要在这里做出选择
if (TELINK_EQUIP_TYPE STREQUAL "ZC")
    set(TELINK_LIB_ZB
        ${CMAKE_SDK_SOURCE_DIR}/zigbee/lib/tc32/libzb_coordinator.a
    )
elseif(TELINK_EQUIP_TYPE STREQUAL "ZR")
    set(TELINK_LIB_ZB
        ${CMAKE_SDK_SOURCE_DIR}/zigbee/lib/tc32/libzb_router.a
    )
elseif(TELINK_EQUIP_TYPE STREQUAL "ZED")
    set(TELINK_LIB_ZB
        ${CMAKE_SDK_SOURCE_DIR}/zigbee/lib/tc32/libzb_ed.a
    )
else()
    message(FATAL_ERROR "Unknown TELINK_EQUIP_TYPE: ${TELINK_EQUIP_TYPE}")
endif()

set(TELINK_LIB_PLATFORM
    ${CMAKE_SDK_SOURCE_DIR}/platform/tc32/libsoft-fp.a
    ${CMAKE_SDK_SOURCE_DIR}/platform/lib/libdrivers_8258.a
    ${CMAKE_SDK_SOURCE_DIR}/platform/riscv/libfirmware_encrypt.a
)

set(TELINK_LIBS
    ${TELINK_LIB_PLATFORM}
    ${TELINK_LIB_ZB}
)
