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
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
	title = game.getStrByKey("jjc")..game.getStrByKey("store"),
})

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


