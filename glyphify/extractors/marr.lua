local class = require('pl.class')
local image = require('image')
local torch = require('torch')


local MarrExtractor = class()


--- Performs simplistic edge detection and normalizes the result to [0, 1].
-- See: http://homepages.inf.ed.ac.uk/rbf/HIPR2/log.htm.
function MarrExtractor.extract_features(img, opts)
    local ext = opts.blur + opts.kernel - 2
    img = image.scale(img, img:size(2) + ext, img:size(1) + ext, 'bicubic')
    local edges = image.convolve(img, image.gaussian(opts.blur))
    edges = image.convolve(edges, image.laplacian(opts.kernel))
    edges = (edges - edges:mean()) / edges:std()
    edges = torch.cmax(edges, opts.threshold) - opts.threshold
    if opts.reverse then
        edges = -edges
    end
    return edges / edges:max()
end


return MarrExtractor
