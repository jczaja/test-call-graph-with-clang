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

create_sed_script()
create_gawk_script()

function(make_callgraph)
    set(iter "0")
    set(m4_args "")
    foreach(ARG ${ARGN})
        set(script "${script} include(${ARG})\n")
        add_library(test-callgraph_${iter} OBJECT ${ARG}) 
        target_compile_options(test-callgraph_${iter} PUBLIC ${CMAKE_C_FLAGS} -S -emit-llvm)
        add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/callgraph_${iter}.dot
        COMMAND cat $<TARGET_OBJECTS:test-callgraph_${iter}> | opt -analyze -dot-callgraph 
        COMMAND cat ${CMAKE_BINARY_DIR}/callgraph.dot | c++filt > ${CMAKE_BINARY_DIR}/callgraph_filt.dot
        COMMAND sed -i -f ${CMAKE_BINARY_DIR}/sed_script ${CMAKE_BINARY_DIR}/callgraph_filt.dot
        COMMAND gawk -f ${CMAKE_BINARY_DIR}/gawk_script ${CMAKE_BINARY_DIR}/callgraph_filt.dot >  ${CMAKE_BINARY_DIR}/callgraph_${iter}.dot
        DEPENDS test-callgraph_${iter})
        list(APPEND m4_args ${CMAKE_BINARY_DIR}/callgraph_${iter}.dot)
        math(EXPR iter "${iter}+1")
    endforeach()
    create_m4_script(${m4_args})

    add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/callgraph_merged.pdf
    COMMAND m4 ${CMAKE_BINARY_DIR}/merger.m4 > ${CMAKE_BINARY_DIR}/callgraph_merged.dot
    COMMAND dot -Tpdf ${CMAKE_BINARY_DIR}/callgraph_merged.dot -o ${CMAKE_BINARY_DIR}/callgraph_merged.pdf
    DEPENDS ${m4_args})

    add_custom_target(callgraph DEPENDS ${CMAKE_BINARY_DIR}/callgraph_merged.pdf)


endfunction()



