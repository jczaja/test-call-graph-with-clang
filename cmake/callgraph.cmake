execute_process(
COMMAND clang++ -S -emit-llvm ${src} -o - 
COMMAND bash -c "opt -analyze -dot-callgraph" 
WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
