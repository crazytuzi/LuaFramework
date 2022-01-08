--
-- Author: MiYu
-- Date: 2014-04-29 14:12:14
--
CCTMXOrientationOrtho = 0
CCTMXOrientationHex = 1
CCTMXOrientationIso = 2

TFTABLEVIEWEX_CLICK 		= 234
TFTABLEVIEWEX_CELLAT 		= 235
TFTABLEVIEWEX_MOVECOMPLETED = 236


TFTableViewEx = class("TFTableViewEx", function(width, height)
	local panel = TFPanel:create()
	if width == nil or height == nil then
		local size = me.EGLView:getDesignResolutionSize()
		width = size.width
		height = size.height
	end
	panel._setDesignResolutionSize = panel.setDesignResolutionSize
	panel.isRemoveChild = false
	panel.changeCells = ""
	panel.slopeAngle = 15
	panel.touchMoveEnable = true
	panel.innerContainer = TFPanel:create()
	panel.innerContainer:setRotationX3D(-panel.slopeAngle)
	me.Director:setZFar(3)
	panel:addChild(panel.innerContainer)
	panel:setSize(ccs(width, height))
	panel.x = 0
	panel.y = 0
	panel.gridColor = ccc4f(1, 1, 1, 0.3)
	panel.gridRadius = 1

	panel.touchPanel = TFPanel:create()
	panel.touchPanel:setSize(ccs(me.frameSize.width * 2 , me.frameSize.height * 2))
	panel.touchPanel.self = panel

	panel:addChild(panel.touchPanel)
	return panel
end)

function TFTableViewEx:setSlopeAngle(angle)
	self.slopeAngle = angle or self.slopeAngle
	self.innerContainer:setRotationX3D(-self.slopeAngle)
	for cell in self.cells:iterator() do 
		cell:setRotationX3D(self.slopeAngle)
	end
end

function TFTableViewEx:getSlopeAngle()
	return self.slopeAngle
end

function TFTableViewEx:addEvent()
	self.touchPanel:setTouchEnabled(true)
	self.touchPanel:addMEListener(TFWIDGET_CLICK, function(target, pos)
		if self.clickFunc then
			local point = self.innerContainer:convertToNodeSpace(pos)
			local w = self.rows * self.cellWidth
			local h = self.columns * self.cellHeight
			
			if self.isLoop then
				point.x 		= (point.x + self.x + w) % (w)
				point.y 		= (point.y + self.y + h) % (h)
				local cellPos 	= self:cellAtPos(point.x, point.y)
				local column 	= (math.floor(cellPos.x) + self.columns) % self.columns
				local row 		= (math.floor(cellPos.y) + self.rows) % self.rows
				self.clickFunc(self, self:getCell(row + 1, column + 1), column + 1, row + 1)
			else
				point.x 		= point.x + self.x 
				point.y 		= point.y + self.y
				local cellPos 	= self:cellAtPos(point.x, point.y)
				local row 		= math.floor(cellPos.y) + 1
				local column 	= math.floor(cellPos.x) + 1 

				if row <= self.rows and column <= self.columns and row > 0 and column > 0 then
					self.clickFunc(self, self:getCell(row, column), row, column)
				end
			end
		end

		if self.toucheEndTimer then
			TFDirector:removeTimer(self.toucheEndTimer)
			self.toucheEndTimer = nil
		end
	end)
	self.touchPanel:addMEListener(TFWIDGET_TOUCHMOVED, function(sender, pos, seekPos)
		self.backGrid:setVisible(true)
		self.changeCells = ""
		if self.touchMoveEnable then
			self:show(self.x - seekPos.x, self.y - seekPos.y)
			self:updateShowCell()
			if self.moveCompleted then
				self.moveCompleted(self.changeCells)
			end
		end
	end)

	self.touchPanel:addMEListener(TFWIDGET_TOUCHENDED, function(sender, pos, seekPos)
		self.backGrid:setVisible(false)
		if self.touchEndCallBack then
			if self.touchDelay <= 0 then
				self.touchEndCallBack()
				return
			end
			self.toucheEndTimer = TFDirector:addTimer(self.touchDelay, 1, nil, function ( ... )
				if self.touchEndCallBack then
					self.touchEndCallBack()
				end
			end)
		end
	end)

	self.touchPanel:addMEListener(TFWIDGET_CHECK_CHILDINFO, function(target, handStatus, touchPos)
		if handStatus == 1 then
			self.backGrid:setVisible(true)
			local x = touchPos.x - self.touchX
			local y = touchPos.y - self.touchY
			self.changeCells = ""
			self:show(self.x - x, self.y - y)
			self:updateShowCell()
			if self.moveCompleted then
				self.moveCompleted(self.changeCells)
			end
		else
			self.backGrid:setVisible(false)
		end
		self.touchX = touchPos.x
		self.touchY = touchPos.y
	end)
