--[[
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
local shopID = -2
------------------------------------------------------------------------------------
local root = Mnode.createNode({ cSize = cc.size(960, 640) })
local rootSize = root:getContentSize()
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
	anchor = cc.p(1, 0.5),
	pos = cc.p(856, 600),
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
-- 我的魂值
local currency = Mcurrency.new(
{
	cate = PLAYER_SOUL_SCORE,
	bg = "res/common/19.png",
	color = MColor.yellow,
})

Mnode.addChild(
{
	parent = root,
	child = currency,
	anchor = cc.p(0, 0.5),
	pos = cc.p(38, 53),
})
------------------------------------------------------------------------------------
-- 刷新按钮
MMenuButton.new(
{
	parent = root,
	src = "res/component/button/12.png",
	label = {
		src = game.getStrByKey("refresh"),
		size = 25,
	},
	effect = "b2s",
	cb = function(tag, node)
		local MConfirmBox = require "src/functional/ConfirmBox"
		local box = MConfirmBox.new(
		{
			handler = function(box)
				local MshopNet = require "src/layers/shop/shopNet"
				MshopNet:refreshMysteryStore(shopID)
				if box then
					removeFromParent(box)
					box = nil
				end
			end,
			
			builder = function(box)
				return Mnode.combineNode(
				{
					nodes = {
						Mnode.createLabel({
							src = game.getStrByKey("consume_prefix_tips"),
							size = 20,
							color = MColor.white,
						}),
						
						Mnode.createLabel({
							src = grid:refreshIngotrRequired() .. game.getStrByKey("ingot"),
							size = 22,
							color = MColor.green,
						}),
						
						Mnode.createLabel({
							src = game.getStrByKey("refresh_soul_shop_tips"),
							size = 20,
							color = MColor.white,
						}),
					},
				})
			end,
		})
	end,
	pos = cc.p(836, 53),
})
------------------------------------------------------------------------------------
return root


end }
]]
 

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
local shopID = params.shopID
local is_cross_server = shopID == 13
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local root = Mnode.createNode({ cSize = cc.size(960, 640) })
local rootSize = root:getContentSize()

Mnode.addChild(
{
	parent = root,
	child = cc.Sprite:create("res/common/bg/bg.png"),
	anchor = cc.p(0.5, 0.5),
	pos = cc.p(480, 285),
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
-- 我的荣誉
local honor = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = is_cross_server and (game.getStrByKey("my")..game.getStrByKey("feats").."：") or (game.getStrByKey("my")..game.getStrByKey("honor_s").."："),
		size = 25,
		color = MColor.yellow,
	}),
	
	v = {
		src = "123456789",
		size = 25,
		color = MColor.white,
	},
})

honor:setValue( is_cross_server and MRoleStruct:getAttr(PLAYER_MERITORIOUS) or MRoleStruct:getAttr(PLAYER_HONOUR) )

Mnode.addChild(
{
	parent = root,
	child = honor,
	anchor = cc.p(0, 0.5),
	pos = cc.p(679, 53),
})
------------------------------------------------------------------------------------
local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
	if isMe then
		if (attrId == PLAYER_MERITORIOUS and is_cross_server) or (attrId == PLAYER_HONOUR and not is_cross_server) then
			honor:setValue(attrValue)
		end
	end
end

root:registerScriptHandler(function(event)
	if event == "enter" then
		MRoleStruct:register(onDataSourceChanged)
	elseif event == "exit" then
		MRoleStruct:unregister(onDataSourceChanged)
	end
end)
------------------------------------------------------------------------------------
return root


end }




