#!/bin/sh
clang++ -S -emit-llvm main.cpp -o - | opt -analyze -dot-callgraph
cat callgraph.dot | c++filt | sed 's,>,\\>,g; s,-\\>,->,g; s,<,\\<,g' | gawk '/external node/{id=$1} $1 != id' | 
dot -Tpdf -o callgraph.pdf
