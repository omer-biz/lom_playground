cmake_minimum_required(VERSION 3.13)
project(hermes LANGUAGES C)

set(LUA_DIR ${CMAKE_SOURCE_DIR}/vendor/lua)
set(HERMES_DIR ${CMAKE_SOURCE_DIR}/vendor/hermes-parser)
set(BUILD_DIR ${CMAKE_BINARY_DIR})

file(GLOB LUA_SRCS "${LUA_DIR}/*.c")
list(FILTER LUA_SRCS EXCLUDE REGEX ".*onelua\\.c$")
file(GLOB HERMES_SRCS "${HERMES_DIR}/src/*.c")

include_directories(${LUA_DIR} ${HERMES_DIR}/src)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")

set(EM_FLAGS
    "-sWASM=1"
    "-sMODULARIZE=1"
    "-sEXPORT_ES6=1"
    "-sFORCE_FILESYSTEM=1"
    "-sSTANDALONE_WASM=0"
    "-sNO_EXIT_RUNTIME=1"
    "-sEXPORTED_FUNCTIONS=['_hermes_init','_hermes_run','_hermes_close']"
    "-sEXPORTED_RUNTIME_METHODS=['cwrap','FS','PATH']"
)

add_executable(hermes ${LUA_SRCS} ${HERMES_SRCS} ./src/hermes_wrapper.c)

set_target_properties(hermes PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BUILD_DIR}
    OUTPUT_NAME "hermes"
)

if (EMSCRIPTEN)
    target_link_options(hermes PRIVATE ${EM_FLAGS})
endif()

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E rm -rf ${BUILD_DIR}
    COMMENT "Cleaning build directory")
