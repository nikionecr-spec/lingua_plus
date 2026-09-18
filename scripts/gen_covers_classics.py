#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generates premium covers for the Lingua+ classics collection.
600×900 JPEG per book: level palette, ornamental frame, Persian title
(shaped via arabic-reshaper + bidi), English title, author, badge."""
import os
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = "/home/z/my-project/lingua_plus"
COVERS = os.path.join(ROOT, "assets", "covers")
FONTS = os.path.join(ROOT, "assets", "fonts")
FA_BOLD = os.path.join(FONTS, "Vazirmatn-Bold.ttf")
FA_MED = os.path.join(FONTS, "Vazirmatn-Medium.ttf")
EN_BOLD = os.path.join(FONTS, "Poppins-Bold.ttf")
EN_SEMI = os.path.join(FONTS, "Poppins-SemiBold.ttf")
EN_MED = os.path.join(FONTS, "Poppins-Medium.ttf")

W, H = 600, 900

# (base_dark, base_light, accent) per CEFR level
PALETTE = {
    "A1": ((15, 118, 110), (19, 78, 74), (94, 234, 212)),
    "A2": ((2, 90, 145), (12, 55, 94), (125, 211, 252)),
    "B1": ((91, 33, 182), (59, 22, 116), (196, 154, 255)),
    "B2": ((157, 23, 77), (96, 16, 51), (249, 168, 212)),
    "C1": ((146, 64, 14), (87, 42, 8), (252, 211, 77)),
}

import importlib.util
spec = importlib.util.spec_from_file_location(
    "bc", "/home/z/my-project/scripts/build_classics.py")
bc = importlib.util.module_from_spec(spec)
# Prevent main() execution: module only defines data when imported.
spec.loader.exec_module(bc)
BOOKS = bc.BOOKS


def fa(text: str) -> str:
    """Pillow+Raqm shapes and bidi-reorders Persian natively."""
    return text


def vgrad(c_dark, c_light):
    """Vertical gradient image with a soft radial glow."""
    img = Image.new("RGB", (W, H))
    px = img.load()
    for y in range(H):
        t = y / (H - 1)
        t = t ** 1.25
        r = int(c_dark[0] + (c_light[0] - c_dark[0]) * t)
        g = int(c_dark[1] + (c_light[1] - c_dark[1]) * t)
        b = int(c_dark[2] + (c_light[2] - c_dark[2]) * t)
        for x in range(0, W, 1):
            # slight horizontal shading for depth
            hx = int(14 * (abs(x - W / 2) / (W / 2)))
            px[x, y] = (max(0, r - hx), max(0, g - hx), max(0, b - hx))
    # radial glow near the title zone
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    gd.ellipse([W * 0.08, H * 0.16, W * 0.92, H * 0.52], fill=46)
    glow = glow.filter(ImageFilter.GaussianBlur(80))
    accent = Image.new("RGB", (W, H), c_light)
    img = Image.composite(Image.blend(img, accent, 0.35), img, glow)
    return img


def add_noise(img):
    noise = Image.effect_noise((W, H), 14).convert("L")
    noise_img = Image.new("RGB", (W, H), (255, 255, 255))
    noise_img.putalpha(noise)
    return Image.blend(img, Image.alpha_composite(
        img.convert("RGBA"), noise_img).convert("RGB"), 0.05)


def vignette(img):
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse([-W * 0.35, -H * 0.25, W * 1.35, H * 1.25], fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(120))
    dark = Image.new("RGB", (W, H), (0, 0, 0))
    inv = Image.eval(mask, lambda v: 255 - v)
    return Image.composite(dark, img, inv.point(lambda v: v * 0.38))


def fit_font(path, text, max_w, start_size, min_size=18):
    for size in range(start_size, min_size - 1, -2):
        f = ImageFont.truetype(path, size)
        if f.getbbox(text)[2] - f.getbbox(text)[0] <= max_w:
            return f
    return ImageFont.truetype(path, min_size)


def wrap(text, font, max_w):
    words, lines, cur = text.split(), [], ""
    for w_ in words:
        trial = (cur + " " + w_).strip()
        if font.getbbox(trial)[2] - font.getbbox(trial)[0] <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w_
    if cur:
        lines.append(cur)
    return lines


def draw_centered(d, lines, font, cy, fill, spacing=1.22):
    heights = []
    for ln in lines:
        bb = font.getbbox(ln)
        heights.append(bb[3] - bb[1])
    lh = max(heights) * spacing if heights else 0
    total = lh * len(lines)
    y = cy - total / 2
    for ln in lines:
        bb = font.getbbox(ln)
        w_ = bb[2] - bb[0]
        x = (W - w_) / 2 - bb[0]
        y0 = y - bb[1]
        # soft shadow
        d.text((x + 1.5, y0 + 2), ln, font=font, fill=(0, 0, 0, 90))
        d.text((x, y0), ln, font=font, fill=fill)
        y += lh


def ornament(d, cx, cy, accent, r=7):
    """line ──◆── line ornament."""
    d.line([cx - 52, cy, cx - r - 5, cy], fill=accent, width=2)
    d.line([cx + r + 5, cy, cx + 52, cy], fill=accent, width=2)
    d.polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)],
              outline=accent, width=2)


def frame(d, accent):
    inset1, inset2 = 22, 30
    d.rectangle([inset1, inset1, W - inset1, H - inset1],
                outline=accent + (150,), width=2)
    d.rectangle([inset2, inset2, W - inset2, H - inset2],
                outline=accent + (90,), width=1)
    # corner diamonds
    for cx, cy in [(inset1, inset1), (W - inset1, inset1),
                   (inset1, H - inset1), (W - inset1, H - inset1)]:
        r = 6
        d.polygon([(cx, cy - r), (cx + r, cy), (cx, cy + r), (cx - r, cy)],
                  fill=accent + (210,))


def badge(d, level, accent):
    f = ImageFont.truetype(EN_BOLD, 26)
    text = level
    bb = f.getbbox(text)
    tw, th = bb[2] - bb[0], bb[3] - bb[1]
    pad_x, h_ = 18, 40
    x0, y0 = 52, H - 96
    box = [x0, y0, x0 + tw + pad_x * 2, y0 + h_]
    d.rounded_rectangle(box, radius=h_ // 2, fill=(255, 255, 255, 28),
                        outline=accent + (230,), width=2)
    d.text((x0 + pad_x - bb[0], y0 + (h_ - th) / 2 - bb[1]), text,
           font=f, fill=accent + (255,))
    return box[2]


def wordmark(d, en_med, color):
    f = ImageFont.truetype(EN_SEMI, 20)
    text = "Lingua+  Classics"
    bb = f.getbbox(text)
    tw = bb[2] - bb[0]
    d.text((W - 52 - tw - bb[0], H - 96 + 8 - bb[1]), text,
           font=f, fill=color)


def make_cover(slug, level, ten, tfa, aen, afa):
    c_dark, c_light, accent_rgb = PALETTE.get(level, PALETTE["B1"])
    img = vgrad(c_dark, c_light)
    img = add_noise(img)
    img = vignette(img)
    img = img.convert("RGBA")
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    accent = accent_rgb

    frame(d, accent)

    # top ornament + series line
    f_series = ImageFont.truetype(EN_MED, 17)
    d.text((W / 2 - f_series.getbbox("L I B R A R Y")[2] / 2, 62),
           "T H E   C L A S S I C S", font=f_series, fill=accent + (200,))
    ornament(d, W / 2, 116, accent)

    # Persian title (shaped)
    fa_title = fa(tfa)
    f_fa = fit_font(FA_BOLD, max(fa_title.split(), key=len), W - 140, 56)
    fa_lines = wrap(fa_title, f_fa, W - 130)[:3]
    draw_centered(d, fa_lines, f_fa, 268, (255, 255, 255, 255))

    ornament(d, W / 2, 268 + (max((f_fa.getbbox(l)[3] for l in fa_lines),
             default=40)) * 1.35, accent, r=5)

    # English title
    f_en = fit_font(EN_SEMI, max(ten.split(), key=len), W - 150, 34)
    en_lines = wrap(ten, f_en, W - 140)[:3]
    draw_centered(d, en_lines, f_en, 402, (255, 255, 255, 225))

    # author (FA + EN)
    author_fa = fa(afa) if afa else ""
    f_auth = fit_font(FA_MED, author_fa, W - 180, 24)
    bb = f_auth.getbbox(author_fa)
    d.text(((W - (bb[2] - bb[0])) / 2 - bb[0], 512), author_fa,
           font=f_auth, fill=(255, 255, 255, 205))
    f_auth2 = fit_font(EN_MED, aen, W - 180, 20)
    bb2 = f_auth2.getbbox(aen)
    d.text(((W - (bb2[2] - bb2[0])) / 2 - bb2[0], 552), aen,
           font=f_auth2, fill=(255, 255, 255, 165))

    # bottom badges
    badge(d, level, accent)
    wordmark(d, EN_MED, (255, 255, 255, 150))

    img = Image.alpha_composite(img, overlay)
    out = os.path.join(COVERS, f"cl_{slug}.jpg")
    img.convert("RGB").save(out, "JPEG", quality=86, optimize=True)
    return os.path.getsize(out)


def main():
    os.makedirs(COVERS, exist_ok=True)
    total = 0
    for gid, slug, level, ten, tfa, aen, afa, _syn in BOOKS:
        size = make_cover(slug, level, ten, tfa, aen, afa)
        total += size
        print(f"[cover] {slug}: {size // 1024} KB")
    print(f"=== {len(BOOKS)} covers, {total / 1048576:.1f} MB ===")


if __name__ == "__main__":
    main()
