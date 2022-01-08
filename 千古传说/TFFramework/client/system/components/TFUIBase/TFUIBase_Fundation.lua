--[[--
	控件基本方法:

	--By: yun.bo
	--2013/11/28
]]

function TFUIBase:setAlign(align)
	if not self.setAnchorPoint then return false end
	if align == "left" then 
		self:setAnchorPoint(ccp(0, 0.5))
	elseif align == "right" then 
		self:setAnchorPoint(ccp(1, 0.5))
	elseif align == "center" then 
		self:setAnchorPoint(ccp(0.5, 0.5))
	end
	return true
end

function TFUIBase:setAlpha(alpha)
	if not self.setOpacity then return false end
	self:setOpacity(alpha * 255)
	return true
end

--[[
	Add custom event
	param szEventType: event type
	param func: event handle
	param ...: event params
--]]
function TFUIBase:addEventListener(eventType, func, isOnce)
	if type(eventType) == 'number' then 
		self:addMEListener(eventType, func)
	else
		TFDirector:addMEListener(self, eventType, func, isOnce or false)
	end
	return self
end

--[[
	Add custom event, only run once
	param szEventType: event type
	param func: event handle
	param ...: event params
--]]
function TFUIBase:addEventListenerOnce(szEventType, func)
	TFDirector:addMEListenerOnce(self, szEventType, func)
	return self
end

--[[
	Remove custom event
	param szEventType: event type
	param func: event handle
--]]
function TFUIBase:removeEventListener(eventType, func)
	if type(eventType) == 'number' then 
		self:removeMEListener(eventType)
	else
		TFDirector:removeMEListener(self, eventType, func)
	end
	return self
end

--[[
	Dispatch custom event
	param szEventType: event type
	param ...: event params
--]]
function TFUIBase:dispatchEvent(szEventType, ...)
	TFDirector:dispatchEventWith(self, szEventType, ...)
	return self
end

--[[
	Dispatch global event
	param szEventType: event type
	param ...: event params
--]]
function TFUIBase:dispatchGlobalEvent(szEventType, ...)
	TFDirector:dispatchGlobalEventWith(self, szEventType, ...)
	return self
end

function TFUIBase:clone(bIsContainChild)
	if not tolua.isnull(self) and self.__MECppClone then
		bIsContainChild = (bIsContainChild ~= false)
		local objClone = self:__MECppClone(bIsContainChild)
		if not objClone then return nil end
		objClone.initFundations = self.initFundations
		TFUIBase:extends(objClone)
		cloneMEWidgetChildren(objClone)
		return objClone
	end
end

function TFUIBase:removeFromParent(bIsCleanup)
	if not tolua.isnull(self) then
		bIsCleanup = bIsCleanup ~= false and true or false
		self:removeFromParentAndCleanup(bIsCleanup)
	end
end

function TFUIBase:convertToParentSpace(pos)
	local objParent = self:getParent()
	if objParent then
		return CCPointApplyAffineTransform(pos, self:nodeToParentTransform())
	end
	return pos
end

function TFUIBase:setLayoutByTable(tParam)
	local layoutParameter
	if type(tParam) == 'string' then return end
	if tParam.nType then
		if tParam.nType+0 == 2 or tParam.nType+0 == 1 then
			layoutParameter	= TFLinearLayoutParameter:create()
			if tParam.nGravity then	layoutParameter:setGravity(tParam.nGravity+0) end
		elseif tParam.nType+0 == 3 then
			layoutParameter = TFRelativeLayoutParameter:create()
			layoutParameter:setRelativeName(self:getName())
			layoutParameter:setRelativeToWidgetName(self:getName())
			if tParam.relativeToName and tParam.relativeToName ~= "" then
				layoutParameter:setRelativeToWidgetName(tParam.relativeToName)
			end
			if tParam.nAlign then
				layoutParameter:setAlign(tParam.nAlign+0)
			end
		elseif tParam.nType+0 == 4 then
			layoutParameter = TFGridLayoutParameter:create()
		end
	end

	if tParam.PositionX or tParam.PositionY then
		tParam.PositionX = tParam.PositionX or 0
		tParam.PositionY = tParam.PositionY or 0
		self:setPosition(ccp(tParam.PositionX, tParam.PositionY))
	end

	if layoutParameter and (tParam.LeftPositon or tParam.TopPosition or tParam.RightPosition or tParam.BottomPosition) then
		tParam.LeftPositon = tParam.LeftPositon or 0
		tParam.TopPosition = tParam.TopPosition or 0
		tParam.RightPosition = tParam.RightPosition or 0
		tParam.BottomPosition = tParam.BottomPosition or 0
		layoutParameter:setMargin(TFMargin(tParam.LeftPositon, tParam.TopPosition, tParam.RightPosition, tParam.BottomPosition))
	end

	if tParam.IsPercent and type(tParam.IsPercent) ~= 'string' then
		self:setPositionType(TF_POSITION_PERCENT)
		tParam.PercentX = tParam.PercentX or 0
		tParam.PercentY = tParam.PercentY or 0
		local x, y = tParam.PercentX / 100, tParam.PercentY / 100
		self:setPositionPercent(ccp(x, y))
	end

	--remove by next version
	if tParam.type == 'line' then
		layoutParameter	= TFLinearLayoutParameter:create()
	elseif tParam.type == 'relative' then
		layoutParameter = TFRelativeLayoutParameter:create()
	elseif tParam.type ~= nil then -- default is line
		layoutParameter	= TFLinearLayoutParameter:create()
	end

	if layoutParameter then
		if tParam.margin then
			local tNums = string.split(tParam.margin, ',')
			tNums[1] = string.trim(tNums[1])
			tNums[2] = string.trim(tNums[2])
			tNums[3] = string.trim(tNums[3])
			tNums[4] = string.trim(tNums[4])

			tNums[1] = tNums[1] == '' and 0 or tNums[1] + 0
			tNums[2] = tNums[2] == '' and 0 or tNums[2] + 0
			tNums[3] = tNums[3] == '' and 0 or tNums[3] + 0
			tNums[4] = tNums[4] == '' and 0 or tNums[4]	+ 0

			layoutParameter:setMargin(TFMargin(tNums[1], tNums[2], tNums[3], tNums[4]))
		end

		if tParam.align and layoutParameter.setAlign then
			layoutParameter:setAlign(tParam.align)
		end

		if tParam.gravity then
			layoutParameter:setGravity(tParam.gravity)
		end
	end
	---------------------------------------
	if layoutParameter then
		self:setLayoutParameter(layoutParameter)
	end
end

function TFUIBase:setGrayEnabled(bGrayEnabled, toContainChild)
	if nil == toContainChild then
		toContainChild = true
	end
	if bGrayEnabled then
		self:setShaderProgram("GrayShader", toContainChild)
	else
		self:setShaderProgramDefault(toContainChild)
	end
end

function TFUIBase:setHighLightEnabled(bHighLightEnabled, toContainChild)
	if nil == toContainChild then
		toContainChild = false
	end
	if bHighLightEnabled then
		self:setShaderProgram("HighLight", toContainChild)
	else
		self:setShaderProgramDefault(toContainChild)
	end
end