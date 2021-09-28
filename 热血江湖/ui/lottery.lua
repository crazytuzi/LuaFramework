------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_lottery = i3k_class("wnd_lottery",ui.wnd_base)

function wnd_lottery:configure()
	local widget = self._layout.vars
	widget.close:onClick(self,self.onCloseUI)
	widget.posibility:onClick(self, self.onCheckPosibility)
	widget.record:onClick(self, self.onRecord)
	widget.one:onClick(self, self.onBuy, true)
	widget.ten:onClick(self, self.onBuy, false)
	-- widget.pay:onClick(self, self.onPay)
	widget.desc:setText(i3k_get_string(5911))
end

function wnd_lottery:refresh(infos)
	self.infos = infos
	local widgets = self._layout.vars
	local giftex = infos.cfg.giftex
	local tmp = {[0] = {id = giftex.id, count = giftex.count}}
	for i,v in ipairs(infos.cfg.gifts) do
		table.insert(tmp, {id = v.gift.id, count = v.gift.count})
	end
	for i = 0, 12 do
		local v = tmp[i]
		if not v then widgets['bg'..i]:hide() break end
		local id,count = v.id, v.count
		widgets['bg'..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widgets['icon'..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		widgets['btn'..i]:onClick(self, self.onItemTips, id)
		widgets['suo'..i]:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(id))
		widgets['cnt'..i]:setText(count > 1 and 'x' .. count or "")
		if i ~= 0 then
			widgets['name'..i]:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		end
	end
	widgets.leftTimes:setText(i3k_get_string(5906, infos.cfg.maxPlayTimes - infos.playTimes, infos.cfg.maxPlayTimes))
	widgets.ten:setTag(infos.cfg.mutiTimes)
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
	g_i3k_ui_mgr:RefreshUI(eUIID_DBF)
end

function wnd_lottery:onCheckPosibility(sender)
	local data = {}
	local oldProbability = 0
	for i,v in ipairs(self.infos.cfg.gifts) do
		table.insert(data, {id = v.gift.id, probability = v.probability - oldProbability})
		oldProbability = v.probability
	end
	g_i3k_ui_mgr:OpenUI(eUIID_LotteryPosibility)
	g_i3k_ui_mgr:RefreshUI(eUIID_LotteryPosibility, data)
end

function wnd_lottery:onRecord(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RecentlyGet)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_RecentlyGet, "showLotteryGet", self.infos.logs)
end

function wnd_lottery:onBuy(sender, isSingle)
	local cfg = self.infos.cfg
	local info = self.infos
	if info.playTimes >= cfg.maxPlayTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
		return
	end
	local size = g_i3k_game_context:GetBagInfo()
	local cellsize = g_i3k_game_context:GetBagUseCell()
	if size - cellsize < (isSingle and 2 or (cfg.mutiTimes + 1)) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
		return
	end
	local have = g_i3k_game_context:GetCommonItemCanUseCount(cfg.cost)
	if have < (isSingle and cfg.singleCost or cfg.mutiCost) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(216))
		return
	end
	if not isSingle then
		if cfg.maxPlayTimes - info.playTimes < cfg.mutiTimes then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15481))
		end
	end
	local cost = isSingle and cfg.singleCost or cfg.mutiCost
	local itemId = cfg.giftex.id
	local itemName = g_i3k_db.i3k_db_get_common_item_name(itemId)
	local buycount = isSingle and 1 or cfg.mutiTimes
	local str = i3k_get_string(5907, cost, itemName, buycount, buycount)
	g_i3k_ui_mgr:ShowMessageBox2(str, function(bValue)
		if bValue then
			i3k_sbean.newluckyroll_play(self.infos, isSingle)
		end
	end)
end

function wnd_lottery:onPay(sender)
	i3k_sbean.sync_channel_pay()
end

function wnd_lottery:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_lottery:wrapRewardToShow(ids)
	local items = {}
	local gifts = self.infos.cfg.gifts
	for i, v in ipairs(ids) do
		for ii, vv in ipairs(gifts) do
			if vv.id == v then
				table.insert(items, {id = vv.gift.id, count = vv.gift.count})
				table.insert(self.infos.logs, {id = vv.gift.id, num = vv.gift.count, time = i3k_game_get_time()})
				break
			end
		end
	end
	local ui
	if #items > 3 then
		ui = eUIID_UseItemGainMoreItems
	else
		ui = eUIID_UseItemGainItems
	end
	g_i3k_ui_mgr:OpenUI(ui)
	g_i3k_ui_mgr:RefreshUI(ui, items)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_lottery.new()
	wnd:create(layout,...)
	return wnd
end