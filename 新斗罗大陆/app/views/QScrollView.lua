--
-- Author: Qinyuanji
-- Date: 2015-03-19 14:41:17
-- This is a wrapper class for scrolling functionality, similar to CCScrollView
-- Parameters:
	-- options.size : ScrollView size
	-- options.bufferMode : load all children into buffer and show them on demand. 
	   -- 0: no buffer mode, all the children will be placed into scroll view. -- No interface is needed, worst performance
	   -- 1: all children are saved but only show those in screen. -- getContentSize must be implemented and anchor point must be top-left, first load is slow
	   -- 2: only a certain number of node is created beforehand. -- must call setCacheNumber, implement setInfo and the requirements of mode 2
	-- options.renderFun : render function run every frame
	-- options.moveDuration : speed of movement
	-- options.senstiveDistance : the distance to send QScrollView.GESTURE_MOVING event
	-- options.startGradient/endGradient : the color for gradient
	-- options.horizontalAlignment/verticalAlignment : alignment mode 
	-- options.layer\alphaThreshold : use CCB layer as the mask
	-- options.nodeAR: anchor point for child node, only useful in buffermode 1, 2
-- If content size is larger than scroll view size, scrolling is supported
-- Inertia effect is by default supported
-- setBounce to enable/disable bound effect
-- Note: If using it in widget, include it in OnEnter(). If using in ViewController, include it in ctor()

-- getContentSize should better be "truly" implemented for the node in scroll view, comment by nzhang
 
local QScrollView = class("QScrollView", function(parentNode)
     		return display.newNode()
  		end)

local QUIGestureRecognizer = import("..ui.QUIGestureRecognizer")

QScrollView.DEFAULT_START_GRADIENT = ccc4(0, 0, 0, 0)
QScrollView.DEFAULT_END_GRADIENT = ccc4(41, 23, 8, 255)
QScrollView.MOVE_DURATION = 1.3
QScrollView.SENSITIVE_DISTANCE = 0
QScrollView.ALPHA_THRESHOLD = 0.05

QScrollView.GESTURE_MOVING = "QSCROLLVIEW_GESTURE_MOVING"
QScrollView.GESTURE_END = "QSCROLLVIEW_GESTURE_END"
QScrollView.GESTURE_BEGAN = "QSCROLLVIEW_GESTURE_BEGAN"
QScrollView.MOVING = "QSCROLLVIEW_MOVING"
QScrollView.FREEZE = "QSCROLLVIEW_FREEZE"

QScrollView.LEFT_ALIGNMENT = 1
QScrollView.RIGHT_ALIGNMENT = 2
QScrollView.TOP_ALIGNMENT = 4
QScrollView.BOTTOM_ALIGNMENT = 8


local QScrollViewImp = {}

function QScrollView:ctor(parentNode, size, options)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	self.size = size
	options = options or {}
	self.bufferMode = options.bufferMode or 0
	self.renderFunc = options.renderFunc
	self.startGradient = options.startGradient or QScrollView.DEFAULT_START_GRADIENT
	self.endGradient = options.endGradient or QScrollView.DEFAULT_END_GRADIENT
	self.moveDuration = options.moveDuration or QScrollView.MOVE_DURATION
	self.sensitiveDistance = options.sensitiveDistance or QScrollView.SENSITIVE_DISTANCE
	self.horizontalAlignment = options.horizontalAlignment or QScrollView.LEFT_ALIGNMENT
	self.verticalAlignment = options.verticalAlignment or QScrollView.TOP_ALIGNMENT
	self.alphaThreshold = options.alphaThreshold or QScrollView.ALPHA_THRESHOLD
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

    --xurui:不再使用新的node作为QScrollView的根节点
	parentNode:addChild(self)
	QScrollViewImp.bindTouchArea(self)

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
	QScrollViewImp.showGradientBar(self)
end

function QScrollViewImp:bindTouchArea()
	self.touchLayer = QUIGestureRecognizer.new({color = self._color})
	self.touchLayer:setSlideRate(0.3)
	self.touchLayer:setAttachSlide(true)
	self.touchLayer:attachToNode(self, self.size.width, self.size.height, 0, -self.size.height, handler(self, QScrollViewImp.onEvent))
    self.touchLayer:enable()
    self.touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, QScrollViewImp.onEvent))
end

function QScrollViewImp:setSlideEnable(b)
	self.touchLayer:setAttachSlide(b)
end

function QScrollView:resetTouchRect()
	self.touchLayer:resetTouchRect(self, self.size.width, self.size.height, 0, -self.size.height)
end

function QScrollView:setSlideEnable( b)
	-- body
	QScrollViewImp.setSlideEnable(self)
end

function QScrollView:onEnter()
    self._onFrameHandler = scheduler.scheduleGlobal(handler(self, QScrollViewImp.onFrame), 0)
end

