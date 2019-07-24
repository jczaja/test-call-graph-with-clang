cmake_minimum_required(VERSION 3.0)
project(test-callgraph)

add_definitions(-I${CMAKE_CURRENT_SOURCE_DIR})

include(cmake/callgraph.cmake)

make_callgraph(main.cpp second.cpp)

