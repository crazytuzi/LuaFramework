--CCBTableEventHandler.lua


local CCBTableEventHandler = class ("CCBTableEventHandler", function ( )
	return display.newNode()
end)

function CCBTableEventHandler:ctor( )
	self._cellSize = CCSizeMake(1, 1)

	self._cellAtIndexHandler = nil
	self._numberOfCellHandler = nil
	self._cellTouchedHandler = nil
	self._cellTouchBeginHandler = nil
	self._cellTouchEndHandler = nil
	self._cellHighlightHandler = nil
	self._cellUnHighlightHandler = nil
	self._cellRecycleHandler = nil

	self._luaEventHandler = function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			-- Return cell size
			-- a1 is cell index (-1 means default size, in cocos2d-x version below 2.1.3, it's always -1)
			r = self:_getCellSize() --CCSizeMake(320,30)
		elseif fn == "cellAtIndex" then
			-- Return CCTableViewCell, a1 is cell index (zero based), a2 is dequeued cell (maybe nil)
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
	end
end

function CCBTableEventHandler:getEventHandler(  )
	return self._luaEventHandler
end

--functions that inline that user shoud not use
function CCBTableEventHandler:_getCellSize( )
	return self._cellSize
end

function CCBTableEventHandler:_getCellAtIndex( a1, a2)
	if self._cellAtIndexHandler == nil then
		return CCTableViewCell:create()
	end

	return self._cellAtIndexHandler(a1, a2)
end

function CCBTableEventHandler:_getNumberOfCells( a1, a2)
	if self._numberOfCellHandler == nil then
		return 0
	end

	return self._numberOfCellHandler(a1, a2)
end

function CCBTableEventHandler:_onCellTouched( a1, a2 )
	if self._cellTouchedHandler == nil then
		return nil
	end

	return self._cellTouchedHandler(a1, a2)
end

function CCBTableEventHandler:_onCellTouchBegin( a1, a2 )
	if self._cellTouchBeginHandler == nil then
		return false
	end

	return self._cellTouchBeginHandler(a1, a2)
end

function CCBTableEventHandler:_onCellTouchEnd( a1, a2 )
	if self._cellTouchEndHandler == nil then
		return nil
	end

	return self._cellTouchEndHandler(a1, a2)
end

function CCBTableEventHandler:_onCellHighlight( a1, a2 )
	if self._cellHighlightHandler == nil then
		return nil
	end

	return self._cellHighlightHandler(a1, a2)
end

function CCBTableEventHandler:_onCellUnHighlight( a1, a2 )
	if self._cellUnHighlightHandler == nil then
		return nil
	end

	return self._cellUnHighlightHandler(a1, a2)
end

function CCBTableEventHandler:_onCellWillRecycle( a1, a2 )
	if self._cellRecycleHandler == nil then
		return nil
	end

	return self._cellRecycleHandler(a1, a2)
end


-- functions that user shoud call to set event handler
function CCBTableEventHandler:setCellSize ( size )
	self._cellSize = size
end

function CCBTableEventHandler:setCellAtIndexHandler( fun )
	self._cellAtIndexHandler = fun
end

function CCBTableEventHandler:setNumberOfCellHandler( fun )
	self._numberOfCellHandler = fun
end

function CCBTableEventHandler:setCellTouchedHandler( fun )
	self._cellTouchedHandler = fun
end

function CCBTableEventHandler:setCellTouchBeginHandler( fun )
	self._cellTouchBeginHandler = fun
end

function CCBTableEventHandler:setCellTouchEndHandler( fun )
	self._cellTouchEndHandler = fun
end

function CCBTableEventHandler:setCellHighlightHandler( fun )
	self._cellHighlightHandler = fun
end

function CCBTableEventHandler:setCellUnHighlightHandler( fun )
	self._cellUnHighlightHandler = fun
end

function CCBTableEventHandler:setCellRecycleHandler( fun )
	self._cellRecycleHandler = fun
end

return CCBTableEventHandler