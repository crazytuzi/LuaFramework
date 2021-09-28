return { new = function()
------------------------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local MPackView = require "src/layers/bag/PackView"
local Mcurrency = require "src/functional/currency"
local MMenuButton = require "src/component/button/MenuButton"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
------------------------------------------------------------------------------------
local res = "res/layers/bag/"
------------------------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
local recycle = MPackManager:getPack(MPackStruct.eRecycle)
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
	title = game.getStrByKey("sell"),
	
	close = {
		handler = function(root)
			removeFromParent(root)
		end,
	},
})
local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
-- local left_bg = cc.Sprite:create("res/common/bg/bg11.png")
-- local left_bg_size = left_bg:getContentSize()
-- local left_bg_size = cc.size(529, 526)
-- local left_bg = createScale9Frame(
--         root,
--         "res/common/scalable/panel_outer_base_1.png",
--         "res/common/scalable/panel_outer_frame_scale9_1.png",
--         cc.p(544, 288),
--         left_bg_size,
--         5,
--         cc.p(1, 0.5)
--     )
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = left_bg,
-- 	anchor = cc.p(1, 0.5),
-- 	pos = cc.p(544, 288),
-- })

local left_bd = cc.Sprite:create("res/common/bg/bg1.png")
local left_bd_size = left_bd:getContentSize()

Mnode.addChild(
{
	parent = root,
	child = left_bd,
	anchor = cc.p(1, 0.5),
	pos = cc.p(542, 288),
})
--------------
-- local right_bg = cc.Sprite:create("res/common/bg/bg13.png")
-- local right_bg_size = right_bg:getContentSize()
local right_bg_size = cc.size(390, 500)
local right_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(544, 288),
        right_bg_size,
        5,
        cc.p(0,0.5)
    )


-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = right_bg,
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(540, 288),
-- })
------------------------------------------------------------------------------------
-- TableView
local recycle = MPackManager:getPack(MPackStruct.eRecycle)
local nums = recycle:maxNumOfGirdCanOpen()