function QScrollView:onExit()
    if self._onFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onFrameHandler)
		self._onFrameHandler = nil
	end
end

function QScrollView:onCleanup()
	self.touchLayer:detach()
	self:removeAllEventListeners()
	self:clear()
end

function QScrollView:setRect(top, bottom, left, right)
	if not self.rect then self.rect = {} end

	self.rect.top = top or self.rect.top
	self.rect.bottom = bottom or self.rect.bottom
	self.rect.left = left or self.rect.left
	self.rect.right = right or self.rect.right

	QScrollViewImp.showGradientBar(self)
	QScrollViewImp.updateRange(self)
end

function QScrollView:addItemBox(...)
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

	QScrollViewImp.showGradientBar(self)
	QScrollViewImp.updateRange(self)
end

-- return item content size and buffer content
function QScrollView:setCacheNumber(number, cls)
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

function QScrollView:setVerticalBounce(enable)
	self.verticalBounce = enable
end

function QScrollView:setHorizontalBounce(enable)
	self.horizontalBounce = enable
end

function QScrollView:setBufferShowState(state, index)
	if self.bufferMode == 2 then return end

	if self.buffer[index] ~= nil then
		self.buffer[index].isShow = state
		self.buffer[index]:setVisible(state)
	end
end

function QScrollView:clearCache(resetPos)
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

	QScrollViewImp.removeAction(self)
	QScrollViewImp.showGradientBar(self)
end

function QScrollView:clear(resetPos)
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

	QScrollViewImp.removeAction(self)
	QScrollViewImp.showGradientBar(self)
end

function QScrollView:setGradient(enable)
	self.gradient = enable
	QScrollViewImp.showGradientBar(self)
end

-- Replace programtically-created graident with real ccb element
function QScrollView:replaceGradient(top, bottom, left, right)
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

function QScrollView:runToTop(action, time)
	QScrollViewImp.moveTo(self, self.content:getPositionX(), -self.rect.top, action, time)
end

function QScrollView:runToBottom(action, time)
	QScrollViewImp.moveTo(self, self.content:getPositionX(), -(self.rect.bottom + self.size.height), action, time)
end

function QScrollView:runToLeft(action, time)
	QScrollViewImp.moveTo(self, -self.rect.left, self.content:getPositionY(), action, time)
end

function QScrollView:runToRight(action, time)
	QScrollViewImp.moveTo(self, self.size.width - self.rect.right, self.content:getPositionY(), action, time)
end

function QScrollView:moveBy(posX, posY, action)
	QScrollViewImp.moveBy(self, posX, posY, action)
end

function QScrollView:moveTo(posX, posY, action, time)
	QScrollViewImp.moveTo(self, posX, posY, action, time)
end

function QScrollView:moveToItemByIndex(index, action, time)
	if self.bufferMode == 2 then
		if self.cacheData[index] then
			QScrollViewImp.moveTo(self, self.cacheData[index].x, self.cacheData[index].y, action, time)
		end
	end
end

function QScrollView:getPositionX()
	return self.content:getPositionX()
end

function QScrollView:getPositionY()
	return self.content:getPositionY()
end

function QScrollView:setPosition(position)
	return self.content:setPosition(position)
end

function QScrollView:getWidth()
	return self.rect.right - self.rect.left
end

function QScrollView:getHeight()
	return self.rect.top - self.rect.bottom
end

function QScrollView:setRenderFunc(renderFunc)
	self.renderFunc = renderFunc
end

function QScrollView:stopAllActions()
	return QScrollViewImp.removeAction(self)
end

function QScrollView:getCount()
	return self.count
end

function QScrollView:isScrollViewMoving(  )
	-- body
	return self.isMoving 
end

-- nzhang: force call item:setInfo(param).   This only works in buffer mode = 2.
function QScrollView:refreshInfo()
	QScrollViewImp.refreshInfo(self)
end

function QScrollView:setTouchState(state)
	if state == nil then state = true end
	self.isNoTouch = not state
end

function QScrollViewImp:onEvent(event)
	if self.isNoTouch then return end
	if event == nil or event.name == nil then
        return
    end

    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		QScrollViewImp.moveBy(self, event.distance.x, event.distance.y, true)
  	elseif event.name == "began" then
  		QScrollViewImp.removeAction(self)
  		self.startPos = ccp(event.x, event.y)
  		self.prevPos = ccp(event.x, event.y)
  		self.pagePos = ccp(self.content:getPositionX(), self.content:getPositionY())
		self:dispatchEvent({name = QScrollView.GESTURE_BEGAN})
    elseif event.name == "moved" then 
    	if  self.startPos == nil then
    		self.startPos = ccp(event.x, event.y)
    	end
    	if  self.prevPos == nil then
    		self.prevPos = ccp(event.x, event.y)
    	end
    	if math.abs(event.x - self.startPos.x) >= self.sensitiveDistance or math.abs(event.y - self.startPos.y) >= self.sensitiveDistance then
			self:dispatchEvent({name = QScrollView.GESTURE_MOVING})
    	end
		QScrollViewImp.moveBy(self, event.x - self.prevPos.x, event.y - self.prevPos.y, false)
		self.prevPos.x = event.x
		self.prevPos.y = event.y
	elseif event.name == "ended" then
		self:dispatchEvent({name = QScrollView.GESTURE_END})
    end
