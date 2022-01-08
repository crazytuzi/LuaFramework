--[[--
	*.lua配置生成ui控件:

	--By: yun.bo
	--2013/8/8
]]

TFLua = class('TFLua')

function TFLua:initControl(val, parent)
	local ui = createUIByLua(val.path)
	if parent then
		parent:addChild(ui) 
	end

	local tempVersion = TFUIBase.version
	TFUIBase.version = TFUIBase:adaptVersion(val.version)
	ui:initMELua(val, parent)
	TFUIBase.version = tempVersion
	return true, ui
end

return TFLua