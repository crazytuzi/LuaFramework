
local QUIGestureRecognizer = class("QUIGestureRecognizer")

QUIGestureRecognizer.EVENT_SWIPE_GESTURE = "EVENT_SWIPE_GESTURE"
QUIGestureRecognizer.EVENT_SLIDE_GESTURE = "EVENT_SLIDE_GESTURE"

QUIGestureRecognizer.SWIPE_LEFT = 1
QUIGestureRecognizer.SWIPE_RIGHT = 2
QUIGestureRecognizer.SWIPE_UP = 3
QUIGestureRecognizer.SWIPE_DOWN = 4
QUIGestureRecognizer.SWIPE_LEFT_UP = 5
QUIGestureRecognizer.SWIPE_LEFT_DOWN = 6
QUIGestureRecognizer.SWIPE_RIGHT_UP = 7
QUIGestureRecognizer.SWIPE_RIGHT_DOWN = 8

QUIGestureRecognizer.SWIPE_DELTA = 50
QUIGestureRecognizer.IGNORE_INERTIA = 0.3

function QUIGestureRecognizer:ctor(options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options == nil then options = {} end
    -- 滑动距离调节系数
    self._rate = 0.3
    self._isSlide = false
    self._isColor = options.color
end

-- node: add touch layer to node's child
-- width and height: touch layer width and height
function QUIGestureRecognizer:attachToNode(node, width, height, offsetX, offsetY, callback)
	if node == nil then
		return
	end

	if width == nil or width < 0 then
		width = 0
	end
	if height == nil or height < 0 then
		height = 0
	end

	if offsetX == nil then
		offsetX = 0
	end

	if offsetY == nil then
		offsetY = 0
	end
	self._callback = callback
	if self._isColor == true then
		self._touchLayer = CCLayerColor:create(ccc4(255,0,0,120))
	else
		self._touchLayer = CCNode:create()
	end
	node:addChild(self._touchLayer)
	self._touchLayer:setPosition(offsetX, offsetY)

	local offsetP = nil
	if self._mainMenu then
	    offsetP = ccp(node:getPosition())
	    local parentNode = node:getParent()
	    if parentNode ~= nil then
	    	offsetP = parentNode:convertToWorldSpaceAR(offsetP)
		else
			offsetP = ccp(0,0)
	    end
	else    
		offsetP = node:convertToWorldSpaceAR(ccp(0,0))
	    -- local parentNode = node:getParent()
	    -- if parentNode ~= nil then
	    --     offsetP = parentNode:convertToWorldSpaceAR(offsetP)
	    -- else
	    --     offsetP = ccp(0,0)
	    -- end
	end

	self._touchRect = CCRect(offsetP.x + offsetX, offsetP.y + offsetY, width, height)

	-- touch event
	self._touchLayer:setCascadeBoundingBox(CCRect(0, 0, display.width, display.height))
    self._touchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._touchLayer:setTouchSwallowEnabled(false)
    self._touchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIGestureRecognizer._onTouch))

	if self._isColor == true then
		local testLayer = CCLayerColor:create(ccc4(0,255,0,120))
		testLayer:setContentSize(CCSize(width,height))
		printInfo("offsetP.x: %s  offsetP.y: %s  offsetX: %s  offsetY: %s",offsetP.x,offsetP.y,offsetX,offsetY)
		testLayer:setPosition(offsetP.x + offsetX, offsetP.y + offsetY)
		app._uiScene:addChild(testLayer)
	end
end

function QUIGestureRecognizer:resetTouchRect(node, width, height, offsetX, offsetY)
	local offsetP = node:convertToWorldSpaceAR(ccp(0,0))
	self._touchRect = CCRect(offsetP.x + offsetX, offsetP.y + offsetY, width, height)

end

-- 设置滑动系数
function QUIGestureRecognizer:setSlideRate(n)
	self._rate = n
end

function QUIGestureRecognizer:detach()
	if self._touchLayer == nil then
		return
	end
	self._touchLayer:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
	self._touchLayer:removeFromParent()
	self._touchLayer = nil
end

function QUIGestureRecognizer:enable()
	if self._touchLayer == nil then
		return
	end

    self._touchLayer:setTouchEnabled( true )
end

function QUIGestureRecognizer:disable()
	if self._touchLayer == nil then
		return
	end

	self._touchLayer:setTouchEnabled( false )
end

function QUIGestureRecognizer:setAttachSlide(b)
	self._isSlide = b
end

