return { new = function(params)
-----------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MequipOp = require "src/config/equipOp"
local Mbaseboard = require "src/functional/baseboard"
local MMenuButton = require "src/component/button/MenuButton"
local Mprop = require "src/layers/bag/prop"
local MCustomView = require "src/layers/bag/CustomView"
-----------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
local dress = MPackManager:getPack(MPackStruct.eDress)
local bank = MPackManager:getPack(MPackStruct.eBank)
-----------------------------------------------------------------------
local now = params.now
local handler = params.handler or function() end
local filtrate = params.filtrate or function(packId, grid, now)
	return true
end

local act_src = params.act_src
local onCellLongTouched = params.onCellLongTouched
-----------------------------------------------------------------------
local root = Mbaseboard.new( 
{
	src = "res/common/bg/bg27.png",
	close = {
		scale = 0.8,
	},
	title = {
		src = "装备选择",
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
	local equips = {}
	
	-- 背包
	local bag_list = bag:filtrate(function(grid)
		return filtrate(MPackStruct.eBag, grid, now)
	end, MPackStruct.eAll)
	
	for i, v in ipairs(bag_list) do
		equips[#equips+1] = { packId = MPackStruct.eBag, grid = v }
	end
	
	-- 着装
	local dress_list = dress:filtrate(function(grid)
		return filtrate(MPackStruct.eDress, grid, now)
	end, MPackStruct.eAll)
	
	for i, v in ipairs(dress_list) do
		equips[#equips+1] = { packId = MPackStruct.eDress, grid = v }
	end
	
	-- 仓库
	local bank_list = bank:filtrate(function(grid)
		return filtrate(MPackStruct.eBank, grid, now)
	end, MPackStruct.eAll)
	
	for i, v in ipairs(bank_list) do
		equips[#equips+1] = { packId = MPackStruct.eBank, grid = v }
	end
	
	local Mconvertor = require "src/config/convertor"
	
	table.sort(equips, function(a, b)
		local a_packId = a.packId
		local b_packId = b.packId
		
		if a_packId == MPackStruct.eDress and b_packId ~= MPackStruct.eDress then
			return true
		end
		
		if a_packId ~= MPackStruct.eDress and b_packId == MPackStruct.eDress then
			return false
		end
		
		--role
		local roleSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
		local roleSex = MRoleStruct:getAttr(PLAYER_SEX)
		
		--a
		local a_protoId = MPackStruct.protoIdFromGird(a.grid)
		local a_quality = MpropOp.quality(a_protoId)
		local a_propSchool = MpropOp.schoolLimits(a_protoId)
		local a_propSex = MpropOp.sexLimits(a_protoId)
		local a_kind = MequipOp.kind(a_protoId)
		local a_wearable = (a_propSchool == Mconvertor.eWhole or a_propSchool == roleSchool) and
		                   (a_propSex == Mconvertor.eSexWhole or a_propSex == roleSex)
		
		--b
		local b_protoId = MPackStruct.protoIdFromGird(b.grid)
		local b_quality = MpropOp.quality(b_protoId)
		local b_propSchool = MpropOp.schoolLimits(b_protoId)
		local b_propSex = MpropOp.sexLimits(b_protoId)
		local b_kind = MequipOp.kind(b_protoId)
		local b_wearable = (b_propSchool == Mconvertor.eWhole or b_propSchool == roleSchool) and
		                   (b_propSex == Mconvertor.eSexWhole or b_propSex == roleSex)
		
		if a_wearable and not b_wearable then
			return true
		end
		
		if not a_wearable and b_wearable then
			return false
		end
		
		if a_quality > b_quality then
			return true
		elseif a_quality < b_quality then
			return false
		else
			return a_kind < b_kind
		end
	end)
	
	return equips
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
	local protoId = MPackStruct.protoIdFromGird(grid)
	local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	local griId = MPackStruct.girdIdFromGird(grid)
	local num = MPackStruct.overlayFromGird(grid)
	local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	------------------------------------------------------------
	local Mprop = require "src/layers/bag/prop"
	
	local icon = Mprop.new(
	{
		grid = grid,
		--num = num,
		strengthLv = strengthLv,
		--showBind = true,
		--isBind = isBind,
		red_mask = true,
		powerHint = item.packId ~= MPackStruct.eDress and true or nil,
		using = item.packId == MPackStruct.eDress,
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