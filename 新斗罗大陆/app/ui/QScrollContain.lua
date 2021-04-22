--
-- Author: Your Name
-- Date: 2015-03-19 14:41:17
-- 滑动组件类
-- 仅支持纵向或者横向滑动 需要传入滑动方向 sheet容器节点 sheet_layout 滑动区域
-- 使用完毕请调用disappear
--
local QScrollContain = class("QScrollContain")

local QUIGestureRecognizer = import(".QUIGestureRecognizer")

QScrollContain.directionY = "directionY"
QScrollContain.directionX = "directionX"

function QScrollContain:ctor(options)
	self.sheet = options.sheet
	self.sheet_layout = options.sheet_layout
	self.direction = options.direction
	self.touchLayerOffsetY = options.touchLayerOffsetY
	self.directionDown = true --默认为true Y方向从上到下 false时则从下到上 X方向未实现
	self.isMove = false
	self.isMask = true
	if options.isMask ~= nil then
		self.isMask = options.isMask
	end
	if options.directionDown ~= nil then
		self.directionDown = options.directionDown
	end
	self:setMoveEndRate(options.endRate)
	if self.direction == nil then
		self.direction = QScrollContain.directionY
	end

	if self.sheet == nil or self.sheet_layout == nil then
		assert(false, "the options sheet or sheet_layout value is nil !")
	end
	self.renderFun = options.renderFun
	self.moveDistance = 10
	self.size = self.sheet_layout:getContentSize()
	self.totalSize = {width = 0, height = 0}

	self.content = CCNode:create()
	self.childList = {}

	if self.isMask == true then
		local layerColor = CCLayerColor:create(ccc4(0,0,0,150), self.size.width, self.size.height)
		local ccclippingNode = CCClippingNode:create()
		layerColor:setPositionX(self.sheet_layout:getPositionX())
		layerColor:setPositionY(self.sheet_layout:getPositionY())
		ccclippingNode:setStencil(layerColor)
		ccclippingNode:addChild(self.content)

		self.sheet:addChild(ccclippingNode)
	else
		self.sheet:addChild(self.content)
	end
	
	self.touchLayerOffsetY = self.touchLayerOffsetY or -self.size.height
	self.touchLayer = QUIGestureRecognizer.new()
	self.touchLayer.parentName = "QScrollContain"
	self.touchLayer:setSlideRate(options.slideRate or 0.3)
	self.touchLayer:setAttachSlide(true)
	self.touchLayer:attachToNode(self.sheet, self.size.width, self.size.height, 0, self.touchLayerOffsetY, handler(self, self.onEvent))
    self.touchLayer:enable()
    self.touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onEvent))
end

function QScrollContain:resetTouchRect()
	if self.touchLayer ~= nil then
		self.touchLayer:resetTouchRect(self.sheet, self.size.width, self.size.height, 0, self.touchLayerOffsetY)
	end
end

function QScrollContain:addChild(child)
	table.insert(self.childList, child)
	self.content:addChild(child)
end

function QScrollContain:removeAllChildren()
	self.content:removeAllChildren()
	self.totalSize = {width = 0, height = 0}
	self.childList = {}
end

function QScrollContain:getAllChildren()
	return self.childList
end

function QScrollContain:setContentSize(width, height)
	self.totalSize.width = width
	self.totalSize.height = height
end

--设置移动到边界的衰减值
function QScrollContain:setMoveEndRate(endRate)
	self.endRate = endRate or 1
end

function QScrollContain:getContentSize()
	return self.totalSize
end

function QScrollContain:getMoveState()
	return self.isMove
end

function QScrollContain:setAutoMove(b)
	self._isAutoMove = b
	if self._isAutoMove == true then
		self:autoStart()
	else
		self:autoEnd()
	end
end

function QScrollContain:setIsCheckAtMove(b)
	self._isCheckAtMove = b
end

function QScrollContain:onEvent(event)
	if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
		self:moveTo(event.distance.x, event.distance.y, true)
  	elseif event.name == "began" then
  		self:removeAction()
  		self.startPos = ccp(event.x, event.y)
  		self.pagePos = ccp(self.content:getPositionX(), self.content:getPositionY())
    elseif event.name == "moved" then
        if (self.direction == QScrollContain.directionY and math.abs(event.y - self.startPos.y) > self.moveDistance) or 
        	(self.direction == QScrollContain.directionX and math.abs(event.x - self.startPos.x) > self.moveDistance) then
            self.isMove = true
        end
		self:moveTo((self.pagePos.x + event.x - self.startPos.x), (self.pagePos.y + event.y - self.startPos.y), false)
	elseif event.name == "ended" then
    	scheduler.performWithDelayGlobal(function ()
    		self.isMove = false
    		end,0)
    end
end

