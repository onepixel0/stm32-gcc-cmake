set(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m0 -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
set(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m0 -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m0 -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mcpu=cortex-m0 -mabi=aapcs" CACHE INTERNAL "executable linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -mabi=aapcs" CACHE INTERNAL "module linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -mabi=aapcs" CACHE INTERNAL "shared linker flags")


set(STM32_CHIP_TYPES
        030x6 030x8 031x6 038xx
        042x6 048x6 051x8 058xx
        070x6 070xB 071xB 072xB
        078xx 030xC 091xC 098xx)

set(STM32_CODES
        030.[46]
        030.[8]
        031.[46]
        038.[6]
        042.[46]
        048.[6]
        051.[468]
        058.[8]
        070.[6]
        070.[B]
        071.[8B]
        072.[8B]
        078.[B]
        030.[C]
        091.[BC]
        098.[C])


macro(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    string(TOUPPER ${CHIP} CHIP)
    string(REGEX REPLACE "^[sS][tT][mM]32[fF]((03[018].[468C])|(04[28].[46])|(05[18].[468])|(07[0128].[68B])|(09[18].[BC]))+$" "\\1" STM32_CODE ${CHIP})
    set(INDEX 0)
    foreach(TYPE ${STM32_CHIP_TYPES})
        list(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        if(${STM32_CODE} MATCHES ${CHIP_TYPE_REGEXP})
            set(RESULT_TYPE ${TYPE})
        endif()
        math(EXPR INDEX "${INDEX}+1")
    endforeach()
    set(${CHIP_TYPE} ${RESULT_TYPE})
endmacro()


macro(STM32_GET_CHIP_PARAMETERS CHIP CHIP_TYPE)
    string(TOUPPER ${CHIP} CHIP)
    string(REGEX REPLACE "^[sS][tT][mM]32[fF](0[34579][0128]).[468BC]" "\\1" STM32_CODE ${CHIP})
    string(REGEX REPLACE "^[sS][tT][mM]32[fF]0[34579][0128].([468BC])" "\\1" STM32_SIZE_CODE ${CHIP})

    if(STM32_SIZE_CODE STREQUAL "4")
        set(FLASH "16K")
    elseif(STM32_SIZE_CODE STREQUAL "6")
        set(FLASH "32K")
    elseif(STM32_SIZE_CODE STREQUAL "8")
        set(FLASH "64K")
    elseif(STM32_SIZE_CODE STREQUAL "B")
        set(FLASH "128K")
    elseif(STM32_SIZE_CODE STREQUAL "C")
        set(FLASH "256K")
    endif()

    STM32_GET_CHIP_TYPE(${CHIP} CHIP_TYPE)

    if(${CHIP_TYPE} STREQUAL 030x6)
        set(RAM "4K")
    elseif(${CHIP_TYPE} STREQUAL 030x8)
        set(RAM "8K")
    elseif(${CHIP_TYPE} STREQUAL 031x6)
        set(RAM "4K")
    elseif(${CHIP_TYPE} STREQUAL 038xx)
        set(RAM "4K")
    elseif(${CHIP_TYPE} STREQUAL 042x6)
        set(RAM "6K")
    elseif(${CHIP_TYPE} STREQUAL 048x6)
        set(RAM "6K")
    elseif(${CHIP_TYPE} STREQUAL 051x8)
        set(RAM "8K")
    elseif(${CHIP_TYPE} STREQUAL 058xx)
        set(RAM "8K")
    elseif(${CHIP_TYPE} STREQUAL 070x6)
        set(RAM "6K")
    elseif(${CHIP_TYPE} STREQUAL 070xB)
        set(RAM "16K")
    elseif(${CHIP_TYPE} STREQUAL 071xB)
        set(RAM "16K")
    elseif(${CHIP_TYPE} STREQUAL 072xB)
        set(RAM "16K")
    elseif(${CHIP_TYPE} STREQUAL 078xx)
        set(RAM "16K")
    elseif(${CHIP_TYPE} STREQUAL 030xC)
        set(RAM "32K")
    elseif(${CHIP_TYPE} STREQUAL 091xC)
        set(RAM "32K")
    elseif(${CHIP_TYPE} STREQUAL 098xx)
        set(RAM "32K")
    endif()

    set(${FLASH_SIZE} ${FLASH})
    set(${RAM_SIZE} ${RAM})
endmacro()


function(STM32_SET_CHIP_DEFINITION TARGET CHIP_TYPE)
    list(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    if(TYPE_INDEX EQUAL -1)
        message(FATAL_ERROR "Invalid/unsupported STM32F0 chip: ${CHIP_TYPE}")
    endif()
    get_target_property(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    if(TARGET_DEFS)
        set(TARGET_DEFS "STM32F0;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    else()
        set(TARGET_DEFS "STM32F0;STM32F${CHIP_TYPE}")
    endif()
    set_target_properties(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
endfunction()