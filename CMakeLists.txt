cmake_minimum_required(VERSION 3.0)
project(test-callgraph)

add_definitions(-I${CMAKE_CURRENT_SOURCE_DIR})
add_executable(test-callgraph main.cpp second.cpp) 

macro(generic_callgraph_exec srcName dotName)
add_custom_command(
OUTPUT ${dotName}
COMMAND cmake -Dsrc=${srcName} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/callgraph.cmake
COMMAND cmake -E copy ${CMAKE_BINARY_DIR}/callgraph.dot ${dotName}  
)
endmacro()

generic_callgraph_exec(${CMAKE_CURRENT_SOURCE_DIR}/main.cpp ${CMAKE_BINARY_DIR}/callgraph_main.dot)
generic_callgraph_exec(${CMAKE_CURRENT_SOURCE_DIR}/second.cpp ${CMAKE_BINARY_DIR}/callgraph_second.dot)

#TODO: merge graphs

add_custom_target(callgraph DEPENDS ${CMAKE_BINARY_DIR}/callgraph_main.dot ${CMAKE_BINARY_DIR}/callgraph_second.dot)

#execute_process(
#COMMAND clang++ -S -emit-llvm ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp -o - 
#COMMAND bash -c "opt -analyze -dot-callgraph && cat callgraph.dot | c++filt |  sed 's,>,\\>,g; s,-\\>,->,g; s,<,\\<,g'| gawk '/external node/{id=$1} $1 != id' | dot -Tpdf -o callgraph_main.pdf"
#WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#)

#execute_process(
#COMMAND clang++ -S -emit-llvm ${CMAKE_CURRENT_SOURCE_DIR}/second.cpp -o - 
#COMMAND bash -c "opt -analyze -dot-callgraph && cat callgraph.dot | c++filt |  sed 's,>,\\>,g; s,-\\>,->,g; s,<,\\<,g'| gawk '/external node/{id=$1} $1 != id' | dot -Tpdf -o callgraph_second.pdf"
#WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#)
