return { new = function(params)
local Mmodel = require "src/component/selector/model"
local Mnumber = require "src/component/number/view"
------------------------------------------------------------------------------------
local res = "res/component/selector/"
------------------------------------------------------------------------------------
local bg = Mnode.createSprite( { src = res .. "2.png", } )
local bgSize = bg:getContentSize()
local bgCenter = cc.p(bgSize.width/2, bgSize.height/2)
------------------------------------------------------------------------------------
local paddingLR = 2
local selector = YGirdView:create( cc.size(bgSize.width - 2 * paddingLR, bgSize.height) )
selector:setDirection(YScrollView.HORIZONTAL)
Mnode.addChild(
{
	parent = bg,
	child = selector,
	pos = bgCenter,
	zOrder = 1,
})

Mnode.addChild(
{
	parent = bg,
	child = cc.Sprite:create( res .. "1.png"),
	pos = bgCenter,
	zOrder = 2,
})

local M = Mnode.beginNode(selector)
------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------
getRootNode = function(self)
	return self:getParent()
end

value = function(self)
	return self.mModel:currentValue()
end

local notify = function(self)
	local handler = self.onValueChanged
	if type(handler) == "function" then
		handler( self, self:value() )
	end
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
	
	if centerIdx ~= -1 then
		local cell = gird:cellAtIndex(centerIdx)
		local content = cell:getChildByTag(9)
		
		if content then
			content:setScale(1.25)
			if centerIdx ~= gird.mfocused then
				if gird.mfocused then
					local old = gird:cellAtIndex(gird.mfocused)
					if old then
						local content = old:getChildByTag(9)
						if content then content:setScale(1) end
					end
				end
				-------------------------
				gird.mfocused = centerIdx
				gird.mModel:currentPosition( idxExcludePadding(gird, centerIdx) )
				
				if gird.ready then notify(gird) end
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
		Mnode.addChild(
		{
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


onValueChanged = params.onValueChanged

refresh = function(self, params)
	self.mModel = Mmodel.new(params)
	local save = self.mModel:currentPosition()
	
	self.ready = false
	self:reloadData() -- 必不可少
	self.ready = true
	
	self.mModel:currentPosition(save)
	self:setContentOffset( calculateAlignPoint( self, idxIncludePadding(self, save) ) )
	notify(self)
end; selector:refresh(params)
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
return selector

end }