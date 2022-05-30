local CScrollLayer = class("CScrollLayer", function ()
	return display.newNode()
end)

DisplayStyle = {
ONE_BY_ONE_FROM_BOTTOM = 1
}

--不用设置位置，通过x, y参数指定
function CScrollLayer:ctor(param)
	
	local _x        = param.x
	local _y        = param.y
	
	--点击Cell 是否会有缩放效果
	local _bIsTouchScale = param.bIsTouchScale or false
	
	--拖动Cell是否会有延迟效果 悟  空源 码网 www.w ky mw.com
	local _bIsDragLag = param.bIsDragLag or false
	local dragTime = 0
	if _bIsDragLag then
		dragTime = 0.2
	end
	
	
	local _wx       = param.width
	local _wy       = param.height
	
	local _rowSize   = param.rowSize or 1
	local _pageSize  = param.pageSize or 1
	
	local _Vertical = param.bVertical
	local _displayStyle = param.displayStyle
	local _nodes    = param.nodes or {}
	local _space    = param.space or 0
	
	self:setPosition(_x, _y)
	local _colSize = _pageSize / _rowSize
	local _totalPage = math.ceil(#_nodes / _pageSize)
	
	local clipNode = display.newClippingRegionNode(CCRectMake(_x, _y,  _wx, _wy))
	self:addChild(clipNode)
	local viewLayer = display.newLayer()
	
	-- local colorlayer = CCLayerColor:create(ccc4(255, 0, 0, 255), _wx, _wy)
	-- colorlayer:setPosition(_x, _y)
	-- self:addChild(colorlayer)
	
	clipNode:addChild(viewLayer)
	
	local _totalHeight = 0
	
	local scrollBar = nil
	local _scrollBarX = 0
	local _scrollBarY = 0
	local function showVScrollBar()
		if _totalHeight > _wy then
			scrollBar = ResMgr.getUIScale9Sprite("ranking_scroll_bar.png")
			scrollBar:setContentSize(CCSizeMake(scrollBar:getContentSize().width, _wy * (_wy / _totalHeight)))
			
			_scrollBarX = _x + _wx - 10
			_scrollBarY = _y + _wy - scrollBar:getContentSize().height / 2
			
			scrollBar:setPosition(_scrollBarX, _scrollBarY)
			self:addChild(scrollBar)
		end
		
	end
	
	local SPACE = 2 + _space
	
	local function rollScrollBar(percent, bEnd)
		
		local tmpX = 0
		local tmpY = 0
		
		if scrollBar then
			if percent < 0 then
				
				tmpX = _scrollBarX
				tmpY = _scrollBarY
				
			elseif percent >= 1 then
				
				tmpX = _scrollBarX
				tmpY = _y + scrollBar:getContentSize().height / 2
				
			else
				
				local offsetH = (_wy - scrollBar:getContentSize().height) * percent
				tmpX = _scrollBarX
				tmpY = _scrollBarY - offsetH
				
			end
			
			if bEnd then
				local move = CCMoveTo:create(0.5, CCPointMake(tmpX, tmpY))
				local easeSineOut = CCEaseSineOut:create(move);
				scrollBar:runAction(easeSineOut);
			else
				scrollBar:setPosition(tmpX, tmpY)
			end
		end
	end
	
	local function showNode(node, targetX, targetY, delayTime)
		if _displayStyle == DisplayStyle.ONE_BY_ONE_FROM_BOTTOM then
			node:setPosition(targetX, -70)
		end
		
		node:runAction(transition.sequence({
		CCDelayTime:create(delayTime),
		CCMoveTo:create(0.15,CCPointMake(targetX, targetY))
		}))
		
	end
	
	--
	local function onVDisplay()
		local tmpY = _wy - SPACE + _y
		for k, v in ipairs(_nodes) do
			if k == 1 then
				tmpY = tmpY - v:getContentSize().height / 2 - SPACE
			else
				tmpY = tmpY - v:getContentSize().height - SPACE
			end
			_totalHeight = _totalHeight + SPACE + v:getContentSize().height
			if _displayStyle and k <= 5 then
				showNode(v, _wx / 2 + _x, tmpY, 0.17 * k)
			else
				v:setPosition(_wx / 2 + _x, tmpY)
			end
			viewLayer:addChild(v)
		end
		
		--        showVScrollBar()
	end
	
	local _totalWidth = 0
	local function onHDisplay()
		local tmpX = _wx + _x
		
		local cellWidth = _wx / _rowSize
		local cellHeight = _wy / _colSize
		
		local baseX = cellWidth / 2
		local baseY = _wy - cellHeight / 2
		
		
		_totalWidth = _wx * _totalPage
		for k, v in ipairs(_nodes) do
			
			local row = math.floor((k - 1) / _rowSize)
			local col = math.floor( (k - 1) % _rowSize)
			
			local page = math.ceil(k / _pageSize) - 1
			row = row - page * _colSize
			
			v:setPosition(baseX + cellWidth * col + page * _wx, baseY - cellHeight * row)
			viewLayer:addChild(v)
		end
		
	end
	
	
	
	
	local touchNode = nil
	local bIsMove = false
	local prePos = {}
	local startPos = {}
	local startTime = 0
	local endTime = 0
	
	local function onTouchBegin(tx, ty)
		bIsMove = false
		touchNode = nil
		if CCRectMake(_x, _y, _wx, _wy):containsPoint(self:convertToNodeSpace(CCPointMake(tx, ty))) then
			prePos.x = tx
			prePos.y = ty
			
			startPos.x = tx
			startPos.y = ty
			
			startTime = os.clock()
			for k, v in ipairs(_nodes) do
				
				--printf(v:getBoundingBox().origin.x .. "   Y:" .. v:getBoundingBox().origin.y .. "  width:" ..v:getBoundingBox().size.width)
				if v:getBoundingBox():containsPoint(v:convertToNodeSpace(CCPointMake(tx, ty))) then
					touchNode = v
					touchNode:setColor(ccc3(100, 100, 100))
					break
				end
			end
			
			return true
		else
			return false
		end
	end
	
	local function onVerticalScroll(tx, ty)
		local cx, cy = viewLayer:getPosition()
		local dis = ty - prePos.y
		
		if (dis > 5 or dis < -5) then
			bIsMove = true
			viewLayer:setPosition(CCPointMake(cx, cy + dis))
			prePos.x = tx
			prePos.y = ty
			
			rollScrollBar( (cy + dis) / (_totalHeight - _wy))
			
			
			
			if (touchNode) ~= nil then
				local b = false
				for k, v in ipairs(_nodes) do
					
					local act = nil
					if b then
						act = CCMoveBy:create(dragTime, CCPointMake(0, -dis / 3))
						
					elseif v ~= touchNode then
						act = CCMoveBy:create(dragTime, CCPointMake(0, -dis / 3))
					end
					
					if v == touchNode then
						b = true
						if _bIsTouchScale then
							act = CCScaleTo:create(0.2, 0.95)
							if act then
								v:runAction(transition.sequence({
								act,
								CCScaleTo:create(0.1, 1)
								}))
							end
						end
					else
						if act then
							v:runAction(transition.sequence({
							act,
							act:reverse()
							}))
						end
					end
					
				end
				
				touchNode:setColor(ccc3(255, 255, 255))
			end
		end
	end
	
	
	local function onHorizontalScroll(tx, ty)
		local cx, cy = viewLayer:getPosition()
		local dis = tx - prePos.x
		
		if (dis > 5 or dis < -5) then
			bIsMove = true
			viewLayer:setPosition(CCPointMake(cx + dis, cy))
			prePos.x = tx
			prePos.y = ty
			
			if (touchNode) ~= nil then
				touchNode:setColor(ccc3(255, 255, 255))
			end
		end
	end
	
	local function onTouchMoved(tx, ty)
		
		if _Vertical then
			onVerticalScroll(tx, ty)
		else
			onHorizontalScroll(tx, ty)
		end
		
	end
	
	local function onVerticalTouchEnd(tx, ty)
		local dis = ty - startPos.y
		local posX, posY = viewLayer:getPosition()
		
		endTime = os.clock()
		
		if (_totalHeight <= _wy) or (posY + dis < 0) then
			posY = 0
			transition.moveTo(viewLayer, {time = 0.2, x = posX , y = posY})
		elseif posY + dis > _totalHeight - _wy then
			posY = _totalHeight - _wy
			transition.moveTo(viewLayer, {time = 0.2, x = posX, y = posY})
		else
			local delay = endTime - startTime
			if delay < 0.8 then
				local endY = posY
				if dis < 0 then
					endY = endY - 250
				elseif dis > 0 then
					endY = endY + 250
				end
				
				if endY < 0 then
					endY = 0
				elseif endY > _totalHeight - _wy then
					endY = _totalHeight - _wy
				end
				
				local move = CCMoveTo:create(0.5, CCPointMake(posX , endY))
				local easeSineOut = CCEaseSineOut:create(move)
				viewLayer:runAction(easeSineOut)
				posY = endY
			end
		end
		rollScrollBar( posY / (_totalHeight - _wy), true)
		
		startTime = 0
		endTime = 0
	end
	
	local function onHorizontalTouchEnd(tx, ty)
		local dis = tx - startPos.x
		local posX, posY = viewLayer:getPosition()
		
		endTime = os.clock()
		
		if (_totalWidth <= _wy) or (posX + dis > 0) then
			posX = 0
			transition.moveTo(viewLayer, {time = 0.2, x = posX, y = posY})
		elseif posX + dis < -(_totalWidth - _wx) then
			posX = -(_totalWidth - _wx)
			transition.moveTo(viewLayer, {time = 0.2, x = posX, y = posY})
		else
			local delay = endTime - startTime
			if delay < 0.8 then
				local endX = posX
				if dis > 0 then
					endX = endX + 100
				elseif dis < 0 then
					endX = endX - 100
				end
				
				if endX > 0 then
					endX = 0
				elseif endX < -(_totalWidth - _wx) then
					endX = -(_totalWidth - _wx)
				end
				
				local move = CCMoveTo:create(0.5, CCPointMake(endX, posY))
				local easeSineOut = CCEaseSineOut:create(move)
				viewLayer:runAction(easeSineOut)
			end
		end
		
	end
	
	
	local function onTouchEnded(tx, ty)
		
		if  bIsMove then
			if (_Vertical) then
				onVerticalTouchEnd(tx, ty)
			else
				onHorizontalTouchEnd(tx, ty)
			end
		end
		
		if (bIsMove == false) then
			if (touchNode ~= nil) then
				touchNode:onTouch(touchNode)
				touchNode:setColor(ccc3(255, 255, 255))
				touchNode = nil
			end
		end
		
		for k, v in ipairs(_nodes) do
			v:runAction(CCScaleTo:create(0.1, 1))
		end
	end
	
	local function onTouch(eventType, tx, ty)
		
		if eventType == "began" then
			local touch = onTouchBegin(tx, ty)
			return touch
		elseif eventType == "moved" then
			onTouchMoved(tx, ty)
		elseif eventType == "ended" then
			onTouchEnded(tx, ty)
		end
	end
	
	viewLayer:setTouchEnabled(true)
	viewLayer:addTouchEventListener(onTouch, false, -128, true)
	
	self.setLayerTouchEnabled = function (_, bEnabled)
		for k, v in ipairs(_nodes) do
			v:setTouchEnabled(bEnabled)
		end
	end
	
	if _Vertical then
		onVDisplay()
	else
		onHDisplay()
	end
end

function CScrollLayer:onEnter()
	
end

return CScrollLayer