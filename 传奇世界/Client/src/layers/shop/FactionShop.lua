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
local faction_lv = 1
local faction_money = 0
------------------------------------------------------------------------------------
local grid = nil
local factionMoney = nil
------------------------------------------------------------------------------------
g_msgHandlerInst:registerMsgHandler(FACTION_SC_GETSHOPDATARET, function(buf)
	local t = g_msgHandlerInst:convertBufferToTable("GetMyFactionDataRet", buf)
    local lv = t.storeLv
	local money = t.contribution
	--dump({lv = lv, money = money})
	faction_lv = lv
	faction_money = money
	factionMoney:setValue(money)
	grid:refresh(4 + lv)
end)

--g_msgHandlerInst:sendNetDataByFmtExEx(FACTION_CS_GETSHOPDATA, "i", G_ROLE_MAIN.obj_id)

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
local return_node = cc.Layer:create()
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
	title = "",
	parent = return_node,
})

local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
grid = MShopCore.new({ row = 4 })

--grid:refresh(4 + lv)

Mnode.addChild(
{
	parent = root,
	child = grid:getRootNode(),
	anchor = cc.p(0, 1),
	pos = cc.p(25, 540),
})
------------------------------------------------------------------------------------

-- 当前帮会等级
Mnode.addChild(
{
	parent = root,
	child = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("cur_bs_lv").."：",
			size = 25,
			color = MColor.yellow,
		}),
		
		v = {
			src = faction_lv,
			size = 25,
			color = MColor.white,
		},
	}),
	
	anchor = cc.p(0, 0.5),
	pos = cc.p(392, 53),
})

-- 我的帮贡
factionMoney = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("my")..game.getStrByKey("bang_gong").."：",
		size = 25,
		color = MColor.yellow,
	}),
	
	v = {
		src = faction_money,
		size = 25,
		color = MColor.white,
	},
})
-----------------------------------------------------
-- 刷新帮贡, 坑爹的代码
--[[
local CallFunc = cc.CallFunc:create(function(node)
	--dump(root:getParent().fac_data[11], "帮贡")
	node:setValue(root:getParent().fac_data[11])
end)
local DelayTime = cc.DelayTime:create(1)
local Sequence = cc.Sequence:create(CallFunc, DelayTime)
local RepeatForever = cc.RepeatForever:create(Sequence)
factionMoney:runAction(RepeatForever)
]]
-----------------------------------------------------
Mnode.addChild(
{
	parent = root,
	child = factionMoney,
	anchor = cc.p(0, 0.5),
	pos = cc.p(679, 53),
})
------------------------------------------------------------------------------------
root:registerScriptHandler(function(event)
	if event == "enter" then
	elseif event == "exit" then
		g_msgHandlerInst:registerMsgHandler(FACTION_SC_GETSHOPDATARET, nil)
	end
end)
------------------------------------------------------------------------------------	
return return_node
end }


