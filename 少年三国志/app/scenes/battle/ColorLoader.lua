-- ColorLoader

local ColorLoader = {}

local color_list_default = {}

local color_list = {}
local color_get_list = nil

function ColorLoader.add(...)
    local _p = {...}
    for i=1, #_p do
        local _t = _p[i]
        for k, color in pairs(_t) do
            if #color == 3 then
                local colorKey = color[1]..'_'..color[2]..'_'..color[3]
                if not color_list[colorKey] then color_list[colorKey] = color end
            end
        end
    end
end

function ColorLoader.clear()
    color_list = {}
    color_get_list = nil
end

function ColorLoader.getList()
    
    color_get_list = {}
    
    local _t = clone(color_list_default)

    for k, v in pairs(color_list) do
        if not _t[k] then _t[k] = v end
    end
    
    for k, v in pairs(_t) do
        color_get_list[#color_get_list+1] = v
    end
    
    return color_get_list
end

function ColorLoader.desc()    
    local list = ColorLoader.getList()
    for i=1, #list do
        local color = list[i]
        print("<load color: {"..color[1]..","..color[2]..","..color[3].."}>")
    end
end

return ColorLoader

