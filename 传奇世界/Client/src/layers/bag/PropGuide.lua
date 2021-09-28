local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local tag_cellBg, tag_bgSel = 123, 456
-- 在元宝商城快捷购买
shortcut_buy = function(protoId, price, data)
	local tag = 9900
	local ref = getRunScene()
	if ref ~= nil then
		local old = ref:getChildByTag(tag)
		if old then old:removeFromParent() end
	end
	--------------------------------------------
	local MpropOp = require "src/config/propOp"
	local whole = data ~= nil and data.wholeRemaining ~= -1
	local single = data ~= nil and data.roleLimit ~= -1
	local singleBuyLimits = data and data.roleLimit
	local wholeBuyLimits = data and data.allLimit
	price = tonumber(price) or 0
	---------------------------------
	--dump({whole=whole, single=single})
	local maxNum = 0
	if whole then -- 全服限购
		if single then -- 全服限购 && 个人限购
			maxNum = math.min(data.roleLimitLeft, data.mWholeRemaining)
		else -- 全服限购 && 个人不限购
			maxNum = data.mWholeRemaining
		end
	else -- 全服不限购
		if single then -- 全服不限购 && 个人限购
			maxNum = data.roleLimitLeft
		else -- 全服不限购 && 个人不限购
			maxNum = MpropOp.maxOverlay(protoId)
		end
	end
	
	--dump(maxNum, "maxNum")
	
	local MChoose = require("src/functional/ChooseQuantity")
	local buyWay,ingotKind = 0,game.getStrByKey("ingot")
	if G_NO_OPEN_PAY then
		buyWay = 1
		ingotKind = game.getStrByKey("bind_ingot")
	end
    local realMaxNum = 0
    if buyWay == 0 then
   		realMaxNum = math.floor(MRoleStruct:getAttr(PLAYER_INGOT) / price)
   	elseif buyWay == 1 then
   		realMaxNum = math.floor(MRoleStruct:getAttr(PLAYER_BINDINGOT) / price)
    else
   		realMaxNum = math.floor(MRoleStruct:getAttr(PLAYER_MONEY) / price) 
   	end
    if realMaxNum == 0 then
        realMaxNum = 1
    end
    if realMaxNum < maxNum then
        maxNum = realMaxNum
    end
	local box = MChoose.new(
	{
		title = "购买物品",
		parent = getRunScene(),
		tag = tag,
		config = { sp = 1, ep = maxNum, cur = maxNum == 0 and 0 or 1 },
		builder = function(box, parent)
			local cSize = parent:getContentSize()
			
			box:buildPropName(MPackStruct:buildGirdFromProtoId(protoId), false)
			
			local Mprop = require "src/layers/bag/prop"
			-- 物品图标
			local icon = Mprop.new(
			{
				protoId = protoId,
				cb = "tips",
			})
			
			Mnode.addChild(
			{
				parent = parent,
				child = icon,
				pos = cc.p(70, 264),
			})
			
			box.icon = icon
			
			local nodes = {}
			
			if data and data.roleLimit ~= -1 then
				nodes[#nodes+1] = Mnode.createLabel(
				{
					src = (protoId == 1076 and "限购" or game.getStrByKey("single_buy_limits")) .. ": " .. (data.roleLimit-data.roleLimitLeft) .."/" .. data.roleLimit,
					color = MColor.lable_yellow,
					size = 20,
					outline = false,
				})
			end
				
			if data and data.wholeRemaining ~= -1 then
				nodes[#nodes+1] = Mnode.createLabel(
				{
					src = game.getStrByKey("whole_buy_limits") .. ": " .. (data.allLimit-data.wholeRemaining) .. "/" .. data.allLimit,
					color = MColor.lable_yellow,
					size = 20,
					outline = false,
				})
			end
			
			
			local TotalPrice = Mnode.createKVP(
			{
				k = Mnode.createLabel(
				{
					src = game.getStrByKey("buy_totle_price").." ",
					color = MColor.lable_yellow,
					size = 20,
					outline = false,
				}),
				
				v = {
					src = "",
					color = MColor.lable_yellow,
					size = 20,
				},
			})
			
			nodes[#nodes+1] = TotalPrice
			
			Mnode.addChild(
			{
				parent = parent,
				child = Mnode.combineNode(
				{
					nodes = nodes,
					ori = "|",
					align = "l",
					margins = 5,
				}),
				
				anchor = cc.p(0, 0.5),
				--pos = cc.p(153, 243),
				pos = cc.p(130, 264),
			})
			
			box.TotalPrice = TotalPrice
		end,
		
		handler = function(box, value)
			local secondaryPass = require("src/layers/setting/SecondaryPassword")
			if not secondaryPass.isSecPassChecked() then
				secondaryPass.inputPassword()
				return
			end
			--------------------------------------------------
			local MShopOp = require "src/layers/shop/ShopOp"
			MShopOp:buyProtoId(buyWay, protoId, value)

			--传音号角特殊处理
			if protoId == 1000 then
				local chatLayer =getRunScene():getChildByTag(305)
				if chatLayer and chatLayer.isShow and chatLayer.isShow == true and chatLayer.choseTrumpetCallBack then 
					chatLayer.choseTrumpetCallBack()
				end      
			end
			
			if box then removeFromParent(box) box = nil end
		end,
		
		onValueChanged = function(box, value)
			box.icon:setOverlay(value)
			box.TotalPrice:setValue(price * value .. " " .. ingotKind)
		end,
	})
end

propOutput = function(protoId)
local tag = 9901
local ref = getRunScene()
if ref ~= nil then
	local old = ref:getChildByTag(tag)
	if old then old:removeFromParent() end
end
--------------------------------------------
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
local Mbaseboard = require "src/functional/baseboard"
local MPropOutput = require "src/config/PropOutputWayOp"
--------------------------------------------
-- 物品等级
local level = MpropOp.levelLimits(protoId)
-- 使用职业
local school = MpropOp.schoolLimits(protoId)
-- 使用性别
local sex = MpropOp.sexLimits(protoId)
--------------------------------------------------------
local size = 20
local color = MColor.lable_yellow
--------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/bg/bg27.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -5, y = 5 },
	},
	title = {
		src = "购买物品",
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

local rootSize = root:getContentSize()

-- local bg = Mnode.createSprite(
-- {
-- 	parent = root,
-- 	src = "res/common/bg/bg27-4.png",
-- 	anchor = cc.p(0.5, 0),
-- 	pos = cc.p(rootSize.width/2, 22),
-- })
local bg_size = cc.size(381, 464)
local bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(10, 10),
        bg_size,
        5
    )
    
