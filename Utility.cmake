

macro(set_inverse VAR_NAME VALUE)
    if(${VALUE})
        set(${VAR_NAME} FALSE)
    else()
        set(${VAR_NAME} TRUE)
    endif()
endmacro()