end

function TFTableViewEx:setTouchMoveEnable(enable)
	self.touchMoveEnable = enable
end

function TFTableViewEx:setTouchEndCallBack(delay, touchEndCallBack)
	self.touchDelay = delay
	self.touchEndCallBack = touchEndCallBack
end

function TFTableViewEx:setBackgroupMap(pFile)
	local size = self.touchPanel:getSize()
	self.mapBg = TFImage:create(pFile)
	self.bgMapSize = self.mapBg:getTexture():getContentSizeInPixels()
	self.mapBg:setAnchorPoint(ccp(0, 0))
	self.mapBg:setImageSizeType(TF_SIZE_CORRDS)
	self.innerContainer:addChild(self.mapBg, -1000);

	local p = self:convertToWorldSpace(ccp(size.width, size.height))
	local tr = self.innerContainer:convertToNodeSpace(p)

	-- panelSize = self:getSize()
	p = self:convertToWorldSpace(ccp(0, 0))
	local bl = self.innerContainer:convertToNodeSpace(p)

	p = self:convertToWorldSpace(ccp(0, size.height))
	local tl = self.innerContainer:convertToNodeSpace(p)

	self.mapBg:setSize(ccs(tr.x - tl.x, tl.y - bl.y))
	self.mapBg:setPosition(ccp(tl.x - self:getPosition().x, bl.y - self:getPosition().y))
end

function TFTableViewEx:setBackGridColor(r, g, b, a)
	self.gridColor = ccc4f(r, g, b, a)
end

function TFTableViewEx:setBackGridRadius(radius)
	self.gridRadius = radius
end

function TFTableViewEx:setGridVisisble(bVisible)
	self.backGridVisible = bVisible
	if nil == self.backGrid then
		self.backGrid = TFDrawNode:create()
		self.innerContainer:addChild(self.backGrid, -999)
		self:drawGrid()
	end
	self.backGrid:setVisible(bVisible)
end

