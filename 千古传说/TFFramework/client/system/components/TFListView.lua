local _create = TFListView.create
function TFListView:create()
	local obj = _create(TFListView)
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFListView:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
    local obj = new(val, parent)
    obj:initMEListView(val, parent) 
    return true, obj
end
rawset(TFListView, "initControl", initControl)

return TFListView