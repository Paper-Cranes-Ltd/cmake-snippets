function(get_asio_standalone VERSION_TAG)
    include(FindPackageHandleStandardArgs)
    include(FetchContent)


    fetchcontent_declare(asio
            GIT_REPOSITORY "https://github.com/chriskohlhoff/asio.git"
            GIT_TAG "${VERSION_TAG}"
            GIT_SUBMODULES_RECURSE YES
            GIT_SHALLOW YES
            GIT_REMOTE_UPDATE_STRATEGY CHECKOUT
    )

    message(STATUS "Fetching Asio Standalone")
    fetchcontent_populate(asio)

    add_library(asio "${asio_SOURCE_DIR}/asio/include/asio.hpp" "${asio_SOURCE_DIR}/asio/src/asio.cpp")
    target_compile_definitions(asio PUBLIC ASIO_STANDALONE)
    target_compile_definitions(asio PUBLIC ASIO_SEPARATE_COMPILATION)

#    if(WIN32)
#        target_precompile_headers(asio PUBLIC "<SDKDDKVer.h>")
#    endif()

    target_include_directories(asio
            PUBLIC "${asio_SOURCE_DIR}/asio/include"
            PRIVATE "${asio_SOURCE_DIR}/asio/src"
    )
endfunction()


