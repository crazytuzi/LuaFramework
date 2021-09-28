-- Location

-- Location 定义所有的在标准尺寸分辨率（640*960）上的位置坐标
local Location = {
    
    scale_factor = 0.77,
    perspective_factor = 0.05,
    space_factor = 150,
    
    -- 敌方的位置
    enemy = {
        --[[B1 = ]]{140, 570}, --[[B2 = ]]{320, 570}, --[[B3 = ]]{500, 570},
        --[[B4 = ]]{160, 720}, --[[B5 = ]]{320, 720}, --[[B6 = ]]{480, 720}
    },
    
    -- 我方的位置
    mine = {
        --[[A1 = ]]{120, 290}, --[[A2 = ]]{320, 290}, --[[A3 = ]]{520, 290},
        --[[A4 = ]]{110, 90}, --[[A5 = ]]{320, 90}, --[[A6 = ]]{530, 90}
    },

}

local function getContentScaleFactor() return display.width / CONFIG_SCREEN_WIDTH end

-- real to virtual
local function R2V(position)
    
    local _position = clone(position)
    
    local scaleFactor = getContentScaleFactor()

    return {_position[1] / scaleFactor, _position[2] / scaleFactor}
end

-- virtual to real
local function V2R(position)
    
    local _position = clone(position)
    
    local scaleFactor = getContentScaleFactor()

    return {_position[1] * scaleFactor, _position[2] * scaleFactor}
end

-- LocationFactory

local LocationFactory = {}

function LocationFactory.getSelfPositionByIndex(index)
    
    local _position = clone(Location.mine[index])

    if index < 4 then
        local space = (((Location.enemy[4][2] - Location.mine[4][2]) * Location.perspective_factor) / 100 + 1) * Location.space_factor
        _position[2] = Location.mine[4][2] + space
    end
    
    return V2R(_position)
    
end

function LocationFactory.getEnemyPositionByIndex(index)
    
    local _position = clone(Location.enemy[index])
    
    local scaleFactor = getContentScaleFactor()
    _position[2] = _position[2] - (960 - display.height / scaleFactor) / 2
    
    return V2R(_position)
end

function LocationFactory.getScaleByPosition(position)

    local _position = clone(position)
    
    _position = R2V(_position)
    -- 以B组的角色缩放比为基准
    local factor = ((((Location.enemy[4][2] - _position[2]) * Location.perspective_factor) / 100 + 1) * Location.scale_factor)

    return factor * getContentScaleFactor() * math.min(display.height, 960) / 960
    
end

return LocationFactory

