-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bid = i3k_class("wnd_bid", ui.wnd_base)

function wnd_bid:ctor()
	self._timeCounter = 0
	self._timeCounter2 = 0
	self._setGrayFlag = false
	self._readdTimeLabels = {} -- 补货倒计时的label
end

function wnd_bid:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.refresh_btn:onClick(self, self.onRefreshBtn)
	widgets.bidRecordBtn:onClick(self, self.onBidRecordBtn)
	widgets.payBtn:onClick(self, self.onPayBtn)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	local needDiamond = g_BASE_ITEM_DRAGON_COIN -- 龙魂币
	self:setNeedItem(needDiamond)
	self._scrollPercent = 0
end

function wnd_bid:onShow()
	self:onSecondTask()
end

function wnd_bid:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	self._timeCounter2 = self._timeCounter2 + dTime
	if self._timeCounter > 1 then
		self:onSecondTask(dTime)
		self._timeCounter = 0
	end
	if self._timeCounter2 > 7 then
		if not self._setGrayFlag and not self._syncBidFlag then
			i3k_sbean.syncBid() -- 5秒钟刷新一次
		end
		self._timeCounter2 = 0
	end
end

function wnd_bid:refresh(items, unAddGroupIds)
	local unAddedMap = self:getUnAddGroupsMap(unAddGroupIds)
	self:setScroll(items, unAddedMap)
end

function wnd_bid:getUnAddGroupsMap(list)
	return list
	-- local map = {}
	-- local t = "unadd "..#list.. " list:"
	-- for k, v in ipairs(list) do
	-- 	map[v] = true
	-- 	t = t..", "..v
	-- end
	-- i3k_log(t)
	-- return map
end

function wnd_bid:setScroll(items, unAddedMap)
	local widgets = self._layout.vars
	local scroll = widgets.item_scroll
	self._scrollPercent = scroll:getListPercent() -- 记录刷新前，滚动条的位置
	scroll:removeAllChildren()
	for k, v in ipairs(items) do
		local ui = require("ui/widgets/paimait")()
		local cfg = g_i3k_db.i3k_db_get_bid_item_cfg(v.gid)
		local itemID = cfg.itemID
		local needCoinID = cfg.needCoinID
		ui.vars._gid = v.gid -- 每个控件上记录一个gid
		ui.vars.yb1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needCoinID, g_i3k_game_context:IsFemaleRole()))
		ui.vars.yb2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needCoinID, g_i3k_game_context:IsFemaleRole()))
		ui.vars.yb3:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needCoinID, g_i3k_game_context:IsFemaleRole()))
		local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(itemID)
		local itemName = g_i3k_db.i3k_db_get_common_item_name(itemID)
		ui.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID) )
		ui.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
		ui.vars.itemCount:setText(cfg.count)
		ui.vars.name_label:setText(itemName)
		ui.vars.itemBtn:onClick(self, self.onItemInfo, itemID)
		-- ui.vars.roleName:setText(v.curRoleName)
		ui.vars.curPrice:setText(v.curPrice)
		ui.vars.bidPrice:setText(v.curPrice + cfg.pricePerBid)
		ui.vars.finalPrice:setText(cfg.finalPrice)
		local bidInfo = { id = k, needCoinID = cfg.needCoinID, pricePerBid = cfg.pricePerBid, itemID = itemID, gid = v.gid, price = v.curPrice + cfg.pricePerBid, finalPrice = cfg.finalPrice}
		ui.vars.bidBtn:onClick(self, self.onBidBtn, bidInfo)
		ui.vars.finalBtn:onClick(self, self.onFinalPriceBtn, bidInfo)
		ui.vars.buhuo:hide()
		if v.isSell == 1 then
			if unAddedMap[v.gid] then -- 不会补货
				ui.vars.bidBtn:hide()
				ui.vars.finalBtn:hide()
				ui.vars.yb1:hide()
				ui.vars.yb2:hide()
				ui.vars.yb3:hide()
				ui.vars.soldOut:show()
			else -- 会补货，并显示补货倒计时
				local offsetTime = g_i3k_db.i3k_db_get_add_bid_item_last_time(v.gid)
				ui.vars.bidBtn:hide()
				ui.vars.finalBtn:hide()
				ui.vars.yb1:hide()
				ui.vars.yb2:hide()
				ui.vars.yb3:hide()
				ui.vars.soldOut:hide()

				if offsetTime > 0 then
					ui.vars.buhuo:show()
					ui.vars.bhTime:setText("剩余时间："..g_i3k_get_HourAndMin(offsetTime))
					ui.timeCfg = { time = offsetTime}
				else
					ui.vars.buhuo:hide()
					ui.vars.soldOut:show()
				end
			end
		end
		if v.curPrice + cfg.pricePerBid > cfg.finalPrice then
			ui.vars.bidBtn:disableWithChildren()
		end
		if self:needSetGray() then
			ui.vars.bidBtn:disableWithChildren()
			ui.vars.finalBtn:disableWithChildren()
		end
		if not g_i3k_game_context:checkBidTime(v.gid) then
			ui.vars.bidBtn:disableWithChildren()
			-- v.vars.finalBtn:disableWithChildren()
		end
		scroll:addItem(ui)
	end

	scroll:jumpToListPercent(self._scrollPercent)
