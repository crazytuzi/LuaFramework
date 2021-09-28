local PkModeLayer = class("PkModeLayer",function() return cc.Layer:create() end )

local cur_mode = 0
PkModeLayer.modes = {}

PkModeLayer.isChangeModeShow =false

function PkModeLayer:ctor(parent)

end

function PkModeLayer:setCurMode(mode)
	cur_mode = mode
	--print("mode"..mode)
end

function PkModeLayer:getCurMode()
	return cur_mode
end

return PkModeLayer