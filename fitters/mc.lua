local class = require('pl.class')
local torch = require('torch')

local BaseFitter = require('fitters.base')


local MonteCarloFitter = class(BaseFitter)

--- Draws opts.quality random locations and chooses the best one.
function MonteCarloFitter.fit_glyph(diff, glyph, opts)
    local best_value = -math.huge
    local best_x, best_y = nil, nil
    local dx, dy = glyph:size(1) - 1, glyph:size(2) - 1
    local max_x = diff:size(1) - glyph:size(1)
    local max_y = diff:size(2) - glyph:size(2)
    for _ = 1, opts.quality do
        local x = math.random(max_x)
        local y = math.random(max_y)
        local value = -torch.dist(diff:sub(x, x + dx, y, y + dy), glyph)
        if value > best_value then
            best_value = value
            best_x, best_y = x, y
        end
    end
    return best_value, best_x, best_y
end

return MonteCarloFitter
