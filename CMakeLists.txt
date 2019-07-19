cmake_minimum_required(VERSION 3.0)
project(test-callgraph)

add_definitions(-I${CMAKE_CURRENT_SOURCE_DIR})
add_executable(test-callgraph main.cpp second.cpp) 


function(create_m4_script)
set(script "digraph { \n")
set(script "${script} define(`digraph',`subgraph')\n")
foreach(ARG ${ARGN})
    set(script "${script} include(${ARG})\n")
endforeach()
set(script "${script} }")
file(WRITE "${CMAKE_BINARY_DIR}/merger.m4" "${script}")
endfunction()

function(create_sed_script)
set(script "s,>,\\>,g; s,-\\>,->,g; s,<,\\<,g")
file(WRITE "${CMAKE_BINARY_DIR}/sed_script" "${script}")
endfunction()

function(create_gawk_script)
set(script "/external node/{id=$1} $1 != id")
file(WRITE "${CMAKE_BINARY_DIR}/gawk_script" "${script}")
endfunction()


macro(generic_callgraph_exec srcName dotName)
add_custom_command(
OUTPUT ${dotName}
COMMAND cmake -Dsrc=${srcName} -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/callgraph.cmake
COMMAND cmake -E copy ${CMAKE_BINARY_DIR}/callgraph.dot ${dotName}  
)
endmacro()

generic_callgraph_exec(${CMAKE_CURRENT_SOURCE_DIR}/main.cpp ${CMAKE_BINARY_DIR}/callgraph_main.dot)
generic_callgraph_exec(${CMAKE_CURRENT_SOURCE_DIR}/second.cpp ${CMAKE_BINARY_DIR}/callgraph_second.dot)

create_m4_script(${CMAKE_BINARY_DIR}/callgraph_main.dot ${CMAKE_BINARY_DIR}/callgraph_second.dot)
create_sed_script()
create_gawk_script()

add_custom_command(
OUTPUT ${CMAKE_BINARY_DIR}/callgraph_merged.pdf
COMMAND m4 ${CMAKE_BINARY_DIR}/merger.m4 > ${CMAKE_BINARY_DIR}/callgraph_im.dot
COMMAND bash -c "c++filt <callgraph_im.dot>callgraph_im2.dot" 
COMMAND sed -i -f ${CMAKE_BINARY_DIR}/sed_script ${CMAKE_BINARY_DIR}/callgraph_im2.dot
COMMAND gawk -f ${CMAKE_BINARY_DIR}/gawk_script ${CMAKE_BINARY_DIR}/callgraph_im2.dot >  ${CMAKE_BINARY_DIR}/callgraph_merged.dot
COMMAND dot -Tpdf ${CMAKE_BINARY_DIR}/callgraph_merged.dot -o ${CMAKE_BINARY_DIR}/callgraph_merged.pdf
DEPENDS ${CMAKE_BINARY_DIR}/callgraph_main.dot ${CMAKE_BINARY_DIR}/callgraph_second.dot
)

add_custom_target(callgraph DEPENDS ${CMAKE_BINARY_DIR}/callgraph_merged.pdf)
