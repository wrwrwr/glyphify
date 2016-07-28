local class = require('pl.class')
local torch = require('torch')

local BaseFitter = require('glyphify.fitters.base')


local BruteForceFitter = class(BaseFitter)


--- Tries all positions (only viable for small images).
function BruteForceFitter.fit_glyph(diff, glyph)
    local best_value = -math.huge
    local best_x, best_y = nil, nil
    local dx, dy = glyph:size(1) - 1, glyph:size(2) - 1
    local max_x = diff:size(1) - glyph:size(1)
    local max_y = diff:size(2) - glyph:size(2)
    for x = 1, max_x do
        for y = 1, max_y do
            local value = -torch.dist(diff:sub(x, x + dx, y, y + dy), glyph)
            if value > best_value then
                best_value = value
                best_x, best_y = x, y
            end
        end
    end
    return best_value, best_x, best_y
end


return BruteForceFitter