function TFTableViewEx:drawGrid()
	print("###############################################draw grid")
	self.backGrid:clear()
	local size = self:getSize()
	local p = self:convertToWorldSpace(ccp(size.width, size.height))
	local tr = self.innerContainer:convertToNodeSpace(p)
	p = self:convertToWorldSpace(ccp(size.width, 0))
	local br = self.innerContainer:convertToNodeSpace(p)
	p = self:convertToWorldSpace(ccp(0, 0))
	local bl = self.innerContainer:convertToNodeSpace(p)
	p = self:convertToWorldSpace(ccp(0, size.height))
	local tl = self.innerContainer:convertToNodeSpace(p)
		
	if self.orien == CCTMXOrientationIso then
		local leftColumn 	= math.floor(self:cellAtPos(bl.x, bl.y).x)
		local rightColumn 	= math.ceil(self:cellAtPos(tr.x ,tr.y).x) + 2
		local bottomRow 	= math.floor(self:cellAtPos(br.x, br.y).y)
		local topRow 		= math.ceil(self:cellAtPos(tl.x, tl.y).y) + 2
		if self.isLoop == false then
			leftColumn 	= 0
			rightColumn = self.columns
			bottomRow	= 0
			topRow 		= self.rows
		end	

		local fromX = self.cellWidth / 2 * (self.columns + leftColumn - bottomRow)
		local fromY = self.cellHeight / 2 * (bottomRow + leftColumn)
		local toX   = self.cellWidth / 2 * (self.columns + leftColumn - topRow)
		local toY   = self.cellHeight / 2 * (topRow + leftColumn)

		for colum = leftColumn, rightColumn do
			self.backGrid:drawSegment(ccp(fromX, fromY), ccp(toX, toY), self.gridRadius, self.gridColor)
			fromX = fromX + self.cellWidth  / 2
			fromY = fromY + self.cellHeight / 2
			toX   = toX   + self.cellWidth  / 2
			toY   = toY   + self.cellHeight / 2
		end

		fromX = self.cellWidth / 2 * (self.columns + leftColumn - bottomRow)
		fromY = self.cellHeight / 2 * (bottomRow + leftColumn)
		toX   = self.cellWidth / 2 * (self.columns + rightColumn - bottomRow)
		toY   = self.cellHeight / 2 * (bottomRow + rightColumn)
		for colum = bottomRow, topRow do
			self.backGrid:drawSegment(ccp(fromX, fromY), ccp(toX, toY), self.gridRadius, self.gridColor)
			fromX = fromX - self.cellWidth  / 2
			fromY = fromY + self.cellHeight / 2
			toX   = toX   - self.cellWidth  / 2
			toY   = toY   + self.cellHeight / 2
		end
	else
		local leftColumn 	= math.floor(tl.x / self.cellWidth)
		local rightColumn 	= math.ceil(tr.x / self.cellWidth) + 2
		local bottomRow 	= math.floor(bl.y / self.cellHeight)
		local topRow 		= math.ceil(tl.y / self.cellHeight) + 2

		local fromX = leftColumn * self.cellWidth
		local fromY = bottomRow * self.cellHeight
		local toX   = leftColumn * self.cellWidth
		local toY   = topRow * self.cellHeight

		for colum = leftColumn, rightColumn do
			self.backGrid:drawSegment(ccp(fromX, fromY), ccp(toX, toY), self.gridRadius, self.gridColor)
			fromX = fromX + self.cellWidth
			toX   = toX   + self.cellWidth
		end

		fromX = leftColumn * self.cellWidth
		fromY = bottomRow * self.cellHeight
		toX   = rightColumn * self.cellWidth
		toY   = bottomRow * self.cellHeight
		for colum = bottomRow, topRow do
			self.backGrid:drawSegment(ccp(fromX, fromY), ccp(toX, toY), self.gridRadius, self.gridColor)
			fromY = fromY + self.cellHeight
			toY   = toY   + self.cellHeight
		end
	end
end

function TFTableViewEx:updateShowCell()
	local size = self:getSize()
	local p = self:convertToWorldSpace(ccp(size.width / 2, size.height / 2))
	p = self.innerContainer:convertToNodeSpace(p)
	local x = self.x + p.x
	local y = self.y + p.y
	local row
	local column
	if self.orien == CCTMXOrientationIso then
		row = math.floor(self.rows / 2 - x / self.cellWidth + y / self.cellHeight)
		column = math.floor(-self.columns / 2 + x / self.cellWidth + y / self.cellHeight + 1)
	else
		column = math.floor((x + self.cellWidth / 2) / self.cellWidth)
		row = math.floor((y + self.cellHeight / 2) / self.cellHeight)
	end
	self.showingCell = self.grid[column .. "_" .. row]
end

function TFTableViewEx:getCell(row, col)
	return self.grid[col-1 .. "_" .. row-1]
end

