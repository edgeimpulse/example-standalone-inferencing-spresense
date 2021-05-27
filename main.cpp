#include <stdio.h>
#include <sys/boardctl.h>



extern "C"
{
int spresense_main(void)
{
    boardctl(BOARDIOC_INIT, 0);


    printf("Hello world\r\n");
    return 0;
}
}
