#include<stdio.h>
#include "show.h"

int main() {
	printf("Characters are %zu bytes\n", sizeof(char));
	SHOW(char, 'A');
	SHOW(char, 'a');
	printf("%c\n", 'a'+1); SHOW(char, 'a' + 1);
	SHOW(char, '0');
}