--------------------------------------------------------
-- 标题栏
local title_bg = Mnode.createSprite(
{
	parent = bg,
	src = "res/common/bg/bg27-4-3.png",
	anchor = cc.p(0.5, 1),
	pos = cc.p(bg_size.width/2, bg_size.height-10),
})

local title_bg_size = title_bg:getContentSize()

-- 物品名字
Mnode.createLabel(
{
	parent = title_bg,
	src = MpropOp.name(protoId),
	color = MpropOp.nameColor(protoId),
	anchor = cc.p(0, 0.5),
	pos = cc.p(10, title_bg_size.height/2),
	size = size,
})

-- 是否绑定
Mnode.createLabel(
{
	parent = title_bg,
	src = game.getStrByKey("not")..game.getStrByKey("theBind"),
	color = MColor.green,
	anchor = cc.p(0, 0.5),
	pos = cc.p(200, title_bg_size.height/2),
	size = size,
})

-- 物品等级
local n_level = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = "LV.",
		size = size,
		color = color,
	}),
	
	v = {
		src = tostring(level),
		size = size,
		color = MRoleStruct:getAttr(ROLE_LEVEL) >= level and MColor.green or MColor.red,
	},
})

Mnode.addChild(
{
	parent = title_bg,
	child = n_level,
	anchor = cc.p(0, 0.5),
	pos = cc.p(280, title_bg_size.height/2),
})

-- 物品图标
local icon = Mprop.new(
{
	protoId = protoId,
})

Mnode.addChild(
{
	parent = root,
	child = icon,
	pos = cc.p(68, 375),
})

-- 使用职业
local n_school = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("school").."：",
		size = size,
		color = color,
	}),
	
	v = {
		src = Mconvertor:school(school),
		size = size,
		color = (school~= Mconvertor.eWhole and school ~= MRoleStruct:getAttr(ROLE_SCHOOL)) and  MColor.red or MColor.green,
	},
})

