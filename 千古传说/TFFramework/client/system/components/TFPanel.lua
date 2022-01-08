--[[--
	面板控件:

	--By: yun.bo
	--2013/7/12
]]

local _pcreate = TFPanel.create
function TFPanel:create(tParams)
	local obj = _pcreate(TFPanel)
	if  not obj then return end
	TFUIBase:extends(obj)

	if tParams then 
		local nType = tParams.colorType or TF_LAYOUT_COLOR_SOLID
		
		if nType == TF_LAYOUT_COLOR_SOLID then
			obj:setBackGroundColorType(nType)
			if tParams.backColor then 
				obj:setBackGroundColor(tParams.backColor)
			end
		elseif nType == TF_LAYOUT_COLOR_GRADIENT then
			obj:setBackGroundColorType(nType)
			obj:setBackGroundColor(tParams.backColor[1], tParams.backColor[2])
		end
		if tParams.size then 
			obj:setSize(tParams.size)
		else
			obj:setSizeType(TF_SIZE_PERCENT)
			obj:setSizePercent(ccp(1, 1))
		end
	end

	return obj
end

local function new(val, parent)
	local obj
	obj = TFPanel:create()
	if parent then
		if parent:getDescription() ~= "TFPageView" then
			parent:addChild(obj) 
		else
			parent:addPage(obj)	--pageView only use to add page in editor
		end
	end
	return obj
end

local function initControl(_, val, parent)
	local obj = new(val, parent)
	obj:initMEPanel(val, parent)
	return true, obj
end
rawset(TFPanel, "initControl", initControl)

return TFPanel