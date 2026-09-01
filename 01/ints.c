#include <stdio.h>
#include <limits.h>
#include "show.h"

int main() {
	SHOW(int, 0);
	SHOW(int, 1);
	SHOW(int, 17);
	SHOW(int, -17);	// Notice that all digits are inverted except the last "1". Careful about little-endian format
	SHOW(int, 256);
	// printf("INT_MAX = %d\n", INT_MAX); SHOW(int, INT_MAX);	// Notice that all ones, but MSB is zero.
	// printf("INT_MIN = %d\n", INT_MIN); SHOW(int, INT_MIN);	// Notice that all ones, but MSB is one.

	// SHOW(short, 17);
	// SHOW(long, 17);

	// //
	// printf("-1*INT_MIN = %d\n", -1*INT_MIN); SHOW(int, -1* INT_MIN);
	// printf("INT_MAX + 1 = %d\n", INT_MAX + 1); SHOW(int, INT_MAX + 1);
	return 0;
}