Mnode.addChild(
{
	parent = root,
	child = n_school,
	anchor = cc.p(0, 0.5),
	pos = cc.p(136, 395),
})

-- 使用性别
local n_sex = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("sex").."：",
		size = size,
		color = color,
	}),
	
	v = {
		src = Mconvertor:sexName(sex),
		size = size,
		color = (sex ~= Mconvertor.eSexWhole and sex ~= MRoleStruct:getAttr(PLAYER_SEX)) and  MColor.red or MColor.green,
	},
})

Mnode.addChild(
{
	parent = root,
	child = n_sex,
	anchor = cc.p(0, 0.5),
	pos = cc.p(136, 355),
})

-- 分割线
createTitleLine(bg, cc.p(bg_size.width/2, 300), 346, cc.p(0.5,0.5))


-- 标题线
Mnode.createSprite(
{
	parent = bg,
	src = "res/common/bg/bg27-4-2.png",
	pos = cc.p(bg_size.width/2, 270),
})
----------------------------------------------------------
-- 获得途径
Mnode.createLabel(
{
	parent = bg,
	src = "获得途径",
	size = 22,
	color = MColor.lable_yellow,
	pos = cc.p(bg_size.width/2, 270),
})
----------------------------------------------------------
local way = MpropOp.outputWay(protoId)
if #way > 0 then
	-- 数据
	local list = {}
	for i, v in ipairs(way) do
		local finx = tonumber(way[i])
		if finx then
			local record = MPropOutput:record(finx)
			if not record then break end
			--dump(record, "record")
			list[#list+1] = {id = finx, record = record}
		end
	end
	---------------------------------------------------------------
	
	local focused = nil
	---------------------------------------------------------------
	-- TableView
	local TextureSize = cc.size(344, 57)
    local paddingWidth, paddingHeight = 35, 10
	local iSize = cc.size(TextureSize.width + paddingWidth, TextureSize.height + paddingHeight)    --点到padding也会触发点击事件
	local vSize = cc.size(TextureSize.width + paddingWidth, 240)
	local tableView = cc.TableView:create(vSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:setDelegate()
	tableView:addSlider("res/common/slider.png")
	
	
	tableView:registerScriptHandler(function(tv)
		return #list
	end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	tableView:registerScriptHandler(function(tv, idx)
		return iSize.height, iSize.width
	end, cc.TABLECELL_SIZE_FOR_INDEX)
	
	local buildCellContent = nil
	tableView:registerScriptHandler(function(tv, idx)
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
	
	tableView:registerScriptHandler(function(tv, cell)
		cell:removeAllChildren()
	end, cc.TABLECELL_WILL_RECYCLE)
	
	tableView:registerScriptHandler(function(tv, cell)
		
		--dump("TABLECELL_HIGH_LIGHT")
	end, cc.TABLECELL_HIGH_LIGHT)
	
	tableView:registerScriptHandler(function(tv, cell)
		
		--dump("TABLECELL_UNHIGH_LIGHT")
	end, cc.TABLECELL_UNHIGH_LIGHT)
	
	buildCellContent = function(tv, idx, cell)
        print(focused)
		local cell_size = cell:getContentSize()
        local bg = Mnode.createScale9Sprite(
        {
	        src = "res/common/scalable/item.png",
	        cSize = TextureSize,
            parent = cell,
	        pos = cc.p(cell_size.width/2, cell_size.height/2),
	        tag = tag_cellBg,
        })
    
        local bg_sel = Mnode.createScale9Sprite(
	    {
		    src = "res/common/scalable/item_sel.png",
		    cSize = TextureSize,
	    })
        bg_sel:setTag(tag_bgSel)
        bg_sel:setPosition(getCenterPos(bg))
        bg_sel:setVisible(idx == focused)
        bg:addChild(bg_sel)

		local bgSize = bg:getContentSize()
		
		local cur = list[idx+1]
		
		local n_label = Mnode.createLabel(
		{
			parent = bg,
			src = MPropOutput:name(cur.record),
			size = size,
			color = MColor.lable_yellow,
			pos = cc.p(bgSize.width/2, bgSize.height/2),
		})
	end
	
	tableView:registerScriptHandler(function(tv, cell)
		local idx = cell:getIdx()
		dump("idx="..idx, "---------")
		
		if idx ~= focused then
			local content = cell:getChildByTag(tag_cellBg)
			if content then content:getChildByTag(tag_bgSel):setVisible(true) end
			
			if focused then
				local last = tv:cellAtIndex(focused)
				if last then
					content = last:getChildByTag(tag_cellBg)
					content:getChildByTag(tag_bgSel):setVisible(false)
				end
			end
			
			focused = idx
			--------------------------------------
			local cur = list[idx+1]
			local finx = cur.finx
			local record = cur.record
			
			-- 直接调用会崩溃，尚未明确是何原因
			performWithDelay(root, function()
				removeFromParent(root)
				if G_MAINSCENE.map_layer:isHideMode() and G_MAINSCENE.mapId ~= 6017 then
					TIPS( {str = game.getStrByKey("current_map"), type = 1})
					return 
				end
				__GotoTarget({ ru = MPropOutput:goto(record) })
			end, 0.0)
			--------------------------------------
		end
	end, cc.TABLECELL_TOUCHED)
	
	
	tableView:reloadData()
	
	Mnode.addChild(
	{
		parent = bg,
		child = tableView,
		anchor = cc.p(0.5, 1),
		pos = cc.p(bg_size.width/2, 250),
	})
end
--------------------------------------------------------
local Manimation = require "src/young/animation"
Manimation:transit(
{
	ref = getRunScene(),
	node = root,
	--trend = "-",
	zOrder = 200,
	swallow = true,
	tag = tag,
})
--------------------------------------------------------
return root
end


-- 商城表
local tShopCfg =  getConfigItemByKeys("MallDB", {
	"q_shop_type",
	"q_sell",
})
local nShopType = 0--元宝商城
if G_NO_OPEN_PAY then
	nShopType = 1--绑元商城
end
		
-- 货币物品不足，通知客户端引导
g_msgHandlerInst:registerMsgHandler(ITEM_SC_MAT_NOT_ENOUGH, function(buff)
	dump("货币物品不足，通知客户端引导")
	local t = g_msgHandlerInst:convertBufferToTable("ItemNotEnoughProtocol", buff)
	--dump(t, "货币物品不足，通知客户端引导")
	
	--do return end
	local MPackStruct = require "src/layers/bag/PackStruct"
	local matType = t.matType --int类型，类型（1金币，2元宝，3绑定元宝，4物品）
	local protoId = t.matID -- int类型，物品ID，matType为4的时候值才不为0
	dump({matType=matType, protoId=protoId, "货币物品不足，通知客户端引导"})
	
	if matType == 4 and protoId ~= 0 then
		-- 物品类型
		local isMedicine = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eMedicine
		if isMedicine and protoId ~= 1043 then return end

		local item = tShopCfg[nShopType][protoId]
		if item and not G_NO_OPEN_PAY then -- 元宝商城有售
			--dump(item, "item")
			local MShopOp = require "src/layers/shop/ShopOp"
			MShopOp:LimitsBuyQuery(item.q_id, function(data)
				shortcut_buy(protoId, item.q_gold, data)
			end)
		elseif item and G_NO_OPEN_PAY then
			local MShopOp = require "src/layers/shop/ShopOp"
			MShopOp:LimitsBuyQuery(item.q_id, function(data)
				shortcut_buy(protoId, item.q_bindgold, data)
			end)
		else
			propOutput(protoId)
		end
	elseif matType == 2 then
		if protoId and protoId>0 then
			MessageBoxYesNo(nil,string.format(game.getStrByKey("noGold3"), protoId),function() __GotoTarget( { ru = "a33" } ) end)
		else
			MessageBoxYesNo(nil,game.getStrByKey("noGold"),function() __GotoTarget( { ru = "a33" } ) end)
		end
		
	elseif matType == 1 then
		local item = tShopCfg[nShopType][2002]
		if item then
			if G_NO_OPEN_PAY then
				shortcut_buy(2002, item.q_bindgold) -- 金条
			else
				shortcut_buy(2002, item.q_gold) -- 金条
			end
		end
	end
end)