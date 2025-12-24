我先给你一套**长期可维护的 Telink 8258 + CMake 工程结构**，然后再把你“没看懂”的那段话**从链接器视角掰开揉碎**，保证你以后看到 `-nostdlib + add_executable` 再也不迷糊。

------

# 一、一次性整理：长期可维护的工程结构（实战版）

目标很明确：

- 裸机 MCU（无 OS）
- Telink SDK（历史包袱多）
- GCC / CMake
- 支持：
  - app / bootloader应用程序/引导加载程序
  - elf / bin / map精灵/箱子/地图
  - 可裁剪模块
  - **不靠运气构建**

------

## 1️⃣ 推荐的目录结构（你现在的工程可以平滑迁）

```
tlsr_zigbee_sdk_cmake/
├── CMakeLists.txt          # 顶层调度
├── cmake/
│   ├── common.cmake        # 公共编译/链接规则
│   ├── functions.cmake     # 自定义函数
│   ├── options.cmake       # 编译选项 / 宏
│   └── toolchain.cmake     # 工具链（强烈推荐拆出来）
│
├── tl_zigbee_sdk
│
├── project
│
├── build/                  # out-of-tree build
└ ...
```

这个结构的核心思想只有一句话：

> **SDK 是 SDK，App 是 App，构建逻辑集中在 cmake/**

------

## 2️⃣ toolchain 文件（避免污染主 CMakeLists）

```
cmake/toolchain-tc32.cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(TOOLCHAIN_PREFIX tc32-elf)
set(TOOLCHAIN_DIR ${CMAKE_SOURCE_DIR}/toolchain/tc32/bin)

set(CMAKE_C_COMPILER   ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-gcc.exe)
set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_AR           ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-ar.exe)
set(CMAKE_OBJCOPY      ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-objcopy.exe)
set(CMAKE_OBJDUMP      ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-objdump.exe)
set(CMAKE_SIZE         ${TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-size.exe)
```

顶层用法：

```
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-tc32.cmake
```

这是**工业级 CMake 的基本礼仪**。

------

## 3️⃣ “正确的”可维护 target 定义方式

### 核心原则

- **永远不要直接操作文件名**
- **永远通过 target**

```
add_executable(tlsr)

target_sources(tlsr PRIVATE
    platform/boot/8258/cstartup_8258.S
    platform/chip_8258/flash.c
    ...
)

target_include_directories(tlsr PRIVATE
    platform
    platform/chip_8258
    apps/sampleLight
)
```

------

## 4️⃣ 链接规则（这是裸机的灵魂）

```
target_link_options(tlsr PRIVATE
    -T${CMAKE_SOURCE_DIR}/platform/boot/8258/boot_8258.link
    -nostdlib
    -nostartfiles
    -nodefaultlibs
    -Wl,--gc-sections
    -Wl,-Map=$<TARGET_FILE_BASE_NAME:tlsr>.map
)
```

注意这里已经开始用 **generator expression**，这是长期维护的关键。

------

## 5️⃣ 生成 bin / lst / size（跨平台、零歧义）

```
add_custom_command(TARGET tlsr POST_BUILD
    COMMAND ${CMAKE_OBJCOPY}
            -O binary
            $<TARGET_FILE:tlsr>
            $<TARGET_FILE_BASE_NAME:tlsr>.bin

    COMMAND ${CMAKE_OBJDUMP}
            -D $<TARGET_FILE:tlsr>
            > $<TARGET_FILE_BASE_NAME:tlsr>.lst

    COMMAND ${CMAKE_SIZE}
            $<TARGET_FILE:tlsr>
)
```