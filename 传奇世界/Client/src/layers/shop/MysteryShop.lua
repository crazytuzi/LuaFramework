return { new = function(params)
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local MMenuButton = require "src/young/component/button/MenuButton"
local Mcurrency = require "src/functional/currency"
local MShopCore = require "src/layers/shop/ShopCore"
------------------------------------------------------------------------------------
local res = "res/layers/shop/"
------------------------------------------------------------------------------------
local params = params or {}
local shopID = -3
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
	title = {
		icon = res .. "10.png",
		label = res .. "22.png",
	},
})
local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
Mnode.addChild(
{
	parent = root,
	child = cc.Sprite:create("res/common/bg/bg.png"),
	anchor = cc.p(0.5, 0.5),
	pos = cc.p(480, 285),
})
------------------------------------------------------------------------------------
local refresh_time_tip = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("shop_time"),
		size = 20,
		color = MColor.white,
	}),
	
	v = {
		src = "12:00 18:00 21:00",
		size = 22,
		color = MColor.yellow,
	},
})

Mnode.addChild(
{
	parent = root,
	child = refresh_time_tip,
	anchor = cc.p(0, 0.5),
	pos = cc.p(16, 600),
})
------------------------------------------------------------------------------------
local grid = MShopCore.new({ row = 4 })

grid:refresh(shopID)

Mnode.addChild(
{
	parent = root,
	child = grid:getRootNode(),
	anchor = cc.p(0, 1),
	pos = cc.p(25, 540),
})
------------------------------------------------------------------------------------
-- 我的元宝
local ingot = Mcurrency.new(
{
	cate = PLAYER_INGOT,
	bg = "res/common/19.png",
	color = MColor.yellow,
})

Mnode.addChild(
{
	parent = root,
	child = ingot,
	anchor = cc.p(0, 0.5),
	pos = cc.p(38, 53),
})
------------------------------------------------------------------------------------
-- 充值按钮
MMenuButton.new(
{
	parent = root,
	src = "res/component/button/50.png",
	label = {
		src = game.getStrByKey("recharge"),
		size = 25,
	},
	effect = "b2s",
	cb = function(tag, node)
		Manimation:transit(
		{
			node = require("src/layers/pay/PayView").new(),
			sp = node:getParent():convertToWorldSpace(cc.p(node:getPosition())),
			curve = "-",
			zOrder = 200,
			swallow = true,
		})
	end,
	pos = cc.p(556, 53),
})

-- 刷新按钮
MMenuButton.new(
{
	parent = root,
	src = "res/component/button/50.png",
	label = {
		src = game.getStrByKey("refresh"),
		size = 25,
	},
	effect = "b2s",
	cb = function(tag, node)
		local refresh = function()
			local MshopNet = require "src/layers/shop/shopNet"
			MshopNet:refreshMysteryStore(shopID)
		end
		local str_text = game.getStrByKey("consume_prefix_tips").."^c(green)"..grid:refreshIngotrRequired() .. game.getStrByKey("ingot").."^"..game.getStrByKey("refresh_mystery_shop_tips")
		MessageBoxYesNo(nil,str_text ,refresh)
	end,
	pos = cc.p(836, 53),
})
------------------------------------------------------------------------------------
return root


end }


