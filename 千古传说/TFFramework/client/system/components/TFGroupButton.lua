--[[--
	按钮控件:

	--By: yun.bo
	--2013/8/27
]]

local _create = TFGroupButton.create
function TFGroupButton:create(texture, selecttexture)
	local obj = _create(TFGroupButton)
	if  not obj then return end
	TFUIBase:extends(obj)
	if texture 			then obj:setNormalTexture(texture) end
	if selecttexture 	then obj:setPressedTexture(selecttexture) end
	return obj
end

local function new(val, parent)
	local obj
	obj 	= TFGroupButton:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEGroupButton(val, parent)
	return true, obj
end
rawset(TFGroupButton, "initControl", initControl)

return TFGroupButton