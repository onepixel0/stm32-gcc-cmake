cmake_minimum_required(VERSION 2.8)
project(stm32)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(TOOLCHAIN_PREFIX /opt/arm-none-eabi)
set(STM32_CHIP "stm32f030f4")
include(stm32_gcc.cmake)

set(SOURCE_FILES main.c)
add_executable(stm32 ${SOURCE_FILES})