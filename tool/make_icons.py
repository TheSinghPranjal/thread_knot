# Regenerates every platform app icon from assets/icon/source.png.
# Run from the repo root: python3 tool/make_icons.py .  (needs Pillow)
import json, os, sys
from PIL import Image, ImageDraw
root = sys.argv[1]
src = Image.open(os.path.join(root, 'assets/icon/source.png')).convert('RGB')
N = src.size[0]
ORANGE = (253, 182, 36)
R, INSET = 322, 5  # rounded-rect radius / inset, trimmed inside the dark AA fringe

def mask(size):
    s = 4
    m = Image.new('L', (size * s, size * s), 0)
    k = s * size / N
    ImageDraw.Draw(m).rounded_rectangle(
        [INSET * k, INSET * k, (N - INSET) * k, (N - INSET) * k], radius=R * k, fill=255)
    return m.resize((size, size), Image.LANCZOS)

full = Image.new('RGB', (N, N), ORANGE); full.paste(src, (0, 0), mask(N))
rounded = Image.new('RGBA', (N, N), (0, 0, 0, 0)); rounded.paste(src, (0, 0), mask(N))
full.save(os.path.join(root, 'assets/icon/app_icon.png'))
rounded.save(os.path.join(root, 'assets/icon/app_icon_rounded.png'))

def save(img, path, size, mode=None):
    out = img.resize((size, size), Image.LANCZOS)
    if mode: out = out.convert(mode)
    out.save(os.path.join(root, path), optimize=True)

def padded(img, size, frac, bg):
    canvas = Image.new('RGBA', (size, size), bg)
    inner = round(size * frac)
    canvas.paste(img.resize((inner, inner), Image.LANCZOS).convert('RGBA'),
                 ((size - inner) // 2, (size - inner) // 2),
                 img.resize((inner, inner), Image.LANCZOS).convert('RGBA'))
    return canvas

# iOS: opaque, no alpha
ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
for e in json.load(open(os.path.join(root, ios, 'Contents.json')))['images']:
    px = round(float(e['size'].split('x')[0]) * int(e['scale'][0]))
    save(full, f"{ios}/{e['filename']}", px, 'RGB')

# Android legacy + adaptive (foreground sits in the 72/108 visible zone)
res = 'android/app/src/main/res'
for d, dp in {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}.items():
    save(full, f'{res}/mipmap-{d}/ic_launcher.png', round(48 * dp), 'RGB')
    padded(full, round(108 * dp), 72 / 108, (0, 0, 0, 0)).save(
        os.path.join(root, f'{res}/mipmap-{d}/ic_launcher_foreground.png'), optimize=True)
os.makedirs(os.path.join(root, f'{res}/mipmap-anydpi-v26'), exist_ok=True)
open(os.path.join(root, f'{res}/mipmap-anydpi-v26/ic_launcher.xml'), 'w').write(
'''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')

# macOS: Big Sur style, rounded art at 824/1024 with transparent margin
mac = 'macos/Runner/Assets.xcassets/AppIcon.appiconset'
for s in [16, 32, 64, 128, 256, 512, 1024]:
    padded(rounded, s, 824 / 1024, (0, 0, 0, 0)).save(os.path.join(root, f'{mac}/app_icon_{s}.png'), optimize=True)

# Web
save(rounded, 'web/icons/Icon-192.png', 192)
save(rounded, 'web/icons/Icon-512.png', 512)
for s in [192, 512]:
    padded(full, s, 0.86, ORANGE + (255,)).convert('RGB').save(
        os.path.join(root, f'web/icons/Icon-maskable-{s}.png'), optimize=True)
save(rounded, 'web/favicon.png', 32)

# Windows
rounded.resize((256, 256), Image.LANCZOS).save(
    os.path.join(root, 'windows/runner/resources/app_icon.ico'),
    sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print('done')
