local HandBookScroll = class("HandBookScroll", function(data)
	return display.newNode()
end)

function HandBookScroll:ctor(param)
	local data = param.data
	local size = param.size
	local scrollNode = display.newColorLayer(cc.c4b(100, 200, 50, 0))
	local scrollViewBg = CCScrollView:create()
	self:addChild(scrollViewBg)
	self._index = 0
	self._touchs = {}
	self.cellTable = {}
	local orY = 0
	local orX = size.width / 2
	local curX = orX
	local curY = orY
	local scrollHeight = 0
	
	for i = 1, #data do
		local cell = require("game.HandBook.HandBookCell").new({
		cellData = data[i],
		_touchs = self._touchs,
		})
		self.cellTable[#self.cellTable + 1] = cell
		scrollHeight = scrollHeight + cell:getHeight()
		scrollNode:addChild(cell)
		
		for i = 1, #cell._touchs do
			table.insert(self._touchs, cell._touchs[i])
		end
		cell._touchs = nil
	end
	
	curY = orY + scrollHeight
	for i = 1, #self.cellTable do
		if i ~= 1 then
			curY = curY - self.cellTable[i - 1]:getHeight()
		end
		self.cellTable[i]:setPosition(curX, curY)
	end
	scrollViewBg:setViewSize(cc.size(size.width, size.height - 50))
	scrollViewBg:ignoreAnchorPointForPosition(true)
	scrollViewBg:setContainer(scrollNode)
	scrollNode:setContentSize(cc.size(size.width, scrollHeight))
	scrollViewBg:setContentSize(cc.size(size.width, scrollHeight))
	scrollViewBg:updateInset()
	local min = scrollViewBg:minContainerOffset()
	scrollViewBg:setContentOffset(min, false)
	scrollViewBg:setDirection(kCCScrollViewDirectionVertical)
	scrollViewBg:setClippingToBounds(true)
	scrollViewBg:setBounceable(true)
	scrollViewBg:setAnchorPoint(cc.p(0.5, 0))
end

function HandBookScroll:setVisibleEnable(able)
	for i = 1, #self._touchs do
		--print("sssssssssssssssssssssssssssss"..i)
		self._touchs[i]:setTouchEnabled(able)
	end
end

return HandBookScroll