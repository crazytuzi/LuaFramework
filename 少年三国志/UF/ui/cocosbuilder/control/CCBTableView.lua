--CCBTableView.lua


local CCBTableView = class("CCBTableView", function ( )
	return display.newNode()
end)

function CCBTableView:ctor( )
	self._cellSize = CCSizeMake(320, 30)

	self._cellAtIndexHandler = nil
	self._numberOfCellHandler = nil
	self._cellTouchedHandler = nil
	self._cellTouchBeginHandler = nil
	self._cellTouchEndHandler = nil
	self._cellHighlightHandler = nil
	self._cellUnHighlightHandler = nil
	self._cellRecycleHandler = nil
end

function CCBTableView:createCCBTableView( rect )
	local h = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			-- Return cell size
			-- a1 is cell index (-1 means default size, in cocos2d-x version below 2.1.3, it's always -1)
			r = self:_getCellSize() --CCSizeMake(320,30)
		elseif fn == "cellAtIndex" then
			-- Return CCCCBTableViewCell, a1 is cell index (zero based), a2 is dequeued cell (maybe nil)
			-- Do something to create cell and change the content
			r = self:_getCellAtIndex(a1, a2)
		elseif fn == "numberOfCells" then
			-- Return number of cells
			r = self:_getNumberOfCells(a1, a2)
		-- Cell events:
		elseif fn == "cellTouched" then			
			-- A cell was touched, a1 is cell that be touched. This is not necessary.
			r = self:_onCellTouched(a1, a2)
		elseif fn == "cellTouchBegan" then		
			-- A cell is touching, a1 is cell, a2 is CCTouch
			r = self:_onCellTouchBegin(a1, a2)
		elseif fn == "cellTouchEnded" then		
			-- A cell was touched, a1 is cell, a2 is CCTouch
			r = self:_onCellTouchEnd(a1, a2)
		elseif fn == "cellHighlignt" then		
			-- A cell is highlighting, coco2d-x 2.1.3 or above
			r = self:_onCellHighlight(a1, a2)
		elseif fn == "cellUnhighlignt" then		
			-- A cell had been unhighlighted, coco2d-x 2.1.3 or above
			r = self:_onCellUnHighlight(a1, a2)
		elseif fn == "cellWillRecycle" then		
			-- A cell will be recycled, coco2d-x 2.1.3 or above
			r = self:_onCellWillRecycle(a1, a2)
		end
		return r
	end)

	local t = LuaCCBTableView:createWithHandler(h, rect)
	if t ~= nil then 
		t:setBounceable(true)
		self:addChild(t)
	end

	return t
end


--functions that inline that user shoud not use
function CCBTableView:_getCellSize( )
	return self._cellSize
end

function CCBTableView:_getCellAtIndex( a1, a2)
	if self._cellAtIndexHandler == nil then
		return nil
	end

	return self._cellAtIndexHandler(a1, a2)
end

function CCBTableView:_getNumberOfCells( a1, a2)
	if self._numberOfCellHandler == nil then
		return nil
	end

	return self._numberOfCellHandler(a1, a2)
end

function CCBTableView:_onCellTouched( a1, a2 )
	if self._cellTouchedHandler == nil then
		return nil
	end

	return self._cellTouchedHandler(a1, a2)
end

function CCBTableView:_onCellTouchBegin( a1, a2 )
	if self._cellTouchBeginHandler == nil then
		return nil
	end

	return self._cellTouchBeginHandler(a1, a2)
end

function CCBTableView:_onCellTouchEnd( a1, a2 )
	if self._cellTouchEndHandler == nil then
		return nil
	end

	return self._cellTouchEndHandler(a1, a2)
end

function CCBTableView:_onCellHighlight( a1, a2 )
	if self._cellHighlightHandler == nil then
		return nil
	end

	return self._cellHighlightHandler(a1, a2)
end

function CCBTableView:_onCellUnHighlight( a1, a2 )
	if self._cellUnHighlightHandler == nil then
		return nil
	end

	return self._cellUnHighlightHandler(a1, a2)
end

function CCBTableView:_onCellWillRecycle( a1, a2 )
	if self._cellRecycleHandler == nil then
		return nil
	end

	return self._cellRecycleHandler(a1, a2)
end


-- functions that user shoud call to set event handler
function CCBTableView:setCellSize ( size )
	self._cellSize = size
end

function CCBTableView:setCellAtIndexHandler( fun )
	self._cellAtIndexHandler = fun
end

function CCBTableView:setNumberOfCellHandler( fun )
	self._numberOfCellHandler = fun
end

function CCBTableView:setCellTouchedHandler( fun )
	self._cellTouchedHandler = fun
end

function CCBTableView:setCellTouchBeginHandler( fun )
	self._cellTouchBeginHandler = fun
end

function CCBTableView:setCellTouchEndHandler( fun )
	self._cellTouchEndHandler = fun
end

function CCBTableView:setCellHighlightHandler( fun )
	self._cellHighlightHandler = fun
end

function CCBTableView:setCellUnHighlightHandler( fun )
	self._cellUnHighlightHandler = fun
end

function CCBTableView:setCellRecycleHandler( fun )
	self._cellRecycleHandler = fun
end

return CCBTableView