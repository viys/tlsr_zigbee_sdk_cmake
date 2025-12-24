function(check_vars)
    foreach(VAR_NAME IN LISTS ARGV)
        if(DEFINED ${VAR_NAME})
            message("${VAR_NAME}: ${${VAR_NAME}}")
        else()
            message(WARNING "${VAR_NAME} is not defined")
        endif()
    endforeach()
endfunction()

function(include_link_file FILE_NAME DIR)
    if(NOT DEFINED FILE_NAME)
        message(FATAL_ERROR "FILE_NAME is not defined")
    endif()

    if(NOT DEFINED DIR)
        set(DIR ${CMAKE_CURRENT_LIST_DIR})  # 默认用当前 CMakeLists.txt 所在目录
    endif()

    set(FULL_PATH "${DIR}/${FILE_NAME}")

    if(EXISTS ${FULL_PATH})
        include(${FULL_PATH})
        message(STATUS "Included link file: ${FULL_PATH}")
    else()
        message(FATAL_ERROR "Link file not found: ${FULL_PATH}")
    endif()
endfunction()
