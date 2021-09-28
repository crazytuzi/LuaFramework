-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_buy_coin = i3k_class("wnd_buy_coin",ui.wnd_base)

--元宝
DiamondType = 1
local price = g_i3k_db.i3k_db_get_buy_coin_price()

function wnd_buy_coin:ctor()
    self.index = 0
    self.buyTimes = 0
	self.isShowSuo = {}
	self.backDaily = false
end

function wnd_buy_coin:configure()

    local widgets = self._layout.vars
    widgets.close_btn:onClick(self,self.onCloseUI)
    widgets.buyOne_btn:onClick(self,self.buyOneBtn)
    widgets.buyTen_btn:onClick(self,self.buyTenBtn)

	self.list = widgets.list
	self.suo = widgets.suo

	self:updateBinding()
    local vipLvl = g_i3k_game_context:GetVipLevel()
    local baseTimes =  g_i3k_game_context:GetBuyCoinTimes()
    local dayMaxTimes = g_i3k_db.i3k_db_get_day_buy_coin_times(vipLvl)
    self:updateBuyInfo(vipLvl, baseTimes)
	self:updateBuyLogs({})
end

function wnd_buy_coin:refresh(result,scrollData)
	self:updateBinding()
	local vipLvl = g_i3k_game_context:GetVipLevel()
    local baseTimes =  g_i3k_game_context:GetBuyCoinTimes()
    local dayMaxTimes = g_i3k_db.i3k_db_get_day_buy_coin_times(vipLvl)
    self:updateBuyInfo(vipLvl, baseTimes)
    self:updateBuyLogs(result, scrollData)
end

function wnd_buy_coin:updateBinding(isBuy)
	if g_i3k_game_context:GetDiamond(false) == 0  and g_i3k_game_context:GetDiamond(true) > 0 then
		self.suo:hide()
		if isBuy then
			self.isShowSuo = false
		end
	else
		self.suo:show()
		if isBuy then
			self.isShowSuo = true
		end
	end
end

function wnd_buy_coin:updateBuyInfo(vipLvl,buyTimes)
	self.buyTimes = buyTimes;
	local canBuyTimes = g_i3k_db.i3k_db_get_day_buy_coin_times(vipLvl)
	self._layout.vars.times_desc:setText(string.format("(今日可购买次数：%s/%s)", buyTimes, canBuyTimes))
	if buyTimes == canBuyTimes then
		self._layout.vars.times_desc:setTextColor(g_COLOR_VALUE_RED)
	end
	local price = g_i3k_db.i3k_db_get_buy_coin_price_AND_times(buyTimes+1)
	self._layout.vars.diamond_count:setText(price)
	local canBuyCoins = g_i3k_db.i3k_db_get_buy_coin_amount(buyTimes, 1)
	self._layout.vars.coin_count:setText(canBuyCoins)
end

function wnd_buy_coin:updateBuyLogs(result, temp)
    local scroll = self._layout.vars.scroll
	if #result > 0 then
		self.list:show()
	else
		self.list:hide()
		return
	end
	for i=1,#result do
		local _layer = require("ui/widgets/djst")()
		local diamondCount = _layer.vars.diamond
		local coinCount = _layer.vars.coin
		local value = _layer.vars.value
		local suo = _layer.vars.suo

		diamondCount:setText(temp[i].needDiamond)
		coinCount:setText(temp[i].getCoinCount * result[i])
		local str = string.format("暴击×%s",result[i])
		value:setText(str)
		suo:setVisible(self.isShowSuo)
		scroll:addItem(_layer)
		self.index = self.index + 1
	end
	scroll:jumpToChildWithIndex(self.index)
end

function wnd_buy_coin:addBuyLogs(vipLvl, level, multipliers)
	self:updateBuyLogs(vipLvl, multipliers)
	self:updateBuyInfo(vipLvl, level, self.buyTimes + #multipliers)
end

-- listener
function wnd_buy_coin:buyOneBtn(sender)
	local temp = {}
	local tmp = {}
	local number = g_i3k_game_context:GetBuyCoinTimes()
	number = number + 1
	local totalDiamond =  g_i3k_game_context:GetCommonItemCanUseCount(DiamondType)
	local needDiamond = g_i3k_db.i3k_db_get_buy_coin_price_AND_times(number)
	tmp.needDiamond = needDiamond
	tmp.getCoinCount = g_i3k_db.i3k_db_get_add_coin_count(number)
	table.insert(temp,tmp)
	if totalDiamond < needDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(146))
		return
	end
    local vipLvl = g_i3k_game_context:GetVipLevel()
    local dayMaxTimes = g_i3k_db.i3k_db_get_day_buy_coin_times(vipLvl)
	if number > dayMaxTimes then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(147))
	else
		-- self:updateBinding(true)
		i3k_sbean.buy_coins(1,number,temp)
	end
end

function wnd_buy_coin:buyTenBtn(sender)
	local temp = {}
	local number = g_i3k_game_context:GetBuyCoinTimes()
	local totalDiamond = g_i3k_game_context:GetCommonItemCanUseCount(DiamondType)
	local num = 1
	local needDiamond = 0
	local getCoinCount = 0
    local nextDiamond = g_i3k_db.i3k_db_get_buy_coin_price_AND_times(number+1)
	if totalDiamond < nextDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(146))
		return
	end
    local vipLvl = g_i3k_game_context:GetVipLevel()
    local dayMaxTimes = g_i3k_db.i3k_db_get_day_buy_coin_times(vipLvl)
    local lastBuyTimes = dayMaxTimes - number -- 剩余购买次数
    if lastBuyTimes == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(147))
        return
	end
    local totalNeedDiamond = 0
    totalNeedDiamond , num = g_i3k_db.i3k_db_get_buy_coin_price_AND_times(number+1)
    if num > lastBuyTimes then
        num = lastBuyTimes
    end
    totalNeedDiamond = totalNeedDiamond * num

    for i = 1, num do
        local tmp = {}
        tmp.needDiamond = nextDiamond
        tmp.getCoinCount = g_i3k_db.i3k_db_get_add_coin_count(number + i)
        table.insert(temp,tmp)
        getCoinCount = getCoinCount + g_i3k_db.i3k_db_get_add_coin_count(number + i)
    end
    if num == 0 then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(147))
        return
    else
        g_i3k_ui_mgr:OpenUI(eUIID_BuyCoinBat)
		g_i3k_ui_mgr:RefreshUI(eUIID_BuyCoinBat, {num = num, number = number + num, needDiamond = totalNeedDiamond, coinCount = getCoinCount, diamondData = temp})
    end
end
function wnd_buy_coin:backDailyUiSign(fun)
	self.backDaily = fun
end

function wnd_buy_coin:onCloseUI(sender)
	if self.backDaily then
		self.backDaily()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_BuyCoin)
end

function wnd_create(layout)
	local wnd = wnd_buy_coin.new()
	wnd:create(layout)
	return wnd
end
