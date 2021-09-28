return { new = function(params)
-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
-----------------------------------------------------------------------
local res = "res/layers/equipment/strengthen/"
local bag = MPackManager:getPack(MPackStruct.eBag)
-----------------------------------------------------------------------
local protoId = params.protoId
-----------------------------------------------------------------------
local root = Mbaseboard.new( 
{
	src = "res/common/bg/bg27.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 3 },
	},
	title = {
		src = "装备合成",
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

local rootSize = root:getContentSize()
-----------------------------------------------------------------------------------
local right_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg44-5.png",
	pos = cc.p(rootSize.width/2, rootSize.height/2-20),
})
-----------------------------------------------------------------------
-- 祝福消耗材料
local material, cost_num, cost_money =  MpropOp.equipCompoundMaterialNeed(protoId)
local own_num = bag:countByProtoId(material)

local n_icon = Mprop.new(
{
	protoId = material,
	cb = "tips",
})

Mnode.addChild(
{
	parent = root,
	child = n_icon,
	pos = cc.p(rootSize.width/2, 265),
})


local n_material = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = MpropOp.name(material) .. "：",
		size = 20,
		color = MpropOp.nameColor(material),
	}),
	
	v = 
	{
		src = own_num .. "/" .. cost_num,
		size = 20,
		color = MColor.lable_yellow,
	},
	
	margins = 0,
})

Mnode.addChild(
{
	parent = root,
	child = n_material,
	anchor = cc.p(0, 0.5),
	pos = cc.p(130, 186),
})

local tmp_func = function(observable, event, pos, pos1, new_grid)
	if event == "-" or event == "+" or event == "=" then
		own_num = bag:countByProtoId(material)
		n_material:setValue({ text = own_num .. "/" .. cost_num })
	end
end

n_material:registerScriptHandler(function(event)
	if event == "enter" then
		bag:register(tmp_func)
	elseif event == "exit" then
		bag:unregister(tmp_func)
	end
end)

Mnode.addChild(
{
	parent = root,
	child = own_material,
	anchor = cc.p(0, 0.5),
	pos = cc.p(238, 120),
})

-- 消耗金币
local cost_coin = cost_money
local bind_coin = MRoleStruct:getAttr(PLAYER_MONEY)
local coin_node = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = "消耗金币".."：",
		size = 19,
		color = MColor.white,
	}),
	
	v = {
		src = numToFatString(cost_coin),
		size = 19,
		color = MColor.yellow,
	}
})

Mnode.addChild(
{
	parent = root,
	child = coin_node,
	anchor = cc.p(0, 0.5),
	pos = cc.p(50, 120),
})

-- 拥有金币数目
local own_coin = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("own").."：",
		size = 19,
		color = MColor.white,
	}),
	
	v = {
		src = numToFatString(bind_coin),
		size = 19,
		color = bind_coin < cost_coin and MColor.red or MColor.green,
	},
})

-- 货币数值发生了变化
local onDataSourceChanged = function(observable, attrId, objId, isMe, attrValue)
	if not isMe then return end
	if attrId == PLAYER_MONEY then
		bind_coin = MRoleStruct:getAttr(PLAYER_MONEY)
		own_coin:setValue(
		{
			text = numToFatString(bind_coin),
			color = bind_coin < cost_coin and MColor.red or MColor.green,
		})
	end
end

own_coin:registerScriptHandler(function(event)
	if event == "enter" then
		MRoleStruct:register(onDataSourceChanged)
	elseif event == "exit" then
		MRoleStruct:unregister(onDataSourceChanged)
	end
end)

Mnode.addChild(
{
	parent = root,
	child = own_coin,
	anchor = cc.p(0, 0.5),
	pos = cc.p(238, 120),
})
-----------------------------------------------------------------------
-- 合成按钮
local compound_menu, compound_btn = MMenuButton.new(
{
	parent = root,
	pos = cc.p(rootSize.width/2, 60),
	src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
	label = {
		src = "合成",
		size = 25,
		color = MColor.lable_yellow,
	},
	
	cb = function(tag, node)
		if not G_ROLE_MAIN or not G_ROLE_MAIN.obj_id then return end
		dump(ITEM_CS_COMPOUND_EQUIP, "装备合成")
		--g_msgHandlerInst:sendNetDataByFmtExEx(ITEM_CS_COMPOUND_EQUIP, "ii", G_ROLE_MAIN.obj_id, protoId)
		g_msgHandlerInst:sendNetDataByTableExEx(ITEM_CS_COMPOUND_EQUIP, "EquipCompoundProtocol", {itemID=protoId})
	end,
})
-----------------------------------------------------------------------
root:registerScriptHandler(function(event)
	if event == "enter" then
		g_msgHandlerInst:registerMsgHandler(ITEM_SC_COMPOUNDRET, function(buff)
			local t = g_msgHandlerInst:convertBufferToTable("ItemCompoundRetProtocol", buff)
			--dump(t, "合成装备返回")
				
			local result = t.result
			dump(result, "result")
			if result == 0 then
				return
			else
				performWithDelay(root, function()
					--合成成功特效
					local animateSpr = Effects:create(false)
					performWithDelay(animateSpr,function() removeFromParent(animateSpr) animateSpr = nil end,1.9)
					animateSpr:playActionData("equipCompound", 11, 1.9, 1)
					addEffectWithMode(animateSpr,1)
					Mnode.addChild(
					{
						parent = root,
						child = animateSpr,
						pos = cc.p(rootSize.width/2, rootSize.height-190),
						zOrder = 1000,
					})
				end, 0.1)
			end
		end)
	elseif event == "exit" then
		g_msgHandlerInst:registerMsgHandler(ITEM_SC_COMPOUNDRET, nil)
	end
end)

-----------------------------------------------------------------------
return root
end }