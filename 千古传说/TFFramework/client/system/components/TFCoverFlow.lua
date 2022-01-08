--[[--
	缩放翻页控件:

	--By: yun.bo
	--2013/8/13
]]

local _create = TFCoverFlow.create
function TFCoverFlow:create()
	local obj = _create(TFCoverFlow)
	if  not obj then return end
	TFUIBase:extends(obj)
	return obj
end

local function new(val, parent)
	local obj = TFCoverFlow:create()
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	if obj.initMECoverFlow then
		obj:initMECoverFlow(val, parent)
	end
	return true, obj
end
rawset(TFCoverFlow, "initControl", initControl)

return TFCoverFlow
