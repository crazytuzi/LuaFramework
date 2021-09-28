-- Filename: STTableView.lua
-- Author: bzx
-- Date: 2015-04-26
-- Purpose:

STTableView = class("STTableView", function (eventHandler, viewSize)
	return STNode:create()
end)

ccs.combine(STScrollView, STTableView)

function STTableView:ctor( ... )
	STScrollView.ctor(self)
	self._cells = {}
	self._eventHandler = nil
	self._pageViewEnabled = false
	self._touchLayer = nil
	self._dragBeganX = nil
	self._touchBeganX = nil
	self._cellSize = nil
end

function STTableView:create(eventHandler, viewSize)
	viewSize = viewSize or g_winSize
	local ret = STTableView:new()
	local eventHandler = function ( functionName, tableView, index, cell )
		return ret:eventHandler(functionName, ret, index, cell)
	end
	local handler = LuaEventHandler:create(eventHandler)
	local subnode = LuaTableView:createWithHandler(handler, viewSize)
	ret:setSubnode(subnode)
	ret:setContentSize(viewSize)
	ret:setVerticalFillOrder(kCCTableViewFillTopDown)
	ret:reloadData()
	return ret
end

function STTableView:eventHandler(functionName, tableView, index, cell)
	-- fuctionName = "cellSize", "cellAtIndex", "numberOfCells", "cellTouched", "scroll", "moveEnd"
	if self._eventHandler == nil then
		return 0
	end
	if functionName == "cellAtIndex" then
		if index ~= nil then
			index = index + 1
		end
		if cell ~= nil then
			cell = self._cells[cell:getIdx() + 1]
		end
	elseif functionName == "cellTouched" then
		cell = self._cells[index:getIdx() + 1]
		index = index:getIdx() + 1
	end
	local ret = self._eventHandler(functionName, self, index, cell)
	if functionName == "cellAtIndex" then
		local newCell = CCTableViewCell:create()
		newCell:addChild(ret)
		ret:setContentSize(self._cellSize)
		ret:setParent(newCell)
		self._cells[index] = ret
		ret = newCell
	end
	if functionName == "cellSize" then
		self._cellSize = ret
	end
	return ret
end

function STTableView:setEventHandler( eventHandler )
	self._eventHandler = eventHandler
end

function STTableView:cellAtIndex( index )
	return self._cells[index]
end

function STTableView:setPageViewEnabled( enabled )
	self._pageViewEnabled = enabled
	self._subnode:setTouchEnabled(false)
	self._touchLayer = STLayer:create()
	local tableView = self
	self._touchLayer.onTouchEvent = function (self, event, x, y )
		return tableView:onTouchEvent(event, x, y)
	end
	self._touchLayer:setTouchPriority(self:getTouchPriority())
	self._touchLayer:setTouchEnabled(true)
	self:addChild(self._touchLayer)
end

function STTableView:setTouchEnabled( enabled )
	STLayer.setTouchEnabled(self, enabled)
	if self._touchLayer then
		self._touchLayer:setTouchEnabled(enabled)
	end
end

function STTableView:setTouchPriority( touchPriority )
	self._touchPriority = touchPriority
	if self._pageViewEnabled then
		self._touchLayer:setTouchPriority(touchPriority)
	else
		self._subnode:setTouchPriority(touchPriority)
	end
end