function TFTableViewEx:ctor(width, height)
	self.grid = {}
	self.cells = TFArray:new()

	self.cellAt = nil
	self.clickFunc = nil
	self.moveCompleted = nil
	self.isLoop = true
	self:addEvent()
end

function TFTableViewEx:create(width, height)
	local  tableView = TFTableViewEx:new(width, height)
	return tableView
end

function TFTableViewEx:setCellSize(width, height)
	self.cellWidth = width
	self.cellHeight = height
end

function TFTableViewEx:setRows(rows)
	self.rows = rows
end

function TFTableViewEx:setColumns(columns)
	self.columns = columns
end

function TFTableViewEx:cellAtPos(x , y)
	local column = -self.columns / 2 + x / self.cellWidth + y / self.cellHeight
	local row = self.rows / 2 - x / self.cellWidth + y / self.cellHeight
	return ccp(column, row)
end

function TFTableViewEx:checkPosition(x, y)
	local size = self:getSize()
	local p = self:convertToWorldSpace(ccp(size.width/2, size.height))
	local top = self.innerContainer:convertToNodeSpace(p)

	local w = self.rows * self.cellWidth
	local h = self.columns * self.cellHeight
	self.x = x
	self.y = y
	if self.isLoop then
		self.x = (x + w) % (w)
		self.y = (y + h) % (h)
	else
		if self.x < 0 then self.x = 0 end
		if self.y < 0 then self.y = 0 end
		if self.x > w - size.width then self.x = w - size.width end
		if self.y > h - top.y then self.y = h - top.y end
	end
end

