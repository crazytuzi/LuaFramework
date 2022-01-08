
local _create = TFTableViewCell.create
function TFTableViewCell:create()
    local obj = _create(TFTableViewCell)
    if  not obj then return end
    TFUIBase:extends(obj)
    return obj
end

local function new(val, parent)
    local obj = TFTableViewCell:create()
    if parent then
        parent:addChild(obj)
    end
    return obj
end

local function initControl(_, val, parent)
    local obj = new(val, parent)
    obj:initMEWidget(val, parent)
    return true, obj
end
rawset(TFTableViewCell, "initControl", initControl)

return TFTableViewCell
