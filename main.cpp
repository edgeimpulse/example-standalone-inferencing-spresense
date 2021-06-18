#include <stdio.h>
#include <sys/boardctl.h>
#include <time.h>


/* Extern reference -------------------------------------------------------- */
extern int ei_main();
extern void ei_printf(const char *format, ...);

extern "C" {

// Declared weak in Arduino.h to allow user redefinitions.
int atexit(void (*func)()) __attribute__((weak));
int atexit(void (* /*func*/ )()) { return 0; }

// Weak empty variant initialization function.
// May be redefined by variant files.
void initVariant() __attribute__((weak));
void initVariant() { }

#if defined(CONFIG_HAVE_CXX) && defined(CONFIG_HAVE_CXXINITIALIZE)
typedef void (*initializer_t)(void);
extern initializer_t _sinit;
extern initializer_t _einit;
extern uint32_t _stext;
extern uint32_t _etext;

static void up_cxxinitialize(void)
{
    initializer_t *initp;

    /* Visit each entry in the initialization table */

    for (initp = &_sinit; initp != &_einit; initp++) {
        initializer_t initializer = *initp;

        /* Make sure that the address is non-NULL and lies in the text region
         * defined by the linker script.  Some toolchains may put NULL values
         * or counts in the initialization table.
         */

        if ((void *)initializer > (void *)&_stext && (void *)initializer < (void *)&_etext) {
            initializer();
        }
    }
}
#endif
}

/**
 * @brief Main application function
 *
 */
extern "C" int spresense_main(void)
{
#if defined(CONFIG_HAVE_CXX) && defined(CONFIG_HAVE_CXXINITIALIZE)
    up_cxxinitialize();
#endif
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
