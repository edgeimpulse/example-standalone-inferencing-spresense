WIP

# Sensors

## Camera

- Ingestion (snapshot, snapshot_stream) format:
 - base64
 - Packed RGB (3B per pixel, as opposed to 4B with high B to 0 for inference
 - Big endian format

- Inference format:
 - Endianness of platform
  - If you encode with bit shifting, you'll be ok
   - something like: static_cast<float>((r << 16) + (g << 8 ) + b))

### Interface

at_get_snapshot_list : Return possible resolutions, greyscale, etc
-     const char **color_depth -> "Greyscale" or "RGB"