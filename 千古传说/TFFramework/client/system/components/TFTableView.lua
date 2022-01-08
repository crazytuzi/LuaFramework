
local _create = TFTableView.create
function TFTableView:create()
    local obj = _create(TFTableView)
    if  not obj then return end
    TFUIBase:extends(obj)
    return obj
end


local function new(val, parent)
    local obj = TFTableView:create()
    if parent then
        parent:addChild(obj) 
    end 
    return obj
end


local function initControl(_, val, parent)
    local obj = new(val, parent)
    obj:initMETableView(val, parent) 
    return true, obj
end
rawset(TFTableView, "initControl", initControl)

return TFTableView