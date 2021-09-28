return { new = function(params)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local Mbaseboard = require "src/functional/baseboard"
local Mprop = require "src/layers/bag/prop"
local MCustomView = require "src/layers/bag/CustomView"
-----------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
local handler = params.handler or function() end
local filtrate = params.filtrate or function(packId, grid)
	return true
end

local act_src = params.act_src
local onCellLongTouched = params.onCellLongTouched
-----------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg27.png",
	close = {
		scale = 1,
	},
	title = {
		src = "选择矿石",
		size = 22,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

local rootSize = root:getContentSize()

Mnode.createScale9Sprite(
{
	parent = root,
	src = "res/common/scalable/setbg.png",
	anchor = cc.p(0.5, 1),
	pos = cc.p(rootSize.width/2, 474),
	cSize = cc.size(380, 452),
})
-----------------------------------------------------------------------
local buildList = function()
	local list = {}
	
	-- 背包
	local bag_list = bag:categoryList(MPackStruct.eOther)
	
	for i, v in ipairs(bag_list) do
		local result, num = filtrate(MPackStruct.eBag, v)
		if result then
			list[#list+1] = { packId = MPackStruct.eBag, grid = v, num = num }
		end
	end
	
	table.sort(list, function(a, b)
		--a
		local a_protoId = MPackStruct.protoIdFromGird(a.grid)
		--local a_purity = MpropOp.purity(a_protoId)
		
		--b
		local b_protoId = MPackStruct.protoIdFromGird(b.grid)
		--local b_purity = MpropOp.purity(b_protoId)
		
		return  a_protoId > b_protoId
	end)
	
	return list
end
local list = buildList()
--dump(list, "list")
-----------------------------------------------------------------------
-- gridView
local layout = { row = 4.7, col = 4, }
local nums = math.max(#list, math.ceil(layout.row) * math.ceil(layout.col))
local gv = MCustomView.new(
{
	--bg = "res/common/68.png",
	layout = layout,
})

gv.numsInGrid = function(gv)
	return nums
end

gv.onCellLongTouched = function(gv, idx, cell)
	local item = list[idx+1]
	if idx >= #list or type(item) ~= "table" then return end
	
	if type(onCellLongTouched) == "function" then
		onCellLongTouched(gv, idx, cell, item)
	elseif type(act_src) == "string" then
		local Mtips = require "src/layers/bag/tips"
		local n_root = nil
		local actions = {}
		actions[#actions+1] = {
			label = act_src,
			cb = function(act_params)
				handler(item)
				if n_root then removeFromParent(n_root) n_root = nil end
				if root then removeFromParent(root) root = nil end
			end,
		}
		
		n_root = Mtips.new({ grid = item.grid, actions = actions })
	else
		local grid = item.grid
		local Mtips = require "src/layers/bag/tips"
		Mtips.new({ grid = grid })
	end
end

gv.onCreateCell = function(gv, idx, cell)
	local item = list[idx+1]
	if idx >= #list or type(item) ~= "table" then return end
	local grid = item.grid
	
	local cellSize = cell:getContentSize()
	local cellCenter = cc.p(cellSize.width/2, cellSize.height/2)
	------------------------------------------------------------
	local num = item.num
	local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	------------------------------------------------------------
	local Mprop = require "src/layers/bag/prop"
	
	local icon = Mprop.new(
	{
		grid = grid,
		num = num,
		showBind = true,
		isBind = isBind,
	})
	
	Mnode.addChild(
	{
		parent = cell,
		child = icon,
		pos = cellCenter,
	})
	
	cell.icon = icon
end

gv.onCellTouched = function(gv, idx, cell)
	local item = list[idx+1]
	if idx >= #list or type(item) ~= "table" then return end
	------------------------------------------------------------
	local grid = item.grid
	local protoId = MPackStruct.protoIdFromGird(grid)
	local MpropOp = require "src/config/propOp"
	AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
	
	local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	local griId = MPackStruct.girdIdFromGird(grid)
	local num = MPackStruct.overlayFromGird(grid)
	
	params.handler(item)
	if root then removeFromParent(root) root = nil end
end

gv:refresh()
	
Mnode.addChild(
{
	parent = root,
	child = gv:getBgNode(),
	anchor = cc.p(0.5, 1),
	pos = cc.p(rootSize.width/2, 474),
})

-- 提示信息
local Msuite = require "src/functional/suite"
local vSize = gv:getViewSize()
local n_tips = Mnode.addChild(
{
	parent = root,
	child = Msuite:createTooltip({ cSize = cc.size(vSize.width, 34), text = "长按物品，显示详细信息" }),
	pos = cc.p(rootSize.width/2, 30),
	zOrder = 1,
})
-----------------------------------------------------------------------
return root
end }