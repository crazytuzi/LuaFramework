local ShowOnCircleLayer = class("ShowOnCircleLayer", function() return cc.Layer:create() end)

function ShowOnCircleLayer:ctor(param)
	self.param = {}

	self:setParam(param)
	self:initData()
	self:updateData()
	self:createTouch()
	self:clearTouch()
	self:stopAutoMove(true)
end

function ShowOnCircleLayer:createTouch()
	local  listenner = cc.EventListenerTouchOneByOne:create()
    --listenner:setSwallowTouches(true)
	listenner:registerScriptHandler(function(touch, event)
		--log("EVENT_TOUCH_BEGAN")
		self.lastTouchPos = touch:getLocation()
        self.m_isInMove = false;
        return true
    	end,cc.Handler.EVENT_TOUCH_BEGAN )

	listenner:registerScriptHandler(function(touch, event)
        -- 禁止点击时候鼠标移动，防止出现该次不移动，下次移动超过120度
        local deltaPoint = touch:getDelta();
        if deltaPoint then
            if math.abs(deltaPoint.x) > 0 or math.abs(deltaPoint.y) > 0 then
                self.m_isInMove = true;
            end
        end

		--log("EVENT_TOUCH_MOVED")
		local touchPos = touch:getLocation()
		--log("x="..touchPos.x.." y="..touchPos.y)
		if self.lastTouchPos == nil then
			self.lastTouchPos = touchPos
		else
			local angleAdd = (touchPos.x - self.lastTouchPos.x) * self.param.moveRate
			self.angleFirst = self.angleFirst + angleAdd
			--log("self.angleFirst = "..self.angleFirst)
			self.touchMove = self.touchMove + math.abs(touchPos.x - self.lastTouchPos.x)
			self.lastTouchPos = touchPos
			self:updateData()
		end

		if self.param.moveFunc then
			self.param.moveFunc()
		end

	 	end,cc.Handler.EVENT_TOUCH_MOVED )	

	listenner:registerScriptHandler(function(touch, event)
		--log("EVENT_TOUCH_ENDED")
		--log("self.touchMove = "..self.touchMove)
		if self.touchMove < 5 and not self.m_isInMove then
			self:touchNode(self.lastTouchPos)
			--self:stopAutoMove(true)
			--self:startAutoMove()
		else
			self:clearTouch()
			self:startAutoMove()
		end
    	end,cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher =  self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end

function ShowOnCircleLayer:clearTouch()
	self.touchMove = 0
	self.lastTouchPos = nil
end

function ShowOnCircleLayer:setParam(param)
	if param == nil or type(param) ~= "table" or param == {} then
		return
	end

	if param.centrePos then
		self.param.centrePos = param.centrePos
	end

	if param.radius then
		self.param.radius = param.radius
	end

	if param.moveRate then
		self.param.moveRate = param.moveRate
	end

	if param.nodeNum then
		self.param.nodeNum = param.nodeNum
	end

	if param.nodes then
		self.param.nodes = param.nodes
	end

	if param.autoMove then
		self.param.autoMove = param.autoMove
	end 

	if param.yOff then
		self.param.yOff = param.yOff
	end 

	if param.defaultIndex then
		self.param.defaultIndex = param.defaultIndex
	end

	if param.boxWidth then
		self.param.boxWidth = param.boxWidth
	end 

	if param.boxHeight then
		self.param.boxHeight = param.boxHeight
	end 

	if param.moveFunc then
		self.param.moveFunc = param.moveFunc
	end 

	-- if param.maxOpacity then
	-- 	self.param.maxOpacity = param.maxOpacity
	-- end

	-- if param.minOpacity then
	-- 	self.param.minOpacity = param.minOpacity
	-- end

	-- if param.maxScale then
	-- 	self.param.maxScale = param.maxScale
	-- end

	-- if param.minScale then
	-- 	self.param.minScale = param.minScale
	-- end
end

function ShowOnCircleLayer:initData()
	local function isNoColor(color)
		if color and (color.r==255 and color.g==255 and color.b==255) then
			return true
		end

		return false
	end
	-- dump(self.param)
	self.angleFirst = 0
	self.angleAdd = 360 / self.param.nodeNum
	if self.param.defaultIndex then
		self.angleFirst = -(self.param.defaultIndex - 1) * self.angleAdd
	end
	self.nodeFirst = self.param.nodes[1]
	self.nodeData = {}
	for i,v in ipairs(self.param.nodes) do
		self.nodeData[i] = {}
		self.nodeData[i].scale = self.param.nodes[i].node:getScale()
		self.nodeData[i].isNoColor = isNoColor(self.param.nodes[i].node:getColor())
	end

	self:initUI()
end

function ShowOnCircleLayer:updateData()
	self.angleFirst = self.angleFirst % 360

	self:updateUI()
end

function ShowOnCircleLayer:initUI()
	self.baseNode = cc.Node:create()
	self:addChild(self.baseNode)
	self.baseNode:setPosition(self.param.centrePos)
	for i,v in ipairs(self.param.nodes) do
		self.baseNode:addChild(v.node)
		v.node:setPosition(cc.p(0, 0))
		--createLabel(v.node, i, cc.p(v.node:getContentSize().width/2, 150), cc.p(0.5, 0), 30)
	end
end

function ShowOnCircleLayer:updateUI()
	for i,v in ipairs(self.param.nodes) do
		local angle = self.angleFirst + (i-1)*self.angleAdd

		local angleTemp = angle % 360

		local x = self.param.radius * math.sin(math.rad(angle))
		if angleTemp > 0 then
			if angleTemp <= 90 or angleTemp >= 270 then
				self.param.nodes[i].node:setLocalZOrder(self.param.radius - math.abs(x))
			else
				self.param.nodes[i].node:setLocalZOrder(-(self.param.radius - math.abs(x)))
			end
		else
			if angleTemp >= -90 or angleTemp <= -270 then
				self.param.nodes[i].node:setLocalZOrder(self.param.radius - math.abs(x))
			else
				self.param.nodes[i].node:setLocalZOrder(-(self.param.radius - math.abs(x)))
			end
		end

		local y = 0
		if self.param.yOff then
			local zOrder = self.param.nodes[i].node:getLocalZOrder()
			if zOrder > 0 then
				y = (self.param.radius - zOrder) / self.param.radius * self.param.yOff
			else
				y = self.param.yOff
			end
		end
		self.param.nodes[i].node:setPosition(cc.p(x, y))

		-- if i == 6 then
		-- 	log("6 angleTemp == "..angleTemp)
		-- end
		-- log(i.." zorder = "..self.param.nodes[i].node:getLocalZOrder())
		self:updateEffect(i)
	end
	--log("self.angleFirst = "..self.angleFirst)
end

function ShowOnCircleLayer:setShowNodeByIndex(index)
	log("ShowOnCircleLayer:setShowNodeByIndex")
	self.angleFirst = -(index - 1) * self.angleAdd
	self:updateData()
	self:stopAutoMove(true)
end

function ShowOnCircleLayer:updateEffect(index)
	local node = self.param.nodes[index].node
	local scaleRate = (node:getLocalZOrder()/self.param.radius + 1)/2
	local minScale = 0.5
	node:setScale(self.nodeData[index].scale * (minScale + (1-minScale)*scaleRate))

	local opacityRate = (node:getLocalZOrder()/self.param.radius + 1)/2
	local minOpacity = 1
	node:setOpacity(255*minOpacity + 255*(1-minOpacity)*opacityRate)

	
	if self.nodeData[index].isNoColor == true then
		--dump(self.param.nodes[index].node:getColor())
		local blackRate = (node:getLocalZOrder()/self.param.radius + 1)/2
		local minBlack = 0.1
		local colorNum = 255*minBlack + 255*(1-minBlack)*blackRate
		node:setColor(cc.c3b(colorNum, colorNum, colorNum))
	end

    if scaleRate < 0.5 then
         local eff = node:getChildByTag(991)
         if eff then
             eff:setColor(cc.c3b(96, 96, 96))
         end

         local eff2 = node:getChildByTag(992)
         if eff2 then
             eff2:setColor(cc.c3b(96, 96, 96))
         end
    else
        local eff = node:getChildByTag(991)
        if eff then
            eff:setColor(cc.c3b(255, 255, 255))
        end
        
        local eff2 = node:getChildByTag(992)
        if eff2 then
            eff2:setColor(cc.c3b(255, 255, 255))
        end    
    end
end

function ShowOnCircleLayer:startAutoMove(isMovePre, isMoveNext)
	log("startAutoMove")
	self:stopAutoMove(true)
	AudioEnginer.playEffect("sounds/uiMusic/ui_change.mp3", false)

	local preAngle = self.angleFirst - self.angleFirst % self.angleAdd 
	local nextAngle = preAngle + self.angleAdd
	local targetAngle
	if math.abs(preAngle - self.angleFirst) < math.abs(nextAngle - self.angleFirst) then
		targetAngle = preAngle
	else
		targetAngle = nextAngle
	end

	if isMovePre then
		targetAngle = preAngle - self.angleAdd
	end

	if isMoveNext then
		targetAngle = nextAngle
	end

	if self.angleFirst == targetAngle then
		return
	end

	if self.angleFirst > targetAngle then
		--log("startAutoMove 1")
		self.autoMoveAction = startTimerAction(self, 0.02, true, function() 
			if self.param.moveFunc then
				self.param.moveFunc()
			end
			self.angleFirst = self.angleFirst - math.abs(self.param.autoMove)
			if self.angleFirst < targetAngle then
				self.angleFirst = targetAngle
				self:stopAutoMove(true)
			end
			self:updateUI()
			end)
	elseif self.angleFirst < targetAngle then
		--log("startAutoMove 2")
		self.autoMoveAction = startTimerAction(self, 0.02, true, function() 
			if self.param.moveFunc then
				self.param.moveFunc()
			end
			self.angleFirst = self.angleFirst + math.abs(self.param.autoMove)
			if self.angleFirst > targetAngle then
				self.angleFirst = targetAngle
				self:stopAutoMove(true)
			end
			self:updateUI()
			end)
	end
end

function ShowOnCircleLayer:startAutoMovePre()
	self:startAutoMove(true)
end

function ShowOnCircleLayer:startAutoMoveNext()
	self:startAutoMove(nil, true)
end

function ShowOnCircleLayer:stopAutoMove(isCheckShowFunc)
	log("stopAutoMove isCheckShowFunc = "..tostring(isCheckShowFunc))
	if self.autoMoveAction then
		self:stopAction(self.autoMoveAction)
		self.autoMoveAction = nil
	end

	if isCheckShowFunc then
		local showIndex
		for i,v in ipairs(self.param.nodes) do
			local rect = {}
			--dump(self.param)
			--dump(self.param.nodes)

			if self.param.boxWidth and self.param.boxHeight then
				local pos = cc.p(self.param.nodes[i].node:getPosition())
				rect.x = pos.x - self.param.boxWidth/2
				rect.y = pos.y - self.param.boxHeight/2
				rect.width = self.param.boxWidth
				rect.height = self.param.boxHeight
			else
				rect = self.param.nodes[i]:getBoundingBox()
			end
			--dump(rect)

			if cc.rectContainsPoint(rect, cc.p(0, 0)) then
				if showIndex == nil then
					showIndex = i
				else
					dump(self.param.nodes[i].node)
					if self.param.nodes[i].node:getLocalZOrder() > self.param.nodes[showIndex].node:getLocalZOrder() then
						showIndex = i
					end
				end
			end
		end

		if showIndex then
			log("showIndex = "..showIndex)
			if self.param.nodes[showIndex].showFunc then
				self.param.nodes[showIndex].showFunc()
			end
		end
	end
end

function ShowOnCircleLayer:touchNode(touch)
	--log("touchNode")
	if touch == nil then
		return
	end

	touch = self.baseNode:convertToNodeSpace(touch)
	local touchIndex
	for i,v in ipairs(self.param.nodes) do
		local rect = {}
		--dump(self.param)
		if self.param.boxWidth and self.param.boxHeight then
			local pos = cc.p(self.param.nodes[i].node:getPosition())
			rect.x = pos.x - self.param.boxWidth/2
			rect.y = pos.y - self.param.boxHeight/2
			rect.width = self.param.boxWidth
			rect.height = self.param.boxHeight
		else
			rect = self.param.nodes[i]:getBoundingBox()
		end
		--dump(rect)

		if cc.rectContainsPoint(rect, cc.p(touch.x, touch.y)) then
			if touchIndex == nil then
				touchIndex = i
			else
				if self.param.nodes[i].node:getLocalZOrder() > self.param.nodes[touchIndex].node:getLocalZOrder() then
					touchIndex = i
				end
			end
		end
	end

	if touchIndex then
		log("touchNode "..touchIndex)
		if self.param.nodes[touchIndex].touchFunc then
			self.param.nodes[touchIndex].touchFunc()
		end

        if touch.x < -60 then
            self:startAutoMoveNext()
        elseif touch.x > 60 then
            self:startAutoMovePre()
        end
	end
end

return ShowOnCircleLayer