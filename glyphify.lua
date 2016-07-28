#!/usr/bin/env luajit

local image = require('image')
local lapp = require('pl.lapp')
local lapp_color = require('lapp_color')
local lfs = require('lfs')
local path = require('pl.path')
local torch = require('torch')

local args = lapp [[
Convert an image to math notation.
    <glyphs>         (string)                     glyphs set to use
    <image>          (string)                     image to process

    Feature detection:
    -e, --extractor  (string default marr)        feature (e.g. edge) detector
    -b, --blur       (number default 5)           blur before edge detection
    --kernel         (number default 11)          edge detection kernel size
    --threshold      (number default .2)          filter out smaller features
    --reverse                                     fill similar intensity areas

    Glyph fitting:
    -f, --fitter     (string default mc)          fitting strategy
    -n, --number     (number default 2500)        max number of glyphs to fit
    -q, --quality    (number default 500)         fitting tries each round
    --min_opacity    (number default .2)          minimum glyph opacity
    --max_opacity    (number default 1)           maximum glyph opacity
    --min_value      (number default -5)          skip badly fit glyphs

    Output:
    -o, --output     (string default output.png)  where to save the output
    -c, --color      (color default #000000)      output hue
]]

lapp_color.parse_defaults(args, {'color'})

-- Feature extractors command-line keys.
local extractors = {
    marr = require('extractors.marr')
}

--- Maps command-line keys to fitter classes.
local fitters = {
    brute = require('fitters.brute'),
    mc = require('fitters.mc')
}


--- Loads an image and converts it to grayscale.
local function load_gray(img_path)
    local img = image.load(img_path)
    if img:size(1) == 4 then
        img = img:sub(2, 4)
    end
    if img:size(1) == 3 then
        img = image.rgb2y(img)
    end
    return img[1]
end


-- Attempts to locate glyph resources, whether installed or run from source.
local function find_glyphs(key)
    local bases = {
        path.dirname(arg[0]),                -- ./glyphify.lua
        path.dirname(path.dirname(arg[0]))   -- .../bin/glyphify
    }
    for _, base in pairs(bases) do
        local dir = path.join(base, 'glyphs', key)
        if path.exists(dir) then
            return dir
        end
    end
    error("Could not locate glyphset " .. key)
end


--- Loads all glyphs (.png images) in the folder.
local function load_glyphs(folder)
    local glyphs = {}
    for filename in lfs.dir(folder) do
        if path.extension(filename) == '.png' then
            local glyph = load_gray(path.join(folder, filename))
            glyphs[#glyphs + 1] = glyph
        end
    end
    return glyphs
end


--- Displays a dot for every 10% of progress.
local function progress_dots()
    local last_progress = 0
    return function(progress)
        if math.floor(10 * last_progress) < math.floor(10 * progress) then
            io.write('.')
            io.flush()
        end
        last_progress = progress
    end
end


--- Converts grayscale data to a monochromatic image with transparency.
local function y2rgba(luminance, color)
    local rgba = torch.Tensor(4, luminance:size(1), luminance:size(2))
    rgba[1] = color.r
    rgba[2] = color.g
    rgba[3] = color.b
    rgba[4] = luminance
    return rgba
end


local img = load_gray(args.image)
local edges = extractors[args.extractor]().extract_features(img, args)
local canvas = torch.zeros(edges:size())
local glyphs = load_glyphs(find_glyphs(args.glyphs))
fitters[args.fitter]():fit_glyphs(edges, canvas, glyphs, args, progress_dots())
image.save(args.output, y2rgba(canvas, args.color))
print()
