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

#include <stdint.h>

class EiCamera {
public:
    /**
     * @brief Call to driver to return an image encoded in RGB88
     * Format should be Big Endian, or in other words, if your image
     * pointer is indexed as a char*, then image[0] is R, image[1] is G
     * image[2] is B, and image[3] is R again (no padding / word alignment) 
     * 
     * @param image Point to output buffer for image.  32 bit for word alignment on some platforms 
     * @param image_size_B Size of buffer allocated ( should be 3 * hsize * vsize ) 
     * @param hsize Horizontal size, in pixels 
     * @param vsize Vertial size, in pixels
     * @return true If successful 
     * @return false If not successful 
     */
    virtual bool ei_camera_capture_rgb888_packed_big_endian(
        uint8_t *image,
        uint32_t image_size_B,
        uint16_t hsize,
        uint16_t vsize);

    // the following are optional

    virtual bool init()
    {
        return true;
    }
    virtual bool deinit()
    {
        return true;
    }

    /**
     * @brief Implementation must provide a singleton getter
     * 
     * @return EiCamera* 
     */
    static EiCamera *get_camera();
};