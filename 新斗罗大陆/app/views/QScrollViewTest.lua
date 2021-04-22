-- @Author: xurui
-- @Date:   2018-09-21 18:46:35
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-21 18:55:21
local QScrollViewTest = class("QScrollViewTest", function(parentNode)
     		return display.newNode()
  		end)

local QUIGestureRecognizer = import("..ui.QUIGestureRecognizer")

QScrollViewTest.DEFAULT_START_GRADIENT = ccc4(0, 0, 0, 0)
QScrollViewTest.DEFAULT_END_GRADIENT = ccc4(41, 23, 8, 255)
QScrollViewTest.MOVE_DURATION = 1.3
QScrollViewTest.SENSITIVE_DISTANCE = 0
QScrollViewTest.ALPHA_THRESHOLD = 0.05

QScrollViewTest.GESTURE_MOVING = "QScrollViewTest_GESTURE_MOVING"
QScrollViewTest.GESTURE_END = "QScrollViewTest_GESTURE_END"
QScrollViewTest.GESTURE_BEGAN = "QScrollViewTest_GESTURE_BEGAN"
QScrollViewTest.MOVING = "QScrollViewTest_MOVING"
QScrollViewTest.FREEZE = "QScrollViewTest_FREEZE"

QScrollViewTest.LEFT_ALIGNMENT = 1
QScrollViewTest.RIGHT_ALIGNMENT = 2
QScrollViewTest.TOP_ALIGNMENT = 4
QScrollViewTest.BOTTOM_ALIGNMENT = 8

local QScrollViewTestImp = {}

function QScrollViewTest:ctor(parentNode, size, options)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self.size = size
	options = options or {}
	self.bufferMode = options.bufferMode or 0
	self.renderFunc = options.renderFunc
	self.startGradient = options.startGradient or QScrollViewTest.DEFAULT_START_GRADIENT
	self.endGradient = options.endGradient or QScrollViewTest.DEFAULT_END_GRADIENT
	self.moveDuration = options.moveDuration or QScrollViewTest.MOVE_DURATION
	self.sensitiveDistance = options.sensitiveDistance or QScrollViewTest.SENSITIVE_DISTANCE
	self.horizontalAlignment = options.horizontalAlignment or QScrollViewTest.LEFT_ALIGNMENT
	self.verticalAlignment = options.verticalAlignment or QScrollViewTest.TOP_ALIGNMENT
	self.alphaThreshold = options.alphaThreshold or QScrollViewTest.ALPHA_THRESHOLD
	self.nodeAR = options.nodeAR or ccp(0, 1)
	self.isNoTouch = options.isNoTouch -- 强制不让滑动 add by Kumo
	self._color = options.color
	self.isMoving = false
	self.count = 0
	self.cacheNumber = 0
	self.buffer = {}

	self.sheet_layout = CCLayer:create()
	self.sheet_layout:setContentSize(self.size.width, self.size.height)
	self.sheet_layout:setPositionY(-self.size.height)
	self:addChild(self.sheet_layout)
	print("~~~~~~~~~ QScrollViewTest:ctor ~~~~~~~~~`")
	self.content = CCNode:create()
	local ccclippingNode = CCClippingNode:create()
	local layer = options.layer
	if not layer then
		layer = CCLayerColor:create(ccc4(0, 0, 0, 150), self.size.width, self.size.height)
		layer:setPositionX(self.sheet_layout:getPositionX())
		layer:setPositionY(self.sheet_layout:getPositionY())
	else
		ccclippingNode:setAlphaThreshold(self.alphaThreshold)
	end
	ccclippingNode:setStencil(layer)
	ccclippingNode:addChild(self.content)
	self:addChild(ccclippingNode)

    self:setNodeEventEnabled(true)

	parentNode:addChild(self)
	QScrollViewTestImp.bindTouchArea(self)

	-- add layer gradient at four sides
	self.topGradient = CCLayerGradient:create(self.startGradient, self.endGradient, ccp(0, 1))
	self.topGradient:setPosition(ccp(0, -25))
	self.topGradient:setContentSize(CCSize(self.size.width, 25))
	self:addChild(self.topGradient)

	self.bottomGradient = CCLayerGradient:create(self.startGradient, self.endGradient, ccp(0, -1))
	self.bottomGradient:setPosition(ccp(0, -self.size.height))
	self.bottomGradient:setContentSize(CCSize(self.size.width, 25))
	self:addChild(self.bottomGradient)

	self.leftGradient = CCLayerGradient:create(self.startGradient, self.endGradient, ccp(-1, 0))
	self.leftGradient:setPosition(ccp(0, -self.size.height))
	self.leftGradient:setContentSize(CCSize(25, self.size.height))
	self:addChild(self.leftGradient)

	self.rightGradient = CCLayerGradient:create(self.startGradient, self.endGradient, ccp(1, 0))
	self.rightGradient:setPosition(ccp(self.size.width - 25, -self.size.height))
	self.rightGradient:setContentSize(CCSize(25, self.size.height))
	self:addChild(self.rightGradient)

	self:setRect(0, 0, 0, 0)
	QScrollViewTestImp.showGradientBar(self)