function TFTableViewEx:showIso(x, y)
	-- print("\n-----------showIso: ", x, y)
	self:checkPosition(x, y)

	x = self.x
	y = self.y
	if self.backGrid then
		if self.isLoop then
			self.backGrid:setPosition(ccp(-(x % self.cellWidth), -(y % self.cellHeight)))
		else
			self.backGrid:setPosition(ccp(-x, -y))
		end
	end

	if self.moveNode then
		if self.isLoop then
			self.moveNode:setPosition(ccp(-(x % self.cellWidth), -(y % self.cellHeight)))
		else
			self.moveNode:setPosition(ccp(-x, -y))
		end
	end

	if self.mapBg then
		local size = self.mapBg:getSize()
		self.mapBg:setTextureRect(ccr(self.x%self.bgMapSize.width, self.bgMapSize.width-self.y%self.bgMapSize.width, size.width, size.height));
	end

	self:showIsoMapCorner(self.x, self.y)
	local size = self:getSize()

	local leftColumn  = math.floor(self:cellAtPos(self.x, self.y).x)
	local rightColumn = math.ceil(self:cellAtPos(self.x + size.width, self.y + size.height).x) + 6
	local bottomRow   = math.floor(self:cellAtPos(self.x + size.width, self.y).y)
	local topRow 	  = math.ceil(self:cellAtPos(self.x, self.y + size.height).y) + 5
	-- print(leftColumn, rightColumn, bottomRow, topRow)
	
	local baseX = self.cellWidth /2 * (self.columns + leftColumn - bottomRow - 1)
	local baseY = self.cellHeight / 2 * (bottomRow + leftColumn)
	baseX = baseX - self.x
	baseY = baseY - self.y
	local zEye = me.Director:getZEye()
	local addDisY = size.height * size.height / (2 * zEye)
	local addDisX = size.height * size.width / (4 * zEye)
	local leftX = -2*self.cellWidth - addDisX
	local rightX = size.width + 2*self.cellWidth + addDisX
	local bottomY = -self.cellHeight
	local topY = size.height + addDisY + 2*self.cellHeight

	local screenSize = me.EGLView:getDesignResolutionSize()
	local tr = self.innerContainer:convertToNodeSpace(ccp(screenSize.width, screenSize.height))
	local tl = self.innerContainer:convertToNodeSpace(ccp(0, screenSize.height))
	local br = self.innerContainer:convertToNodeSpace(ccp(screenSize.width, 0))
	local bl = self.innerContainer:convertToNodeSpace(ccp(0, 0))
	local angerTan = (tr.x - br.x) /(tr.y - br.y) 

	local cellNum = self.cells:length()
	local cell = nil
	local index = 1
	local an = self:getAnchorPoint()
	for i = leftColumn, rightColumn do
		local column = i
		if self.isLoop then
			column = (i + self.columns) % self.columns
		end
		if column >= 0 and column < self.columns then
			for j = bottomRow, topRow do
				local row = j
				if self.isLoop then
					row = (j + self.rows) % self.rows
				end
				if row >= 0 and row < self.rows then
					x = baseX + (i - leftColumn - (j - bottomRow)) * self.cellWidth / 2
					y = baseY + (j - bottomRow + i - leftColumn) * self.cellHeight / 2
					if y + self.cellHeight > bottomY and y < topY	and x + self.cellWidth > leftX and x < rightX then
						if self.grid[column .. "_" .. row] ~= nil then
							cell = self.grid[column .. "_" .. row]
							if cell == self.selectedCell then
								cell:setVisible(true)
							end
						else
							if self.cells:length() > 0 then
								cell = self.cells:pop()
								cell = self.cellAt(cell, column+1, row+1)
								cell:setVisible(true)
							else
								cell = self.cellAt(nil, column+1, row+1)
								self.innerContainer:addChild(cell)
								cell:setSize(ccs(self.cellWidth, self.cellHeight))
								cell:setRotationX3D(self.slopeAngle)
							end
							
							cell.column = column+1
							cell.row = row+1
							self.grid[column .. "_" .. row] = cell
						end

						cell.needRetain = true
						-- an = cell:getAnchorPoint()
						-- cell:setPosition(ccp(x + self.cellWidth * an.x, y + self.cellHeight * an.y))
						cell:setPosition(ccp(x, y))
						cell:setZOrder(10000 - y)

						local offsetX = (y - br.y)*angerTan
						if y + self.cellHeight > 0 and y < tr.y and x + self.cellWidth > bl.x - offsetX and x < br.x +offsetX then
							if self.changeCells == "" then
								self.changeCells = row+1 .. "_" .. column+1
							else
								self.changeCells = self.changeCells .. "," .. row+1 .. "_" .. column+1
							end
						end
					end
				end
			end
		end
	end

	for key, val in pairs(self.grid) do
		if not val.needRetain then
			val:setVisible(false)
			if val ~= self.selectedCell then
				self.cells:pushBack(val)
				if self.isRemoveChild then
					val:removeAllChildren()
				end
				self.grid[key] = nil
			end
		end
		val.needRetain = false
	end
end

function TFTableViewEx:removeAllCell()
	for k,v in pairs(self.grid) do
		v:setVisible(false)
		self.cells:pushBack(v)
		v:removeAllChildren()
	end
	self.grid = {}
end

function TFTableViewEx:addChildOnMap(node)
	if not self.moveNode then
		self.moveNode = TFPanel:create()
		self.moveNode:setZOrder(10001)
		self.innerContainer:addChild(self.moveNode)
		if self.isLoop then
			self.moveNode:setPosition(ccp(-(self.x % self.cellWidth), -(self.y % self.cellHeight)))
		else
			self.moveNode:setPosition(ccp(-self.x, -self.y))
		end
	end

	self.moveNode:addChild(node)
end

