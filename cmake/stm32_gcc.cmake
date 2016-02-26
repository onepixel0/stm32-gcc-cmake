set(STM32_SUPPORTED_FAMILIES F0 CACHE INTERNAL "stm32 supported families")

if(NOT TOOLCHAIN_PREFIX)
    set(TOOLCHAIN_PREFIX "/opt")
    message(STATUS "No TOOLCHAIN_PREFIX specified, using default: ${TOOLCHAIN_PREFIX}")
endif()

if(NOT TARGET_TRIPLET)
    set(TARGET_TRIPLET "arm-none-eabi")
endif()

if(NOT STM32_CHIP)
    message(FATAL_ERROR "No STM32_CHIP specified")
else()
    string(REGEX REPLACE "^[sS][tT][mM]32(([fF][0-4])|([lL][0-1])|([tT])|([wW])).+$" "\\1" STM32_FAMILY ${STM32_CHIP})
    string(TOUPPER ${STM32_FAMILY} STM32_FAMILY)
endif()

list(FIND STM32_SUPPORTED_FAMILIES ${STM32_FAMILY} FAMILY_INDEX)
if(FAMILY_INDEX LESS 0)
    message(FATAL_ERROR "Invalid/unsupported STM32 family: ${STM32_FAMILY}")
endif()

set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/lib)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

include(CMakeForceCompiler)

CMAKE_FORCE_C_COMPILER(${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++ GNU)
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc)

set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy CACHE INTERNAL "objcopy tool")
set(CMAKE_OBJDUMP ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump CACHE INTERNAL "objdump tool")
set(CMAKE_SIZE ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-size CACHE INTERNAL "size tool")

set(CMAKE_C_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "c compiler flags debug")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "cxx compiler flags debug")
set(CMAKE_ASM_FLAGS_DEBUG "-g" CACHE INTERNAL "asm compiler flags debug")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE INTERNAL "linker flags debug")

set(CMAKE_C_FLAGS_RELEASE "-Os" CACHE INTERNAL "c compiler flags release")
set(CMAKE_CXX_FLAGS_RELEASE "-Os" CACHE INTERNAL "cxx compiler flags release")
set(CMAKE_ASM_FLAGS_RELEASE "" CACHE INTERNAL "asm compiler flags release")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-flto" CACHE INTERNAL "linker flags release")

set(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET} ${EXTRA_FIND_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

function(STM32_HEX_TARGET TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
        set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${CMAKE_BUILD_TYPE}/${TARGET}")
    else()
        set(FILENAME "${TARGET}")
    endif()
    add_custom_target(${TARGET}.hex
            DEPENDS ${TARGET}
            COMMAND ${CMAKE_OBJCOPY} -Oihex ${FILENAME} ${FILENAME}.hex)
endfunction()

function(STM32_BIN_TARGET TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
        set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${CMAKE_BUILD_TYPE}/${TARGET}")
    else()
        set(FILENAME "${TARGET}")
    endif()
    add_custom_target(${TARGET}.bin
            DEPENDS ${TARGET}
            COMMAND ${CMAKE_OBJCOPY} -Obinary ${FILENAME} ${FILENAME}.bin)
endfunction()

function(STM32_SIZE_TARGET TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
        set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
        set(FILENAME "${TARGET}")
    endif()
    add_custom_command(TARGET ${TARGET}
            POST_BUILD_COMMAND ${CMAKE_SIZE} ${FILENAME})
endfunction()

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)
include(stm32${STM32_FAMILY_LOWER})


function(STM32_SET_FLASH_PARAMETERS TARGET FLASH_SIZE RAM_SIZE)
    if(NOT STM32_FLASH_ORIGIN)
        set(STM32_FLASH_ORIGIN "0x08000000")
    endif()

    if(NOT STM32_RAM_ORIGIN)
        set(STM32_RAM_ORIGIN "0x20000000")
    endif()

    if(NOT STM32_MIN_STACK_SIZE)
        set(STM32_MIN_STACK_SIZE "0x200")
    endif()

    if(NOT STM32_MIN_HEAP_SIZE)
        set(STM32_MIN_HEAP_SIZE "0")
    endif()

    if(NOT STM32_CCRAM_ORIGIN)
        set(STM32_CCRAM_ORIGIN "0x10000000")
    endif()

    if(NOT STM32_CCRAM_SIZE)
        set(STM32_CCRAM_SIZE "64K")
    endif()

    if(NOT STM32_LINKER_SCRIPT)
        message(STATUS "No linker script specified, generating default")
        include(stm32_linker)
        file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld ${STM32_LINKER_SCRIPT_TEXT})
    else()
        configure_file(${STM32_LINKER_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld)
    endif()
    get_target_property(TARGET_LD_FLAGS ${TARGET} LINK_FLAGS)
    if(TARGET_LD_FLAGS)
        set(TARGET_LD_FLAGS "-T${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld ${TARGET_LD_FLAGS}")
    else()
        set(TARGET_LD_FLAGS "-T${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_flash.ld")
    endif()
    set_target_properties(${TARGET} PROPERTIES LINK_FLAGS ${TARGET_LD_FLAGS})
endfunction()


function(STM32_SET_TARGET_PROPERTIES TARGET)
    if(NOT STM32_CHIP_TYPE)
        if(NOT STM32_CHIP)
            message(WARNING "Set chip!")
        else()
            STM32_GET_CHIP_TYPE(${STM32_CHIP} STM32_CHIP_TYPE)
        endif()
    endif()

    STM32_SET_CHIP_DEFINITION(${TARGET} ${STM32_CHIP_TYPE})
    if(((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE)) AND (NOT STM32_CHIP))
        message(FATAL_ERROR "Cannot get chip params")
    endif()
    if((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE))
        STM32_GET_CHIP_PARAMETERS(${STM32_CHIP} STM32_FLASH_SIZE STM32_RAM_SIZE)
        if((NOT STM32_FLASH_SIZE) OR (NOT STM32_RAM_SIZE))
            message(FATAL_ERROR "Unknown chip: ${STM32_CHIP}")
        endif()
    endif()
    STM32_SET_FLASH_PARAMETERS(${TARGET} ${STM32_FLASH_SIZE} ${STM32_RAM_SIZE})
    message(STATUS "${STM32_CHIP} has ${STM32_FLASH_SIZE}iB flash and ${STM32_RAM_SIZE}iB RAM")
endfunction()