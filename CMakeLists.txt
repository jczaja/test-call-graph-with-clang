cmake_minimum_required(VERSION 3.14)
project(test-callgraph)

add_definitions(-I${CMAKE_CURRENT_SOURCE_DIR})

# Include this file to have 
# make_callgraph function available 
include(cmake/callgraph.cmake)

# Example usage: make_callgraph("<space separated patterns to be present in functions callgraph>" <source1.cpp> <source1.cpp>...)
make_callgraph("paddle main" main.cpp second.cpp)

