cmake_minimum_required(VERSION 3.24)
# macOS (arm64) and iOS (CyPort) build of RedFileSystem. The Windows build is the top-level CMakeLists.txt, unchanged.
#   cmake -S macos -B build-mac && cmake --build build-mac            (macOS)
#   macos/ios-stage.sh                                                (iOS: build-ios/, signed deploy/)
project(RedFileSystem VERSION 0.16.0 LANGUAGES CXX)

set(REDMAC_NAME RedFileSystem)
set(REDMAC_ENTRY redfilesystem_registerNatives)
set(REDMAC_RTTI_ID_BAND 0x7FE90000)
set(REDMAC_SERIAL_SLOT 1)
include("${CMAKE_CURRENT_SOURCE_DIR}/Common.cmake")

configure_file("${REDMAC_ROOT}/src/Config.h.in" Config/Config.h)

set(SRC "${REDMAC_ROOT}/src")
redmac_plugin(
    ${SRC}/main.cpp
    ${SRC}/AsyncFile.cpp
    ${SRC}/File.cpp
    ${SRC}/FileSystem.cpp
    ${SRC}/FileSystemStorage.cpp
)
# RedData's C++ API (header only: it calls the RedData plugin's natives through the RTTI, when that plugin is loaded).
target_include_directories(RedFileSystem PRIVATE "${REDMAC_ROOT}/deps/RedData/include")
target_compile_definitions(RedFileSystem PRIVATE HAS_REDDATA)
