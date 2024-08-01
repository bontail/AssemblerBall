cmake_minimum_required(VERSION 3.28)
enable_language(ASM)
project(AssemblerBall ASM)
set(CMAKE_OSX_ARCHITECTURES "arm64")

add_executable(AssemblerBall
        src/main.s
)

find_package(SDL2 REQUIRED)
include_directories(AssemblerBall ${SDL2_INCLUDE_DIRS})
target_link_libraries(AssemblerBall PRIVATE SDL2::SDL2)