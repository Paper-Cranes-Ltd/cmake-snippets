function(get_wgpu_native VERSION_TAG)
    include(FindPackageHandleStandardArgs)
    include(FetchContent)


    fetchcontent_declare(wgpu_native
            GIT_REPOSITORY "https://github.com/gfx-rs/wgpu-native.git"
            GIT_TAG "${VERSION_TAG}"
            GIT_SUBMODULES_RECURSE YES
            GIT_SHALLOW YES
            GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
    )

    message(STATUS "Fetching wgpu-native")
    fetchcontent_populate(wgpu_native)

    if(NOT EMSCRIPTEN)
        message(STATUS "Building wgpu-native")
        find_program(RUST_CARGO NAMES cargo REQUIRED)
        set(ENV{RUSTFLAGS} "-Awarnings")
        execute_process(COMMAND "${RUST_CARGO}" build --release --quiet --target-dir "${wgpu_native_BINARY_DIR}" --manifest-path "${wgpu_native_SOURCE_DIR}/Cargo.toml")

        add_library(wgpu_native STATIC IMPORTED)
        set_target_properties(wgpu_native PROPERTIES IMPORTED_CONFIGURATIONS "RELEASE")
        set_target_properties(wgpu_native PROPERTIES IMPORTED_LOCATION "${wgpu_native_BINARY_DIR}/release/${CMAKE_STATIC_LIBRARY_PREFIX}wgpu_native${CMAKE_STATIC_LIBRARY_SUFFIX}")

        if(WIN32)
            set(OS_LIBRARIES d3dcompiler ws2_32 userenv bcrypt ntdll opengl32)
        elseif(UNIX AND NOT APPLE)
            set(OS_LIBRARIES "-lm -ldl")
        elseif(APPLE)
            set(OS_LIBRARIES "-framework CoreFoundation -framework QuartzCore -framework Metal")
        endif()

        target_link_libraries(wgpu_native INTERFACE ${OS_LIBRARIES})
    else()
        add_library(wgpu_native INTERFACE)
    endif()

    file(COPY
            "${wgpu_native_SOURCE_DIR}/ffi/wgpu.h"
            "${wgpu_native_SOURCE_DIR}/ffi/webgpu-headers/webgpu.h"
            DESTINATION
            "${wgpu_native_BINARY_DIR}/include/webgpu"
    )

    target_include_directories(wgpu_native INTERFACE "${wgpu_native_BINARY_DIR}/include/")
endfunction()


