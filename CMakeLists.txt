cmake_minimum_required(VERSION 3.10)

# 配置文件
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.cmake)
include(${CMAKE_SCRIPT_DIR}/${TELINK_TOOLCHAIN_FILE})
include(${CMAKE_SCRIPT_DIR}/${TELINK_LINK_FILE})

# 项目名称
project(${TELINK_PROJECT_NAME} C ASM)

# 子目录
add_subdirectory(project)
add_subdirectory(cmake)

# 源文件路径
add_executable(${PROJECT_NAME} ${PROJECT_SOURCES} ${SDK_SOURCES})

# 头文件路径
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDES} ${SDK_INCLUDES})

# 编译宏
target_compile_definitions(${PROJECT_NAME} PRIVATE ${TELINK_COMPILE_DEFINITIONS})

# 链接选项

target_link_options(${PROJECT_NAME} PRIVATE -Wl,-Map=${PROJECT_NAME}.map ${TELINK_LINK_FLAGS})

# 链接库路径
target_link_libraries(${PROJECT_NAME} PRIVATE ${TELINK_LIBS})

# 生成 bin / lst
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJDUMP} -D $<TARGET_FILE:${PROJECT_NAME}> > ${PROJECT_NAME}.lst
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
)