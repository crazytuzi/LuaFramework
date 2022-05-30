local TableLayout = class("TableLayout", function ()
	return display:newNode()
end)

function TableLayout:ctor(param)
	self._width = param.width
	self._height = param.height
	self._rowNum = param.rowNum
	self._bgNode = display.newNode()
	self._bgNode:setPosition(0, self._height)
	self:addChild(self._bgNode)
	self:setColor(cc.c3b(255, 0, 0))
	assert(self._rowNum ~= 0, "row num = 0!!")
	self._posX = {}
	for i = 1, self._rowNum do
		self._posX[i] = (i * 2 - 1) / (self._rowNum * 2) * self._width
	end
	self._nodes = {}
	self._viewW = param.width
	self._viewH = param.height
	self:setContentSize(CCSizeMake(self._width, self._height))
end

function TableLayout:getContentSize()
	return CCSizeMake(self._width, self._height)
end

function TableLayout:getNodes()
	return self._nodes
end

function TableLayout:addChildEx(child)
	table.insert(self._nodes, child)
	local posX
	local index = #self._nodes % self._rowNum
	if index == 0 then
		posX = self._posX[self._rowNum]
	else
		posX = self._posX[index]
	end
	local row = math.ceil(#self._nodes / self._rowNum)
	local h = 0
	for i = 1, row do
		h = h + self._nodes[1 + (i - 1) * self._rowNum]:getContentSize().height + 4
	end
	self._bgNode:addChild(child)
	if h > self._height then
		self._height = h
		self:setContentSize(CCSizeMake(self._width, self._height + 5))
	end
	child:setScale(0)
	child:setPosition(CCPointMake(posX, -h + self._nodes[1 + (row - 1) * self._rowNum]:getContentSize().height / 2))
	self._bgNode:setPosition(0, h + 5)
	child:runAction(transition.sequence({
	CCScaleTo:create(0.2, 1)
	}))
end

return TableLayout