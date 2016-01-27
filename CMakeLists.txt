cmake_minimum_required(VERSION 2.8)
project(stm32)


find_package(CMSIS REQUIRED)
find_package(HAL COMPONENTS rcc gpio tim REQUIRED)

include_directories(
        ${CMSIS_INCLUDE_DIRS}
        ${HAL_INCLUDE_DIRS})

set(SOURCE_FILES main.c)
add_executable(stm32 ${SOURCE_FILES} ${CMSIS_SOURCES} ${HAL_SOURCES})