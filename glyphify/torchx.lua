local torchx = {}


--- Returns a sub-sized subview of the image with upper-left at (x1, y1).
function torchx.rect(img, x1, y1, sub)
    local x2 = x1 + sub:size(1) - 1
    local y2 = y1 + sub:size(2) - 1
    return img:sub(x1, x2, y1, y2)
end


-- Adds sub to a subview of img with upper-left at (x1, y1).
function torchx.add_at(img, x1, y1, sub)
    return torchx.rect(img, x1, y1, sub):add(sub)
end


return torchx
