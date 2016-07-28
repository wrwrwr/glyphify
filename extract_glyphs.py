#!/usr/bin/env python3

"""
Utility to extract a set of glyph images from a font.
"""
from argparse import ArgumentParser
from os import mkdir
from os.path import join
from unicodedata import category

from PIL.Image import Image
from PIL.ImageFont import truetype
from fontTools.ttLib import TTFont

sets = {
    'box': range(0x2500, 0x257F),
    'cuneiform': range(0x12000, 0x1237F),
    'dot': (ord('.'),),
    'math': (c for c in range(0x110000) if category(chr(c)) in ('Sm',)),
    'matrix': map(ord, '01')
}

fonts = {
    'dejavu-sans': '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    'dejavu-serif': '/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf'
}

if __name__ == '__main__':
    parser = ArgumentParser(description="Extract glyph images from a font.")
    parser.add_argument('glyphset', choices=sets.keys(),
                        help="glyphs collection key")
    parser.add_argument('font', nargs='?', default='dejavu-serif',
                        help="path to a .ttf file")
    parser.add_argument('size', type=int, nargs='?', default=14,
                        help="font size")
    args = parser.parse_args()

    folder = join('glyphs', args.glyphset)
    try:
        mkdir(folder)
    except FileExistsError:
        pass

    try:
        args.font = fonts[args.font]
    except KeyError:
        pass
    font = truetype(args.font, args.size)

    available_characters = set(c[0] for t in TTFont(args.font)['cmap'].tables
                                    for c in t.cmap.items())
    characters = set(sets[args.glyphset]) & available_characters
    for character in characters:
        image = Image()._new(font.getmask(chr(character)))
        image.save(join(folder, '{}.png'.format(character)))
    print("Extracted {} glyphs".format(len(characters)))
