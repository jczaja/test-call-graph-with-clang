#include <cstdio>
#include <vector>
#include "second.hpp"

namespace paddle {

void little_func()
{
  printf("little func\n");
}

void inline_func()
{
  printf("inline func\n");
}

int notused()
{
   printf("not called\n");
   return 0;
}
};



int main()
{
  std::vector<int> veciu(2);
  
  paddle::little_func();
  paddle::inline_func();
  paddle::myExternalFunction();
  return 0;
}