function STTableView:onTouchEvent(event, x, y)
	if not self:isVisible() then
		return
	end
	local position = self:convertToNodeSpace(ccp(x, y))
    if event == "began" then
        if self:containsWorldPoint(ccp(x, y)) then
            self._subnode:setBounceable(self:isBounceable())
            self._dragBeganX = self:getContentOffset().x
            self._touchBeganX = position.x
        	return true
        else
        	return false
        end
        return true
    elseif event == "moved" then
        local offset = self:getContentOffset()
        offset.x = self._dragBeganX + position.x - self._touchBeganX
        self:setContentOffset(offset)
        self._eventHandler("scroll", self)
    elseif event == "ended" or event == "cancelled" then
    	self._eventHandler(event, self, nil, nil)
	    local dragEndedX = self:getContentOffset().x
	    local dragDistance = dragEndedX - self._dragBeganX
	    if math.abs(position.x - self._touchBeganX) < 10 then
	    	self._eventHandler("cellTouched", self)
	    end
	    local offset = self:getContentOffset()
	    if dragDistance >= 100 then
	        offset.x = self._dragBeganX + self._cellSize.width
	    elseif dragDistance <= -100 then
	        offset.x = self._dragBeganX - self._cellSize.width
	    else
	        offset.x = self._dragBeganX
	    end
	    self._subnode:setBounceable(false)
	    local offsetMaxX = 0
	    if offset.x > offsetMaxX then
	        offset.x = offsetMaxX
	    end
	    local container = self:getContainer()
	    local offsetMinX = -container:getContentSize().width + self:getViewSize().width
	    if offset.x < offsetMinX then
	        offset.x = offsetMinX
	    end
	    self._touchLayer:setTouchEnabled(false)
	    local array = CCArray:create()
	    array:addObject(CCMoveTo:create(0.2, offset))
	    local sendScrollEvent = function ( ... )
	    	self._eventHandler("scroll", self)
	    end
	    local action = schedule(container, sendScrollEvent, 1/60)
	    local endCallFunc = function()
	        self._touchLayer:setTouchEnabled(true)
	        local curPageIndex = math.floor((-offset.x) / self._cellSize.width) + 1
	        container:stopAction(action)
	        self._eventHandler("moveEnd", self, curPageIndex, nil)
	    end
	    array:addObject(CCDelayTime:create(0.1))
	    array:addObject(CCCallFunc:create(endCallFunc))
	    container:runAction(CCSequence:create(array))
    end
end

function STTableView:showCellByIndexInDuration(p_index, p_time, p_endCallback )
	local container = self:getContainer()
	local targetOffset = ccp(-self._cellSize.width * (p_index - 1), 0)
	local curOffset = self:getContentOffset()
	local movePosition = nil
	local nextCellPosition = curOffset
	if curOffset.x == targetOffset.x then
		return
	end
	if curOffset.x < targetOffset.x then
		nextCellPosition.x = -curOffset.x + self._cellSize.width * 2
		movePosition = ccp(-self._cellSize.width, 0)
	elseif curOffset.x > targetOffset.x then
		nextCellPosition.x = -curOffset.x - self._cellSize.width
		movePosition = ccp(self._cellSize.width, 0)
	end
	self:updateCellAtIndex(p_index)
	local nextCell = self:cellAtIndex(p_index)
	local cellOldPosition = nextCell:getPosition()
	nextCell:setPosition(nextCellPosition)
	local array = CCArray:create()
	array:addObject(CCMoveBy:create(p_time, movePosition))
	local endCallFunc = function ( ... )
		container:setPosition(targetOffset)
		nextCell:setPosition(cellOldPosition)
		if p_endCallback ~= nil then
			p_endCallback()
		end
	end
	array:addObject(CCCallFunc:create(endCallFunc))
	container:runAction(CCSequence:create(array))
end

function STTableView:showCellByIndex( p_index )
	local targetOffset = ccp(-self._cellSize.width * (p_index - 1), 0)
	self:setContentOffset(targetOffset)
end

function STTableView:setContentOffsetInTime( p_contentOffset, p_time, p_endCallback )
	local container = self:getContainer()
	local array = CCArray:create()
	array:addObject(CCMoveTo:create(p_time, p_contentOffset))
	local endCallFunc = function ( ... )
		self:setContentOffset(p_contentOffset)
		if p_endCallback ~= nil then
			p_endCallback()
		end
	end
	array:addObject(CCCallFunc:create(endCallFunc))
	container:runAction(CCSequence:create(array))
end

function STTableView:setVerticalFillOrder( verticalFillOrder )
	self._subnode:setVerticalFillOrder(verticalFillOrder)
end

function STTableView:reloadData( ... )
	self._subnode:reloadData()
end

function STTableView:updateCellAtIndex(index)
	self._subnode:updateCellAtIndex(index - 1)
end

function STTableView:refresh( ... )
	local contentOffset = self:getContentOffset()
	self:reloadData()
	self:setContentOffset(contentOffset)
end