end

function QScrollViewTestImp:bindTouchArea()
	self.touchLayer = QUIGestureRecognizer.new({color = self._color})
	self.touchLayer:setSlideRate(0.3)
	self.touchLayer:setAttachSlide(true)
	self.touchLayer:attachToNode(self, self.size.width, self.size.height, 0, -self.size.height, handler(self, QScrollViewTestImp.onEvent))
    self.touchLayer:enable()
    self.touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, QScrollViewTestImp.onEvent))
end

function QScrollViewTestImp:setSlideEnable(b)
	self.touchLayer:setAttachSlide(b)
end


function QScrollViewTest:setSlideEnable( b)
	-- body
	QScrollViewTestImp.setSlideEnable(self)
end

function QScrollViewTest:onEnter()
    self._onFrameHandler = scheduler.scheduleGlobal(handler(self, QScrollViewTestImp.onFrame), 0)
end

function QScrollViewTest:onExit()
    if self._onFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onFrameHandler)
		self._onFrameHandler = nil
	end
end

function QScrollViewTest:onCleanup()
	self.touchLayer:detach()
	self:removeAllEventListeners()
	self:clear()
end

function QScrollViewTest:setRect(top, bottom, left, right)
	if not self.rect then self.rect = {} end

	self.rect.top = top or self.rect.top
	self.rect.bottom = bottom or self.rect.bottom
	self.rect.left = left or self.rect.left
	self.rect.right = right or self.rect.right

	QScrollViewTestImp.showGradientBar(self)
	QScrollViewTestImp.updateRange(self)
end

