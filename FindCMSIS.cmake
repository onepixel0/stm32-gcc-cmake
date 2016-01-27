set(CMSIS_CORE_HEADERS
        core_cmFunc.h
        core_cmInstr.h
    )

if(STM32_FAMILY STREQUAL "F0")
    if(NOT STM32CUBE_DIR)
        set(STM32CUBE_DIR "/opt/STM32Cube_FW_F0_V1.4.0")
        message(STATUS "No STM32CUBE_DIR specified, using default: ${STM32CUBE_DIR}")
    endif()

    list(APPEND CMSIS_CORE_HEADERS core_cm0.h)
    set(CMSIS_DEVICE_HEADERS
            stm32f0xx.h
            system_stm32f0xx.h)
    set(CMSIS_DEVICE_SOURCES
            system_stm32f0xx.c)
endif()

if(NOT CMSIS_STARTUP_SOURCE)
    set(CMSIS_STARTUP_SOURCE startup_stm32f${STM32_CHIP_TYPE_LOWER}.s)
endif()

find_path(CMSIS_CORE_INCLUDE_DIR ${CMSIS_CORE_HEADERS}
        PATHS ${STM32CUBE_DIR}/Drivers/CMSIS/Include
        CMAKE_FIND_ROOT_PATH_BOTH)


find_path(CMSIS_DEVICE_INCLUDE_DIR ${CMSIS_DEVICE_HEADERS}
        PATHS ${STM32CUBE_DIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Include
        CMAKE_FIND_ROOT_PATH_BOTH)

set(CMSIS_INCLUDE_DIRS
        ${CMSIS_CORE_INCLUDE_DIR}
        ${CMSIS_DEVICE_INCLUDE_DIR}
    )

foreach(SRC ${CMSIS_DEVICE_SOURCES})
    set(STC_FILE SRC_FILE-NOTFOUND)
    find_file(SRC_FILE ${SRC}
        PATHS ${STM32CUBE_DIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Source/Templates
        CMAKE_FIND_ROOT_PATH_BOTH)
    list(APPEND CMSIS_SOURCES ${SRC_FILE})
endforeach()

#TODO: find correct startup file

#if(STM32_CHIP_TYPE)
#set(SRC_FILE SRC_FILE-NOTFOUND)
#find_file(SRC_FILE ${CMSIS_STARTUP_SOURCE}
#        PATHS ${STM32CUBE_DIR}/Drivers/CMSIS/Device/ST/STM32${STM32_FAMILY}xx/Source/Templates/gcc
#        NO_DEFAULT_PATH)
#    list(APPEND STM32CMSIS_SOURCES ${SRC_FILE})
#endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(CMSIS DEFAULT_MSG CMSIS_INCLUDE_DIRS CMSIS_SOURCES)