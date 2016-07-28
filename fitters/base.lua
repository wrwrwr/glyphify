local class = require('pl.class')

local torchx = require('torchx')


local BaseFitter = class()


--- Tries to fit each glyph separately using subclasses fit_glyph().
function BaseFitter:fit_glyphs(target, canvas, glyphs, opts, progress)
    local diff = target - canvas
    local opacity_range = opts.max_opacity - opts.min_opacity
    math.randomseed(os.time())
    for round = 1, opts.number do
        progress(round / opts.number)
        local opacity = opts.min_opacity + math.random() * opacity_range
        local glyph = glyphs[math.random(#glyphs)] * opacity
        local value, x, y = self.fit_glyph(diff, glyph, opts)
        if value > opts.min_value then
            torchx.add_at(canvas, x, y, glyph)
            torchx.add_at(diff, x, y, -glyph)
        end
    end
end


return BaseFitter
