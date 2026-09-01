#include <stdio.h>
#include <limits.h>
#include "show.h"

int main(void) {
		printf("unsigned int is %zu bytes. It can store maximum of %u\n", sizeof(unsigned int), UINT_MAX);
    // scanf("%u", &n)

		SHOW(unsigned int, 1);
		SHOW(unsigned int, 1 << 1);
		SHOW(unsigned int, 1 << 2);
		SHOW(unsigned int, 1 << 4);
		SHOW(unsigned int, 1 << 8);
		SHOW(unsigned int, 1 << 16);
		SHOW(unsigned int, 1 << 32);	// Undefined-behavior. Can print any garbage. Compiler also gives a warning!
		printf("UINT_MAX = %u\n", UINT_MAX); 
		SHOW(unsigned int, UINT_MAX); 

		printf("ULONG_MAX = %lu\n", ULONG_MAX);
		SHOW(unsigned long, ULONG_MAX);	
		SHOW(unsigned long, 1ULL<<32);

		unsigned int n = (unsigned int)(1ULL<<32);
		printf("n = %u\n", n);
		SHOW(unsigned int, n);	

		// n = - 1;
		// printf("n = %u\n", n);
		// SHOW(unsigned int, n);	

		printf("UINT_MAX is %u. UINT_MAX + 1 is %u\n", UINT_MAX, UINT_MAX + 1);
    return 0;
}
