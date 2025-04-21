find_package(Python3 REQUIRED COMPONENTS Interpreter)

macro(set_inverse VAR_NAME VALUE)
    if(${VALUE})
        set(${VAR_NAME} FALSE)
    else()
        set(${VAR_NAME} TRUE)
    endif()
endmacro()

function(add_sync_target TARGET_NAME SOURCE_DIR TARGET_DIR)
    add_custom_target(${TARGET_NAME} ALL
            COMMAND ${Python3_EXECUTABLE} "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/remove_missing_files.py" "${SOURCE_DIR}" "${TARGET_DIR}"
            COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different "${DATA_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/assets"
            COMMENT "Copying assets..."
    )
endfunction()

function(copy_shared TARGET LIBRARY)
    add_custom_command (TARGET ${TARGET} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:${LIBRARY}> $<TARGET_FILE_DIR:${TARGET}>
    )
endfunction()