function QScrollViewTest:addChildBox(...)
	if self.bufferMode == 2 then
		local s = {...}
		assert(#s == 3, "The arguments in bufferMode: posX, posY, param")
		assert(self.cacheData, "You have to call setCacheNumber first")
		table.insert(self.cacheData, {x = s[1], y = s[2], param = s[3]})
	elseif self.bufferMode == 1 then
		local s = {...}
		assert(s[1], "You have to specify the child to be added")
		s[1]:retain()
		table.insert(self.buffer, s[1])
	else
		local s = {...}
		assert(s[1], "You have to specify the child to be added")
		self.content:addChild(s[1])
	end

	self.count = self.count + 1

	QScrollViewTestImp.showGradientBar(self)
	QScrollViewTestImp.updateRange(self)
end

-- return item content size and buffer content
function QScrollViewTest:setCacheNumber(number, cls)
	assert(self.bufferMode == 2, "You have to set bufferMode to 2 to use cache function")
	assert(self.cacheNumber == 0, "You cannot call setCacheNumber twice or call clear first")
	assert(number > 0, "You have to set number larger than zero")

	self.cacheNumber = number
	self.cacheData = {}
	for i = 1, self.cacheNumber do
        local class = import(app.packageRoot .. ".ui." .. cls)
        local item = class.new()
        assert(not item.used, "Class object should remove used member")
        item.used = false
        item:setVisible(false)
        self.content:addChild(item)

        table.insert(self.buffer, item)
        self.itemContentSize = item:getContentSize()
	end

	return self.itemContentSize, self.buffer
end

function QScrollViewTest:setVerticalBounce(enable)
	self.verticalBounce = enable
end

function QScrollViewTest:setHorizontalBounce(enable)
	self.horizontalBounce = enable
end

function QScrollViewTest:setBufferShowState(state, index)
	if self.bufferMode == 2 then return end

	if self.buffer[index] ~= nil then
		self.buffer[index].isShow = state
		self.buffer[index]:setVisible(state)
	end
end

function QScrollViewTest:clearCache(resetPos)
	for i = 1, #self.buffer do
        self.buffer[i].used = false
        self.buffer[i]:setVisible(false)
	end
	self.cacheData = {}
	self.count = 0

	self.rect.top = 0
	self.rect.bottom = 0
	self.rect.left = 0
	self.rect.right = 0

	if resetPos ~= false then
		self.content:setPosition(ccp(0, 0))
	end

	QScrollViewTestImp.removeAction(self)
	QScrollViewTestImp.showGradientBar(self)
end

function QScrollViewTest:clear(resetPos)
	if self.bufferMode == 2 then
		self.cacheNumber = 0
		self.cacheData = nil
		self.buffer = {}
	elseif self.bufferMode == 1 then
		for k, v in ipairs(self.buffer) do
			QCleanNode(v)
			v:release()
		end
		self.buffer = {}
	end

	self.content:removeAllChildren()
	self.count = 0

	self.rect.top = 0
	self.rect.bottom = 0
	self.rect.left = 0
	self.rect.right = 0

	if resetPos ~= false then
		self.content:setPosition(ccp(0, 0))
	end

	QScrollViewTestImp.removeAction(self)
	QScrollViewTestImp.showGradientBar(self)
end

function QScrollViewTest:setGradient(enable)
	self.gradient = enable
	QScrollViewTestImp.showGradientBar(self)
end

-- Replace programtically-created graident with real ccb element
function QScrollViewTest:replaceGradient(top, bottom, left, right)
	local oldTop = self.topGradient
	local oldBottom = self.bottomGradient
	local oldLeft = self.leftGradient
	local oldRight = self.rightGradient

	self.topGradient = top or oldTop
	self.bottomGradient = bottom or oldBottom
	self.leftGradient = left or oldLeft
	self.rightGradient = right or oldRight

	return oldTop, oldBottom, oldLeft, oldRight
end

function QScrollViewTest:runToTop(action, time)
	QScrollViewTestImp.moveTo(self, self.content:getPositionX(), -self.rect.top, action, time)
end

function QScrollViewTest:runToBottom(action, time)
	QScrollViewTestImp.moveTo(self, self.content:getPositionX(), -(self.rect.bottom + self.size.height), action, time)
end

function QScrollViewTest:runToLeft(action, time)
	QScrollViewTestImp.moveTo(self, -self.rect.left, self.content:getPositionY(), action, time)
end

function QScrollViewTest:runToRight(action, time)
	QScrollViewTestImp.moveTo(self, self.size.width - self.rect.right, self.content:getPositionY(), action, time)
end

function QScrollViewTest:moveBy(posX, posY, action)
	QScrollViewTestImp.moveBy(self, posX, posY, action)
end

function QScrollViewTest:moveTo(posX, posY, action, time)
	QScrollViewTestImp.moveTo(self, posX, posY, action, time)
end

function QScrollViewTest:moveToItemByIndex(index, action, time)
	if self.bufferMode == 2 then
		if self.cacheData[index] then
			QScrollViewTestImp.moveTo(self, self.cacheData[index].x, self.cacheData[index].y, action, time)
		end
	end
end

function QScrollViewTest:getPositionX()
	return self.content:getPositionX()
end

function QScrollViewTest:getPositionY()
	return self.content:getPositionY()
end

function QScrollViewTest:setPosition(position)
	return self.content:setPosition(position)
end

function QScrollViewTest:getWidth()
	return self.rect.right - self.rect.left
end

function QScrollViewTest:getHeight()
	return self.rect.top - self.rect.bottom
end

function QScrollViewTest:setRenderFunc(renderFunc)
	self.renderFunc = renderFunc
end

function QScrollViewTest:stopAllActions()
	return QScrollViewTestImp.removeAction(self)
end

function QScrollViewTest:getCount()
	return self.count
end

function QScrollViewTest:isScrollViewMoving(  )
	-- body
	return self.isMoving 
end

-- nzhang: force call item:setInfo(param).   This only works in buffer mode = 2.
function QScrollViewTest:refreshInfo()
	QScrollViewTestImp.refreshInfo(self)
end

function QScrollViewTest:setTouchState(state)
	if state == nil then state = true end
	self.isNoTouch = not state
end

function QScrollViewTestImp:onEvent(event)
	if self.isNoTouch then return end
	if event == nil or event.name == nil then
        return
    end

    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		QScrollViewTestImp.moveBy(self, event.distance.x, event.distance.y, true)
  	elseif event.name == "began" then
  		QScrollViewTestImp.removeAction(self)
  		self.startPos = ccp(event.x, event.y)
  		self.prevPos = ccp(event.x, event.y)
  		self.pagePos = ccp(self.content:getPositionX(), self.content:getPositionY())
		self:dispatchEvent({name = QScrollViewTest.GESTURE_BEGAN})
    elseif event.name == "moved" then 
    	if  self.startPos == nil then
    		self.startPos = ccp(event.x, event.y)
    	end
    	if  self.prevPos == nil then
    		self.prevPos = ccp(event.x, event.y)
    	end
    	if math.abs(event.x - self.startPos.x) >= self.sensitiveDistance or math.abs(event.y - self.startPos.y) >= self.sensitiveDistance then
			self:dispatchEvent({name = QScrollViewTest.GESTURE_MOVING})
    	end
		QScrollViewTestImp.moveBy(self, event.x - self.prevPos.x, event.y - self.prevPos.y, false)
		self.prevPos.x = event.x
		self.prevPos.y = event.y
	elseif event.name == "ended" then
		self:dispatchEvent({name = QScrollViewTest.GESTURE_END})
    end
end

function QScrollViewTestImp:moveBy(posX, posY, inertia)
	QScrollViewTestImp.showGradientBar(self)

	local newPosX, newPosY, oriPosX, oriPosY, posX, posY = QScrollViewTestImp.checkDistance(self, posX, posY)
	if inertia and newPosX == oriPosX and newPosY == oriPosY then
		return
	end

	self.isMoving = true
	if not inertia then
		if self.verticalBounce then
			newPosY = oriPosY + posY
		end
		if self.horizontalBounce then
			newPosX = oriPosX + posX
		end
		self.content:setPosition(ccp(newPosX, newPosY))
		QScrollViewTestImp.onFrame(self)
		self.isMoving = false
	else
		self:dispatchEvent({name = QScrollViewTest.MOVING})
		QScrollViewTestImp.runAction(self, newPosX, newPosY)
	end
end

function QScrollViewTestImp:moveTo(posX, posY, inertia, time)
	QScrollViewTestImp.showGradientBar(self)

	local offsetX = posX - self.content:getPositionX()
	local offsetY = posY - self.content:getPositionY()
	local newPosX, newPosY, oriPosX, oriPosY = QScrollViewTestImp.checkDistance(self, offsetX, offsetY)
	if inertia and newPosX == oriPosX and newPosY == oriPosY then
		return
	end

	self.isMoving = true
	if not inertia then
		self.content:setPosition(ccp(newPosX, newPosY))
		QScrollViewTestImp.onFrame(self)
		self.isMoving = false
	else
		self:dispatchEvent({name = QScrollViewTest.MOVING})
		QScrollViewTestImp.runAction(self, newPosX, newPosY, time)
	end
end

function QScrollViewTestImp:checkDistance(posX, posY)
	local tposX = posX/4
	local tposY = posY/4
	local contentX = self.content:getPositionX()
	local contentY = self.content:getPositionY()

	-- count width
	if self:getWidth() <= self.size.width then
		if self.horizontalAlignment == QScrollViewTest.LEFT_ALIGNMENT then
			posX = -self.rect.left
		else
			posX = self.size.width - self.rect.right
		end
	elseif -(contentX + posX) >= self.rect.right - self.size.width then
		posX = self.size.width - self.rect.right
	elseif contentX + posX >= -self.rect.left then
		posX = -self.rect.left
	else
		tposX = posX
		posX = contentX + posX
	end

	--count height
	if self:getHeight() <= self.size.height then
		if self.verticalAlignment == QScrollViewTest.TOP_ALIGNMENT then
			posY = -self.rect.top
		else
			posY = -self.rect.bottom - self.size.height
		end
	elseif contentY + posY >= -self.rect.bottom - self.size.height then
		posY = -self.rect.bottom - self.size.height
	elseif contentY + posY <= -self.rect.top then
		posY = -self.rect.top
	else
		tposY = posY
		posY = contentY + posY
	end

	return posX, posY, contentX, contentY, tposX, tposY
end

function QScrollViewTestImp:showGradientBar()
	local contentX = self.content:getPositionX()
	local contentY = self.content:getPositionY()

	-- Set horizontal gradient visibility
	if contentX + self.rect.right > self.size.width then
		QScrollViewTestImp.setGradientVisible(self, self.rightGradient, true)
	else
		QScrollViewTestImp.setGradientVisible(self, self.rightGradient, false)
	end
	if contentX >= -self.rect.left then
		QScrollViewTestImp.setGradientVisible(self, self.leftGradient, false)
	else
		QScrollViewTestImp.setGradientVisible(self, self.leftGradient, true)
	end

	-- Set vertical gradient visibility
	if contentY + self.size.height >= -self.rect.bottom then
		QScrollViewTestImp.setGradientVisible(self, self.bottomGradient, false)
	else
		QScrollViewTestImp.setGradientVisible(self, self.bottomGradient, true)
	end
	if contentY <= -self.rect.top then
		QScrollViewTestImp.setGradientVisible(self, self.topGradient, false)
	else
		QScrollViewTestImp.setGradientVisible(self, self.topGradient, true)
	end
end

function QScrollViewTestImp:setGradientVisible(gradient, visible)
	if self.gradient then
		gradient:setVisible(visible)
	else
		gradient:setVisible(false)
	end
end

function QScrollViewTestImp:removeAction()
	if self.actionHandler ~= nil then
		self.content:stopAction(self.actionHandler)		
		self.actionHandler = nil
	end
end

function QScrollViewTestImp:runAction(posX,posY,time)
	time = time or self.moveDuration
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(time, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
										    	QScrollViewTestImp.showGradientBar(self)
    											QScrollViewTestImp.removeAction(self)
    											QScrollViewTestImp.onFrame(self)
    											self.isMoving = false
												self:dispatchEvent({name = QScrollViewTest.FREEZE})
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self.content:runAction(ccsequence)
end

function QScrollViewTestImp:onFrame()
	-- if self.isMoving then
		QScrollViewTestImp.updateRange(self)

		if self.renderFunc ~= nil then
			self.renderFunc() 
		end	
	-- end

end

function QScrollViewTestImp:refreshInfo()
	if self.bufferMode == 2 and self.cacheData then
		for i = 1, #self.cacheData do
			if self.cacheData[i].item then
				self.cacheData[i].item:setInfo(self.cacheData[i].param)
			end
		end
	end
end

function QScrollViewTestImp:updateRange()
	if self.bufferMode == 0 then return end

	if self.bufferMode == 2 and self.cacheData then
		local itemContentSize = self.itemContentSize
		for i = 1, #self.cacheData do
			local left = self.cacheData[i].x - itemContentSize.width * self.nodeAR.x
			local right = self.cacheData[i].x + itemContentSize.width
			local top = self.cacheData[i].y + itemContentSize.height * (1 - self.nodeAR.y)
			local bottom = self.cacheData[i].y - itemContentSize.height

			local contentX = self.content:getPositionX()
			local contentY = self.content:getPositionY()

			if right < -contentX or left > (-contentX + self.size.width) or top < (-contentY - self.size.height) or bottom > -contentY then
				if self.cacheData[i].item and self.cacheData[i].item.used then
					self.cacheData[i].item:setVisible(false)
					self.cacheData[i].item.used = false
					self.cacheData[i].item = nil
				end
			else
				if not self.cacheData[i].item then
					local item = nil
					for j = 1, self.cacheNumber do if self.buffer[j].used == false then item = self.buffer[j] break end end

					if item then
						item:setInfo(self.cacheData[i].param)
						item:setPosition(ccp(self.cacheData[i].x, self.cacheData[i].y))
						item:setVisible(true)
						item.used = true
						self.cacheData[i].item = item
					end
				end
			end
		end
	else
		for i = 1, #self.buffer do
			if self.buffer[i].isShow == nil or self.buffer[i].isShow == true then
				local left = self.buffer[i]:getPositionX() - self.buffer[i]:getContentSize().width * self.nodeAR.x
				local right = self.buffer[i]:getPositionX() + self.buffer[i]:getContentSize().width
				local top = self.buffer[i]:getPositionY() + self.buffer[i]:getContentSize().height * (1 - self.nodeAR.y)
				local bottom = self.buffer[i]:getPositionY() - self.buffer[i]:getContentSize().height

				local contentX = self.content:getPositionX()
				local contentY = self.content:getPositionY()

				if right < -contentX or left > (-contentX + self.size.width) or top < (-contentY - self.size.height) or bottom > -contentY then
					if self.buffer[i].used then
						self.buffer[i]:setVisible(false)
						self.buffer[i].used = false
						self.buffer[i]:removeFromParentAndCleanup(false)
					end
				else
					if not self.buffer[i].used then
						self.buffer[i]:setVisible(true)
						self.buffer[i].used = true
						self.content:addChild(self.buffer[i])
					end
				end
			end
		end
	end
end

return QScrollViewTest
