return { new = function(params)
------------------------------------------------------------------------------------
local MtradeOp = require "src/layers/trade/tradeOp"
local MtradeView = require "src/layers/trade/tradeView"
local MPackView = require "src/layers/bag/PackView"
local Mbaseboard = require "src/functional/baseboard"
local Mcurrency = require "src/functional/currency"
------------------------------------------------------------------------------------
local res = "res/layers/trade/"
------------------------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
	title = game.getStrByKey("trade")
})
local rootSize = root:getContentSize()

local M = Mnode.beginNode(root)

------------------------------------------------------------------------------------
local left_bd = cc.Sprite:create("res/common/bg/bg32.png")
local left_bd_size = left_bd:getContentSize()
local contentNode = cc.Node:create()
contentNode:setPosition(cc.p(16,12))
root:addChild(contentNode)
contentNode:setScale(0.97)
Mnode.addChild(
{
	parent = contentNode,
	child = left_bd,
	anchor = cc.p(1, 0.5),
	pos = cc.p(516+12, 286),
})
--------------
-- local right_bg = cc.Sprite:create("res/common/bg/bg13.png")
-- local right_bg_size = right_bg:getContentSize()
local right_bg_size = cc.size(403, 536)
local right_bg = cc.Node:create()
right_bg:setPosition(cc.p(534,11))
contentNode:addChild(right_bg)
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = right_bg,
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(516+12+4, 286),
-- })
------------------------------------------------------------------------------------
local bagView = MPackView.new(
{
	packId = MPackStruct.eBag,
	--bg = "res/common/32.png",
	layout = { row = 5.2, col = 5, },
	marginLR = 0,
	marginUD = 5,
	mode = "trade",
})

bagView:registerEventHandler(function(gv, cell)
	local idx = cell:getIdx()
	local grid = bag:getGirdByGirdId(idx+1)
	if not grid then return end
	
	local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
	local isLocked = gv.mOneselfLocked
	
	local Mtips = require "src/layers/bag/tips"
	local actions = {}
	actions[#actions+1] = {
		label = game.getStrByKey("put"),
		cb = function(act_params)
			if isLocked then
				TIPS({ type = 1  , str = game.getStrByKey("trade_locked_tips") })
				return
			end
		
			local MtradeOp = require "src/layers/trade/tradeOp"
			local MpropOp = require "src/config/propOp"
			local grid = act_params.grid
			local gridId = MPackStruct.girdIdFromGird(grid)
			local protoId = MPackStruct.protoIdFromGird(grid)
			local num = MPackStruct.overlayFromGird(grid)
			
			
			local bar = MtradeOp:searchInTradingBar(gridId)
			local available = num
			if bar then available = num - bar.tradingBarNum end
			
			if available > 1 then
				local MChoose = require("src/functional/ChooseQuantity")
				MChoose.new(
				{
					title = game.getStrByKey("put"),
					config = { sp = 1, ep = available, cur = available },
					builder = function(box, parent)
						local cSize = parent:getContentSize()
						
						box:buildPropName(grid)
						
						local Mprop = require "src/layers/bag/prop"
						local icon = Mprop.new(
						{
							grid = grid,
							cb = "tips",
							red_mask = true,
						})
						
						-- 物品图标
						Mnode.addChild(
						{
							parent = parent,
							child = icon,
							pos = cc.p(70, 264),
						})
						
						box.icon = icon
					end,
					
					handler = function(box, value)
						MtradeOp:preparingItems(gridId, value, 0)
						removeFromParent(box)
					end,
					
					onValueChanged = function(box, value)
						box.icon:setOverlay(value)
					end,
				})
			elseif available == 1 then
				MtradeOp:preparingItems(gridId, 1, 0)
			end
		end,
	}
	
	Mtips.new({ grid = grid, actions = not isBind and not isLocked and actions or nil})
	
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
------------------------------------------------------------------------------------
local tradeView = MtradeView.new(params)

Mnode.addChild(
{
	parent = right_bg,
	child = tradeView,
	pos = cc.p(right_bg_size.width/2, right_bg_size.height/2),
})
------------------------------------------------------------------------------------
-- 货币显示
local buildCurrencyArea = function()
	local Mcurrency = require "src/functional/currency"
	return Mnode.combineNode(
	{
		nodes = {
			[1] = Mnode.combineNode(
			{
				nodes = {
					[1] = Mcurrency.new(
					{
						cate = PLAYER_INGOT,
						--bg = "res/common/19.png",
						color = MColor.yellow,
					}),
					
					-- [2] = Mcurrency.new(
					-- {
					-- 	cate = PLAYER_BINDINGOT,
					-- 	--bg = "res/common/19.png",
					-- 	color = MColor.yellow,
					-- })
				},
				
				margins = -29,
			})
			-- ,
			
			-- [2] = Mnode.combineNode(
			-- {
			-- 	nodes = {
			-- 		[1] = Mcurrency.new(
			-- 		{
			-- 			cate = PLAYER_MONEY,
			-- 			--bg = "res/common/19.png",
			-- 			color = MColor.yellow,
			-- 		}),
			-- 	},
				
			-- 	margins = 5,
			-- }),
		},
		
		ori = "|",
		align = "l",
		margins = 0,
	})
end

Mnode.addChild(
{
	parent = contentNode,
	child = buildCurrencyArea(),
	anchor = cc.p(0, 0.5),
	pos = cc.p(55, 575),
})
------------------------------------------------------------------------------------
local tradingBarListener = function(observable, event, ...)
	dump(event, "trade_event")
	
	if event == "otherCanceled" or event == "oneselfCanceled" or event == "tradeCompleted" then
		removeFromParent(root)
	elseif event == "oneselfGoodsChanged" then
		tradeView:oneselfGoodsChanged(...)
	elseif event == "otherGoodsChanged" then
		tradeView:otherGoodsChanged(...)
	elseif event == "oneselfLocked" then
		tradeView:oneselfLocked()
	elseif event == "otherLocked" then
		tradeView:otherLocked()
	elseif event == "oneselfCompleted" then
		tradeView:oneselfCompleted()
	else
		dump("未知事件")
	end
end
root:registerScriptHandler(function(event)
	if event == "enter" then
		MtradeOp:register(tradingBarListener)
	elseif event == "exit" then
		MtradeOp:unregister(tradingBarListener)
		MtradeOp:submit(false)
	end
end)
------------------------------------------------------------------------------------
return root
------------------------------------------------------------------------------------
end }