end


function wnd_bid:setNeedItem(id)
	if not id then
		id = g_BASE_ITEM_DRAGON_COIN
	end
	local widgets = self._layout.vars
	widgets.contri_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local count = g_i3k_game_context:GetCommonItemCount(id)
	widgets.contri_value:setText(count)
end


function wnd_bid:onItemInfo(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

-- InvokeUIFunction
function wnd_bid:setHistory(info)
	self._history = info
end

-- 竞价
function wnd_bid:onBidBtn(sender, info)
	local needItem = info.needCoinID
	local count = g_i3k_game_context:GetCommonItemCount(needItem)
	if count < info.price then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	i3k_sbean.bidForPrice(info.gid, info.price, false, true, info)
end

function wnd_bid:bidSuccessCallback(info)
	local widgets = self._layout.vars
	local scroll = widgets.item_scroll
	local child = scroll:getChildAtIndex(info.id)
	local curPrice = tonumber(child.vars.curPrice:getText())
	child.vars.curPrice:setText(curPrice + info.pricePerBid)
	child.vars.bidPrice:setText(curPrice + info.pricePerBid * 2)
end

-- 一口价
function wnd_bid:onFinalPriceBtn(sender, info)
	local needItem = info.needCoinID
	local count = g_i3k_game_context:GetCommonItemCount(needItem)
	if count < info.finalPrice then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_BidTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_BidTips, info)
end

-- 刷新
function wnd_bid:onRefreshBtn(sender)
	i3k_sbean.syncBid(true)
end

-- 记录
function wnd_bid:onBidRecordBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BidHistory)
	g_i3k_ui_mgr:RefreshUI(eUIID_BidHistory, self._history)
end

function wnd_bid:onSecondTask(dTime)
	local widgets = self._layout.vars
	local todaySecond = i3k_game_get_time() % (3600 * 24)
	local endTime = i3k_db_bid_cfg.endTime
	if endTime - todaySecond > 0 then
		local timeString = i3k_get_time_show_text(endTime - todaySecond)
		widgets.timeLeft:setText(timeString)
	else
		widgets.leftTimeLabel:hide()
		widgets.timeLeft:hide()
	end
	-- 按钮灰化
	if self:needSetGray() then
		-- if not self._setGrayFlag then
			local widgets = self._layout.vars
			local scroll = widgets.item_scroll
			local children = scroll:getAllChildren()
			for k, v in ipairs(children) do
				v.vars.bidBtn:disableWithChildren()
				v.vars.finalBtn:disableWithChildren()
			end
			self._setGrayFlag = true
		-- end
	end
	self:setBidPriceTimeLimitGray(dTime)
	self:updateReaddItemLabels(dTime)
end

-- 刷新补货道具显示的剩余时间
function wnd_bid:updateReaddItemLabels(dTime)
	self:updateScrollTimeLabel()
end

function wnd_bid:updateScrollTimeLabel()
	local widgets = self._layout.vars
	local scroll = widgets.item_scroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		if v.timeCfg then
			local time = v.timeCfg.time
			if time <= 0 then
				i3k_sbean.syncBid()
				self._syncBidFlag = true
				return
			else
				v.vars.bhTime:setText("剩余时间："..g_i3k_get_HourAndMin(time))
				v.timeCfg.time = time - 1
				self._syncBidFlag = false
			end
		end
	end
end



function wnd_bid:setBidPriceTimeLimitGray(dTime)
	local widgets = self._layout.vars
	local scroll = widgets.item_scroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		local gid =  v.vars._gid
		if not g_i3k_game_context:checkBidTime(gid) then
			v.vars.bidBtn:disableWithChildren()
			-- v.vars.finalBtn:disableWithChildren()
		end
	end
end

function wnd_bid:needSetGray()
	local todaySecond = i3k_game_get_time() % (3600 * 24)
	local endTime = i3k_db_bid_cfg.endTime
	return (endTime - todaySecond) < i3k_db_bid_cfg.unableTime
end


function wnd_bid:onPayBtn(sender)
	g_i3k_logic:OpenChannelPayUI(nil, g_CHANNEL_LONGHUNBI_TYPE) 
end

function wnd_bid:onHelpBtn(sender)
	local cfg = i3k_db_bid_cfg
	local beginTime = cfg.startTime
	local endTime = cfg.endTime
	local hour = math.modf(beginTime/3600)
	local minute = math.modf(beginTime%3600/60)
	local endHour = math.modf(endTime/3600)
	local endMinute = math.modf(endTime%3600/60)
	if minute < 10 then
		minute = "0"..minute
	end
	if endMinute < 10 then
		endMinute = "0"..endMinute
	end

	local startDate = cfg.startDate
	local endDate = cfg.endDate
	-- local startDateString = g_i3k_get_commonDateStr(startDate)
	-- local endDatteString = g_i3k_get_commonDateStr(endDate)
	local t = os.date("*t", endDate)

	-- g_i3k_ui_mgr:PopupTipMessage("h"..hour.."endHour".. endHour.."month".. t.month.."day".. t.day)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16853, hour, endHour, t.month, t.day))
end

function wnd_create(layout, ...)
	local wnd = wnd_bid.new()
	wnd:create(layout, ...)
	return wnd;
end
