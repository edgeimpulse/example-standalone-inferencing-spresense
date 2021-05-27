#include <stdio.h>
#include <sys/boardctl.h>

#include "ei_device_sony_spresense.h"

extern int ei_main();

extern "C"
{
int spresense_main(void)
{
    boardctl(BOARDIOC_INIT, 0);


    printf("Hello world\r\n");
    ei_printf("Hello from Edge Impulse\r\n");
    ei_main();
    return 0;
}
}
