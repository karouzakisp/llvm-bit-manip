#include <stdio.h>

int main(void){
  int x, y;
  x = 5;
  y = 4;
  x = x + (y << 2);
  printf("X is %d\n", x);
  return 0;
}
