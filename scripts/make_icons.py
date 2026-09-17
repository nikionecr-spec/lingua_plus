#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generates Lingua+ launcher icons (legacy + adaptive) with PIL."""
import os
from PIL import Image, ImageDraw, ImageFont

RES = "/home/z/my-project/lingua_plus/android/app/src/main/res"
FONT = "/home/z/my-project/lingua_plus/assets/fonts/Poppins-Bold.ttf"

C1 = (79, 124, 255)   # #4F7CFF
C2 = (155, 92, 255)   # #9B5CFF
BG = (10, 15, 36)     # #0A0F24


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient_circle(size):
    """Diagonal blue→violet gradient, full-bleed square with rounded circle."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size - 2)
            px[x, y] = lerp(C1, C2, t) + (255,)
    # circular mask
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse([0, 0, size - 1, size - 1], fill=255)
    img.putalpha(mask)
    return img


def draw_glyph(img, scale=0.52):
    """Draws the L+ glyph centered, white, Poppins Bold."""
    size = img.width
    text = "L+"
    fs = int(size * scale)
    try:
        font = ImageFont.truetype(FONT, fs)
    except Exception:
        font = ImageFont.load_default()
    d = ImageDraw.Draw(img)
    # measure
    bbox = d.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (size - tw) / 2 - bbox[0]
    y = (size - th) / 2 - bbox[1]
    # subtle shadow
    d.text((x + max(1, size // 200), y + max(1, size // 200)), text,
           font=font, fill=(0, 0, 0, 70))
    d.text((x, y), text, font=font, fill=(255, 255, 255, 255))
    return img


def make_legacy(size, out_path):
    img = gradient_circle(size)
    # soft dark ring for contrast on light backgrounds
    d = ImageDraw.Draw(img)
    d.ellipse([0, 0, size - 1, size - 1], outline=(255, 255, 255, 60),
              width=max(1, size // 48))
    draw_glyph(img, scale=0.5)
    img.save(out_path)


def make_foreground(size, out_path):
    """Adaptive foreground: transparent bg, glyph inside 66% safe zone."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    glyph = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_glyph(glyph, scale=0.30)
    img.alpha_composite(glyph)
    img.save(out_path)


def write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content)


def main():
    densities = {
        "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192,
    }
    fg_densities = {
        "mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432,
    }

    for dpi, size in densities.items():
        make_legacy(size, f"{RES}/mipmap-{dpi}/ic_launcher.png")
        make_legacy(size, f"{RES}/mipmap-{dpi}/ic_launcher_round.png")

    for dpi, size in fg_densities.items():
        make_foreground(size, f"{RES}/mipmap-{dpi}/ic_launcher_foreground.png")

    write(f"{RES}/mipmap-anydpi-v26/ic_launcher.xml", ADAPTIVE)
    write(f"{RES}/mipmap-anydpi-v26/ic_launcher_round.xml", ADAPTIVE)
    write(f"{RES}/values/colors.xml", COLORS)
    print("icons generated")


ADAPTIVE = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""

COLORS = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0A0F24</color>
</resources>
"""

if __name__ == "__main__":
    main()
