return { new = function(grid)
local Mbaseboard = require "src/functional/baseboard"
local Mprop = require "src/layers/bag/prop"
local MCompoundDBop = require "src/config/CompoundDBop"
local MMenuButton = require "src/component/button/MenuButton"
local MpropOp = require "src/config/propOp"
local Mcurrency = require "src/functional/currency"
----------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
----------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 4 },
	},
	title = {
		src = game.getStrByKey("compound"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})
G_TUTO_NODE:setTouchNode(compoundBtn, TOUCH_COMPOUND_COMPOUND)
G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_COMPOUND_CLOSE)
local rootSize = root:getContentSize()
---------------------------------------------------------------------------
-- 底板
local n_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg18-7.png",
	pos = cc.p(rootSize.width/2, rootSize.height/2-20),
})

local n_bg_size = n_bg:getContentSize()

local n_icon_now_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg1.png",
	pos = cc.p(145, 340),
})

-- 连接条
Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg1-1.png",
	pos = cc.p(400, 340),
})

local n_icon_next_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/iconBg2.png",
	pos = cc.p(680, 340),
})

-- 下底板
Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg18-8.png",
	pos = cc.p(rootSize.width/2, 85),
})
---------------------------------------------------------------------------
local protoId = MPackStruct.protoIdFromGird(grid)
local gridId = MPackStruct.girdIdFromGird(grid)

local info = MCompoundDBop:record(protoId)
local src_num_need = tonumber(info.q_needCnt)
local dst_num_output = tonumber(info.q_produceCnt)
--dump(info, "info")

local num = 0

local output = string.mysplit(tostring(info.q_produceid), ",")
local school = MRoleStruct:getAttr(ROLE_SCHOOL)
local sex = MRoleStruct:getAttr(PLAYER_SEX)
local dst_id = tonumber(output[3 * (sex-1) + school])
local produceCnt = 0

local gridId1, gridId2 = gridId, 0

local reloadData = function(isInit)
	produceCnt = bag:countByProtoId(dst_id)
	
	local g1 = bag:getGirdByGirdId(gridId1)
	local p1 = MPackStruct.protoIdFromGird(g1)
	local n1 = MPackStruct.overlayFromGird(g1) or 0
	--dump({g1=g1, p1=p1, n1=n1}, "gpn1")
	
	if isInit and n1 < src_num_need then
		--dump("111111111111111111111")
		local list = bag:getGirdsByProtoId(protoId) or {}
		--dump(list, "list")
		
		list = table.toarray(list)
		table.sort(list, function(a, b)
			return MPackStruct.overlayFromGird(a)>MPackStruct.overlayFromGird(b)
		end)
		--dump(list, "list")
	
		local gid2 = MPackStruct.girdIdFromGird(list[1])
		if gid2 == gridId then gid2 = MPackStruct.girdIdFromGird(list[2]) end
		local n2 = bag:numOfOverlay(gid2) or 0
		
		num = n1+n2
		gridId1 = gridId
		gridId2 = gid2 or 0
		--dump({gridId1=gridId1, gridId2=gridId2}, "gridId")
	elseif p1 ~= protoId then -- isInit 必定为false
		dump("这堆已经合成完毕!")
		--dump({gridId1=gridId1, gridId2=gridId2}, "gridId")
		gridId1 = gridId2
		gridId2 = 0
		
		g1 = bag:getGirdByGirdId(gridId1)
		if g1 == nil then
			gridId1 = 0
			num = 0
		else
			num = MPackStruct.overlayFromGird(g1)
		end
		--dump({gridId1=gridId1, gridId2=gridId2}, "gridId")
	else
		local g2 = bag:getGirdByGirdId(gridId2)
		local n2 = MPackStruct.overlayFromGird(g2) or 0
		num = n1+n2
		if g2 == nil then gridId2 = 0 end
		--dump({gridId1=gridId1, gridId2=gridId2}, "gridId")
	end
end

reloadData(true)

--dump(grid, "grid")
---------------------------------------------------------------------------
-- 合成比列
Mnode.createLabel(
{
	parent = root,
	src = src_num_need .. game.getStrByKey("compound") .. dst_num_output,
	size = 20,
	color = MColor.lable_yellow,
	pos = cc.p(386, 380),
})

-- 合成源
local srcIcon = Mprop.new(
{
	protoId = protoId,
	cb = "tips",
	num = num,
})

