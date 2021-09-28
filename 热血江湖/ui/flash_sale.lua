-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_flashsale = i3k_class("wnd_flashsale", ui.wnd_base)

local ITEMNAME = "ui/widgets/xstmt2"

function wnd_flashsale:ctor()
	self._time = 0
end

function wnd_flashsale:configure( )
	local widgets = self._layout.vars
	self.coloseBtn = widgets.closeBtn
	self.coloseBtn:onClick(self, self.onCloseUI)
	self.time = widgets.time
	self.desc = widgets.desc
	self.listScroll = widgets.listScroll
	self.reward_icon = widgets.reward_icon
	self.reward_get_icon = widgets.reward_get_icon
	self.reward_btn = widgets.reward_btn
	self.rewardBox = widgets.rewardBox
	-- self.vipbuytxt = widgets.vipbuytxt
	-- self.buybtn = widgets.buybtn
	-- self.canbuytimes = widgets.canbuytimes
	-- self.oldPrice = widgets.oldPrice
	-- self.newPrice = widgets.newPrice
	-- self.zhekou = widgets.zhekou
	-- self.title = widgets.title
	-- self.leftBtn = widgets.leftBtn
	-- self.rightBtn = widgets.rightBtn
	-- self.leftBtn:onClick(self,self.selectLeft)
	-- self.rightBtn:onClick(self,self.selectRight)
	-- self.content = widgets.content
	-- self.imagebg = widgets.imagebg
	-- self.hadbuycount = widgets.hadbuycount
	-- self.barpercent = widgets.barpercent
end

function wnd_flashsale:refresh(info , index)
	self.info = info
	self.index = index
	--self.title:setText(self.info.cfg.title)
	--self.content:setText(self.info.cfg.content)
	self.desc:setText(info.cfg.content)
	self:excessTime(info.cfg.time,info.cfg.buyEndTime)
	self:updateScroll()
	self:updateRedPoint()
	self:updateRewardBox()