end

function QScrollViewImp:moveBy(posX, posY, inertia)
	QScrollViewImp.showGradientBar(self)

	local newPosX, newPosY, oriPosX, oriPosY, posX, posY = QScrollViewImp.checkDistance(self, posX, posY)
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
		QScrollViewImp.onFrame(self)
		self.isMoving = false
	else
		self:dispatchEvent({name = QScrollView.MOVING})
		QScrollViewImp.runAction(self, newPosX, newPosY)
	end
end

function QScrollViewImp:moveTo(posX, posY, inertia, time)
	QScrollViewImp.showGradientBar(self)

	local offsetX = posX - self.content:getPositionX()
	local offsetY = posY - self.content:getPositionY()
	local newPosX, newPosY, oriPosX, oriPosY = QScrollViewImp.checkDistance(self, offsetX, offsetY)
	if inertia and newPosX == oriPosX and newPosY == oriPosY then
		return
	end

	self.isMoving = true
	if not inertia then
		self.content:setPosition(ccp(newPosX, newPosY))
		QScrollViewImp.onFrame(self)
		self.isMoving = false
	else
		self:dispatchEvent({name = QScrollView.MOVING})
		QScrollViewImp.runAction(self, newPosX, newPosY, time)
	end
end

function QScrollViewImp:checkDistance(posX, posY)
	local tposX = posX/4
	local tposY = posY/4
	local contentX = self.content:getPositionX()
	local contentY = self.content:getPositionY()

	-- count width
	if self:getWidth() <= self.size.width then
		if self.horizontalAlignment == QScrollView.LEFT_ALIGNMENT then
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
		if self.verticalAlignment == QScrollView.TOP_ALIGNMENT then
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

function QScrollViewImp:showGradientBar()
	local contentX = self.content:getPositionX()
	local contentY = self.content:getPositionY()

	-- Set horizontal gradient visibility
	if contentX + self.rect.right > self.size.width then
		QScrollViewImp.setGradientVisible(self, self.rightGradient, true)
	else
		QScrollViewImp.setGradientVisible(self, self.rightGradient, false)
	end
	if contentX >= -self.rect.left then
		QScrollViewImp.setGradientVisible(self, self.leftGradient, false)
	else
		QScrollViewImp.setGradientVisible(self, self.leftGradient, true)
	end

	-- Set vertical gradient visibility
	if contentY + self.size.height >= -self.rect.bottom then
		QScrollViewImp.setGradientVisible(self, self.bottomGradient, false)
	else
		QScrollViewImp.setGradientVisible(self, self.bottomGradient, true)
	end
	if contentY <= -self.rect.top then
		QScrollViewImp.setGradientVisible(self, self.topGradient, false)
	else
		QScrollViewImp.setGradientVisible(self, self.topGradient, true)
	end
end

function QScrollViewImp:setGradientVisible(gradient, visible)
	if self.gradient then
		gradient:setVisible(visible)
	else
		gradient:setVisible(false)
	end
end

function QScrollViewImp:removeAction()
	if self.actionHandler ~= nil then
		self.content:stopAction(self.actionHandler)		
		self.actionHandler = nil
	end
end

function QScrollViewImp:runAction(posX,posY,time)
	time = time or self.moveDuration
    local actionArrayIn = CCArray:create()
    local curveMove = CCMoveTo:create(time, ccp(posX,posY))
	local speed = CCEaseExponentialOut:create(curveMove)
	actionArrayIn:addObject(speed)
    actionArrayIn:addObject(CCCallFunc:create(function () 
										    	QScrollViewImp.showGradientBar(self)
    											QScrollViewImp.removeAction(self)
    											QScrollViewImp.onFrame(self)
    											self.isMoving = false
												self:dispatchEvent({name = QScrollView.FREEZE})
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self.content:runAction(ccsequence)
end

function QScrollViewImp:onFrame()
	-- if self.isMoving then
		QScrollViewImp.updateRange(self)

		if self.renderFunc ~= nil then
			self.renderFunc() 
		end	
	-- end

end

function QScrollViewImp:refreshInfo()
	if self.bufferMode == 2 and self.cacheData then
		for i = 1, #self.cacheData do
			if self.cacheData[i].item then
				self.cacheData[i].item:setInfo(self.cacheData[i].param)
			end
		end
	end
end

function QScrollViewImp:updateRange()
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

return QScrollView