#!/usr/bin/env python3
"""Generate a multi-size .ico from a source icon image (PNG or SVG).

Usage:
  python ENGINE/tools/generate_icon_from_svg.py

Installs:
    pip install pillow
    pip install cairosvg  # only needed when SOURCE_PATH points to an SVG
"""
import os
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SOURCE_PATH = os.path.join(REPO_ROOT, 'WEB', 'static', 'images', 'final_ico', 'final_256.png')
OUT_ICO = os.path.join(REPO_ROOT, 'ENGINE', 'assets', 'kinetic.ico')


def main():
    try:
        from PIL import Image
    except Exception:
        print('Missing dependency: pillow. Install with: pip install pillow')
        sys.exit(2)

    if not os.path.exists(SOURCE_PATH):
        print(f'Icon source not found: {SOURCE_PATH}')
        sys.exit(1)

    ext = os.path.splitext(SOURCE_PATH)[1].lower()
    if ext == '.svg':
        try:
            import cairosvg
        except Exception:
            print('Missing dependency: cairosvg. Install with: pip install cairosvg')
            sys.exit(2)

        from io import BytesIO
        png_bytes = cairosvg.svg2png(url=SOURCE_PATH, output_width=256, output_height=256)
        im = Image.open(BytesIO(png_bytes)).convert('RGBA')
    else:
        im = Image.open(SOURCE_PATH).convert('RGBA')
        if im.size != (256, 256):
            im = im.resize((256, 256), Image.LANCZOS)

    # Ensure output dir exists
    os.makedirs(os.path.dirname(OUT_ICO), exist_ok=True)

    # Save multi-size ICO (Pillow will create resized variants)
    try:
        im.save(OUT_ICO, format='ICO', sizes=[(256, 256), (48, 48), (32, 32), (16, 16)])
        print(f'Wrote: {OUT_ICO}')
    except Exception as e:
        print('Failed to write .ico:', e)
        sys.exit(1)


if __name__ == '__main__':
    main()
