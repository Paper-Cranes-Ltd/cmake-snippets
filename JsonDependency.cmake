macro(get_range_end VAR_NAME COUNT)
    math(EXPR ${VAR_NAME} "${${COUNT}} - 1")
    if(${VAR_NAME} EQUAL -1)
        set(${VAR_NAME} 0)
    endif()
endmacro()

function(json_config_dependencies)
    include(FetchContent)
    
    set(SINGLE_OPTIONS ROOT)
    set(ONE_VALUE_ARGS FILE)
    set(MULTI_VALUE_ARGS MEMBER_SELECTOR)
    cmake_parse_arguments(JSON_CONFIG "${SINGLE_OPTIONS}" "${ONE_VALUE_ARGS}" "${MULTI_VALUE_ARGS}" ${ARGN})
    
    set_property(
            DIRECTORY
            APPEND
            PROPERTY CMAKE_CONFIGURE_DEPENDS JSON_CONFIG_FILE
    )
    
    set(FETCHCONTENT_QUIET FALSE)
    set(DEPENDENCY_COMMON_OPTIONS)
    list(APPEND DEPENDENCY_COMMON_OPTIONS GIT_SHALLOW YES)
    list(APPEND DEPENDENCY_COMMON_OPTIONS GIT_REMOTE_UPDATE_STRATEGY CHECKOUT)
    list(APPEND DEPENDENCY_COMMON_OPTIONS GIT_PROGRESS ON)
    
    if(JSON_CONFIG_ROOT)
        set(JSON_CONFIG_MEMBER_SELECTOR "")
    endif()
    
    file(READ ${JSON_CONFIG_FILE} CONFIG_FILE)
    string(JSON DEPENDENCIES_COUNT LENGTH "${CONFIG_FILE}" ${JSON_CONFIG_MEMBER_SELECTOR})
    get_range_end(DEPENDENCIES_RANGE_END DEPENDENCIES_COUNT)
    
    foreach(INDEX RANGE 0 "${DEPENDENCIES_RANGE_END}")
        string(JSON DEPENDENCY_JSON GET "${CONFIG_FILE}" ${JSON_CONFIG_MEMBER_SELECTOR} "${INDEX}")
        string(JSON DEPENDENCY_NAME GET "${DEPENDENCY_JSON}" "name")
        string(JSON DEPENDENCY_URL GET "${DEPENDENCY_JSON}" "url")
        string(JSON DEPENDENCY_VERSION GET "${DEPENDENCY_JSON}" "version")
        string(JSON DEPENDENCY_OPTIONS ERROR_VARIABLE OPTIONS_MISSING GET "${DEPENDENCY_JSON}" "options")
        string(JSON DEPENDENCY_RECURSE_SUBMODULES ERROR_VARIABLE RECURSE_SUBMODULES_MISSING GET "${DEPENDENCY_JSON}" "recurse_submodules")
        string(JSON DEPENDENCY_SUBMODULES ERROR_VARIABLE SUBMODULES_MISSING GET "${DEPENDENCY_JSON}" "submodules")
        
        string(CONFIGURE ${DEPENDENCY_VERSION} DEPENDENCY_VERSION)
        message(STATUS "Processing dependency: ${DEPENDENCY_NAME} - " ${DEPENDENCY_VERSION})
        
        set(DEPENDENCY_CUSTOM_OPTIONS)
        
        if(RECURSE_SUBMODULES_MISSING)
            list(APPEND DEPENDENCY_CUSTOM_OPTIONS GIT_SUBMODULES_RECURSE YES)
        else()
            message(STATUS "Recursing submodules: ${DEPENDENCY_RECURSE_SUBMODULES}")
            list(APPEND DEPENDENCY_CUSTOM_OPTIONS GIT_SUBMODULES_RECURSE "${DEPENDENCY_RECURSE_SUBMODULES}")
            
            if(NOT SUBMODULES_MISSING)
                set(SUBMODULES_TO_INITIALIZE)
                string(JSON SUBMODULES_COUNT LENGTH "${DEPENDENCY_SUBMODULES}")
                get_range_end(SUBMODULES_RANGE_END SUBMODULES_COUNT)
                
                foreach(SUBMODULE_INDEX RANGE 0 ${SUBMODULES_RANGE_END})
                    string(JSON SUBMODULE GET "${DEPENDENCY_SUBMODULES}" "${SUBMODULE_INDEX}")
                    message(STATUS "Initializing submodule: ${SUBMODULE}")
                    list(APPEND SUBMODULES_TO_INITIALIZE ${SUBMODULE})
                endforeach()
                
                list(APPEND DEPENDENCY_CUSTOM_OPTIONS GIT_SUBMODULES ${SUBMODULES_TO_INITIALIZE})
            endif()
        endif()
        
        fetchcontent_declare(
                "${DEPENDENCY_NAME}"
                GIT_REPOSITORY "${DEPENDENCY_URL}"
                GIT_TAG "${DEPENDENCY_VERSION}"
                ${DEPENDENCY_CUSTOM_OPTIONS}
                ${DEPENDENCY_COMMON_OPTIONS}
        )
        
        if(NOT "${DEPENDENCY_OPTIONS}" MATCHES "NOTFOUND$")
            string(JSON OPTIONS_COUNT LENGTH "${DEPENDENCY_OPTIONS}")
            get_range_end(OPTIONS_RANGE_END OPTIONS_COUNT)
            
            foreach(OPTION_INDEX RANGE 0 ${OPTIONS_RANGE_END})
                string(JSON OPTION_INFO GET "${DEPENDENCY_OPTIONS}" "${OPTION_INDEX}")
                string(JSON OPTION_NAME GET "${OPTION_INFO}" "name")
                string(JSON OPTION_VALUE GET "${OPTION_INFO}" "value")
                
                set("${OPTION_NAME}" "${OPTION_VALUE}" CACHE INTERNAL "")
            endforeach()
        endif()
        
        fetchcontent_makeavailable("${DEPENDENCY_NAME}")
    endforeach()
endfunction()
