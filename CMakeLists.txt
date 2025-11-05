cmake_minimum_required(VERSION 3.13)
project(lom LANGUAGES C)

set(LUA_DIR ${CMAKE_SOURCE_DIR}/vendor/lua)
set(LOM_DIR ${CMAKE_SOURCE_DIR}/vendor/lom)
set(BUILD_DIR ${CMAKE_BINARY_DIR})

file(GLOB LUA_SRCS "${LUA_DIR}/*.c")
list(FILTER LUA_SRCS EXCLUDE REGEX ".*onelua\\.c$")
file(GLOB LOM_SRCS "${LOM_DIR}/src/*.c")

include_directories(${LUA_DIR} ${LOM_DIR}/include)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")

set(EM_FLAGS
    "-sWASM=1"
    "-sMODULARIZE=1"
    "-sEXPORT_ES6=1"
    "-sEXPORTED_FUNCTIONS=['_lom_init','_lom_run','_lom_close']"
    "-sEXPORTED_RUNTIME_METHODS=['cwrap']"
)

add_executable(lom ${LUA_SRCS} ${LOM_SRCS})

set_target_properties(lom PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${BUILD_DIR}
    OUTPUT_NAME "lom"
)

if (EMSCRIPTEN)
    target_link_options(lom PRIVATE ${EM_FLAGS})
endif()

set(LUA_PARSER_EXTRAS "${LOM_DIR}/lua_scripts/parser_extras.lua")

file(READ "${LUA_PARSER_EXTRAS}" LUA_PARSER_EXTRAS_SCRIPT)
string(REPLACE "\\" "\\\\" LUA_PARSER_EXTRAS_SCRIPT "${LUA_PARSER_EXTRAS_SCRIPT}")
string(REPLACE "\"" "\\\"" LUA_PARSER_EXTRAS_SCRIPT "${LUA_PARSER_EXTRAS_SCRIPT}")
string(REPLACE "\n" "\\n" LUA_PARSER_EXTRAS_SCRIPT "${LUA_PARSER_EXTRAS_SCRIPT}")

add_compile_definitions(PARSER_EXTRAS_LUA="${LUA_PARSER_EXTRAS_SCRIPT}")

add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E rm -rf ${BUILD_DIR}
    COMMENT "Cleaning build directory")
