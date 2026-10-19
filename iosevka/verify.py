# Sanity checks for the patched fonts. Run with FontForge's Python:
#   fontforge -script verify.py FONT.ttf...
import sys

import fontforge

FAMILY = "IosevkaTermSS06X Nerd Font Mono"
STYLES = {
    # style: OS/2 weight class
    "Regular": 400,
    "Bold": 700,
    "Italic": 400,
    "Bold Italic": 700,
}
WIDTH = 600
REQUIRED = {
    0x0041: "Latin A",
    0x0416: "Cyrillic Zhe",
    0x044F: "Cyrillic ya",
    0xE0B0: "Powerline arrow",
    0xF015: "Font Awesome home",
    0xF0001: "Material Design icon",
}

errors = []
seen = set()


def check(path, ok, message):
    if not ok:
        errors.append(f"{path}: {message}")


for path in sys.argv[1:]:
    font = fontforge.open(path)
    # Index glyphs by Unicode code point, including planes above the BMP.
    font.encoding = "UnicodeFull"
    names = {(lang, key): value for lang, key, value in font.sfnt_names}
    family = names.get(("English (US)", "Preferred Family")) or font.familyname
    style = names.get(("English (US)", "Preferred Styles")) or names.get(("English (US)", "SubFamily"))
    seen.add(style)

    check(path, family == FAMILY, f"family is {family!r}, expected {FAMILY!r}")
    check(path, style in STYLES, f"unexpected style {style!r}")
    if style in STYLES:
        check(path, font.os2_weight == STYLES[style], f"OS/2 weight is {font.os2_weight}, expected {STYLES[style]}")

    for codepoint, label in REQUIRED.items():
        if codepoint not in font:
            check(path, False, f"missing U+{codepoint:04X} ({label})")
        else:
            width = font[codepoint].width
            check(path, width == WIDTH, f"U+{codepoint:04X} ({label}) is {width} wide, expected {WIDTH}")

    features = {
        feature
        for lookup in font.gsub_lookups
        for feature, _ in font.getLookupInfo(lookup)[2]
    }
    check(path, "calt" in features, "no calt lookups (ligatures lost)")

    print(f"{path}: {family} / {style}, weight {font.os2_weight}, {len(list(font.glyphs()))} glyphs")
    font.close()

missing = set(STYLES) - seen
if missing:
    errors.append(f"missing styles: {', '.join(sorted(missing))}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print("All checks passed.")
