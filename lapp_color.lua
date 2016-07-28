local lapp = require('pl.lapp')


local lapp_color = {}


-- Lapp converter for #RGB and #RRGGBB arguments.
function lapp_color.parse_color(color)
    if color:sub(1, 1) == '#' then
        color = color:sub(2)
    end
    lapp.assert(color:len() == 3 or color:len() == 6,
                "please use #RGB or #RRGGBB notation for colors")
    if color:len() == 3 then
        return {
            r = tonumber('0x' .. color:sub(1, 1)),
            g = tonumber('0x' .. color:sub(2, 2)),
            b = tonumber('0x' .. color:sub(3, 3))
        }
    else
        return {
            r = tonumber('0x' .. color:sub(1, 2)),
            g = tonumber('0x' .. color:sub(3, 4)),
            b = tonumber('0x' .. color:sub(5, 6))
        }
    end
end


-- WA: The add_type() converter is not applied to default values.
function lapp_color.parse_defaults(args, color_args)
    for _, key in pairs(color_args) do
        if type(args[key]) == 'string' then
            args[key] = lapp_color.parse_color(args[key])
        end
    end
end


lapp.add_type('color', lapp_color.parse_color)


return lapp_color
