#!/usr/bin/env python3
"""Generate StremioWeb app icons (purple rounded square, white play triangle)
and write AppIcon.appiconset/Contents.json with explicit filenames."""
import os
import json
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "StremioWeb", "Assets.xcassets", "AppIcon.appiconset")
PURPLE = (124, 77, 255)
WHITE = (255, 255, 255)

def draw_icon(size):
    img = Image.new("RGB", (size, size), PURPLE)
    d = ImageDraw.Draw(img)
    r = int(size * 0.225)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=PURPLE)
    # white play triangle, centered
    cx, cy = size * 0.5, size * 0.52
    w, h = size * 0.30, size * 0.36
    d.polygon([(cx - w / 2, cy - h / 2), (cx - w / 2, cy + h / 2), (cx + w / 2, cy)], fill=WHITE)
    return img

SIZES = [1024, 180, 120, 87, 80, 60, 58, 40, 29, 20]
os.makedirs(OUT, exist_ok=True)
for s in SIZES:
    img = draw_icon(s)
    name = "icon-1024.png" if s == 1024 else f"icon-{s}.png"
    img.save(os.path.join(OUT, name))
    print("wrote", name)

def entry(idiom, size, scale, px):
    return {"idiom": idiom, "size": size, "scale": scale,
            "filename": "icon-1024.png" if px == 1024 else f"icon-{px}.png"}

images = [
    entry("iphone", "20x20", "2x", 40),
    entry("iphone", "20x20", "3x", 60),
    entry("iphone", "29x29", "2x", 58),
    entry("iphone", "29x29", "3x", 87),
    entry("iphone", "40x40", "2x", 80),
    entry("iphone", "40x40", "3x", 120),
    entry("iphone", "60x60", "2x", 120),
    entry("iphone", "60x60", "3x", 180),
    entry("ipad", "20x20", "1x", 20),
    entry("ipad", "20x20", "2x", 40),
    entry("ipad", "29x29", "1x", 29),
    entry("ipad", "29x29", "2x", 58),
    entry("ipad", "40x40", "1x", 40),
    entry("ipad", "40x40", "2x", 80),
    entry("ipad", "76x76", "2x", 152),
    entry("ipad", "83.5x83.5", "2x", 167),
    entry("ios-marketing", "1024x1024", "1x", 1024),
]
for px in (152, 167):
    img = draw_icon(px)
    img.save(os.path.join(OUT, f"icon-{px}.png"))
    print("wrote", f"icon-{px}.png")

contents = {"images": images, "info": {"author": "xcode", "version": 1}}
with open(os.path.join(OUT, "Contents.json"), "w", encoding="utf-8") as f:
    json.dump(contents, f, indent=2)
print("wrote Contents.json")
print("done")