Mnode.addChild(
{
	parent = root,
	child = srcIcon,
	pos = cc.p(145, 340),
})

-- 物品名字
Mnode.createLabel(
{
	parent = root,
	src = MpropOp.name(protoId),
	color = MpropOp.nameColor(protoId),
	pos = cc.p(145, 225),
	size = 20,
})

-- 产出
local dstIcon = Mprop.new(
{
	protoId = dst_id,
	cb = "tips",
	num = produceCnt,
})

Mnode.addChild(
{
	parent = root,
	child = dstIcon,
	pos = cc.p(680, 340),
	size = 20,
})

-- 物品名字
Mnode.createLabel(
{
	parent = root,
	src = MpropOp.name(dst_id),
	color = MpropOp.nameColor(dst_id),
	pos = cc.p(680, 200),
})
----------------------------------------------------
-- 消耗金币
local cost_coin = tonumber(info.q_needmoney)
local bind_coin = MRoleStruct:getAttr(PLAYER_MONEY)
local coin_node = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("compound") .. game.getStrByKey("once") .. game.getStrByKey("consume").."：",
		size = 19,
		color = MColor.white,
	}),
	
	v = {
		src = game.getStrByKey("gold_coin") .. numToFatString(cost_coin),
		size = 19,
		color = MColor.yellow,
	}
})

Mnode.addChild(
{
	parent = root,
	child = coin_node,
	anchor = cc.p(0, 0.5),
	pos = cc.p(70, 100),
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
	
	v = Mcurrency.new(
	{
		cate = PLAYER_MONEY,
		--bg = "res/common/19.png",
		color = MColor.yellow,
	}),
})

Mnode.addChild(
{
	parent = root,
	child = own_coin,
	anchor = cc.p(0, 0.5),
	pos = cc.p(70, 65),
})

local compound = function(mode)
	--dump({gridId1=gridId1, gridId2=gridId2}, "gridId")
	--g_msgHandlerInst:sendNetDataByFmtExEx(ITEM_CS_COMPOUND, "ibss", G_ROLE_MAIN.obj_id, mode, gridId1, gridId2)
	local t = {}
	t.compoundAll = mode
	t.slot1 = gridId1
	t.slot2 = gridId2
	--dump(t, "t")
	g_msgHandlerInst:sendNetDataByTableExEx(ITEM_CS_COMPOUND, "ItemCompoundProtocol", t)
	addNetLoading(ITEM_CS_COMPOUND, ITEM_SC_COMPOUNDRET)
end

-- 合成按钮
local compoundBtn = MMenuButton.new(
{
	parent = root,
	src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	label = {
		src = game.getStrByKey("compound"),
		size = 25,
		color = MColor.lable_yellow,
	},
	
	pos = cc.p(540, 85),
	
	cb = function(tag, node)
		compound(false)
	end,
})
G_TUTO_NODE:setTouchNode(compoundBtn, TOUCH_COMPOUND_COMPOUND)

-- 全部合成按钮
MMenuButton.new(
{
	parent = root,
	src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	--effect = "b2s",
	
	label = {
		src = game.getStrByKey("all")..game.getStrByKey("compound"),
		size = 25,
		color = MColor.lable_yellow,
	},
	
	cb = function(tag, node)
		compound(true)
	end,
	
	pos = cc.p(700, 85),
})
----------------------------------------------------
local reloadView = function()
	srcIcon:setOverlay(num)
	dstIcon:setOverlay(produceCnt)
end
----------------------------------------------------------
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
					animateSpr:playActionData("strengthen_succeed", 18, 1.9, 1)
					animateSpr:setScale(1.1)
					Mnode.addChild(
					{
						parent = root,
						child = animateSpr,
						pos = cc.p(rootSize.width/2, rootSize.height-190),
						zOrder = 1000,
					})
					AudioEnginer.playEffect("sounds/uiMusic/ui_compose.mp3",false)
				end, 0.1)
			end
			
			reloadData()
			reloadView()
			
			--TIPS({ type = 1  , str = game.getStrByKey("compound")..game.getStrByKey("success") })
		end)
		G_TUTO_NODE:setShowNode(root, SHOW_COMPOUND)
	elseif event == "exit" then
		g_msgHandlerInst:registerMsgHandler(ITEM_SC_COMPOUNDRET, nil)
	end
end)
----------------------------------------------------------
return root	

end }