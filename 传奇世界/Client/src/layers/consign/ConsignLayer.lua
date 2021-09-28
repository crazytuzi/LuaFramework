return { new = function()
---------------------------------------------------------------
local res = "res/layers/consign/"
local Mbaseboard = require "src/functional/baseboard"
local MMenuButton = require "src/component/button/MenuButton"
local MConsignOp = require "src/layers/consign/ConsignOp"
local Mcurrency = require "src/functional/currency"
---------------------------------------------------------------
-- 打开寄售
MConsignOp:openConsign()
---------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/2.jpg",
	close = {
		handler = function(root)
			removeFromParent(root, function()
				TextureCache:removeUnusedTextures()
			end)
		end,
	},
	quick = true,
})

-- 引导节点有可能失效
if G_TUTO_NODE ~= nil then
    G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_SELL_CLOSE)
end

local rootSize = root:getContentSize()
------------------------------------------------------------
-- 货币显示
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = Mnode.combineNode(
-- 	{
-- 		nodes = {
-- 			[1] = Mcurrency.new(
-- 			{
-- 				cate = PLAYER_INGOT,
-- 				--bg = "res/common/19.png",
-- 				color = MColor.yellow,
-- 			}),
			
-- 			[2] = Mcurrency.new(
-- 			{
-- 				cate = PLAYER_MONEY,
-- 				--bg = "res/common/19.png",
-- 				color = MColor.yellow,
-- 			}),
-- 		},
		
-- 		ori = "|",
-- 		margins = 0,
-- 	}),
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(20, 605),
-- })
------------------------------------------------------------
-- 替换界面
local replace_view = function(sub_view)
	local old = root:getChildByTag(1)
	if old then removeFromParent(old) end
	
	if sub_view then
		Mnode.addChild(
		{
			parent = root,
			child = sub_view,
			pos = cc.p(rootSize.width/2, rootSize.height/2),
			tag = 1,
		})
	end
end

-- "我要购买"
local i_will_buy_t = "竞拍"
-- "我要出售"
local i_will_sell_t = "寄售"
-- "我的摊位"
local my_stall_t = "寄售中"
-- "我的收益"
local my_earnings_t = "待领取"

local config = {
	[i_will_buy_t] = {
		action = function()
			replace_view( require("src/layers/consign/buy"):new() )
		end,
	},
	
	[i_will_sell_t] = {
		action = function()
			replace_view( require("src/layers/consign/sell"):new() )
		end,
	},
	
	[my_stall_t] = {
		action = function()
			replace_view( require("src/layers/consign/my_stall"):new() )
		end,
	},
	
	[my_earnings_t] = {
		action = function()
			replace_view( require("src/layers/consign/earnings"):new() )
		end,
	},
}

local tabs = {}
tabs[#tabs+1] = i_will_buy_t
tabs[#tabs+1] = i_will_sell_t
tabs[#tabs+1] = my_stall_t
tabs[#tabs+1] = my_earnings_t


local TabControl = Mnode.createTabControl(
{
	src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
	size = 22,
	titles = tabs,
	margins = 2,
	ori = "|",
	align = "r",
	side_title = true,
	cb = function(node, tag)
		config[tabs[tag]].action()
		local title_label = root:getChildByTag(12580)
		if title_label then title_label:setString(tabs[tag]) end
	end,
	selected = i_will_buy_t,
})
if G_TUTO_NODE ~= nil then
	G_TUTO_NODE:setTouchNode(TabControl:tabAtTitle(i_will_buy_t) ,TOUCH_SELL_BUY)
	G_TUTO_NODE:setTouchNode(TabControl:tabAtTitle(i_will_sell_t) ,TOUCH_SELL_SELL)
	G_TUTO_NODE:setTouchNode(TabControl:tabAtTitle(my_stall_t) ,TOUCH_SELL_SHOP)
	G_TUTO_NODE:setTouchNode(TabControl:tabAtTitle(my_earnings_t) ,TOUCH_SELL_MONEY)
end

Mnode.addChild(
{
	parent = root,
	child = TabControl,
	anchor = cc.p(0, 0.0),
	pos = cc.p(931, 460),
	zOrder = 100,
})

-- 我的收益红点
local n_rp_parent = TabControl:tabAtTitle(my_earnings_t)
local n_rp = Mnode.createSprite(
{
	src = "res/component/flag/red.png",
	parent = n_rp_parent,
	pos = cc.p(60, 100),
	hide = true,
})
local source = MConsignOp:getEarningsSource()
local num = table.size(source)
n_rp:setVisible(num>0)

local dataSourceChanged = function(observable, event, data)
	if event == "PullSaleList" then return end

	local source = MConsignOp:getEarningsSource()
	local num = table.size(source)
	n_rp:setVisible(num>0)
end

root:registerScriptHandler(function(event)
	if event == "enter" then
		if G_TUTO_NODE ~= nil then
			G_TUTO_NODE:setShowNode(root, SHOW_SELL)
			MConsignOp:register(dataSourceChanged)
		end
	elseif event == "exit" then
		MConsignOp:unregister(dataSourceChanged)
	end
end)
--------------------------------------------------------------
return root
end }