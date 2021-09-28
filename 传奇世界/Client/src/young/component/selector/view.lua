
return { new = function(params)
local Mnode = require "src/young/node"
local Mmodel = require "src/young/component/selector/model"
local Mnumber = require "src/young/component/number/view"
------------------------------------------------------------------------------------
local bg = Mnode.createSprite( { src = "res/component/selector/2.png", } )
local bgSize = bg:getContentSize()
local paddingLR = 2
local bgCenterX, bgCenterY = bgSize.width/2, bgSize.height/2
local selector = YGirdView:create( cc.size(bgSize.width - 2 * paddingLR, bgSize.height) )
selector:setDirection(YScrollView.HORIZONTAL)
Mnode.addChild({
	parent = bg,
	child = selector,
	pos = cc.p(bgCenterX, bgCenterY),
})

local M = Mnode.beginNode(selector)

value = function(self)
	return self.mModel:currentValue()
end

mValueChangedHandler = nil
local notify = function(self)
	if not self.mValueChangedHandler then return end
	if self.mUnderway then
		if not self.mAgain then self.mAgain = true end
		return
	end
	
	self.mUnderway = true
	self.mValueChangedHandler( self, self:value() )
	self.mUnderway = false
	
	if self.mAgain then
		self.mUnderway = true
		self.mValueChangedHandler( self, self:value() )
		self.mUnderway = false
		self.mAgain = false
	end
end

onValueChanged = function(self, handler)
	if type(handler) == "function" and
	   self.mValueChangedHandler ~= handler then
		self.mValueChangedHandler = handler
		notify(self)
	else
		return self.mValueChangedHandler
	end
end

local focus = Mnode.createSprite({
	src = "res/component/selector/1.png",
	parent = bg,
	pos = cc.p(bgCenterX, bgCenterY),
})

mCellH = bgSize.height
mCellW = 97

local adjustCellW = function(selector)
	local halfViewSizeW = selector:getViewSize().width/2
	local halfCellW = selector.mCellW/2
	local count = math.ceil(halfViewSizeW/halfCellW)
	if count % 2 ~= 1 then count = math.max(count - 1, 1) end
	selector.mPadding = (count - 1)/2
	selector.mCellW = halfViewSizeW/count * 2
end; adjustCellW(selector)


getRootNode = function(self)
	return self:getParent()
end
------------------------------------------------------------------------------------
mNumberBuilder = Mnumber.new("res/component/number/1.png")
------------------------------------------------------------------------------------
-- gird view
local getIndexFromPoint = function(gird)
	local point = gird:convertToWorldSpaceAR( cc.p(0, 0) )
	point = gird:getContainer():convertToNodeSpace(point)
	return gird:getIndexFromPoint(point), point
end

local calculateAlignPoint = function(gird, align)
	local idx, point = getIndexFromPoint(gird)
	local x, y = gird:getPositionFromIndex(align or idx)
	local offset = point.x - (x + gird.mCellW/2)
	x, y = gird:getContainer():getPosition()
	return cc.p(x + offset, y)
end

local isInvalidBound = function(gird, idx)
	return idx < gird.mPadding or
		   idx >= gird.mPadding + gird.mModel:count()
end

local idxExcludePadding = function(gird, idx)
	return idx - gird.mPadding
end

local idxIncludePadding = function(gird, idx)
	return idx + gird.mPadding
end
------------------------------------------------------------------------------------
local VIEW_SCROLL = function(gird)
	local centerIdx = getIndexFromPoint(gird)
	if gird.mfocused then
		local old = gird:cellAtIndex(gird.mfocused)
		if old then
			local content = old:getChildByTag(9)
			if content then content:setScale(1) end
		end
	end
	
	if centerIdx ~= -1 then
		local cell = gird:cellAtIndex(centerIdx)
		local content = cell:getChildByTag(9)
		
		if content then
			content:setScale(1.25)
			if centerIdx ~= gird.mfocused then
				gird.mfocused = centerIdx
				gird.mModel:currentPosition( idxExcludePadding(gird, centerIdx) )
				notify(gird)
			end
		end
	end
end

local VIEW_STOPPED = function(gird)
	gird:setContentOffset(calculateAlignPoint(gird), true)
end

local IS_CELLSIZE_IDENTICAL = function(gird)
	return true
end

local SIZE_FOR_CELL = function(gird, idx)
	return gird.mCellW, gird.mCellH
end

local NUMS_IN_GIRD = function(gird)
	return gird.mModel:count() + gird.mPadding * 2
end

local CELL_AT_INDEX = function(gird, idx)
	local width, height = SIZE_FOR_CELL(gird, idx)
	
	local createContent = function(cell)
		if isInvalidBound(gird, idx) then return end
		local number = gird.mModel:numberAtPosition( idxExcludePadding(gird, idx) )
		Mnode.addChild({
			parent = cell,
			child = gird.mNumberBuilder:create(number, -1),
			pos = cc.p(width/2, height/2),
			tag = 9,
		})
	end
	
	local cell = gird:dequeueCell()
	if not cell then
		cell = YGirdViewCell:create()
		cell:setContentSize(width, height)
		createContent(cell)
	else
		createContent(cell)
	end
	
	return cell
end

local CELL_WILL_RECYCLE = function(gird, cell)
	cell:removeAllChildren()
end

local initGirdView = function(gird)
	gird:registerEventHandler(CELL_WILL_RECYCLE, YGirdView.CELL_WILL_RECYCLE)
	gird:registerEventHandler(IS_CELLSIZE_IDENTICAL, YGirdView.IS_CELLSIZE_IDENTICAL)
	gird:registerEventHandler(SIZE_FOR_CELL, YGirdView.SIZE_FOR_CELL)
	gird:registerEventHandler(CELL_AT_INDEX, YGirdView.CELL_AT_INDEX)
	gird:registerEventHandler(NUMS_IN_GIRD, YGirdView.NUMS_IN_GIRD)
	gird:registerEventHandler(VIEW_SCROLL, YGirdView.VIEW_SCROLL)
	gird:registerEventHandler(VIEW_STOPPED, YGirdView.VIEW_STOPPED)
	gird:setDelegate()
end; initGirdView(selector)

refresh = function(self, params)
	self.mModel = Mmodel.new(params)
	local save = self.mModel:currentPosition()
	self:reloadData() -- 必不可少
	self.mModel:currentPosition(save)
	self:setContentOffset( calculateAlignPoint( self, idxIncludePadding(self, save) ) )
	notify(self)
end; selector:refresh(params)

return selector

end }