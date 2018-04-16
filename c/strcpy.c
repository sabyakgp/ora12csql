#include <stdio.h>
#include <string.h>
void main()
{
char* greeting = "Hello";
char* temp = malloc(6);
strncpy(temp, greeting, 3);
strncpy(temp+3, "pi!", 3);
greeting = temp;
puts(temp);
puts(greeting);
}
