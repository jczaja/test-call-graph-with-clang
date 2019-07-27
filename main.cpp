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

};


int main()
{
  std::vector<int> veciu(2);
  
  paddle::little_func();
  paddle::inline_func();
  paddle::myExternalFunction();
  return 0;
}