function QScrollContain:moveTo(posX, posY, isAnimation, callBack)
	self:removeAction()
	if isAnimation == false then
		if self._isCheckAtMove == true then
			posX, posY = self:checkDistance(posX - self.content:getPositionX(), posY - self.content:getPositionY())
		elseif self.endRate ~= 1 then
			local _posX, _posY = self:checkDistance(posX - self.content:getPositionX(), posY - self.content:getPositionY())
			if posX ~= _posX then
				posX = _posX + (posX - _posX) * self.endRate
			end
			if posY ~= _posY then
				posY = _posY + (posY - _posY) * self.endRate
			end
		end

		if self.direction == QScrollContain.directionY then
			self.content:setPositionY(posY)
		elseif self.direction == QScrollContain.directionX then
			self.content:setPositionX(posX)
		end
		self:onFrame()
		if callBack then callBack() end
		return
	end
	posX, posY = self:checkDistance(posX, posY)
	if self.direction == QScrollContain.directionY then
		posX = 0
	elseif self.direction == QScrollContain.directionX then
		posY = 0
	end

	self:onEnterFrame()
	self:runAction(posX, posY, callBack)
end

function QScrollContain:checkDistance(posX, posY)
	local isResetX = false
	local isResetY = false
	local contentX = self.content:getPositionX()
	local contentY = self.content:getPositionY()
	-- count width
	if self.totalSize.width <= self.size.width then
		posX = 0
		isResetX = true
	elseif contentX + posX < self.size.width - self.totalSize.width then
		posX = self.size.width - self.totalSize.width
		isResetX = true
	elseif contentX + posX > 0 then
		posX = 0
		isResetX = true
	else
		posX = contentX + posX
	end
	--count height
	if self.totalSize.height <= self.size.height then
		posY = 0
		isResetY = true
	elseif self.directionDown == true then
		if contentY + posY > self.totalSize.height - self.size.height then
			posY = self.totalSize.height - self.size.height
			isResetY = true
		elseif contentY + posY < 0 then
			posY = 0
			isResetY = true
		else
			posY = contentY + posY
		end
	elseif self.directionDown == false then
		if contentY + posY < self.size.height - self.totalSize.height then
			posY = self.size.height - self.totalSize.height
			isResetY = true
		elseif contentY + posY > 0 then
			posY = 0
			isResetY = true
		else
			posY = contentY + posY
		end
	end
	return posX,posY,isResetX,isResetY
end

function QScrollContain:removeAction()
	if self.actionHandler ~= nil then
		self.content:stopAction(self.actionHandler)		
		self.actionHandler = nil
	end
end

function QScrollContain:runAction(posX,posY,callBack)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCMoveTo:create(0.3, ccp(posX,posY)))
    actionArrayIn:addObject(CCCallFunc:create(function () 
    											self:removeAction()
    											self:exitEnterFrame()
    											self:onFrame()
    											if callBack then callBack() end
                                            end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self.actionHandler = self.content:runAction(ccsequence)
end

function QScrollContain:onFrame()
	if self.renderFun ~= nil then
		self.renderFun() 
	end
end

function QScrollContain:onEnterFrame()
	if self.renderFun ~= nil then
		self:exitEnterFrame()
		self._onFrameHandler = scheduler.scheduleGlobal(handler(self, self.onFrame), 0)
	end
end

function QScrollContain:exitEnterFrame()
	if self._onFrameHandler ~= nil then
		scheduler.unscheduleGlobal(self._onFrameHandler)
		self._onFrameHandler = nil
	end
end

--自动滚动
function QScrollContain:autoStart(speed, isRound, roundOffset)
	if speed ~= nil then
		self._speed = speed
	end
	self._isRound = isRound or false
	self._roundOffset = roundOffset or 0
	self._autoHandler = scheduler.scheduleGlobal(handler(self, self.onMoveFrame), 0)
end

function QScrollContain:onMoveFrame()
	local posX = 0
	local posY = 0
	local isResetX
	local isResetY
	if self.direction == QScrollContain.directionY then
		posX, posY, isResetX, isResetY = self:checkDistance(0, self._speed)
		if isResetY == true then
			if self._isRound == false then
				self._speed  = self._speed  * -1
			else
				posY = self._roundOffset
			end
		end
	elseif self.direction == QScrollContain.directionX then
		posX, posY, isResetX, isResetY = self:checkDistance(self._speed, 0)
		if isResetX == true then
			if self._isRound == false then
				self._speed  = self._speed  * -1
			else
				posX = self._roundOffset
			end
		end
	end
	self.content:setPositionX(posX)
	self.content:setPositionY(posY)
end

--设置滑动方向
function QScrollContain:setDirection(direction)
	self.direction = direction
end

--终止自动滚动
function QScrollContain:autoEnd()
	if self._autoHandler ~= nil then
		scheduler.unscheduleGlobal(self._autoHandler)
		self._autoHandler = nil
	end
end

--复位
function QScrollContain:resetPos()
	self:exitEnterFrame()
	self:autoEnd()
	self.content:setPositionX(0)
	self.content:setPositionY(0)
end

function QScrollContain:disappear()
    self.touchLayer:removeAllEventListeners()
    self.touchLayer:disable()
    self.touchLayer:detach()
	self:exitEnterFrame()
	self:autoEnd()
end

------------------------------以下为兼容QScrollView----------------------------------
function QScrollContain:clear()
	self:removeAllChildren()
	self:resetPos()
end

function QScrollContain:setRect(top, bottom, left, right)
    self:setContentSize(right, -bottom)
end
------------------------------以上为兼容QScrollView----------------------------------

return QScrollContain