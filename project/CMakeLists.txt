# Gather sources and include directories for the application project.

file(GLOB_RECURSE PROJECT_SOURCES_VAR
    "${CMAKE_CURRENT_SOURCE_DIR}/sampleLight/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/common/*.c"
)

set(PROJECT_INCLUDES_VAR
    "${CMAKE_CURRENT_SOURCE_DIR}/sampleLight"
    "${CMAKE_CURRENT_SOURCE_DIR}/common"
)

# Propagate these variables to the parent scope.
set(PROJECT_SOURCES ${PROJECT_SOURCES_VAR} PARENT_SCOPE)
set(PROJECT_INCLUDES ${PROJECT_INCLUDES_VAR} PARENT_SCOPE)