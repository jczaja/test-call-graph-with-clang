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
set(script "s,>,\\>,g; s,-\\>,->,g; s,<,\\\\<,g; s,\\([^-]\\)>,\\1\\\\>,g")
file(WRITE "${CMAKE_BINARY_DIR}/sed_script" "${script}")
endfunction()

function(create_gawk_script)
set(script "
BEGIN{i = 0; e = 0; print(\"digraph {\")}

/shape/{  
if (index($0, \"paddle\") || index($0, \"main\") ) { 
  whitelist[i] = $1
  i = i + 1
  print($0)
}
  next
}

/*/
{
   if(index($0,\"shape\")) {
       next
   }

   if(index($1,\"Node0x\")) {
        edges[e] = $0
        e = e + 1
        next
   }
}

END {

  for(l = 0; l<e; ++l) { 
 
    candidate = edges[l] 
    for(j=0; j<i;++j) {
       if(index(edges[l],whitelist[j])) {
          for(k=0; k<i;++k) {
              if((k!=j) && index(edges[l],whitelist[k])) {
                  print(edges[l])
              }
          }
     }
  }
  }
  print(\"}\")
}

")
file(WRITE "${CMAKE_BINARY_DIR}/gawk_script" "${script}")
endfunction()


function(create_gawk_second_script)
set(script "

/shape/{  

if(functions[$2]) {
   transitions[$1] = functions[$2]
   next
} else {
  functions[$2] = $1
   print($0)
   next
}

}

/*/
{
   if(index($0,\"shape\")) {
       next
   }

   if(index($1,\"Node0x\")) {

        if(transitions[$1]) {
           A = transitions[$1]
        } else {
           A = $1
        }

        if(transitions[$3]) {
           B = transitions[$3]
        } else {
           B = $3
        }

        print(A \" -> \" B )

        next
   }

   print($0)
}

")
file(WRITE "${CMAKE_BINARY_DIR}/gawk_second_script" "${script}")
endfunction()





create_sed_script()
create_gawk_script()
create_gawk_second_script()

function(make_callgraph)
    set(iter "0")
    set(m4_args "")
    foreach(ARG ${ARGN})
        set(script "${script} include(${ARG})\n")
        add_library(test-callgraph_${iter} OBJECT ${ARG}) 
        target_compile_options(test-callgraph_${iter} PRIVATE ${CMAKE_CXX_FLAGS} -S -emit-llvm)
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
    COMMAND m4 ${CMAKE_BINARY_DIR}/merger.m4 > ${CMAKE_BINARY_DIR}/callgraph_combined.dot
    COMMAND gawk -f  ${CMAKE_BINARY_DIR}/gawk_second_script ${CMAKE_BINARY_DIR}/callgraph_combined.dot >  ${CMAKE_BINARY_DIR}/callgraph_merged_raw.dot
    COMMAND uniq  ${CMAKE_BINARY_DIR}/callgraph_merged_raw.dot ${CMAKE_BINARY_DIR}/callgraph_merged.dot
    COMMAND dot -Tpdf ${CMAKE_BINARY_DIR}/callgraph_merged.dot -o ${CMAKE_BINARY_DIR}/callgraph_merged.pdf
    DEPENDS ${m4_args})

    add_custom_target(callgraph DEPENDS ${CMAKE_BINARY_DIR}/callgraph_merged.pdf)


endfunction()



