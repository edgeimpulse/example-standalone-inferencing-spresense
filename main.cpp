#include <stdio.h>
#include <sys/boardctl.h>
#include <time.h>

#include "ei_device_sony_spresense.h"

/* Extern reference -------------------------------------------------------- */
extern int ei_main();

/**
 * @brief Main application function
 *
 */
extern "C" int spresense_main(void)
{
    boardctl(BOARDIOC_INIT, 0);
    ei_main();
    return 0;
}

/**
 * @brief Get current time from spresense lib
 *
 * @param sec
 * @param nano
 */
extern "C" void spresense_time_cb(uint32_t *sec, uint32_t *nano)
{
    struct timespec cur_time;
    clock_gettime(CLOCK_MONOTONIC, &cur_time);
    *(sec) = cur_time.tv_sec;
    *(nano)= cur_time.tv_nsec;
}
