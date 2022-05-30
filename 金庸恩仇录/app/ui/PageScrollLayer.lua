local PageScrollLayer = class("PageScrollLayer", function (param)
	return display.newClippingRegionNode(CCRectMake(param.x, param.y, param.width, param.height))
end)

function PageScrollLayer:init(param)
	local x  = param.x
	local y  = param.y
	local wx = param.width
	local touchFunc = param.callTouchFunc
	self.wx = wx
	local wy = param.height
	local pageSize = param.pageSize
	local rowSize  = param.rowSize
	local nodes    = param.nodes or {}
	local bVertical= param.vertical or false
	local bFreeScroll = param.bFreeScroll or false
	local rowNum = math.ceil(pageSize / rowSize)
	local cellWidth = wx / rowSize
	local cellHeight = wy / rowNum
	local cellCX = cellWidth / 2
	local cellCY = cellHeight / 2
	local totoaRow = math.ceil(#nodes / rowSize)
	local totalPage = 0
	if (#nodes % pageSize == 0) then
		totalPage = #nodes / pageSize;
	else
		totalPage = math.ceil(#nodes / pageSize)
	end
	
	--所有节点排列总长度	
	local allNodesWidth = 0
	local view = display.newLayer()
	self.view = view
	view:setPosition(0, 0)
	self:addChild(view)
	
	-------------------------------------------------
	local freeScrollWidth = 0
	local function onHorizontalDisplay()
		local tmpX = cellCX
		local tmpY = cellCY
		if (bFreeScroll ) and nodes[1] then
			tmpX = nodes[1]:getBoundingBox().width / 2  + 2
		end
		for k, v in ipairs(nodes) do
			if (bFreeScroll ) and k > 1 then
				tmpX = tmpX + v:getBoundingBox().width + 2
				freeScrollWidth = v:getBoundingBox().width + 2
			else
				if ((k - 1) % rowSize == 0) and (k > 1) then
					tmpX = cellCX + display.width * math.floor((k - 1) / pageSize)
					if (k - 1) % pageSize == 0 then
						tmpY = cellCY
					else
						tmpY = tmpY + cellHeight
					end
				elseif k > 1 then
					tmpX = tmpX + cellWidth
				end
			end
			v:setPosition(tmpX + x , tmpY + y)
			view:addChild(v);
			allNodesWidth = allNodesWidth + v:getBoundingBox().width + 2
		end
		allNodesWidth = allNodesWidth - 2
	end
	self.currentPage   = 1
	self.localPosition = {x = 0, y = 0 }
	
	self.getCurrentPage = function ()
		return self.currentPage, ((self.currentPage - 1) * pageSize + 1)
	end
	
	self.refreshItem = function (_, index, data)
		nodes[index]:refresh(data)
	end
	
	self.getPageSize = function ()
		return pageSize
	end
	
	self.changeCurrentPage = function ()
		if param.callFunc then
			param.callFunc(self.currentPage)
		end
	end
	
	self.removeFromBorder = function ()
		local prePosition = nil
		local bReset = false
		local index = 0
		local delIndex = {}
		local bBreak = true
		for k, v in ipairs(nodes) do
			if v:isDel() then
				delIndex[#delIndex + 1] = k
			end
		end
		local loopNum = #delIndex
		local function displayAnim()
			bBreak = true
			for k, v in ipairs(nodes) do
				if bBreak and v:isDel() then
					if (bFreeScroll) then
						allNodesWidth = allNodesWidth - freeScrollWidth
					end
					bBreak = false
					bReset = true
					index = k
					prePosition = cc.p(v:getPosition())
					v:runAction(transition.sequence({
					CCMoveBy:create(0.2, cc.p(v:getContentSize().width, 0)),
					CCCallFunc:create(function ()
						v:removeFromParentAndCleanup(true)
						local tmp = #nodes % pageSize
						loopNum = loopNum - 1
						print(tmp) 	--当前页面只有一项	
						if tmp == 0 then
							if totalPage > 1 then
								if self.currentPage == totalPage then
									view:runAction(CCMoveBy:create(0.3, cc.p(0, -display.height)))
									self.localPosition.y = self.localPosition.y - display.height
									
								end
								totalPage = totalPage - 1
								if self.currentPage > 1 then
									self.currentPage = self.currentPage - 1
									self:changeCurrentPage()
								end
							end
						end
						
						if k == #nodes and loopNum > 0 then
							displayAnim()
						end
					end)
					}))
					
				else
					if (bReset) then
						v:runAction(transition.sequence({
						CCDelayTime:create(0.4),
						CCMoveTo:create(0.3,prePosition),
						CCCallFunc:create(function ()
							if k == #nodes and loopNum > 0 then
								displayAnim()
							end
						end)
						}))
					end
					prePosition = cc.p(v:getPosition())
				end
			end
			table.remove(nodes, index)
		end
		displayAnim()
	end
	
	self.dynamicInsertNode = function (_, node)
		if bFreeScroll then
			nodes[#nodes + 1] = node
			local tmpX = cellCX
			local tmpY = wy - cellCY
			tmpY = wy - nodes[1]:getBoundingBox().size.height / 2  - 5
			for k, v in ipairs(nodes) do
				if k > 1 then
					tmpY = tmpY - v:getBoundingBox().height / 2 - 5
				end
				v:setPosition(tmpX + x, tmpY + y)
				if (bFreeScroll ) and k >= 1 then
					tmpY = tmpY - v:getBoundingBox().height / 2
				end
				if k == #nodes then
					view:addChild(v);
					v:setScale(0)
					v:runAction(transition.sequence({
					CCDelayTime:create(0.1),
					CCScaleTo:create(0.15, 1)
					}))
					allNodesWidth = allNodesWidth + v:getBoundingBox().height + 5
					if ( (allNodesWidth + wx - 5) < wx) then
						self.localPosition.y = 0
					else
						self.localPosition.y =  allNodesWidth
					end
					view:runAction(transition.sequence({
					CCMoveTo:create(0.1, cc.p(self.localPosition.x, self.localPosition.y))
					}))
				end
			end
			
		end
		
	end
	
	local function onVerticalDisplay()
		local tmpX = cellCX
		local tmpY = wy - cellCY
		if (bFreeScroll ) and nodes[1] then
			tmpY = wy - nodes[1]:getBoundingBox().size.height / 2  - 5
		end
		
		for k, v in ipairs(nodes) do
			if (bFreeScroll) and k > 1 then
				tmpY = tmpY - v:getBoundingBox().size.height / 2 - 5
			else
				if ((k - 1) % rowSize == 0) and (k > 1) then
					tmpX = cellCX
					if (k - 1) % pageSize == 0 then
						if (bFreeScroll) then
							tmpY = tmpY - cellHeight
						else
							tmpY = wy - cellCY - display.height * math.floor((k - 1) / pageSize)
						end
					else
						tmpY = tmpY - cellHeight
					end
				elseif (k > 1) then
					tmpX = tmpX + cellWidth;
				end
			end
			v:setPosition(tmpX + x, tmpY + y)
			if (bFreeScroll ) and k >= 1 then
				tmpY = tmpY - v:getBoundingBox().size.height / 2
			end
			view:addChild(v);
			allNodesWidth = allNodesWidth + v:getBoundingBox().size.height + 5
		end
		allNodesWidth = allNodesWidth - wy + 5
	end
	
	local ptBeginPos    = {x = 0, y = 0 }
	local ptPrePos      = {x = 0, y = 0}
	local bIsMove = true
	
	self.setCurrentNode = function (sender, index)
		if bFreeScroll then
			local nodeWidth = nodes[1]:getContentSize().width  + 2
			self.currentPage = math.ceil(index / pageSize)
			self:changeCurrentPage()
			if totalPage ~= 1 then
				if self.currentPage >= totalPage then
					self.localPosition.x =  -allNodesWidth + wx
				else
					local x = (self.currentPage - 1) * rowSize * nodeWidth
					self.localPosition.x = -x
				end
				view:setPosition(self.localPosition.x, 0)
			end
		else
			if index then
				view:setPosition(cc,p(0, (index - 1) * display.height))
			end
		end
	end
	
	self.setShowLastNode = function (bTop)
		if bTop then
			if allNodesWidth > 0 then
				self.localPosition.x = 0
				self.localPosition.y = allNodesWidth
				view:setPosition(0, allNodesWidth)
			end
		else
			self.localPosition.x = 0
			self.localPosition.y = allNodesWidth
			view:setPosition(0, allNodesWidth)
		end
		
	end
	
	local function onHorizontalScroll(tx, ty)
		local dis = tx - ptBeginPos.x
		local cx, cy = view:getPosition()
		if bFreeScroll then
			if allNodesWidth > wx then
				self.localPosition.x = self.localPosition.x + dis
				if (self.localPosition.x > 0) then
					self.localPosition.x = 0
				elseif self.localPosition.x < -allNodesWidth + wx then
					self.localPosition.x =  -allNodesWidth + wx
				end
			end
		else
			if (dis >= wx / 3) then
				if (self.currentPage > 1) then
					self.localPosition.x = self.localPosition.x + display.width;
					self.currentPage = self.currentPage - 1
					self:changeCurrentPage()
				end
			elseif (dis <= -wx / 3) then
				if (self.currentPage < totalPage) then
					self.localPosition.x = self.localPosition.x - display.width;
					self.currentPage = self.currentPage + 1
					self:changeCurrentPage()
				end
			end
		end
		transition.moveTo(view, {time = 0.2, x = self.localPosition.x, y = self.localPosition.y})
	end
	
	local function onVerticalScroll(tx, ty)
		local dis = ptBeginPos.y - ty
		local cx, cy = view:getPosition()
		if bFreeScroll then
			self.localPosition.y = self.localPosition.y - dis
			if (self.localPosition.y <= 0)then
				self.localPosition.y = 0
			elseif self.localPosition.y > allNodesWidth then
				if ( (allNodesWidth + wx - 5) < wx) then
					self.localPosition.y = 0
				else
					self.localPosition.y =  allNodesWidth
				end
			end
		else
			if (dis <= -wy / 4)  then
				if (self.currentPage < totalPage ) then
					self.localPosition.y = self.localPosition.y + display.height;
					self.currentPage = self.currentPage + 1
					self:changeCurrentPage()
				end
			elseif (dis >= wx / 4)  then
				if (self.currentPage > 1 ) then
					self.localPosition.y = self.localPosition.y - display.height;
					self.currentPage = self.currentPage - 1
					self:changeCurrentPage()
				end
			end
		end
		transition.moveTo(view, {time = 0.2, x = self.localPosition.x, y = self.localPosition.y})
	end
	
	local touchNodeIndex = 0
	local touchNode = nil
	local function onTouchBegin(tx, ty)
		bIsMove = false
		touchNode = nil
		if cc.rectContainsPoint(cc.rect(x, y, wx, wy), self:convertToNodeSpace(cc.p(tx, ty))) then
			ptBeginPos.x = tx
			ptBeginPos.y = ty
			ptPrePos.x = tx
			ptPrePos.y = ty
			for k, v in ipairs(nodes) do
				local size = v:getContentSize()
				if cc.rectContainsPoint( cc.rect(-size.width/2, -size.height/2, size.width, size.height), v:convertToNodeSpace(cc.p(tx, ty)) ) then
					touchNode = v
					touchNodeIndex = k
					--dump("onTouchBegin rectContainsPoint" ..k)
					--dump(touchNode)
					touchNode:setColor(cc.c3b(100, 100, 100))
					break
				end
			end
			return true
		else
			return false
		end
	end
	
	local function onTouchMoved(tx, ty)
		local cx, cy = view:getPosition()
		local dis = tx - ptPrePos.x
		if (bVertical) then
			dis = ty - ptPrePos.y
		else
			dis = tx - ptPrePos.x
		end
		if (dis > 5 or dis < -5) then
			bIsMove = true
			if (bVertical) then
				view:setPosition(cc.p(cx, cy + dis))
			else
				view:setPosition(cc.p(cx + dis, cy))
			end
			ptPrePos.x = tx
			ptPrePos.y = ty
			if touchNode ~= nil then
				touchNode:setColor(cc.c3b(255, 255, 255))
			end
		end
	end
	
	local function onTouchEnded(tx, ty)
		if  bIsMove then
			if (bVertical) then
				onVerticalScroll(tx, ty)
			else
				onHorizontalScroll(tx, ty)
			end
		end
		if (bIsMove == false) then
			if table.getn(nodes) > 0 and touchNode ~= nil then
				touchFunc(touchNodeIndex)
				touchNode:setColor(cc.c3b(255, 255, 255))
				touchNode = nil
				touchNodeIndex = 0
			end
		end
	end
	
	local function onTouch(event)
		eventType = event.name
		local tx =event.x
		local ty = event.y
		if eventType == "began" then
			local touch = onTouchBegin(tx, ty)
			return touch
		elseif eventType == "moved" then
			if self.tuto_move ~= nil and self.tuto_move == false then
				return false
			end
			onTouchMoved(tx, ty)
		elseif eventType == "ended" then
			onTouchEnded(tx, ty)
		end
	end
	
	self.setLayerTouchEnabled = function (_, bEnabled)
		for k, v in ipairs(nodes) do
			v:setTouchEnabled(bEnabled)
		end
	end
	
	self.reset = function ()
		view:setPosition(0, 0)
	end
	------------------------------------------------------------------
	view:setTouchEnabled(true)
	view:addNodeEventListener(cc.NODE_TOUCH_EVENT, onTouch)
	if (bVertical) then
		onVerticalDisplay()
	else
		onHorizontalDisplay()
	end
end

function PageScrollLayer:toPageByIndex (index)
	self.currentPage = index
	local scrollTIme = math.abs(index - self:getCurPageIndex())
	local targetX = self.wx * (index-1)
	self.localPosition.x = -targetX
	transition.moveTo(self.view, {time = 0.2 * scrollTIme, x = -targetX, y = 0})
end

function PageScrollLayer:getCurPageIndex()
	local viewX = math.abs(self.view:getPositionX())
	print ("viewX"..viewX, "self wx "..self.wx)
	if self.wx ~= 0 then
		return viewX/self.wx + 1
	else
		return 0
	end
end

function PageScrollLayer:ctor(param)
	self:init(param)
end

return PageScrollLayer