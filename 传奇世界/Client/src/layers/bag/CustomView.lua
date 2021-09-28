return { new = function(params)
----------------------------------------------------------------
local res = "res/layers/bag/"
local focusRes = "res/common/21.png"
----------------------------------------------------------------
-- 参数
local params = params or {}
local bg = params.bg
local gridSize = params.gridSize or TextureCache:addImage(focusRes):getContentSize()
local memory = params.memory
----------------------------------------------------------------
local MtradeOp = require "src/layers/trade/tradeOp"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
----------------------------------------------------------------
local layout = nil
local calculateLayout = function()
	layout = params.layout or {}
	if not layout.row then layout.row = 4.5 end
	if not layout.col then layout.col = 5 end
	
	layout.row = math.max(layout.row, 1)
	layout.col = math.max( math.floor(layout.col), 1 )
end; calculateLayout()
local viewSize = cc.size(gridSize.width * layout.col, gridSize.height * layout.row)
---------------------------
local marginLR, marginUD = params.marginLR or 5, params.marginUD or 5
local gridViewBgSize = cc.size(viewSize.width + 2 * marginLR, viewSize.height + 2 * marginUD)
----------------------------------------------------------------
local root = nil
if bg then 
	root = Mnode.createScale9Sprite({ src = bg, cSize = gridViewBgSize, })
else
	root = Mnode.createNode({cSize = gridViewBgSize})
end
----------------------------------------------------------------
-- 数据
----------------------------------------------------------------
local gridView = YGirdView:create(viewSize)
gridView:viewSizeSelfAdaption(false)
Mnode.addChild(
{
	parent = root,
	child = gridView,
	pos = cc.p(gridViewBgSize.width/2, gridViewBgSize.height/2),
})

local M = Mnode.beginNode(gridView)

getBgNode = function(this)
	return this:getParent()
end
----------------------------------------------------------------
-- 滚动事件
local VIEW_SCROLL = function(gv)
	gv.scroll_pos = gv:getContentOffset()
    ------------------------------------------------------
	if type(gv.onScrolled) == "function" then gv.onScrolled(gv, gv:getContentOffset()) end
end
----------------------------------------------------------------
getFocusNode = function(gv)
	local focusNode = gv.mFocusNode
	if not focusNode then
		focusNode = Mnode.addChild(
		{
			parent = gv,
			child = cc.Sprite:create(focusRes),
			pos = cc.p(0, 0),
			zOrder = 1, -- 确保在上层
			hide = true,
		})
		gv.mFocusNode = focusNode
	end
	return focusNode
end

local CELL_HIGHLIGHT = function(gv, cell)
	local idx = cell:getIdx()
	--dump("idx="..idx, "-----CELL_HIGHLIGHT-----")
	if type(gv.onCellHighLight) == "function" then gv.onCellHighLight(gv, idx, cell) end
end
	
local CELL_UNHIGHLIGHT = function(gv, cell)
	local idx = cell:getIdx()
	--dump("idx="..idx, "-----CELL_UNHIGHLIGHT-----")
	if type(gv.onCellUnhighLight) == "function" then gv.onCellUnhighLight(gv, idx, cell) end
end

-- 单击事件
local CELL_TOUCHED = function(gv, cell)
	local idx = cell:getIdx()
	dump("idx="..idx, "-----CELL_TOUCHED-----")
	
	local x, y = cell:getPosition()
	local size = cell:getContentSize()
	local newX, newY = (x + size.width/2), (y + size.height/2)
	
	local focusNode = gv:getFocusNode()
	if idx ~= gv.mFocused then
		focusNode:setVisible(true)
		focusNode:setPosition(newX, newY)
		gv.mFocused = idx
	end
	------------------------------------------------------
	if type(gv.onCellTouched) == "function" then gv.onCellTouched(gv, idx, cell) end
end

local CELL_LONG_TOUCHED = function(gv, cell)
	local idx = cell:getIdx()
	--dump("idx="..idx, "-----CELL_LONG_TOUCHED-----")
	if type(gv.onCellLongTouched) == "function" then gv.onCellLongTouched(gv, idx, cell) end
end

touchCellAtIndex = function(this, idx)
    CELL_TOUCHED(this, this:cellAtIndex(idx))
end

focusd = function(this)
	return this.mFocused
end

disableFocusd = function(this)
	this.mFocused = nil
	local focusNode = this:getFocusNode()
	focusNode:setVisible(false)
end
----------------------------------------------------------------
-- 每个网格是否一样大小
local IS_CELLSIZE_IDENTICAL = function(gv)
	return true
end
----------------------------------------------------------------
-- 每个网格的大小
local SIZE_FOR_CELL = function(gv, idx)
	return gridSize.width, gridSize.height
end
----------------------------------------------------------------
-- 网格总数
local NUMS_IN_GIRD = function(gv)
	if type(gv.numsInGrid) == "function" then 
		return gv.numsInGrid(gv)
	else
		return 0
	end
end
----------------------------------------------------------------
-- 一组的网格数目
local NUMS_IN_GROUP = function(gv)
	return layout.col
end
----------------------------------------------------------------
-- 构建标号为idx的网格
local CELL_AT_INDEX = function(gv, idx)
	--dump("idx="..idx, "-----CELL_AT_INDEX-----")
	local width, height = SIZE_FOR_CELL(gv, idx)
	
	local createContent = function(gv, idx, cell)
		local cellSize = cell:getContentSize()
		local cellCenter = cc.p(cellSize.width/2, cellSize.height/2)
		
		-- 网格底板
		Mnode.createSprite(
		{
			src = "res/common/bg/itemBg.png",
			parent = cell,
			pos = cellCenter,
		})
		
		if type(gv.onCreateCell) == "function" then gv.onCreateCell(gv, idx, cell) end
	end
	
	local cell = gv:dequeueCell()
	if not cell then
		cell = YGirdViewCell:create()
		cell:setContentSize(width, height)
		createContent(gv, idx, cell)
	else
		createContent(gv, idx, cell)
	end
	
	return cell
end
----------------------------------------------------------------
-- 网格退出视野范围
local CELL_WILL_RECYCLE = function(gv, cell)
	cell:removeAllChildren()
end
----------------------------------------------------------------
-- 重新加载数据
refresh = function(this)
	this:disableFocusd()
	this:unregisterEventHandler(YGirdView.VIEW_SCROLL)
	this:reloadData()
	this:registerEventHandler(VIEW_SCROLL, YGirdView.VIEW_SCROLL)
	local scroll_pos = this.scroll_pos
	if memory and scroll_pos then
		this:setContentOffset(scroll_pos)
	end
end
----------------------------------------------------------------
-- 初始化 gridView
gridView:registerEventHandler(CELL_LONG_TOUCHED, YGirdView.CELL_LONG_TOUCHED)
gridView:registerEventHandler(CELL_TOUCHED, YGirdView.CELL_TOUCHED)
--gridView:registerEventHandler(CELL_HIGHLIGHT, YGirdView.CELL_HIGHLIGHT)
--gridView:registerEventHandler(CELL_UNHIGHLIGHT, YGirdView.CELL_UNHIGHLIGHT)
gridView:registerEventHandler(CELL_WILL_RECYCLE, YGirdView.CELL_WILL_RECYCLE)
gridView:registerEventHandler(IS_CELLSIZE_IDENTICAL, YGirdView.IS_CELLSIZE_IDENTICAL)
gridView:registerEventHandler(SIZE_FOR_CELL, YGirdView.SIZE_FOR_CELL)
gridView:registerEventHandler(CELL_AT_INDEX, YGirdView.CELL_AT_INDEX)
gridView:registerEventHandler(NUMS_IN_GIRD, YGirdView.NUMS_IN_GIRD)
gridView:registerEventHandler(NUMS_IN_GROUP, YGirdView.NUMS_IN_GROUP)
gridView:setDelegate()
----------------------------------------------------------------
----------------------------------------------------------------
-- 定位到某一个物品, 返回物品位置
gridView.locateItem = function(gv, list, protoId)
	local cell_idx = nil
	for i, v in ipairs(list) do
		local id = MPackStruct.protoIdFromGird(v)
		if id ~= nil and protoId == id then
			cell_idx = i - 1
			break
		end
	end
	
	if cell_idx == nil then return end
	
	--dump(cell_idx, "cell_idx")
	local x, y = gv:getPositionFromIndex(cell_idx)
	local width, height = SIZE_FOR_CELL(gv, cell_idx)
	local cp = cc.p(x + width/2, y + height/2)
	local view_size = gv:getViewSize()
	local container = gv:getContainer()
	local container_size = container:getContentSize()
	--local pos_in_world = gv:getParent():convertToWorldSpace(cc.p(view_size.width/2, view_size.height/2))
	local pos_in_world = gv:convertToWorldSpace(cc.p(view_size.width/2, view_size.height/2))
	local pos_in_container = container:convertToNodeSpace(pos_in_world)
	local container_pos = gv:getContentOffset()
	local vector = cc.p(0, pos_in_container.y - cp.y)
	gv:setContentOffset(cc.p(container_pos.x + vector.x, container_pos.y + vector.y))
	container_pos = gv:getContentOffset()
	if container_pos.y > 0 then
		if container_size.height >= viewSize.height then
			gv:setContentOffset(cc.p(0, 0))
		else
			gv:setContentOffset(cc.p(0, viewSize.height-container_size.height))
		end
	elseif container_pos.y < (viewSize.height-container_size.height) then
		gv:setContentOffset(cc.p(0, viewSize.height-container_size.height))
	end
	
	local cell = gv:cellAtIndex(cell_idx)
	--local ret = cell:getParent():convertToWorldSpace(cp)
	--dump(ret, "ret")
	return cell
end
----------------------------------------------------------------	
return gridView
end }