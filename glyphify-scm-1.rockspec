package = 'glyphify'
version = 'scm-1'

description = {
    summary = "Redraw an image using glyphs.",
    detailed = [[
        A Torch-based command-line image filter. May be used to give a usual
        photo or picture a "matrix-kind" style, with a free choice on what
        characters (glyphs) to use.
    ]],
    license = 'MIT',
    homepage = 'https://github.com/wrwrwr/glyphify',
    maintainer = 'lua@wr.waw.pl'
}

dependencies = {
    'lua >= 5.1',
    'penlight >= 1.3',
    'torch >= 7'
}

source = {
    url = 'git://github.com/wrwrwr/glyphify.git'
}

build = {
    type = 'builtin',
    modules = {
        glyphify = 'glyphify.lua',
        lapp_color = 'lapp_color.lua',
        torchx = 'torchx.lua',
        ['extractors.marr'] = 'extractors/marr.lua',
        ['fitters.brute'] = 'fitters/brute.lua',
        ['fitters.mc'] = 'fitters/mc.lua'
    },
    install = {
        bin = {
            extract_glyphs = 'extract_glyphs.py',
            glyphify = 'glyphify.lua'
        }
    },
    copy_directories = {'examples', 'glyphs'}
}