local list = nil
local map = nil
local reloadSource = function()
	list = recycle:filtrate(nil, MPackStruct.eAll)
	table.sort(list, function(a, b)
		local a_expiration = MPackStruct.attrFromGird(a, MPackStruct.eAttrStallTime)
		local b_expiration = MPackStruct.attrFromGird(b, MPackStruct.eAttrStallTime)
		
		--[[
		local expiration = MPackStruct.attrFromGird(gird, MPackStruct.eAttrStallTime)
		dump(expiration, "expiration")
		local dt = os.date("*t", expiration)
		dump(dt, "expiration")
		local readable = string.format(game.getStrByKey("full_date_format"), dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
		dump(readable, "readable")
		]]
	
		if a_expiration ~= nil and b_expiration ~= nil then
			return a_expiration > b_expiration
		else
			local a_gridId = MPackStruct.girdIdFromGird(a)
			local b_gridId = MPackStruct.girdIdFromGird(b)
			return a_gridId < b_gridId
		end
	end)
	
	map = {}
	for i, v in ipairs(list) do
		local gridId = MPackStruct.girdIdFromGird(v)
		map[gridId] = i
	end
	
	--dump(list, "list")
end
----------------------------------	
local iSize = cc.size(396, 118)
local vSize = cc.size(396, 492)
local recycleView = cc.TableView:create(vSize)
recycleView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
recycleView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
recycleView:setDelegate()

local reloadData = function()
	reloadSource()
	recycleView:reloadData()
end

recycleView:registerScriptHandler(function(tv)
	return nums
end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

recycleView:registerScriptHandler(function(tv, idx)
	return iSize.height, iSize.width
end, cc.TABLECELL_SIZE_FOR_INDEX)

local buildCellContent = nil
recycleView:registerScriptHandler(function(tv, idx)
	local cell = tv:dequeueCell()
	if not cell then
		cell = cc.TableViewCell:new()
		cell:setContentSize(iSize)
		buildCellContent(tv, idx, cell)
	else
		buildCellContent(tv, idx, cell)
	end
	return cell
end, cc.TABLECELL_SIZE_AT_INDEX)

recycleView:registerScriptHandler(function(tv, cell)
	cell:removeAllChildren()
end, cc.TABLECELL_WILL_RECYCLE)

buildCellContent = function(tv, idx, cell)
	local cellSize = cell:getContentSize()
	local baseboard = Mnode.createSprite(
	{
		src = "res/common/bg/bg14.png",
		parent = cell,
		pos = cc.p(cellSize.width/2, cellSize.height/2),
	})
	
	---------------------------
	local gird = list[idx+1]
	if not gird then return end
	---------------------------
	local protoId = MPackStruct.protoIdFromGird(gird)
	local isEquip = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eEquipment
	local girdId = MPackStruct.girdIdFromGird(gird)
	local num = MPackStruct.overlayFromGird(gird)
	local expiration = MPackStruct.attrFromGird(gird, MPackStruct.eAttrExpiration)
	local isBind = MPackStruct.attrFromGird(gird, MPackStruct.eAttrBind)
	local quality = isEquip and MPackStruct.attrFromGird(gird, MPackStruct.eAttrQuality) or nil
	---------------------------
	-- 道具图标
	local icon = Mprop.new(
	{
		protoId = protoId,
		num = num,
		isBind = isBind,
		expiration = expiration,
		quality = quality,
		grid = gird,
		cb = "tips",
		showBind = true,
	})
	---------------------------
	Mnode.overlayNode(
	{
		-- item 背景
		parent = baseboard,
		nodes = 
		{
			{
				-- 道具 icon
				node = icon,
				origin = "l",
				offset = { x = 15, },
			},
			
			{
				-- 道具回购价格
				node = Mnode.combineNode(
				{
					nodes = 
					{
						Mnode.combineNode(
						{
							nodes = 
							{
								Mnode.createLabel(
								{
									src = game.getStrByKey("buy_back_price"),
									size = 18,
									color = MpropOp.nameColor(protoId),
								}),
								
								Mnode.createSprite(
								{
									src = "res/group/currency/1.png",
									scale = 0.55,
								}),
								
								Mnode.createLabel(
								{
									src = MpropOp.recyclePrice(protoId) * num * 2,
									size = 18,
									color = MColor.green,
								}),
							},
							
							margins = { 0, 5 },
						}),
					
						-- 分隔线
						cc.Sprite:create("res/group/separator/5.png"),
						
						Mnode.createLabel(
						{
							src = MpropOp.name(protoId),
							size = 20,
							color = MpropOp.nameColor(protoId),
						}),
					},
					
					margins = 5,
					ori = "|",
				}),
			},
			
			{
				-- 回购按钮
				node = MMenuButton.new(
				{
					src = {"res/component/button/51.png", "res/component/button/51_sel.png"},
					label = {
						src = game.getStrByKey("buy_back"),
						size = 25,
						color = MColor.lable_yellow,
					},
					--effect = "b2s",
					cb = function()
						MPackManager:buyBack(girdId, num)
					end
				}),
				
				origin = "r",
				offset = { x = -20, },
			},
		}
	})
	---------------------------
end

reloadData()

local dataSourceChanged = function(observable, event, pos, pos1, gird)
	--dump({ event = event, pos = pos, pos1 = pos1 })
	if event == "+" or event == "=" then
		reloadData()
	elseif event == "-" then
		local idx = map[pos]
		if idx == nil then
			reloadData()
		else
			map[pos] = nil
			list[idx] = nil
			recycleView:updateCellAtIndex(idx-1)
		end
	end
end

recycleView:getContainer():registerScriptHandler(function(event)
	if event == "enter" then
		recycle:register(dataSourceChanged)
	elseif event == "exit" then
		recycle:unregister(dataSourceChanged)
	end
end)

Mnode.addChild(
{
	parent = right_bg,
	child = recycleView,
	anchor = cc.p(0.5, 1),
	pos = cc.p(right_bg_size.width/2, right_bg_size.height-4),
})
------------------------------------------------------------------------------------
local bagView = MPackView.new(
{
	packId = MPackStruct.eBag,
	--bg = "res/common/32.png",
	layout = { row = 5, col = 5, },
	marginLR = 0,
	marginUD = 5,
	mode = "sell",
})

bagView:registerEventHandler(function(gv, cell)
	local idx = cell:getIdx()
	local grid = bag:getGirdByGirdId(idx+1)
	if not grid then return end
	
	local Mtips = require "src/layers/bag/tips"
	local actions = {}
	actions[#actions+1] = {
		label = "出售",
		cb = function(act_params)
			local MpropOp = require "src/config/propOp"
			local grid = act_params.grid
			local gridId = MPackStruct.girdIdFromGird(grid)
			local protoId = MPackStruct.protoIdFromGird(grid)
			local num = MPackStruct.overlayFromGird(grid)
			if MpropOp.recyclable(protoId) then
				MPackManager:sell(gridId, num)
			else
				dump("物品不可出售")
				TIPS({ type = 1  , str = game.getStrByKey("sell_prop_tips") })
			end
		end,
	}
	
	Mtips.new({ grid = grid, actions = actions })
	
end, YGirdView.CELL_LONG_TOUCHED)

bagView:refresh()

Mnode.addChild(
{
	parent = left_bd,
	child = bagView:getRootNode(),
	pos = cc.p(left_bd_size.width/2, left_bd_size.height/2),
})

-- 提示信息
local Msuite = require "src/functional/suite"
local vSize = bagView:getViewSize()
local n_tips = Mnode.addChild(
{
	parent = left_bd,
	child = Msuite:createTooltip({ cSize = cc.size(vSize.width+16, 34), text = "长按物品，显示详细信息" }),
	pos = cc.p(left_bd_size.width/2, 25),
	zOrder = 1,
})

-- 金币显示
-- 货币显示
-- local buildCurrencyArea = function()
-- 	local Mcurrency = require "src/functional/currency"
-- 	return Mnode.combineNode(
-- 	{
-- 		nodes = {
-- 			[1] = Mnode.combineNode(
-- 			{
-- 				nodes = {
-- 					[1] = Mcurrency.new(
-- 					{
-- 						cate = PLAYER_INGOT,
-- 						--bg = "res/common/19.png",
-- 						color = MColor.yellow,
-- 					}),
					
-- 					[2] = Mcurrency.new(
-- 					{
-- 						cate = PLAYER_BINDINGOT,
-- 						--bg = "res/common/19.png",
-- 						color = MColor.yellow,
-- 					})
-- 				},
				
-- 				margins = 5,
-- 			}),
			
-- 			[2] = Mnode.combineNode(
-- 			{
-- 				nodes = {
-- 					[1] = Mcurrency.new(
-- 					{
-- 						cate = PLAYER_MONEY,
-- 						--bg = "res/common/19.png",
-- 						color = MColor.yellow,
-- 					}),
-- 				},
				
-- 				margins = 5,
-- 			}),
-- 		},
		
-- 		ori = "|",
-- 		align = "l",
-- 		margins = 0,
-- 	})
-- end

-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = buildCurrencyArea(),
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(20, 605),
-- })
------------------------------------------------------------------------------------
return root
end }