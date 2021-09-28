--SuperDebugPanel.lua


local SuperDebugPanel = class("SuperDebugPanel", UFCCSNormalLayer)


function SuperDebugPanel.showDebugPanel( callback, colorful )
	local debugPanel = SuperDebugPanel.new( nil, nil, callback, colorful )
	uf_notifyLayer:getDebugNode():addChild(debugPanel)
end

function SuperDebugPanel:ctor( json, fun, callback, colorful, ... )
	self.super.ctor(self, json, ...)	

	self._callback = callback
	if colorful then 
		self:setBackColor(ccc4(0, 255, 0, 50))
	end

	self._isColorful = colorful and true or false
	self._destTouchData = {}
	self._curTouchIndex = 1
	self._curTouchCount = 0

	
end

function SuperDebugPanel:onLayerEnter( ... )
	self:_initDestRect()
	self:registerTouchEvent(false, false, 0)
end

function SuperDebugPanel:_initDestRect( ... )
	local RECT_WIDTH = 150
	local winSize = CCDirector:sharedDirector():getWinSize()
	table.insert(self._destTouchData, #self._destTouchData + 1, 
		{ rect = CCRectMake(0, winSize.height - RECT_WIDTH, RECT_WIDTH, RECT_WIDTH), count = 8} )
	table.insert(self._destTouchData, #self._destTouchData + 1, 
		{ rect = CCRectMake(winSize.width - RECT_WIDTH, 0, RECT_WIDTH, RECT_WIDTH), count = 5} )
	table.insert(self._destTouchData, #self._destTouchData + 1, 
		{ rect = CCRectMake(winSize.width - RECT_WIDTH, winSize.height - RECT_WIDTH, RECT_WIDTH, RECT_WIDTH), count = 2} )
	table.insert(self._destTouchData, #self._destTouchData + 1, 
		{ rect = CCRectMake(0, 0, RECT_WIDTH, RECT_WIDTH), count = 9} )
	--table.insert(self._destTouchData, #self._destTouchData + 1, 
	--	{ rect = CCRectMake(winSize.width/2 - RECT_WIDTH/2, winSize.height/2 - RECT_WIDTH/2, RECT_WIDTH, RECT_WIDTH), count = 3} )

	if self._isColorful then
		for key, value in pairs(self._destTouchData) do 
			local rect = value.rect
			local count = value.count
			if rect and type(count) == "number" then 
				local clrRect = CCLayerColor:create(ccc4(255, 100, 100, 100), rect.size.width, rect.size.height)
				self:addChild(clrRect)
				clrRect:setPositionXY(rect.origin.x, rect.origin.y )
			end

			local label = CCLabelTTF:create(""..count, "", 20)
			self:addChild(label, 1)
			label:setPositionXY(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2)
		end
	end
end

function SuperDebugPanel:onTouchBegin( xpos, ypos )
	self:_disposeTouch(xpos, ypos)
    return false
end

function SuperDebugPanel:_disposeTouch( xpos, ypos )
	if #self._destTouchData < 1 then 
		return 
	end

	if self._curTouchIndex > #self._destTouchData or self._curTouchIndex < 1 then
		self:_resetTouch()
	end

	local touchData = self._destTouchData[self._curTouchIndex]
	if not touchData then 
		return __LogError("_disposeTouch:wrong touch data for Index:%d", self._curTouchIndex)
	end

	local rectData = touchData.rect

	--__Log("_disposeTouch:curTouchIndex:%d, rect:(%d, %d, %d, %d) pos(%d, %d)",
	--	self._curTouchIndex, rectData.origin.x, rectData.origin.y, rectData.size.width, rectData.size.height,
	--	xpos, ypos)

	if rectData.origin.x <= xpos and 
		rectData.origin.x + rectData.size.width >= xpos and 
		rectData.origin.y <= ypos and 
		rectData.origin.y + rectData.size.height >= ypos then 
		self:_hitTouchData()
	else
		self:_resetTouch()
	end
end

function SuperDebugPanel:_resetTouch( ... )
	--__Log("_resetTouch")
	self._curTouchIndex = 1
	self._curTouchCount = 0
end

function SuperDebugPanel:_hitTouchData( ... )
	local touchData = self._destTouchData[self._curTouchIndex]
	if not touchData then 
		return __LogError("_disposeTouch:wrong touch data for Index:%d", self._curTouchIndex)
	end

	self._curTouchCount = self._curTouchCount + 1
	--__Log("_hitTouchData:index:%d, count:%d", self._curTouchIndex, self._curTouchCount)
	if self._curTouchCount >= touchData.count then 
		self:_onSwitchTouch()
	end
end

function SuperDebugPanel:_onSwitchTouch( ... )
	self._curTouchIndex = self._curTouchIndex + 1
	self._curTouchCount = 0

	--__Log("_onSwitchTouch: touchIndex:%d", self._curTouchIndex)
	if self._curTouchIndex > #self._destTouchData then 
		self:_onHitCallback()
	end
end

function SuperDebugPanel:_onHitCallback( ... )
	if self._callback then 
		self._callback()
	end
end

return SuperDebugPanel

