文件目录如下

```
tlsr_zigbee_sdk_cmake/
├── CMakeLists.txt          # 顶层 CMakeLists
├── cmake/
│   ├── CMakeLists.txt      # tl_zigbee_sdk 层调度
│   ├── config.cmake        # 配置项
│   ├── functions.cmake     # CMake 函数
│   ├── link_trsl8285.cmake # 链接参数
│   └── toolchain.cmake     # 工具链
│
├── tl_zigbee_sdk			# SDK 包
│
├── project
│   └── CMakeLists.txt      # project 层调度
│
├── build/                  # out-of-tree build
└ ...
```