function TFTableViewEx:show(x, y)

	if self.orien == CCTMXOrientationIso then
		self:showIso(x, y)
		return
	end

	if self.backGrid then
		if self.isLoop then
			self.backGrid:setPosition(ccp(-(x % self.cellWidth), -(y % self.cellHeight)))
		else
			self.backGrid:setPosition(ccp(-x, -y))
		end
	end

	if self.moveNode then
		if self.isLoop then
			self.moveNode:setPosition(ccp(-(x % self.cellWidth), -(y % self.cellHeight)))
		else
			self.moveNode:setPosition(ccp(-x, -y))
		end
	end

	if self.mapBg then
		local size = self.mapBg:getSize()
		self.mapBg:setTextureRect(ccr(x%self.bgMapSize.width, self.bgMapSize.width-y%self.bgMapSize.width, size.width, size.height));
	end

	size = self:getSize()
	self.x = (x + self.rows * self.cellWidth) % (self.rows * self.cellWidth)
	self.y = (y + self.columns * self.cellHeight) % (self.columns * self.cellHeight)
	local baseX = -math.floor(self.x % self.cellWidth)
	local baseY = -math.floor(self.y % self.cellHeight)

	local leftColumn = math.floor(self.x / self.cellWidth) - 4
	local rightColumn = math.ceil((self.x + size.width) / self.cellWidth) + 4
	local bottomRow = math.floor(self.y / self.cellHeight) - 4
	local topRow = math.ceil((self.y + size.height) / self.cellHeight) + 4
	local cellNum = self.cells:length()
	local cell = nil
	local index = 1

	local screenSize = me.EGLView:getDesignResolutionSize()
	local tr = self.innerContainer:convertToNodeSpace(ccp(screenSize.width, screenSize.height))
	local tl = self.innerContainer:convertToNodeSpace(ccp(0, screenSize.height))
	local br = self.innerContainer:convertToNodeSpace(ccp(screenSize.width, 0))
	local bl = self.innerContainer:convertToNodeSpace(ccp(0, 0))
	local angerTan = (tr.x - br.x) /(tr.y - br.y) 

	for i = leftColumn, rightColumn do
		local column = i % self.columns
		for j = bottomRow, topRow do
			local row = j % self.rows
			if self.grid[column .. "_" .. row] ~= nil then
				cell = self.grid[column .. "_" .. row]
				if cell == self.selectedCell then
					cell:setVisibled(true)
				end
			else
				if self.cells:length() > 0 then
					cell = self.cells:pop()
					cell = self.cellAt(cell, column+1, row+1)
					cell:setVisibled(true)
				else
					cell = self.cellAt(nil, column+1, row+1)
					self.innerContainer:addChild(cell)
					-- cell:setSize(ccs(self.cellWidth + 1, self.cellHeight + 1))
				end
				
				cell.column = column+1
				cell.row = row+1
				self.grid[column .. "_" .. row] = cell
			end

			local offsetX = (y - br.y)*angerTan
			if y + self.cellHeight > 0 and y < tr.y and x + self.cellWidth > bl.x - offsetX and x < br.x +offsetX then
				if self.changeCells == "" then
					self.changeCells = row+1 .. "_" .. column+1
				else
					self.changeCells = self.changeCells .. "," .. row+1 .. "_" .. column+1
				end
			end

			cell.val = 1 - self.val
			cell:setPosition(ccp(baseX + (i - leftColumn - 4) * self.cellWidth, baseY + (j - bottomRow - 4) * self.cellHeight))
		end
	end
	self.val = 1 - self.val
	for key, val in pairs(self.grid) do
		--todo
		if val.val ~= self.val then
			val:setVisibled(false)
			if val ~= self.selectedCell then
				self.cells:pushBack(val)
				if self.isRemoveChild then
					val:removeAllChildren()
				end
				self.grid[key] = nil
			end
		end
	end
end

function TFTableViewEx:showCell(row, col)
	-- print("showCell")
	row = row - 1
	col = col - 1
	local x = 0
	local y =0
	local size = self:getSize()
	if self.orien == CCTMXOrientationIso then
		x = (self.columns - row + col) * self.cellWidth / 2
 		y = (row + col + 1) * self.cellHeight / 2
	else
		x = self.cellWidth * col
		y = self.cellHeight * row
	end
	local p = self:convertToWorldSpace(ccp(size.width / 2, size.height / 2))
	p = self.innerContainer:convertToNodeSpace(p)
	self.changeCells = ""
	self:show(x - p.x, y - p.y)
	self.showingCell = self.grid[col .. "_" .. row]
	if self.moveCompleted then
		self.moveCompleted(self.changeCells)
	end