function QUIGestureRecognizer:_onTouch(event)
	if event.name == "began" and self._touchRect:containsPoint(ccp(event.x, event.y)) == true then
    	self._touchBegin = true
	end
    if self._touchBegin ~= true then
    	return
    end

	if self._callback then
		self._callback(event)
	end
    if event.name == "began" then
        return self:onTouchBegin(event.x, event.y)
    elseif event.name == "moved" then
        self:onTouchMove(event.x, event.y)
    elseif event.name == "ended" then
        self:onTouchEnd(event.x, event.y)
        self._touchBegin = false
    elseif event.name == "cancelled" then
    	self:onTouchEnd(event.x, event.y)
    	self._touchBegin = false
    end
end

function QUIGestureRecognizer:onTouchBegin(x, y)
	self._beginX = x
	self._beginY = y
	self._endX = self._beginX
	self._endY = self._beginY

	-- slide 滑动
	if self._isSlide then
		self._startValue = ccp(x,y)
		self._endValue = self._startValue
		self._touchXStartTime = q.time()
		self._touchYStartTime = self._touchXStartTime
	end
	return true
end

function QUIGestureRecognizer:onTouchMove(x, y)

	-- slide 滑动
	if self._isSlide then
		if self._endValue ~= nil then
			if ((self._endValue.x - self._startValue.x) > 0 and self._endValue.x > x ) or ((self._endValue.x - self._startValue.x) < 0 and self._endValue.x < x) then
				self._startValue.x = x
				self._touchXStartTime = q.time()
			end
			if ((self._endValue.y - self._startValue.y) > 0 and self._endValue.y > y ) or ((self._endValue.y - self._startValue.y) < 0 and self._endValue.y < y) then
				self._startValue.y = y
				self._touchYStartTime = q.time()
			end
		end
		self._endValue = ccp(x,y)
	end
end

function QUIGestureRecognizer:onTouchEnd(x, y)
	self._endX = x
	self._endY = y

	-- swipe
	local deltaX = self._endX - self._beginX
	local deltaY = self._endY - self._beginY
	local absDeltaX = math.abs(deltaX)
	local absDeltaY = math.abs(deltaY)
	if absDeltaX > QUIGestureRecognizer.SWIPE_DELTA or absDeltaY > QUIGestureRecognizer.SWIPE_DELTA then
		local direct
		if absDeltaX >= absDeltaY * 2.0 then
			if deltaX > 0 then
				direct = QUIGestureRecognizer.SWIPE_RIGHT
			else
				direct = QUIGestureRecognizer.SWIPE_LEFT
			end
		elseif absDeltaY >= absDeltaX * 2.0 then
			if deltaY > 0 then
				direct = QUIGestureRecognizer.SWIPE_UP
			else
				direct = QUIGestureRecognizer.SWIPE_DOWN
			end
		else
			if deltaX > 0 and deltaY > 0 then
				direct = QUIGestureRecognizer.SWIPE_RIGHT_UP
			elseif deltaX > 0 and deltaY < 0 then
				direct = QUIGestureRecognizer.SWIPE_RIGHT_DOWN
			elseif deltaX < 0 and deltaY > 0 then
				direct = QUIGestureRecognizer.SWIPE_LEFT_UP
			elseif deltaX < 0 and deltaY < 0 then
				direct = QUIGestureRecognizer.SWIPE_LEFT_DOWN
			end
		end
		self:dispatchEvent({name = QUIGestureRecognizer.EVENT_SWIPE_GESTURE, direction = direct})
	end

	-- slide 滑动
	if self._isSlide then
		local currentTime = q.time()
		local offsetXTime = 0
		if currentTime ~= self._touchXStartTime then
			if currentTime - self._touchXStartTime < QUIGestureRecognizer.IGNORE_INERTIA then
				offsetXTime = 0.5/(currentTime - self._touchXStartTime) * self._rate
			end
		end
		local offsetYTime = 0
		if currentTime ~= self._touchYStartTime then
			if currentTime - self._touchYStartTime < QUIGestureRecognizer.IGNORE_INERTIA then
				offsetYTime = 0.5/(currentTime - self._touchYStartTime) * self._rate
			end
		end
		local offsetDistance = ccp((self._endValue.x - self._startValue.x) * offsetXTime , (self._endValue.y - self._startValue.y) * offsetYTime )
		self:dispatchEvent({name = QUIGestureRecognizer.EVENT_SLIDE_GESTURE, distance = offsetDistance})
	end
end

 
return QUIGestureRecognizer