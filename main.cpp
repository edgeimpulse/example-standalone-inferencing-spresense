#include <stdio.h>
#include <sys/boardctl.h>
#include <time.h>

#include "ei_device_sony_spresense.h"

extern int ei_main();



extern "C"
{
int spresense_main(void)
{
    boardctl(BOARDIOC_INIT, 0);

    ei_main();
    return 0;
}

void spresense_time_cb(uint32_t *sec, uint32_t *nano)
{
    struct timespec cur_time;
    clock_gettime(CLOCK_MONOTONIC, &cur_time);
    *(sec) = cur_time.tv_sec;
    *(nano)= cur_time.tv_nsec;
}

}
