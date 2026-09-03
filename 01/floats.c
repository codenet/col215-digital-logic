// Source - https://stackoverflow.com/a/44611722
// Posted by David C. Rankin, modified by community. See post 'Timeline' for change history
// Retrieved 2026-08-28, License - CC BY-SA 3.0

#include <float.h>
#include <math.h>
#include "show.h"
#include "util.h"

int main (void) {
    show_ieee754("%.23f\n", 0.0);
    show_ieee754("%.23f\n", -0.0);
    show_ieee754("%.23f\n", 1.0);
    show_ieee754("%.23f\n", 2.0);
    show_ieee754("%.23f\n", 0.5);

		if(0.0 == -0.0)
			printf("0.0 == -0.0\n");
		else
			printf("0.0 != -0.0\n");


    show_ieee754("1/0 -> %e\n", 1.0/0.0);
    show_ieee754("%e\n", INFINITY);
    show_ieee754("%e\n", -INFINITY);
    show_ieee754("sqrt(negative) -> %e\n", sqrt(-40.0));

    show_ieee754("Max -> %e\n", FLT_MAX);
    show_ieee754("Min -> %e\n", FLT_MIN);
    show_ieee754("-Max -> %e\n", -FLT_MAX);
    show_ieee754("-Min -> %e\n", -FLT_MIN);

    show_ieee754("%.23f\n", 0.1);
		// if(0.1+0.2 == 0.3) {
		// // if(float_equal(0.1+0.2, 0.3)) {
		// 	printf("Equal\n");
		// } else {
		// 	printf("Not equal\n");
		// }
    return 0;
}

