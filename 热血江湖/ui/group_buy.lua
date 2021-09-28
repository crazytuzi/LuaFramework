-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_group_buy = i3k_class("wnd_group_buy", ui.wnd_base)

local ITEMNAME = "ui/widgets/sbtjdmzyt1"

function wnd_group_buy:ctor()
	self._time = 0
end

function wnd_group_buy:configure( )
	local widgets = self._layout.vars
	self.coloseBtn = widgets.closeBtn
	self.coloseBtn:onClick(self, self.onCloseUI)
	self.time = widgets.time
	self.desc = widgets.desc
	self.listScroll = widgets.listScroll
	self.vipbuytxt = widgets.vipbuytxt
	self.buybtn = widgets.buybtn
	self.canbuytimes = widgets.canbuytimes
	self.curPrice = widgets.curPrice
	self.itemname = widgets.itemname
	self.itemcount = widgets.itemcount
	self.clickbtn = widgets.clickbtn
	self.itemicon = widgets.itemicon
	self.itembg = widgets.itembg
	self.hadbuycount = widgets.hadbuycount
	self.barpercent = widgets.barpercent
end

function wnd_group_buy:refresh(info , index)
	local cfg = info.cfg
	self.info = info
	self.desc:setText(cfg.content)
	self:excessTime(cfg.time,cfg.buyEndTime)
	self:updateScroll(cfg.goods,index)
	self:updateRedPoint()
end
function wnd_group_buy:excessTime(time,buyendTime)
	----[[倒计时每个板子上写一个回调函数，把self 放到onupdate里（小于三天的时候，三天到一年内显示截至时间，否则显示不限时）
	local cur_Time = i3k_game_get_time()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local lastDay = g_i3k_get_day(time.endTime)
	local days = lastDay - totalDay   --+ 1
	local havetime =(time.endTime - cur_Time- self._time)  /60
	local sec = (time.endTime - cur_Time- self._time) %60
	local min = havetime  % 60
	local hour = havetime/60%24
	local day = math.floor(havetime/3600/24)
	if days <=  3  then--
		local time1 = havetime - self._time
		local str = string.format("%d天%d时%d分",day,hour,min)
		self.time:setText("活动时间："..str )
	else
		local finitetime =  g_i3k_get_ActDateRange(time.startTime, time.endTime)
		self.time:setText("活动时间："..finitetime)
	end
	if cur_Time > buyendTime then
		self.buybtn:disableWithChildren()
	end
end
function wnd_group_buy:OnUpdate(dTime)
	if self._time ~= 0 then
		self._time = self._time + dTime
	end
end
function wnd_group_buy:updateScroll( info , index )
	self.listScroll:removeAllChildren()
	for i = 1 , #info do
		local item = require("ui/widgets/xstgt")()
		item.vars.btn:onClick(self,self.selectGoods,i)
		item.vars.select:setTag(i)
		item.vars.iconbg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info[i].iid) )
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info[i].iid,i3k_game_context:IsFemaleRole()))
		item.vars.zhekou:hide()
		item.vars.select:hide()
		self.listScroll:addItem(item)
		local zhe , _ = self:getZheKou(i)
		if zhe then
			item.vars.zhekou:show()
			item.vars.zhekou:setImage("sc#"..zhe.."z")
		end
		if index == i then
			item.vars.select:show()
			self:updateSelectGood(index)
		end
	end
end

