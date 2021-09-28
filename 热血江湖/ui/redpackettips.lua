
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_redPacketTips = i3k_class("wnd_redPacketTips",ui.wnd_base)

function wnd_redPacketTips:ctor()

end

function wnd_redPacketTips:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)

	self.ui = widgets
end

function wnd_redPacketTips:refresh(day, info)
	--红包时间展示
	local saveStartTime = info.saveConf.saveTime.startTime
	local rewardStartTime = info.rewardConf.rewardTime.startTime

	local saveDay = g_i3k_get_day(saveStartTime) + day - 1
	local rewardDay = g_i3k_get_day(rewardStartTime) + day - 1
	local nowDay = g_i3k_get_day(i3k_game_get_time())

	local rewardTime = rewardStartTime + (day - 1) * 86400
	self.ui.desc:setText(string.format("%s领取", g_i3k_get_YearAndDayTime(rewardTime)))

	--奖励展示
	local diamondRate = info.rewardConf.diamondRate/10000
	local coinRate = info.rewardConf.coinRate/10000

	local diamond = info.log.diamondLog[saveDay]
	local coin = info.log.coinLog[saveDay]

	local diamondCnt = diamond and math.floor(diamond * diamondRate) or 0
	local coinCnt = coin and math.floor(coin * coinRate) or 0

	self.ui.diamondCnt:setText(diamondCnt)
	self.ui.coinCnt:setText(i3k_get_num_to_show(coinCnt))

	--按钮状态
	if info.showType == e_Type_Cost or nowDay < rewardDay then
		self.ui.getBtn:hide()
	else
		local takedRewards = info.log.takedRewards[rewardDay]
		self.ui.btnText:setText(takedRewards and "已领取" or "领取")
		if takedRewards then
			self.ui.getBtn:disableWithChildren()
		end
	end
	--领奖
	self.ui.getBtn:onClick(self, function()
		local gifts = {}
		if diamondCnt > 0 then
			table.insert(gifts, {id = g_BASE_ITEM_DIAMOND, count = diamondCnt})
		end
		if coinCnt > 0 then
			table.insert(gifts, {id = g_BASE_ITEM_COIN, count = coinCnt})
		end
		if diamondCnt == 0 and coinCnt == 0 then
			g_i3k_ui_mgr:PopupTipMessage("没有可领取的奖励")
		else
			i3k_sbean.redpack_take(info.actId, info.actType, info.effectiveTime, rewardDay, gifts)
		end
	end)
end

function wnd_create(layout, ...)
	local wnd = wnd_redPacketTips.new()
	wnd:create(layout, ...)
	return wnd;
end

