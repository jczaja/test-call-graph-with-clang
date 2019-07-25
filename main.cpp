#include <cstdio>
#include <vector>
#include "second.hpp"



void little_func()
{
  printf("little func\n");
}

void inline_func()
{
  printf("inline func\n");
}

int main()
{
  std::vector<int> veciu(2);
  
  little_func();
  inline_func();
  myExternalFunction();
  return 0;
}
