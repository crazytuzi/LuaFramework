cc.SectorView = {}

ccui.SectorViewEventType = {
  onTurning = 0, --正在转向中状态
  onUplift = 1, --转向结束抬起状态
  onClick = 2, --点击状态
}

local INERTIA_ACC = 2 --惯性加速度
local TOUCH_OFFSET = 3 --触摸偏移量
local VIRTUAL_RADIUS = 240 --虚拟半径
local INTERVAL_ANGLE = 15 --间隔角度
local INTERVAL_OPACITY = 10 --间隔透明度
local NORMAL_VIEW_ANGLE = 90 --正常视图角度
local ITEM_MIN_SCALE = 0.5 --Item的最小缩放值
local ITEM_MAX_SCALE = 1 --Item的最大缩放值(默认为1)
local ITEM_SCALE_OFFSET = 0.15 --Item的缩放偏移值
local ITEM_MAX_COUNT = 360 / INTERVAL_ANGLE --最大Item的个数
local MOVEING_SPEED = 1.4 --移动中的速度
local UPLIFT_BUFFER_ACTION_TIME = 0.2 --抬起时的缓冲动作时间(单位：秒)
local INERTIA_SCROLL_SPEED = 2 --惯性滚动速度
local LOCATE_SCROLL_SPEED = 2 --定位滚动速度
local ORIENTATION_LEFT = 0 --左方向
local ORIENTATION_RIGHT = 1 --右方向

local touchPanel = nil --触摸面板

local _viewSize = nil
local _viewPoint = nil
local _beganPoint = nil
local _moveDistance = nil
local _schedulerId = nil
local _curItemIndex = 1
local _itemCount = 0
local _initAngle = 0
local _angle = 0
local _initLeftZOrder = 0
local _initRightZOrder = 0
local _initLeftOpacity = 0
local _initRightOpacity = 0
local _inertiaMoveMaxAngle = 0
local _locateOrientation = nil
local _eventListener = nil

local _onTouch, _onClick, _isMoveing, _isLockMove