end

function TFTableViewEx:gotoCell(row, col, time, nFunc)
	-- print("showCell")
	if time == nil or time <= 0 then
		showCell(row, col)
		return
	end
	row = row - 1
	col = col - 1
	local x = 0
	local y =0
	local size = self:getSize()
	if self.orien == CCTMXOrientationIso then
		x = (self.columns - row + col) * self.cellWidth / 2
 		y = (row + col + 1) * self.cellHeight / 2
	else
		x = self.cellWidth * col
		y = self.cellHeight * row
	end
	local p = self:convertToWorldSpace(ccp(size.width / 2, size.height / 2))
	p = self.innerContainer:convertToNodeSpace(p)
	local dx = x - p.x
	local dy = y - p.y
	dx = dx - self.x
	dy = dy - self.y
	x = self.x
	y =self.y
	local totalTime = 0
	local function enterFrame(dt)
		-- print(dt)
		totalTime = totalTime + dt
		if totalTime >= time then
			self:show(x + dx, y + dy)
			self.showingCell = self.grid[col .. "_" .. row]
			if nFunc then
				nFunc(self.showingCell)
			end
			TFDirector:removeEnterFrameEvent(enterFrame)
		else
			self:show(x + dx * totalTime / time, y + dy * totalTime / time)
		end
	end
	TFDirector:addEnterFrameEvent(enterFrame)
end

function TFTableViewEx:setOrientation(nOrien)
	self.orien = nOrien
end

function TFTableViewEx:addMELuaListener(type, func)
	print("addMELuaListener", type, func)
	if type == TFTABLEVIEWEX_CLICK then
		self.clickFunc = func
		print("self.clickFunc", self.clickFunc)
	elseif type == TFTABLEVIEWEX_CELLAT then
		self.cellAt = func
	elseif type == TFTABLEVIEWEX_MOVECOMPLETED then
		self.moveCompleted = func
	end
end

function TFTableViewEx:removeMELuaListener(type)
	if type == TFTABLEVIEWEX_CLICK then
		self.clickFunc = nil
	elseif type == TFTABLEVIEWEX_CELLAT then
		self.cellAt = nil
	elseif type == TFTABLEVIEWEX_MOVECOMPLETED then
		self.moveCompleted = nil
	end
end

function TFTableViewEx:setMoveLoop(bLoop)
	self.isLoop = bLoop
	if self.backGrid then
		self:drawGrid()
	end
end

function TFTableViewEx:isMoveLoop(bLoop)
	return self.isLoop
end

function TFTableViewEx:setDesignResolutionSize(width, height, policy)
	local size = me.EGLView:getDesignResolutionSize()
	policy = policy or TF_RESOLUTION_SHOW_ALL
	self:_setDesignResolutionSize(width, height, policy)
	local scaleX, scaleY = self:getScaleX(), self:getScaleY()
	self:setPosition(ccp( (size.width - width*scaleX) / 2, (size.height - height*scaleY) / 2))
	print(self:getPosition())
	self.touchPanel:setPosition(ccp(self:convertToNodeSpace(ccp(0, 0))))
	if self.mapBg then
		local panel = self.touchPanel:getSize()
		p = self:convertToWorldSpace(ccp(0, 0))
		local bl = self.innerContainer:convertToNodeSpace(p)

		p = self:convertToWorldSpace(ccp(0, size.height))
		local tl = self.innerContainer:convertToNodeSpace(p)
		self.mapBg:setPosition(ccp(tl.x - self:getPosition().x, bl.y - self:getPosition().y))
	end
end

