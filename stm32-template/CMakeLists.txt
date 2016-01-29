cmake_minimum_required(VERSION 2.8)
set(PROJECT stm32-template)
project(${PROJECT})
enable_language(ASM)

find_package(CMSIS REQUIRED)
find_package(HAL REQUIRED)

include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMSIS_INCLUDE_DIRS}
        ${HAL_INCLUDE_DIRS}
)

set(SOURCE_FILES main.c)
add_executable(${PROJECT} ${SOURCE_FILES} ${CMSIS_SOURCES} ${HAL_SOURCES})
STM32_SET_TARGET_PROPERTIES(${PROJECT})
STM32_BIN_TARGET(${PROJECT})
STM32_HEX_TARGET(${PROJECT})