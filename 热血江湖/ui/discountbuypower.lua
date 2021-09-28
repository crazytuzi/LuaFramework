-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
disCountBuyPower = i3k_class("disCountBuyPower", ui.wnd_base)

local discountImage = {3392, 3393, 3394, 3395, 3396, 3397, 3398, 3399, 3400}

function disCountBuyPower:ctor()

end


function disCountBuyPower:configure(...)
	self._layout.vars.closeBtn:onClick(self,self.onCloseUI)
end

function disCountBuyPower:onShow()
	
end

function disCountBuyPower:refresh(info)
	self:refreshScoll(info)
	self:refreshText(info)
end

function disCountBuyPower:refreshScoll(info)
	local scoll = self._layout.vars.listScroll
	local levelGifts = info.cfg.levelGifts
	local log = info.log
	scoll:removeAllChildren()
	
	for i, e in ipairs(levelGifts) do
		local item = require("ui/widgets/shangpinzhekout")()
		local weight = item.vars
		self:updatePayGiftLevelItem(info.effectiveTime, e, log, weight, i)
		scoll:addItem(item)
	end
end

function disCountBuyPower:updatePayGiftLevelItem(effectiveTime, e, log, weight, index)
	local payGiftTb =
	{
		[1] = {root = weight.bg1, icon = weight.icon1, count = weight.count1, suo = weight.suo1, bg = weight.iconbg1},
		[2] = {root = weight.bg2, icon = weight.icon2, count = weight.count2, suo = weight.suo2, bg = weight.iconbg2},
		[3] = {root = weight.bg3, icon = weight.icon3, count = weight.count3, suo = weight.suo3, bg = weight.iconbg3},
		[4] = {root = weight.bg4, icon = weight.icon4, count = weight.count4, suo = weight.suo4, bg = weight.iconbg4},
		[5] = {root = weight.bg5, icon = weight.icon5, count = weight.count5, suo = weight.suo5, bg = weight.iconbg5},
		[6] = {root = weight.bg6, icon = weight.icon6, count = weight.count6, suo = weight.suo6, bg = weight.iconbg6},
	}
	
	for _, v in ipairs(payGiftTb) do
		v.root:hide()
	end
	
	local locGifts = e.gifts
	
	for k, v in ipairs(locGifts) do
		if v.id ~= 0 then
			payGiftTb[k].root:show()
			payGiftTb[k].bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id) )
			payGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		
			if v.count >= 1 then
				payGiftTb[k].count:setText("x"..v.count)
			else
				payGiftTb[k].count:hide()
			end
		
			payGiftTb[k].icon:onClick(self, self.onTips, v.id)
		
			if v.id == 3 or v.id == 4 or v.id == 31 or v.id == 32 or v.id == 33 or v.id < 0 then
				payGiftTb[k].suo:hide()
			else
				payGiftTb[k].suo:show()
			end
		else
			payGiftTb[k].root:hide()
		end
	end
	
	local haspay = log.pay
	local needpay = e.payReq
	local oldCost = e.originalCost								
	local newCost = e.buyCost								
	
	local discount = math.floor(newCost * 10 / oldCost) 
	local iconID = discountImage[discount]
		
	if iconID then
		weight.zhekou:show()
		weight.zhekou:setImage(i3k_db_icons[iconID].path)
	else
		weight.zhekou:hide()
	end
	
	local str = string.format("%d/%d", haspay, needpay)
	
	if haspay >= needpay then
		str = g_i3k_make_color_string(str, g_i3k_get_green_color())
	else
		str = g_i3k_make_color_string(str, g_i3k_get_red_color())
	end
	
	local goal = i3k_get_string(1476, str, discount)
	weight.dse:setText(goal)
	weight.name:setText(e.title)
	weight.oldPrice:setText(oldCost) 
	weight.newPrice:setText(newCost)
	
	if haspay >= needpay then
		if log.rewards[e.payReq] then
			weight.buytext:setText(i3k_get_string(1477))
			weight.buyBtn:disableWithChildren()
		else
			weight.buytext:setText(i3k_get_string(1478))
			weight.buyBtn:enableWithChildren()
			local takePayGift = {time = effectiveTime , id = log.id, level = needpay, gifts = e.gifts, scollIndex = index, title = e.title, dis = discount, cost = newCost}
			weight.buyBtn:onClick(self, self.onBuyBt, takePayGift)
		end
	else
		weight.buytext:setText(i3k_get_string(1478))
		weight.buyBtn:disableWithChildren()
	end
end

function disCountBuyPower:refreshText(info)
	--倒计时每个板子上写一个回调函数，把self 放到onupdate里（小于三天的时候，三天到一年内显示截至时间，否则显示不限时)
	local cfg = info.cfg
	local log = info.log
	local time = cfg.time
	--control.vars.ActivitiesTitle:setText(cfg.title)标题
	--control.vars.ActivitiesContent:setText(cfg.content)活动描述
	local timeLable = self._layout.vars.time 
	local cur_Time = i3k_game_get_time()
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local lastDay = g_i3k_get_day(time.endTime)
	local days = lastDay - totalDay 
	local havetime =(time.endTime - cur_Time)
	local min = math.floor(havetime / 60 % 60)
	local hour = math.floor(havetime / 3600 % 24)
	local day = math.floor(havetime / 3600 / 24)
	local str 
	
	if days <=  3  then
		local time1 = havetime
		str = i3k_get_string(1479, day, hour, min)
	else
		str =  g_i3k_get_ActDateRange(time.startTime, time.endTime)		
	end
	
	timeLable:setText(i3k_get_string(1480, str))
end

function disCountBuyPower:seBuyBtState(id)
	local scoll = self._layout.vars.listScroll
	local item = scoll:getChildAtIndex(id)
	
	if item then
		local weight = item.vars
		weight.buytext:setText(i3k_get_string(1477))
		weight.buyBtn:disableWithChildren()
	end
end

function disCountBuyPower:onBuyBt(sender, info)
	local haveDiamond = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
	local needVale = info.cost
	
	if haveDiamond < needVale then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15195))
		return
	end
	
	local isEnoughTable = {}
	
	for i, v in pairs(info.gifts) do
		isEnoughTable[v.id] = v.count
	end
	
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
		return
	end
									
	local fun = (function(ok)
		if ok then
			i3k_sbean.discount_buy_power_reward(info)
		end
	end)
		
	g_i3k_ui_mgr:ShowMidMessageBox2(i3k_get_string(1482, needVale, info.dis, info.title), fun)
end

function disCountBuyPower:onTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end


function wnd_create(layout, ...)
	local wnd = disCountBuyPower.new();
		wnd:create(layout, ...);

	return wnd;
end