function wnd_group_buy:updateSelectGood( index )
	local curinfo = self.info.cfg.goods[index]
	self.vipbuytxt:setText(string.format("贵族%d%s",curinfo.vipReq,"可购买"))
	self.curPrice:setText(curinfo.price)
	self.itemname:setText(g_i3k_db.i3k_db_get_common_item_name(curinfo.iid))
	self.itemcount:setText("X"..curinfo.icount)
	self.clickbtn:onClick(self,self.onTips,curinfo.iid)
	self.itemicon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(curinfo.iid,i3k_game_context:IsFemaleRole()))
	self.itembg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(curinfo.iid) )
	self.barpercent:setPercent(0)
	local zhe ,curbuycount = self:getZheKou(index)
	local hadsetPercent = false
	for i = 1 , #curinfo.discounts do
		local tep = curinfo.discounts[i]
		self._layout.vars["zhekou"..i]:setText(tep.discount.."折")
		self._layout.vars["zhekou"..i.."_value"]:setText(tep.countReq)
		if tep.discount == zhe or zhe == nil and hadsetPercent == false then
			hadsetPercent = true
			local posx1 = self._layout.vars["value_img"..i]:getPositionX()
			local posx2 = self.barpercent:getPositionX()
			local percent = 0
			local tep2 = 0
			local posx4 = 0
			if curinfo.discounts[i+1] then
				tep2 = curinfo.discounts[i+1]
				posx4 = self._layout.vars["value_img"..(i+1)]:getPositionX()
				if zhe == 0 then
					posx4 = posx1
					posx1 = posx2
				end
			end
			if tep2 == 0 or posx4 == 0 then
				percent = 100
			else
				local width = self.barpercent:getSize().width
				local posx5 = posx4 - posx1
				if posx5 < 0 then
					posx5 = -1*posx5
				end
				percent = posx1 + (curbuycount - tep.countReq)/(tep2.countReq - tep.countReq)*posx5
				percent = (percent - posx2)/width*100
			end
			self.barpercent:setPercent(percent)
		end
	end
	if zhe then
		self.hadbuycount:setText(string.format("已团购数量为%d%s%d%s",curbuycount,",当前折扣",zhe,"折"))
	else
		self.hadbuycount:setText(string.format("已团购数量为%d%s",curbuycount,",当前没有折扣"))
	end
	local times = curinfo.restriction.times
	if self.info.log.logs[curinfo.id] then
		times = curinfo.restriction.times - self.info.log.logs[curinfo.id].dayBuyTimes
		self.canbuytimes:setText( times)
	else
		self.canbuytimes:setText(times)
	end
	self.buybtn:onClick(self,self.onBuy,{id = curinfo.id,lvl = curinfo.levelReq,vip = curinfo.vipReq,hadTimes = times > 0 ,index = index,price = curinfo.price,gifts = {{id = curinfo.iid ,count = curinfo.icount} } })
end

function wnd_group_buy:getZheKou( index )
	local curinfo = self.info.cfg.goods[index]
	local curbuycount = (self.info.buyCounts[curinfo.id] or 0)
	local zhe = nil
	for i = #curinfo.discounts,1 , -1 do
		if curbuycount >= curinfo.discounts[i].countReq then
			zhe = curinfo.discounts[i].discount
			break
		end
	end
	return zhe , curbuycount
end

function wnd_group_buy:onTips(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end
function wnd_group_buy:onBuy(sender , info )

	if g_i3k_game_context:GetDiamond(true) < info.price then
		return g_i3k_ui_mgr:PopupTipMessage("您的元宝不足")
	end

	if g_i3k_game_context:GetLevel() < info.lvl then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("您的等级不够，需要%d%s",info.lvl,"级方可购买"))
	end

	if g_i3k_game_context:GetVipLevel() < info.vip then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("您的贵族等级不够，需要贵族%d%s",info.vip,"方可购买"))
	end

	if not info.hadTimes then
		return g_i3k_ui_mgr:PopupTipMessage("您今日已经没有购买次数")
	end

	local giftsTb = info.gifts
	local isEnoughTable = { }
	for i,v in pairs(giftsTb) do
		isEnoughTable[v.id] = v.count
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	if isEnough then
		local gift = {}
		for i,v in pairs (isEnoughTable) do
			table.insert(gift,{id = i,count = v})
		end
		i3k_sbean.groupbuy_buy(self.info.effectiveTime,self.info.cfg.time.startTime , info.id , 1 , info.index , gift, info.price)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end

end

function wnd_group_buy:selectGoods(sender , index )
	local widgets = self.listScroll:getAllChildren()
	for i,item in ipairs(widgets) do
		local btn = item.vars.select
		local tag = btn:getTag()
		if tonumber(tag) == index then
			btn:show()
		else
			btn:hide()
		end
	end
	self:updateSelectGood(index)
end

function wnd_group_buy:updateRedPoint()
	local redPoint = false
	for k , curinfo  in pairs(self.info.cfg.goods) do
		if g_i3k_game_context:GetVipLevel() >= curinfo.vipReq then
			if g_i3k_game_context:GetLevel() >= curinfo.levelReq then
				local times = curinfo.restriction.times
				if self.info.log.logs[curinfo.id] then
					times = curinfo.restriction.times - self.info.log.logs[curinfo.id].dayBuyTimes
				end
				if times > 0 then
					redPoint = true
					break
				end
			end
		end
	end
	if redPoint == false then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance,"fuliAnimation")
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_CAN_GROUPBUY_RED)
		g_i3k_game_context:OnGroupBuyShowStateChangedHandler(true,g_i3k_game_context:testNotice(g_NOTICE_TYPE_CAN_GROUPBUY_RED))
	end
end

function wnd_create(layout)
	local wnd = wnd_group_buy.new()
	wnd:create(layout)
	return wnd
end
