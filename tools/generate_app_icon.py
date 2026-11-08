#!/usr/bin/env python3
"""Derive app PNG/ICO from the game's own amber-hopper sprite; stdlib only."""
import importlib.util
import pathlib
import struct
import zlib

ROOT = pathlib.Path(__file__).resolve().parents[1] / 'assets/ui'
SIZES = (16, 32, 48, 64, 128, 256)


def sprite_pixels():
    spec = importlib.util.spec_from_file_location('qbert_original_art', pathlib.Path(__file__).with_name('generate_arcade_art.py'))
    art = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(art)
    # Same atlas cell as PyramidView: kind 0, direction SE (3), resting pose 0.
    return art.W, art.H, art.sprite(0, 3, 0)


def icon_pixels(size):
    width, height, pixels = sprite_pixels()
    opaque = [(x, y) for y in range(height) for x in range(width) if pixels[(y * width + x) * 4 + 3]]
    left, top = min(x for x, y in opaque), min(y for x, y in opaque)
    right, bottom = max(x for x, y in opaque) + 1, max(y for x, y in opaque) + 1
    crop_w, crop_h = right - left, bottom - top
    scale = (size * 7 // 8) / max(crop_w, crop_h)
    if scale >= 1:
        scale = int(scale)  # Integer upscaling retains the original pixel grid.
    target_w, target_h = max(1, int(crop_w * scale)), max(1, int(crop_h * scale))
    offset_x, offset_y = (size - target_w) // 2, (size - target_h) // 2
    output = bytearray(size * size * 4)
    for y in range(target_h):
        for x in range(target_w):
            source = ((top + y * crop_h // target_h) * width + left + x * crop_w // target_w) * 4
            target = ((offset_y + y) * size + offset_x + x) * 4
            output[target:target + 4] = pixels[source:source + 4]
    return output


def png_bytes(size):
    pixels = icon_pixels(size)
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
    scanlines = b''.join(b'\0' + pixels[y * size * 4:(y + 1) * size * 4] for y in range(size))
    return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(scanlines, 9)) + chunk(b'IEND', b'')


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    payloads = [png_bytes(size) for size in SIZES]
    offset = 6 + 16 * len(SIZES)
    directory = bytearray(struct.pack('<HHH', 0, 1, len(SIZES)))
    for size, payload in zip(SIZES, payloads):
        directory.extend(struct.pack('<BBBBHHII', size % 256, size % 256, 0, 0, 1, 32, len(payload), offset))
        offset += len(payload)
    (ROOT / 'qbert.png').write_bytes(payloads[-1])
    (ROOT / 'qbert.ico').write_bytes(directory + b''.join(payloads))


if __name__ == '__main__':
    main()
