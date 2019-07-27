#include <cstdio>


namespace paddle {
void myinnerExternalFunction()
{
  printf("My internal external function\n");
}


void myExternalFunction()
{
 printf("MY external module\n");
 myinnerExternalFunction();
}

}
