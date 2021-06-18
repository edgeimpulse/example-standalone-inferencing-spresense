/* Edge Impulse inferencing library
 * Copyright (c) 2020 EdgeImpulse Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#pragma once

#include "stdint.h"

// ********* Functions for AT commands

/**
 * @brief Use to output an image as base64.  Assign this to an AT command
 * 
 * @param width Width in pixels
 * @param height Height in pixels
 * @param use_max_baudrate Use the fast baud rate for transfer
 * @return true If successful
 * @return false If failure
 */
bool ei_camera_take_snapshot_output_on_serial(size_t width, size_t height, bool use_max_baudrate);


/**
 * @brief Use to output an image as base64, over and over.  Assign this to an AT command
 * Calls ei_camera_take_snapshot_encode_and_output() in a loop until a char is received on the UART 
 * 
 * @param width Width in pixels
 * @param height Height in pixels
 * @param use_max_baudrate Use the fast baud rate for transfer
 * @return true If successful
 * @return false If failure
 */
bool ei_camera_start_snapshot_stream(size_t width, size_t height, bool use_max_baudrate);


// ********* Utilities for drivers to use to:

enum YUV_OPTIONS {
    BIG_ENDIAN_ORDER = 1, //RGB reading from low to high memory.  Otherwise, uses native encoding
    PAD_4B = 2, // pad 0x00 on the high B. ie 0x00RRGGBB
};

void YUV422toRGB888(unsigned char *rgb_out, unsigned const char *yuv_in, unsigned int in_size, YUV_OPTIONS opts);
