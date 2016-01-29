if(STM32_FAMILY STREQUAL "F0")
    set(HAL_COMPONENTS
            adc can cec comp
            cortex crc dac dma
            flash gpio i2c i2s irda
            iwdg pcd pwr rcc rtc
            smartcard smbus spi tim
            tsc uart usart wwdg)
    set(HAL_REQUIRED_COMPONENTS
            cortex pwr rcc)
    set(HAL_EX_COMPONENTS
            adc crc dac flash i2c
            pcd pwr rcc rtc
            smartcard spi tim uart)
    set(HAL_LL_COMPONENTS "")
    set(HAL_PREFIX stm32f0xx_)
    set(HAL_HEADERS
            ${HAL_PREFIX}hal.h
            ${HAL_PREFIX}hal_def.h)
    set(HAL_SRCS
            ${HAL_PREFIX}hal.c)
endif()

if(NOT HAL_FIND_COMPONENTS)
        set(HAL_FIND_COMPONENTS ${HAL_COMPONENTS})
        message(STATUS "No STM32HAL components specified, using all")
endif()

foreach(COMP ${HAL_REQUIRED_COMPONENTS})
    list(FIND HAL_FIND_COMPONENTS ${COMP} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        list(APPEND HAL_FIND_COMPONENTS ${COMP})
    endif()
endforeach()

foreach(COMP ${HAL_FIND_COMPONENTS})
    list(FIND HAL_COMPONENTS ${COMP} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        message(FATAL_ERROR "Unknown STM32HAL component: ${COMP}. Available components: ${HAL_COMPONENTS}")
    endif()
    list(FIND HAL_LL_COMPONENTS ${COMP} STM32HAL_FOUND_INDEX)
    if(${STM32HAL_FOUND_INDEX} LESS 0)
        list(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${COMP}.h)
        list(APPEND HAL_SRCS ${HAL_PREFIX}hal_${COMP}.c)
    else()
        list(APPEND HAL_HEADERS ${HAL_PREFIX}ll_${COMP}.h)
        list(APPEND HAL_SRCS ${HAL_PREFIX}ll_${COMP}.c)
    endif()
    list(FIND HAL_EX_COMPONENTS ${COMP} STM32HAL_FOUND_INDEX)
    if(NOT (${STM32HAL_FOUND_INDEX} LESS 0))
        list(APPEND HAL_HEADERS ${HAL_PREFIX}hal_${COMP}_ex.h)
        list(APPEND HAL_SRCS ${HAL_PREFIX}hal_${COMP}_ex.c)
    endif()
endforeach()

list(REMOVE_DUPLICATES HAL_HEADERS)
list(REMOVE_DUPLICATES HAL_SRCS)

string(TOLOWER ${STM32_FAMILY} STM32_FAMILY_LOWER)

find_path(HAL_INCLUDE_DIRS ${HAL_HEADERS}
        PATHS ${STM32CUBE_DIR}/Drivers/STM32${STM32_FAMILY}xx_HAL_Driver/Inc
        CMAKE_FIND_ROOT_PATH_BOTH)

foreach(HAL_SRC ${HAL_SRCS})
    set(HAL_${HAL_SRC}_FILE HAL_SRC_FILE-NOTFOUND)
    find_file(HAL_${HAL_SRC}_FILE ${HAL_SRC}
            PATHS ${STM32CUBE_DIR}/Drivers/STM32${STM32_FAMILY}xx_HAL_Driver/Src
            CMAKE_FIND_ROOT_PATH_BOTH)
    list(APPEND HAL_SOURCES ${HAL_${HAL_SRC}_FILE})
endforeach()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(STM32HAL DEFAULT_MSG HAL_INCLUDE_DIRS HAL_SOURCES)