local function quickSort(_table, compareFunc)
	local function partion(_table, left, right, compareFunc)
		local key = _table[left]
		local index = left
		_table[index], _table[right] = _table[right], _table[index]
		local i = left
		while i < right do
			if compareFunc(key, _table[i]) then
				_table[index], _table[i] = _table[i], _table[index]
				index = index + 1
			end
			i = i + 1
		end
		_table[right], _table[index] = _table[index], _table[right]
		return index
	end
	local function quick(_table, left, right, compareFunc)
		if left < right then
			local index = partion(_table, left, right, compareFunc)
			quick(_table, left, index - 1, compareFunc)
			quick(_table, index + 1, right, compareFunc)
		end
	end
	quick(_table, 1, #_table, compareFunc)
end

local function compareFunc(obj1, obj2)
	if obj1:getTag() > obj2:getTag() then
		return true
	else
		return false
	end
end

local function stopScheduler()
	if _schedulerId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
		_schedulerId = nil
	end
end

local function getInertiaMoveMaxAngle()
	if _moveDistance == nil then
		return 0
	end
	local reta = math.abs(_moveDistance.x * INERTIA_ACC) / cc.Director:getInstance():getVisibleSize().width
	local tempAngle = _angle
	if _moveDistance.x > 0 then
		tempAngle = _angle - _angle * reta
	else
		tempAngle = _angle + _angle * reta
	end
	return tempAngle
end

local function getItemViewData(angle, isMoveing)
	local itemPoint, itemAngle, itemScale = cc.p(0, 0), 0, 0
	local angleA = angle
	if angleA > NORMAL_VIEW_ANGLE then
		angleA = 180 - angleA
		itemAngle = (NORMAL_VIEW_ANGLE - angleA) * -1
	else
		itemAngle = NORMAL_VIEW_ANGLE - angleA
	end
	if isMoveing then
		itemScale = 1 - (math.abs(itemAngle) / NORMAL_VIEW_ANGLE)
	else
		itemScale = 1 - (math.abs(itemAngle) / NORMAL_VIEW_ANGLE + ITEM_SCALE_OFFSET)
	end
	if itemScale < ITEM_MIN_SCALE then
		itemScale = ITEM_MIN_SCALE
	end
	if itemScale > ITEM_MAX_SCALE then
		itemScale = ITEM_MAX_SCALE
	end
	local lengthX = math.cos(math.rad(angleA)) * (_viewPoint.y + VIRTUAL_RADIUS)
	local lengthY = math.sin(math.rad(angleA)) * (_viewPoint.y + VIRTUAL_RADIUS)
	if angle > NORMAL_VIEW_ANGLE then
		itemPoint = cc.p(_viewPoint.x - lengthX, lengthY - VIRTUAL_RADIUS)
	else
		itemPoint = cc.p(_viewPoint.x + lengthX, lengthY - VIRTUAL_RADIUS)
	end
	return itemPoint, itemAngle, itemScale
end

local function setItemOpacity(item, opacity)
	local childs = item:getChildren()
	for i, obj in pairs(childs) do
		if obj:getChildren() then
			setItemOpacity(obj, opacity)
		end
		obj:setOpacity(opacity)
	end
end

local function onUpliftLogic()
	_moveDistance = nil
	local childs = touchPanel:getChildren()
	quickSort(childs, compareFunc)
	
	local function listenerCallfunc()
		if _eventListener then
			_eventListener(childs[_curItemIndex], ccui.SectorViewEventType.onUplift)
		end
	end
	
	local curAngle = (NORMAL_VIEW_ANGLE + (_curItemIndex - 1) * INTERVAL_ANGLE)
	_angle = curAngle
	local leftOpacity, rightOpacity = 255 - _curItemIndex * INTERVAL_OPACITY, 255
	for i, obj in pairs(childs) do
		local itemPoint, itemAngle, itemScale = getItemViewData(curAngle)
			if i == _curItemIndex then
				itemScale = ITEM_MAX_SCALE
				setItemOpacity(obj, 255)
			elseif i < _curItemIndex then
				setItemOpacity(obj, leftOpacity)
				leftOpacity = leftOpacity + INTERVAL_OPACITY
			else
				rightOpacity = rightOpacity - INTERVAL_OPACITY
				setItemOpacity(obj, rightOpacity)
			end
			local action1 = cc.RotateTo:create(UPLIFT_BUFFER_ACTION_TIME, itemAngle)
			local action2 = cc.MoveTo:create(UPLIFT_BUFFER_ACTION_TIME, itemPoint)
			local action3 = cc.ScaleTo:create(UPLIFT_BUFFER_ACTION_TIME, itemScale)
			if i ~= #childs then
				obj:runAction(cc.Spawn:create(action1, action2, action3))
			else
				obj:runAction(cc.Sequence:create(cc.Spawn:create(action1, action2, action3), cc.CallFunc:create(listenerCallfunc)))
			end
			curAngle = curAngle - INTERVAL_ANGLE
	end
	
	_isMoveing = false
	_isLockMove = false
end

local function inertiaScrollLogic(dt)
	if _moveDistance == nil then
		stopScheduler()
		return
	end
	local childs = touchPanel:getChildren()
	if _moveDistance.x > 0 then
		_angle = _angle - INERTIA_SCROLL_SPEED
	else
		_angle = _angle + INERTIA_SCROLL_SPEED
	end
	local tempAngle, maxScale = _angle, 0
	quickSort(childs, compareFunc)
	for key, obj in pairs(childs) do
		local itemPoint, itemAngle, itemScale = getItemViewData(tempAngle)
		obj:setPosition(itemPoint)
		obj:setRotation(itemAngle)
		obj:setScale(itemScale)
		if itemScale > maxScale then
			maxScale = itemScale
			_curItemIndex = key
		end
		tempAngle = tempAngle - INTERVAL_ANGLE
	end
	local leftZ, rightZ = 1, _curItemIndex
	for key, obj in pairs(childs) do
		if key < _curItemIndex then
			obj:setLocalZOrder(leftZ)
			leftZ = leftZ + 1
		elseif key == _curItemIndex then
			obj:setLocalZOrder(100)
			obj:setScale(ITEM_MAX_SCALE)
			if _eventListener then
				_eventListener(obj, ccui.SectorViewEventType.onTurning)
			end
		else
			obj:setLocalZOrder(rightZ)
			rightZ = rightZ - 1
		end
	end
	if ((_curItemIndex == 1 or _curItemIndex == #childs) and math.abs(childs[_curItemIndex]:getRotation()) >= 0) then
		stopScheduler()
		onUpliftLogic()
	elseif _moveDistance.x > 0 then
		if _angle <= _inertiaMoveMaxAngle then
			stopScheduler()
			onUpliftLogic()
		end
	else
		if _angle >= _inertiaMoveMaxAngle then
			stopScheduler()
			onUpliftLogic()
		end
	end
end

local function scrollToLogic(dt)
	local isScrollEnd = false
	if _locateOrientation == ORIENTATION_LEFT then
		_angle = _angle + LOCATE_SCROLL_SPEED
		if _angle >= (NORMAL_VIEW_ANGLE + (_curItemIndex - 1) * INTERVAL_ANGLE) then
			stopScheduler()
			_angle = (NORMAL_VIEW_ANGLE + (_curItemIndex - 1) * INTERVAL_ANGLE)
			isScrollEnd = true
		end
	elseif _locateOrientation == ORIENTATION_RIGHT then
		_angle = _angle - LOCATE_SCROLL_SPEED
		if _angle <= (NORMAL_VIEW_ANGLE + (_curItemIndex - 1) * INTERVAL_ANGLE) then
			stopScheduler()
			_angle = (NORMAL_VIEW_ANGLE + (_curItemIndex - 1) * INTERVAL_ANGLE)
			isScrollEnd = true
		end
	end
	
	local tempCurItemIndex = nil
	local tempAngle, maxScale = _angle, 0
	local childs = touchPanel:getChildren()
	quickSort(childs, compareFunc)
	for key, obj in pairs(childs) do
		local curPoint, rotationAngle, scale = getItemViewData(tempAngle)
		obj:setPosition(curPoint)
		obj:setRotation(rotationAngle)
		obj:setScale(scale)
		if scale > maxScale then
			maxScale = scale
			tempCurItemIndex = key
		end
		tempAngle = tempAngle - INTERVAL_ANGLE
	end
	local leftOpacity, rightOpacity = 255 - tempCurItemIndex * INTERVAL_OPACITY, 255
	local leftZ, rightZ = 1, tempCurItemIndex
	for i, obj in pairs(childs) do
		if i < tempCurItemIndex then
			obj:setLocalZOrder(leftZ)
			leftZ = leftZ + 1
			setItemOpacity(obj, leftOpacity)
			leftOpacity = leftOpacity + INTERVAL_OPACITY
		elseif i == tempCurItemIndex then
			obj:setLocalZOrder(100)
			obj:setScale(ITEM_MAX_SCALE)
			if _eventListener then
				_eventListener(obj, ccui.SectorViewEventType.onTurning)
			end
			setItemOpacity(obj, 255)
		else
			obj:setLocalZOrder(rightZ)
			rightZ = rightZ - 1
			rightOpacity = rightOpacity - INTERVAL_OPACITY
			setItemOpacity(obj, rightOpacity)
		end
	end
	
	if isScrollEnd then
		if _eventListener then
			_eventListener(childs[_curItemIndex], ccui.SectorViewEventType.onUplift)
		end
	end
end

local function onTouchBegan(touch, event)
	local touchPoint = touchPanel:convertTouchToNodeSpace(touch)
	if touchPoint.x > 0 and touchPoint.x < touchPanel:getContentSize().width and
	   touchPoint.y > 0 and touchPoint.y < touchPanel:getContentSize().height then
		_beganPoint = touchPoint
		_onTouch = true
		if touchPoint.x > _viewPoint.x - _viewSize.width / 2 and touchPoint.x < _viewPoint.x + _viewSize.width / 2 and
		   touchPoint.y > _viewPoint.y - _viewSize.height / 2 and touchPoint.y < _viewPoint.y + _viewSize.height / 2 then
			_onClick = true
		else
			_onClick = false
		end
	else
		_onTouch = false
	end
	return true
end

local function onTouchMoved(touch, event)
	if _onTouch then
		local touchPoint = touchPanel:convertTouchToNodeSpace(touch)
		if touchPoint.x > 0 and touchPoint.x < touchPanel:getContentSize().width and
		   touchPoint.y > 0 and touchPoint.y < touchPanel:getContentSize().height then
			_moveDistance = cc.pSub(touchPoint, _beganPoint)
			if math.abs(_moveDistance.x) > TOUCH_OFFSET and not _isMoveing and not _isLockMove then
		   	stopScheduler()
		   	_isMoveing = true
		   	_onClick = false
		   	if _moveDistance.x > 0 then
		   		_angle = _angle - MOVEING_SPEED
		   	else
		   		_angle = _angle + MOVEING_SPEED
		   	end
		   	local childs = touchPanel:getChildren()
		   	quickSort(childs, compareFunc)
		   	local tempAngle, maxScale = _angle, 0
		   	for key, obj in pairs(childs) do
		   		obj:stopAllActions()
		   		local itemPoint, itemAngle, itemScale = getItemViewData(tempAngle)
		   		obj:setPosition(itemPoint)
					obj:setRotation(itemAngle)
					obj:setScale(itemScale)
					if itemScale > maxScale then
						maxScale = itemScale
						_curItemIndex = key
					end
					tempAngle = tempAngle - INTERVAL_ANGLE
		   	end
		   	if ((_curItemIndex == 1 or _curItemIndex == #childs) and math.abs(childs[_curItemIndex]:getRotation()) >= INTERVAL_ANGLE) then
					_isLockMove = true
				end
				tempAngle = _angle
				local leftOpacity, rightOpacity = 255 - _curItemIndex * INTERVAL_OPACITY, 255
				local leftZ, rightZ = 1, _curItemIndex
				for key, obj in pairs(childs) do
					if key < _curItemIndex then
						obj:setLocalZOrder(leftZ)
						leftZ = leftZ + 1
						setItemOpacity(obj, leftOpacity)
						leftOpacity = leftOpacity + INTERVAL_OPACITY
					elseif key == _curItemIndex then
						obj:setLocalZOrder(100)
						local itemPoint, itemAngle, itemScale = getItemViewData(tempAngle, 0)
						obj:setScale(itemScale)
						if _eventListener then
							_eventListener(obj, ccui.SectorViewEventType.onTurning)
						end
						setItemOpacity(obj, 255)
					else
						obj:setLocalZOrder(rightZ)
						rightZ = rightZ - 1
						rightOpacity = rightOpacity - INTERVAL_OPACITY
						setItemOpacity(obj, rightOpacity)
					end
					tempAngle = tempAngle - INTERVAL_ANGLE
				end
				_isMoveing = false
			end
			_beganPoint = touchPoint
		else
			_onTouch = false
			_onClick = false
			onUpliftLogic()
			_isMoveing = false
		end
	end
end

local function onTouchEnded(touch, event)
	if _onTouch then
		if _onClick then
			local childs = touchPanel:getChildren()
			for key, obj in pairs(childs) do
				if obj:getPositionX() == _viewPoint.x and obj:getPositionY() == _viewPoint.y then
					if _eventListener then
						_eventListener(obj, ccui.SectorViewEventType.onClick)
					end
					break
				end
			end
		else
			if _moveDistance then
				_inertiaMoveMaxAngle = getInertiaMoveMaxAngle()
				_schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(inertiaScrollLogic, 0, false)
			end
		end
	end
end

local function init(_startIndex)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = touchPanel:getEventDispatcher()
	eventDispatcher:removeEventListenersForTarget(touchPanel)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchPanel)
	
	_viewSize = nil
	_viewPoint = nil
	_beganPoint = nil
	_moveDistance = nil
    stopScheduler()
	_schedulerId = nil
	if _startIndex then
		_curItemIndex = _startIndex
	else
		_curItemIndex = 1
	end
	_itemCount = 0
	_initAngle = NORMAL_VIEW_ANGLE + (_curItemIndex - 1) * INTERVAL_ANGLE
	_angle = _initAngle
	
	_initLeftZOrder = 1
	_initRightZOrder = _curItemIndex
	_initLeftOpacity = 255 - _curItemIndex * 10
	_initRightOpacity = 255
	_inertiaMoveMaxAngle = 0
	_locateOrientation = ORIENTATION_LEFT
	_eventListener = nil
	
	_onTouch = false
	_onClick = false
	_isMoveing = false
	_isLockMove = false
end

function cc.SectorView:scrollToIndex(index)
	if index > _itemCount or index == _curItemIndex then
		return
	end
	if index < _curItemIndex then
		_locateOrientation = ORIENTATION_RIGHT
	elseif index > _curItemIndex then
		_locateOrientation = ORIENTATION_LEFT
	end
	_curItemIndex = index
	stopScheduler()
	_schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(scrollToLogic, 0, false)
end

function cc.SectorView:create(_touchPanel, _startIndex)
	if _touchPanel then
		touchPanel = _touchPanel
		init(_startIndex)
		return cc.SectorView
	end
end

function cc.SectorView:addChild(item)
	if item then
		if ITEM_MAX_SCALE ~= item:getScale() then
			ITEM_MAX_SCALE = item:getScale()
		end
		if ITEM_MAX_SCALE < item:getScale() then
			ITEM_MAX_SCALE = item:getScale()
		end
		if _viewSize == nil then
			_viewSize = item:getContentSize()
		end
		if _viewPoint == nil then
			_viewPoint = cc.p(item:getPositionX(), item:getPositionY())
		end
		_itemCount = _itemCount + 1
		local itemPoint, itemAngle, itemScale = getItemViewData(_initAngle)
		_initAngle = _initAngle - INTERVAL_ANGLE
		if _itemCount == _curItemIndex then
			itemScale = ITEM_MAX_SCALE
			setItemOpacity(item, 255)
			touchPanel:addChild(item, ITEM_MAX_COUNT, _itemCount)
		elseif _itemCount < _curItemIndex then
			setItemOpacity(item, _initLeftOpacity)
			_initLeftOpacity = _initLeftOpacity + INTERVAL_OPACITY
			touchPanel:addChild(item, _initLeftZOrder, _itemCount)
			_initLeftZOrder = _initLeftZOrder + 1
		else
			_initRightOpacity = _initRightOpacity - INTERVAL_OPACITY
			setItemOpacity(item, _initRightOpacity)
			touchPanel:addChild(item, _initRightZOrder, _itemCount)
			_initRightZOrder = _initRightZOrder - 1
		end
		item:setPosition(itemPoint)
		item:setRotation(itemAngle)
		item:setScale(itemScale)
	end
end

function cc.SectorView:getCurItemIndex()
	return _curItemIndex
end

function cc.SectorView:getItem(_index)
	local childs = touchPanel:getChildren()
	quickSort(childs, compareFunc)
	for key, obj in pairs(childs) do
		if _index == key then
			return obj
		end
	end
end

function cc.SectorView:addEventListener(eventListener)
	_eventListener = eventListener
end

function cc.SectorView:setTouchEnabled(enabled)
	if enabled then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = touchPanel:getEventDispatcher()
		if eventDispatcher then
			eventDispatcher:removeEventListenersForTarget(touchPanel)
			eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchPanel)
		end
	else
		if touchPanel then
			local eventDispatcher = touchPanel:getEventDispatcher()
			if eventDispatcher then
				eventDispatcher:removeEventListenersForTarget(touchPanel)
			end
		end
	end
end