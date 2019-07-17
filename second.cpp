#include <cstdio>

void myinnerExternalFunction()
{
  printf("My internal external function\n");
}


void myExternalFunction()
{
 printf("MY external module\n");
 myinnerExternalFunction();
}
