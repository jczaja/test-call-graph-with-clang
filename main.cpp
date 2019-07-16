#include <cstdio>

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
  little_func();
  inline_func();
  return 0;
}