end
function wnd_flashsale:excessTime(time,buyendTime)
	----[[倒计时每个板子上写一个回调函数，把self 放到onupdate里（小于三天的时候，三天到一年内显示截至时间，否则显示不限时）
	local cur_Time =  i3k_game_get_time()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local lastDay = g_i3k_get_day(time.endTime)
	local days = lastDay - totalDay   --+ 1
	local havetime =(time.endTime - cur_Time- self._time)
	local min = math.floor(havetime / 60 %60)
	local hour = math.floor(havetime/3600%24)
	local day = math.floor(havetime/3600/24)
	if days <=  3  then--
		local time1 = havetime - self._time
		local str = string.format("<c=yellow>%d </c>天 <c=yellow>%d </c> 时 <c=yellow>%d </c> 分",day,hour,min)
		self.time:setText("活动时间："..str )
	else
		local finitetime =  g_i3k_get_ActDateRange(time.startTime, time.endTime)
		self.time:setText("活动时间："..finitetime)
	end
	--[[if cur_Time > buyendTime then
		self.buybtn:disableWithChildren()
	end--]]
end
function wnd_flashsale:OnUpdate(dTime)
	-- if self._time ~= 0 then
	-- 	self._time = self._time + dTime
	-- end
end
function wnd_flashsale:updateScroll()
	local goods = self.info.cfg.goods
	-- if #goods > 1 then
	-- 	self.leftBtn:show()
	-- 	self.rightBtn:show()
	-- else
	-- 	self.leftBtn:hide()
	-- 	self.rightBtn:hide()
	-- end
	self.listScroll:removeAllChildren()
	for i,info in ipairs(goods) do
		local item = require(ITEMNAME)()
		self.listScroll:addItem(item)
		for i = 1 , 6 do
			local v = info.items[i]
			if v then
				item.vars["btn"..i]:onClick(self,self.onTips,v.id)
				item.vars["iconbg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
				item.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
				item.vars["count"..i]:setText("X"..v.count)
				item.vars["suo"..i]:setVisible(v.id > 0)
			else
				item.vars["bg"..i]:hide()
			end
		end
		if math.abs(info.moneyid) ~= 1 then
			-- 铜钱的图片id为30
			item.vars.moneyimg1:setImage(g_i3k_db.i3k_db_get_icon_path(30))
			item.vars.moneyimg2:setImage(g_i3k_db.i3k_db_get_icon_path(30))
		end

		item.vars.lock1:setVisible(info.moneyid > 0)
		item.vars.lock2:setVisible(info.moneyid > 0)
		local zhe = math.ceil(info.nowprice / info.origprice * 10)
		if zhe > 0 and zhe < 10 then
			item.vars.zhekou:show()
			item.vars.zhekou:setImage("xstm#"..zhe)
		else
			item.vars.zhekou:hide()
		end
		item.vars.name:setText(info.goodsname)
		item.vars.oldPrice:setText(info.origprice)
		item.vars.newPrice:setText(info.nowprice)
		local leftTime = self:getSelfBuyTimes(info) - (self.info.log[info.id] or 0)
		info.limitTimes = leftTime
		item.vars.canbuytimes:setText(string.format("可购次数：%d",leftTime) )
		if leftTime == 0 then
			item.vars.canbuytimes:setTextColor(g_i3k_get_red_color())
		end
		local picture = info.icon
		item.vars.buyBtn:onClick(self,self.flashsale_Tip, info)
	end
end

function wnd_flashsale:onTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_flashsale:flashsale_Tip(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_Flash_Sale_Buy)
	g_i3k_ui_mgr:RefreshUI(eUIID_Flash_Sale_Buy, info)
end

function wnd_flashsale:onBuy(info,count)
	local giftsTb = info.items
	local isEnoughTable = { }
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		local gift = {}
		for i,v in pairs (isEnoughTable) do
			table.insert(gift,{id = i,count = v*count})
		end
		i3k_sbean.flashsale_buy(self.info.effectiveTime, self.info.cfg.id, info.id, self.index, gift, info.nowprice, info.moneyid, count)
		g_i3k_ui_mgr:CloseUI(eUIID_Flash_Sale_Buy)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
end

function wnd_flashsale:getSelfBuyTimes( info )
	local curTimes = 0
	for i = #info.v2t, 1, -1 do
		if g_i3k_game_context:GetVipLevel() >= info.v2t[i].vip then
			vipEnough = true
			curTimes = info.v2t[i].times
			break
		end
	end
	return curTimes
end

function wnd_flashsale:updateRedPoint()
	local redPoint = false
	for k , info  in pairs(self.info.cfg.goods) do
		if g_i3k_game_context:GetLevel() >= info.levelReq then
			if self:getSelfBuyTimes(info) - (self.info.log[info.id] or 0) > 0 then
				redPoint = true
				break
			end
		end
	end
	if redPoint == false and (self.info.isOpen == 1) then
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_FALSHSALE_RED)
		g_i3k_game_context:OnFlashsaleShowStateChangedHandler(true,g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_FALSHSALE_RED))
	end
end

function wnd_flashsale:updateRewardBox()
	local info = self.info
	--如果没有宝箱奖励，不显示宝箱
	local giftsTb = info.cfg.treasureBox
	if next(giftsTb) == nil then
		self.rewardBox:hide()
		return
	end
	local isGet = info.isOpen == 1  --isOpen == 1 have got

	self.reward_get_icon:setVisible(isGet)
	self.reward_icon:setVisible(not isGet)
	if isGet then
		self._layout.anis.c_bx6.stop()
	else
		self._layout.anis.c_bx6.play()
	end

	self.reward_btn:onClick(self, function()
		if isGet then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15561))
		else
			local isEnoughTable = { }
			for i,v in pairs(giftsTb) do
				isEnoughTable[v.id] = v.count
			end
			local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
			if isEnough then
				i3k_sbean.falshsale_open_box_req(info.effectiveTime, info.cfg.id, self.index, giftsTb)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
			end
		end
	end)
end

function wnd_create(layout)
	local wnd = wnd_flashsale.new()
	wnd:create(layout)
	return wnd
end
