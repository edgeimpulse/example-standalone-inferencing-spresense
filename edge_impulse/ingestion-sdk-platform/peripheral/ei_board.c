/*
 * Copyright (c) 2022 Edge Impulse Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS
 * IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/* Includes ---------------------------------------------------------------- */
#include "ei_board.h"
#include <arch/cxd56xx/pin.h>
#include <arch/board/cxd56_gpioif.h>
#include <chip/hardware/cxd5602_memorymap.h>
#include <chip/cxd56_uart.h>
#include <arch/chip/scu.h>
#include <arch/chip/adc.h>
#include <sys/boardctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <stddef.h>
#include <time.h>


/* Constants */
#define putreg32(v,a)   (*(volatile uint32_t *)(a) = (v))
#define getreg32(a)     (*(volatile uint32_t *)(a))

#define CONSOLE_BASE    CXD56_UART1_BASE

#define BOARD_FCLKOUT_FREQUENCY   (100000000)

#define ADC_RANGE_MIN             0.0f
#define ADC_RANGE_MAX             5.0f

/* UART clocking ***********************************************************/
#define BOARD_UART1_BASEFREQ        BOARD_FCLKOUT_FREQUENCY

/* Private variables ------------------------------------------------------- */


/* Private functions ------------------------------------------------------- */

/* Public functions ------------------------------------------------------- */

/**
 * @brief Set baud rate for UART
 * 
 * @param baud_rate 
 */
void spresense_set_uart(uint32_t baud_rate)
{    
    cxd56_uart_reset(0);
    cxd56_setbaud(CONSOLE_BASE, BOARD_UART1_BASEFREQ, baud_rate);
}

/**
 * @brief IRQ is attached to NUTTX handler. Disable to you use Uart directly.
 */
void spresense_disable_uart_irq(void)
{
    putreg32((uint32_t)0x0, CONSOLE_BASE + CXD56_UART_IMSC);
}

/**
 * @brief Hardware initializazion
 * 
 */
void spresense_board_init(void)
{
    boardctl(BOARDIOC_INIT, 0);

    spresense_disable_uart_irq();
    spresense_set_uart(115200);

    //init_acc();
}

/**
 * @brief Write a byte straight to the UART DR register
 *
 * @param byte
 */
void spresense_putchar(char cChar)
{
    while ((getreg32(CONSOLE_BASE + CXD56_UART_FR) & UART_FLAG_TXFF));      // exit when 
    putreg32((uint32_t)cChar, CONSOLE_BASE + CXD56_UART_DR);
    while ( (getreg32(CONSOLE_BASE + CXD56_UART_FR) & (UART_FLAG_TXFE)) == 0);    // exit when is empty
}

/**
 * @brief 
 * 
 * @param str 
 */
void spresense_puts(const char *str)
{
    up_puts(str);
    while ( (getreg32(CONSOLE_BASE + CXD56_UART_FR) & (UART_FLAG_TXFE)) == 0);    // exit when is empty
}

/**
 * @brief Get a char directly from the UART
 *
 * @return char
 */
char spresense_getchar(void)
{
    uint32_t reg = 0;
    reg = getreg32(CONSOLE_BASE + CXD56_UART_FR);
    //if ((UART_FR_RXFE & reg) && !(UART_FR_RXFF & reg)) {
    if ((UART_FLAG_RXFE & reg)) {
        return 0;
    }
    else {
        return (char)getreg32(CONSOLE_BASE + CXD56_UART_DR);
    }
}

/**
 * @brief 
 * 
 */
void spresense_uart_flush(void)
{
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
}

/* Private functions ------------------------------------------------------- */