function TFTableViewEx:setIsoMapCornerTex(pszCornerImgFile)
	self.pszCornerImgFile = pszCornerImgFile
end

function TFTableViewEx:setTopCornerTex(pszTopCornerTex)
	self.pszTopCornerTex = pszTopCornerTex
end

function TFTableViewEx:setBottomCornerTex(pszBottomCornerTex)
	self.pszBottomCornerTex = pszBottomCornerTex
end

function TFTableViewEx:setCornerImgVisible(_bVivible)
	if self.imgMapCornerVec then
		for i,v in ipairs(self.imgMapCornerVec) do
			v:setVisible(_bVivible)
		end
	end
end

function TFTableViewEx:showIsoMapCorner(x, y)
	if (not self.pszTopCornerTex and not self.pszBottomCornerTex) or self.isLoop then
		return
	end

	local w = self.rows * self.cellWidth
	local h = self.columns * self.cellHeight

	local pszCornerImgFile = self.pszTopCornerTex	

	local function get_avail_map_corner(_nCurCorner)
		if not self.imgMapCornerVec then
			self.imgMapCornerVec = {}
		end

		if not self.imgMapCornerVec[_nCurCorner] then
			local img = TFImage:create( pszCornerImgFile )
			img:setAnchorPoint(ccp(0, 0))
			self.mapBg:addChild(img)
			self.imgMapCornerVec[_nCurCorner] = img
		end

		return self.imgMapCornerVec[_nCurCorner]
	end

	local size = self:getSize()
	local screenSize = me.EGLView:getDesignResolutionSize()
	
	local p = self:convertToWorldSpace(ccp(size.width/2, size.height))
	local top = self.innerContainer:convertToNodeSpace(p)

	local imgCorner = get_avail_map_corner(1)
	imgCorner:setPosition(ccp(-1000, -1000))
	local nCornerW = imgCorner:getSize().width
	local nCornerH = imgCorner:getSize().height
	local screenCornerHeight = self.mapBg:convertToWorldSpace(ccp(0, nCornerH))

	local nCurCorner = 1
	if x < nCornerW then
		if y < nCornerH then
			local img = get_avail_map_corner(nCurCorner)
			local localPos = self.mapBg:convertToNodeSpace(ccp(0, screenCornerHeight.y))	
			img:setTexture(self.pszBottomCornerTex)
			img:setPosition(ccp(-x + localPos.x, -y))
			img:setScaleX(1)
			nCurCorner = nCurCorner + 1
		end
		
		if y + size.height >  h - nCornerH then
			local img = get_avail_map_corner(nCurCorner)
			local localPos = self.mapBg:convertToNodeSpace(ccp(0, screenSize.height))	
			img:setTexture(self.pszTopCornerTex)
			img:setPosition(ccp(-x + localPos.x,  -y + h - top.y + localPos.y - nCornerH))
			img:setScaleX(1)
			nCurCorner = nCurCorner + 1
		end
	end

	if x + size.width > w - nCornerW then
		if y < nCornerH then
			local img = get_avail_map_corner(nCurCorner)
			local localPos = self.mapBg:convertToNodeSpace(ccp(screenSize.width, screenCornerHeight.y))		
			img:setTexture(self.pszBottomCornerTex)
			img:setPosition(ccp(w - size.width - x + localPos.x , -y))
			img:setScaleX(-1)
			nCurCorner = nCurCorner + 1
		end

		if y + size.height > h - nCornerH then
			local localPos = self.mapBg:convertToNodeSpace(ccp(screenSize.width, screenSize.height))		
			local img = get_avail_map_corner(nCurCorner)
			img:setTexture(self.pszTopCornerTex)
			img:setPosition(ccp(w - size.width - x + localPos.x, -y + h - top.y + localPos.y - nCornerH))
			img:setScaleX(-1)
			nCurCorner = nCurCorner + 1
		end
	end
end

return TFTableViewEx
