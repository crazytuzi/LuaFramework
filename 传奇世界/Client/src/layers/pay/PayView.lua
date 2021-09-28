local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local MObserver = require "src/young/observer"
local target = cc.Application:getInstance():getTargetPlatform()

require "src/layers/pay/PayCallback"

-----------------------------------------------------
observable = MObserver.new()

-- 观察者监听
register = function(self, observer)
	self.observable:register(observer)
end

-- 观察者取消监听
unregister = function(self, observer)
	self.observable:unregister(observer)
end

-- 向观察者发送广播
broadcast = function(self, ...)
	self.observable:broadcast(self, ...)
end
-----------------------------------------------
-- 礼品卡ID
_G.G_Gift_Card_ID = 0
--dump("G_Gift_Card_ID", "*******************************************************")
g_msgHandlerInst:registerMsgHandler(PUSH_SC_MSG_GHID, function(buf)
	local id = buf:popInt()
	--dump(id, "G_Gift_Card_ID+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	--dump(_G.G_Gift_Card_ID, "G_Gift_Card_ID+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	_G.G_Gift_Card_ID = id
	--dump(_G.G_Gift_Card_ID, "_G.G_Gift_Card_ID+++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	--performWithDelay(self, onEnterGame, 3)
end)
-----------------------------------------------
local maneki_plan = nil
local grow_plan = nil
local month_card = 5

g_msgHandlerInst:registerMsgHandler(ACTIVITY_SC_CHARGE_RET, function(buf)
	--maneki_plan = buf:popBool()
	--grow_plan = buf:popBool()
	
	local t = g_msgHandlerInst:convertBufferToTable("ActivityChargeRet", buf)
	--dump(t, "ACTIVITY_SC_CHARGE_RET")
	month_card = t.monthCardSurplus
	--dump({maneki_plan = maneki_plan, grow_plan = grow_plan, month_card=month_card})
	M:broadcast("buy-item-changed")
end)
-----------------------------------------------
-- 充值相关信息推送
local tPayInfo = {}
g_msgHandlerInst:registerMsgHandler(LITTERFUN_SC_NOTIFY_CHARGE, function(buf)
	table.clear(tPayInfo)
	local pay_item_count = buf:popChar()
	for i = 1, pay_item_count do
		local pay_item = buf:popInt()
		local num_purchased = buf:popInt()
		tPayInfo[pay_item] = num_purchased
	end
	
	M:broadcast("buy-item-changed")
end)
-----------------------------------------------
-- 充值结果返回
g_msgHandlerInst:registerMsgHandler(FRAME_SC_CHARGE_REP, function(buf)
	local result = buf:popInt()
	--dump(result, "充值结果返回")
	TIPS( { type = 1  , str = game.getStrByKey("pay_charge") }  )
	M:broadcast("buy-succeed")
end)


local tExtra = {
	{ q_logo = "maneki", q_limit = 30, q_rmb = 30, flag = 1, q_freeyb = 30, q_double = 0, }, -- 招财进宝
	{ q_logo = "grow", q_limit = 100, q_rmb = 100, flag = 2, q_freeyb = 100, q_double = 0, }, -- 成长计划
}

local tExtra_dollar = {
	{ q_logo = "maneki", q_limit = 4.99, q_rmb = 30, flag = 1, q_freeyb = 0, q_double = 0, }, -- 招财进宝
	{ q_logo = "grow", q_limit = 19.99, q_rmb = 128, flag = 2, q_freeyb = 0, q_double = 0, }, -- 成长计划
}

-- 月卡
local tMonthCard = { q_logo = "MonthCard", q_limit = 30, q_rmb = 30, flag = 3, q_freeyb = 0, q_double = 0, }
--[[
dump({PLATFORM_OS_ANDROID = cc.PLATFORM_OS_ANDROID,
      PLATFORM_OS_IPHONE = cc.PLATFORM_OS_IPHONE,
	  PLATFORM_OS_IPAD = cc.PLATFORM_OS_IPAD,
	  PLATFORM_OS_MAC = cc.PLATFORM_OS_MAC,
	  PLATFORM_OS_WINDOWS = cc.PLATFORM_OS_WINDOWS,
	  PLATFORM_OS_LINUX = cc.PLATFORM_OS_LINUX})
]]


local build_pay_item = function()
	local is_dl = true
	
	local cfg_file = "src/config/payCfg"	
	local tPay = require(cfg_file)
	
	local result = {}
	
	--result[#result+1] = tMonthCard	
	if not isIOS() then
		-- 招财进宝
		if maneki_plan then
			result[#result+1] = is_dl and tExtra[1] or tExtra_dollar[1]
		end
		
		-- 成长计划
		if grow_plan then
			result[#result+1] = is_dl and tExtra[2] or tExtra_dollar[2]
		end
	end
	
	for i, v in ipairs(tPay) do
		if not v.q_terrace then
			result[#result+1] = v
		else
			local plats = tostring(v.q_terrace)
			local cur_plat = tostring(target)
			
			if string.find(plats, cur_plat, 1, true) then
				-- 限制条件
				local num_limit = tonumber(v.q_number)
				if num_limit and num_limit > 0 and num_limit == tPayInfo[v.q_limit] then
				else
					result[#result+1] = v
				end
			end
		end
	end
	
	return result
end

local enterPayView = false
local clickMonthCard = false

new = function(params)
------------------------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local MMenuButton = require "src/component/button/MenuButton"
local MProcessBar = require "src/layers/role/ProcessBar"
------------------------------------------------------------------------------------
local res = "res/layers/pay/"
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{ 
	src = "res/common/2.jpg",
})

-- 声音
if not enterPayView then
	performWithDelay(root, function()
		AudioEnginer.playLiuEffect("sounds/liuVoice/43.mp3", false)
	end, 1.1)
	
	enterPayView = true
end
		

local rootSize = root:getContentSize()
createLabel(root,game.getStrByKey("title_pay"),cc.p(rootSize.width/2,rootSize.height-45),cc.p(0.5,0.5),26,true,nil,nil,MColor.lable_yellow)
local upBg_size = cc.size(910,90)
--local upBg = createScale9Frame(
--        root,
--        "res/common/scalable/panel_outer_base_1.png",
--        "res/common/scalable/panel_outer_frame_scale9_1.png",
--        cc.p(25, rootSize.height-176),
--        upBg_size,
--        5
--    )
--createSprite(root,"res/common/bg/infoBg7.png",cc.p(rootSize.width/2,rootSize.height-131))

--createSprite(upBg,"res/common/bg/infoBg7-1.png",cc.p(upBg_size.width/2,upBg_size.height/2))
--createSprite(upBg,"res/layers/pay/16.png",cc.p(upBg_size.width/2,upBg_size.height/2))

local downBg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 38),
        cc.size(896,501),
        5
    )
--createSprite(root,"res/common/bg/bg30.png",cc.p(rootSize.width/2,rootSize.height/2-76))
------------------------------------------------------------------------------------
local pay_item = build_pay_item()
local cur_pay_item = nil
local cur_pay_rate = 10

------------------------------------------------------------------------------------
local resSize = TextureCache:addImage("res/common/table/cell7.png"):getContentSize()
local spaceh = 5
local spacew = 5
local girdSize = cc.size(resSize.width + spacew * 2, resSize.height + 2*spaceh)
local viewSize = cc.size(girdSize.width * 4, girdSize.height * 2)
local girdView = YGirdView:create(viewSize)
girdView:viewSizeSelfAdaption(false)

Mnode.addChild(
{
	parent = downBg,
	child = girdView,
	pos = cc.p(downBg:getContentSize().width/2, downBg:getContentSize().height/2),
})
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

-- 每个网格是否一样大小
local IS_CELLSIZE_IDENTICAL = function(gv)
	return true
end

-- 每个网格的大小
local SIZE_FOR_CELL = function(gv, idx)
	return girdSize.width, girdSize.height
end
----------------------------------------------------------------
-- 网格总数
local NUMS_IN_GIRD = function(gv)
	return #pay_item
end
----------------------------------------------------------------
-- 一组的网格数目
local NUMS_IN_GROUP = function(gv)
	return 4
end

-- 单击事件
local CELL_TOUCHED = function(gv, cell)
	local idx = cell:getIdx()
	--dump(idx, "idx")
	
	---[[
	-- 请求充值
	
	--[[
	-- 声音
	if idx == 0 and not clickMonthCard then
		performWithDelay(root, function()
			AudioEnginer.playLiuEffect("sounds/liuVoice/44.mp3", false)
		end, 0.0)
		
		clickMonthCard = true
	end
	
	
	if idx == 0 and month_card > 3 then
		DATA_Activity:openID( 5 )
		return
	end
	--]]
	
	--dump("请求充值")
	--g_msgHandlerInst:sendNetDataByFmt(FRAME_CS_CHARGE_REQ, "is", G_ROLE_MAIN.obj_id, cell.flag)
	g_msgHandlerInst:sendNetDataByTable(FRAME_CS_CHARGE_REQ, "FrameChargeReqProtocol", {type=cell.flag})
	cur_pay_item = cell.money
	cur_pay_rate = cell.ingot/cell.money

	addNetLoading(FRAME_CS_CHARGE_REQ, FRAME_SC_CHARGE_REQ)
	--]]
end

-- 构建标号为idx的网格
local CELL_AT_INDEX = function(gv, idx)
	--cclog("-----------idx = " .. idx .. "--------")
	local width, height = SIZE_FOR_CELL(gv, idx)
	
	local createContent = function(cell)
		local item = cc.Sprite:create("res/common/table/cell7.png")
		--local circle = cc.Sprite:create("res/layers/pay/circle.png")
		--local textBg = cc.Sprite:create("res/common/bg/titleBg-3.png")
		--local circleBg = cc.Sprite:create("res/common/table/cell7_1.png")
		local itemSize = item:getContentSize()
		--local circleSize = circle:getContentSize()
		
		--[[
		if idx == 0 then
			Mnode.addChild(
			{
				parent = item,
				child = cc.Sprite:create("res/layers/pay/month_card_label.png"),
				anchor = cc.p(0, 1),
				pos= cc.p(-10, itemSize.height+10),
				zOrder = 1,
			})
		end
		--]]
		
		local cur = pay_item[idx+1]
		
		local money = cur.q_rmb
		local show_money = cur.q_limit
		local is_first_pay = not tPayInfo[money] or tPayInfo[money] == 0
		local ingot = money * 10
		local is_double_ingot = is_first_pay and cur.q_double == 1
		if is_double_ingot then ingot = ingot * 2 end
		local count_limit_str = cur.q_number and cur.q_number > 0 and ("("..game.getStrByKey("limit")..(tPayInfo[money] or 0) .. "/" .. cur.q_number .. game.getStrByKey("times")..")") or ""
		
		cell.flag = cur.flag or 0
		cell.money = money
		cell.ingot = ingot
		cell.show_money = show_money
		
		Mnode.createSprite(
		{
			parent = item,
			src = res .. "item/" .. (cur.q_logo) .. ".png",
			pos = cc.p(itemSize.width/2, itemSize.height/2),
		})
		

        local num_yb_root = Mnode.createNode(
        {
	        parent = item,
            anchor = cc.p(0.5, 0.5),
	        pos = cc.p(itemSize.width/2, itemSize.height - 30),
        })

        local number_yb = MakeNumbers:create("res/component/number/17.png", ingot, -2, true)
        Mnode.addChild(
		{
			parent = num_yb_root,
			child = number_yb,
			pos = cc.p(0, 0),
			anchor = cc.p(0, 0),
		})

        local yb_node = Mnode.createSprite(
		{
			parent = num_yb_root,
			src = "res/component/number/yb.png",
            anchor = cc.p(0, 0),
			pos = cc.p(number_yb:getContentSize().width, -2),
		})

        num_yb_root:setContentSize(cc.size(number_yb:getContentSize().width + yb_node:getContentSize().width, number_yb:getContentSize().height))

--		local title = ingot .. game.getStrByKey("faction_yuanbao") .. (cell.flag == 1 and game.getStrByKey("pay_zhaocai") or (cell.flag == 2 and game.getStrByKey("pay_grow") or ""))
		--if idx == 0 then title = game.getStrByKey("month_card") end
--		Mnode.createLabel(
--		{
--			parent = item,
--			src = title,
--			size = 25,
--			color = MColor.yellow,
--			pos = cc.p(item:getContentSize().width/2, item:getContentSize().height - 30),
--		})
		
		if is_double_ingot then
			Mnode.overlayNode(
			{
				parent = item,
				{
					node = Mnode.createLabel(
					{
						src = game.getStrByKey("pay_firstPayDouble"),
						size = 25,
						color = MColor.white,
					}),
					
					origin = "l",
					offset = { x = 25, },
				}
			})
		end
		
		--local bg = cc.Sprite:create("res/common/bg/inputBg2.png")
		--local cz_text = ((g_Channel_tab.language == "hk" or g_Channel_tab.language == "tw") and "＄" or "￥") .. cur.q_limit .. (cell.flag ~= 0 and "("..game.getStrByKey("limit").."1"..game.getStrByKey("times")..")" or count_limit_str)
		
		--[[
		if idx == 0 then
			if month_card == 0 then
				cz_text = "￥" .. cur.q_limit
			else
				cz_text = "剩余" .. month_card .. "天"
				if month_card < 4 then
					cz_text = cz_text .. "(可续费)"
				end
			end
		end
		--]]
		
        --[[
		Mnode.overlayNode(
		{
			parent = item,
			{
				node = Mnode.createLabel(
				{
					src = cz_text,
					size = 22,
					color = MColor.white,
				}),
				offset = { x = -10, y = -85, },
			}
		})
        --]]

        local num_rmb_root = Mnode.createNode(
        {
	        parent = item,
            anchor = cc.p(0.5, 0.5),
	        pos = cc.p(itemSize.width/2, 28),
        })

        local rmb_node = Mnode.createSprite(
		{
			parent = num_rmb_root,
			src = "res/component/number/rmb.png",
            anchor = cc.p(0, 0),
			pos = cc.p(0, 0),
		})

        local number_rmb = MakeNumbers:create("res/component/number/16.png", cur.q_limit, -4, true)
        Mnode.addChild(
		{
			parent = num_rmb_root,
			child = number_rmb,
			pos = cc.p(rmb_node:getContentSize().width, 0),
			anchor = cc.p(0, 0),
		})

        num_rmb_root:setContentSize(cc.size(number_rmb:getContentSize().width + rmb_node:getContentSize().width, number_rmb:getContentSize().height))
		
		Mnode.addChild(
		{
			parent = cell,
			child = item,
			pos = cc.p(width/2, height/2),
		})
--		Mnode.addChild({
--			parent = item,
--			child = textBg,
--			pos= cc.p(width/2,height-30),
--		})
--		Mnode.addChild({
--			parent = item,
--			child = circleBg,
--			pos= cc.p(width/2,height/2-5),
--		})
--		Mnode.addChild({
--			parent = circleBg,
--			child = circle,
--			pos = cc.p(width/2-15, height/2-50),
--		})
	end
	
	local cell = gv:dequeueCell()
	if not cell then
		cell = YGirdViewCell:create()
		cell:setContentSize(width, height)
		createContent(cell)
	else
		createContent(cell)
	end
	
	return cell
end
----------------------------------------------------------------
-- 网格退出视野范围
local CELL_WILL_RECYCLE = function(gv, cell)
	cell:removeAllChildren()
end

girdView:registerEventHandler(CELL_WILL_RECYCLE, YGirdView.CELL_WILL_RECYCLE)
girdView:registerEventHandler(IS_CELLSIZE_IDENTICAL, YGirdView.IS_CELLSIZE_IDENTICAL)
girdView:registerEventHandler(SIZE_FOR_CELL, YGirdView.SIZE_FOR_CELL)
girdView:registerEventHandler(CELL_AT_INDEX, YGirdView.CELL_AT_INDEX)
girdView:registerEventHandler(NUMS_IN_GIRD, YGirdView.NUMS_IN_GIRD)
girdView:registerEventHandler(NUMS_IN_GROUP, YGirdView.NUMS_IN_GROUP)
girdView:registerEventHandler(CELL_TOUCHED, YGirdView.CELL_TOUCHED)
girdView:setDelegate()
girdView:reloadData()
------------------------------------------------------------------------------------
local refresh = function(M, event)
	if event == "buy-item-changed" then
		pay_item = build_pay_item()
		girdView:reloadData()
	elseif event == "buy-succeed" then
		pay_item = build_pay_item()
		girdView:reloadData()
	end
end

downBg:registerScriptHandler(function(event)
	if event == "enter" then
		M:register(refresh)
		g_msgHandlerInst:registerMsgHandler(FRAME_SC_CHARGE_REQ, function(buf)						
			--dump("请求充值返回订单号")
			local t = g_msgHandlerInst:convertBufferToTable("FrameChargeRetProtocol", buf)
			--dump(t, "请求充值返回订单号")
			payNetLoading(true)
            local yuanbao = cur_pay_item * 10;
            local productID = "com.tencent.cqsj." .. yuanbao .. "ingot"
            local zoneid = tostring(t.worldID) .. "_" .. tostring(userInfo.currRoleStaticId)
            
            --deposit true
            print("startPay", productID, yuanbao, zoneid)
            cc.Application:getInstance():openURL("http://pay.yijiapay.net/Payment/Service/bdcb273ee32b4972ffa5849ee1452882")
            --sdkOpenUrl("http://pay.yijiapay.net/Payment/Service/bdcb273ee32b4972ffa5849ee1452882")
            --callbackTab.startPay(productID, yuanbao, zoneid)
			--sdkPay(productID, yuanbao, true, zoneid, tostring(yuanbao));
			payNetLoading(false)
		end)
	elseif event == "exit" then
		M:unregister(refresh)
		g_msgHandlerInst:registerMsgHandler(FRAME_SC_CHARGE_REQ, nil)
	end
end)
------------------------------------------------------------------------------------
-- local closeFunc = function()
-- 	removeFromParent(root, function()
-- 		TextureCache:removeUnusedTextures()
-- 	end)
-- end
-- registerOutsideCloseFunc( root , closeFunc )
------------------------------------------------------------------------------------
return root
end