set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR wasm32)
set(CMAKE_SYSTEM_VERSION 1)

message(STATUS "Using toolchain file for WebAssembly: ${CMAKE_TOOLCHAIN_FILE}")

set(CMAKE_CROSSCOMPILING YES)

set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET "wasm32")
set(CMAKE_EXECUTABLE_SUFFIX_C ".wasm")

set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_CXX_COMPILER_TARGET "wasm32")
set(CMAKE_EXECUTABLE_SUFFIX_CXX ".wasm")

set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

set(WASM32_COMPILER_FLAGS "")
string(APPEND WASM32_COMPILER_FLAGS " --no-standard-libraries")
string(APPEND WASM32_COMPILER_FLAGS " -msimd128")
string(APPEND WASM32_COMPILER_FLAGS " -mrelaxed-simd")
string(APPEND WASM32_COMPILER_FLAGS " -mbulk-memory")
string(APPEND WASM32_COMPILER_FLAGS " -mextended-const")
string(APPEND WASM32_COMPILER_FLAGS " -mmultivalue")
string(APPEND WASM32_COMPILER_FLAGS " -mnontrapping-fptoint")
string(APPEND WASM32_COMPILER_FLAGS " -mtail-call")
string(APPEND WASM32_COMPILER_FLAGS " -fwasm-exceptions")
string(APPEND WASM32_COMPILER_FLAGS " -matomics")
string(APPEND WASM32_COMPILER_FLAGS " -mreference-types")

set(WASM32_STACK_SIZE 16777216) # 16MB
set(WASM32_LINKER_FLAGS " -Wl,--no-entry -Wl,--export-all -Wl,-z,stack-size=${WASM32_STACK_SIZE}")

string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT "${WASM32_COMPILER_FLAGS}${WASM32_LINKER_FLAGS}")
string(APPEND CMAKE_C_FLAGS_INIT "${WASM32_COMPILER_FLAGS}")
string(APPEND CMAKE_CXX_FLAGS_INIT "${WASM32_COMPILER_FLAGS}")

unset(WIN32)
unset(APPLE)
unset(UNIX)
set(WASM32 YES)

function(add_wasm_library TARGET_NAME TYPE)
    cmake_parse_arguments(WL "" "" "SOURCES;JS_FILES" ${ARGN})
    add_library(${TARGET_NAME} ${TYPE} ${WL_SOURCES})

    set_target_properties(${TARGET_NAME} PROPERTIES JS_FILES "${WL_JS_FILES}")
    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory $<TARGET_FILE_DIR:${TARGET_NAME}>
    )

    foreach (JS_FILE IN LISTS WL_JS_FILES)
        get_filename_component(JS_FILE "${JS_FILE}" ABSOLUTE)
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different ${JS_FILE} $<TARGET_FILE_DIR:${TARGET_NAME}>
        )
    endforeach ()
endfunction()