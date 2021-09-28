-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_channel_pay = i3k_class("wnd_channel_pay", ui.wnd_base)

local l_sBarName = "ui/widgets/czjmt"
local l_nTitle 			= 181
local l_nFullTip 		= 182
local l_nDiamond 		= 183
local l_nDiamondGain 	= 184
local l_nSure 			= 185
local l_nMoonCard 		= 435
local l_sVipLvl 		= "vip#v%s.png"
local l_nThreeDaySecond =  259200 	--3*24*60*60
local l_nThreeDay       = 3
local l_nCurLvl 		= nil

local LONGHUN_LEVEL_ONE = 24  --龙魂币档位
local LONGHUN_LEVEL_TWO = 25
function wnd_channel_pay:ctor()
	self.backDaily = false
	self._tabsType = 0 -- 元宝，龙魂币
end

function wnd_channel_pay:configure()
	local widgets = self._layout.vars
	self.info = {}
	self.percent = self._layout.vars.percent
	self.percentText = self._layout.vars.percentText
	self.title = self._layout.vars.title
	self.vipLvl = self._layout.vars.vipLvl
	self.scroll = self._layout.vars.item_scroll
	self.vipTimes = self._layout.vars.vipTimes
	self.vipTips = self._layout.vars.vipTips
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._tabsButtons = {widgets.coin_btn, widgets.longhunBtn}
	for i, e in ipairs(self._tabsButtons) do
		e:onClick(self, self.onTypeChanged, i)
	end

	local viewVip = self._layout.vars.viewvip_btn
	self.redDot = self._layout.vars.red_dot
	viewVip:onClick(self, self.onViewVip)
end

function wnd_channel_pay:onTypeChanged(sender, tabsType)
	if self._tabsType ~= tabsType then
		self._tabsType = tabsType
		for i, e in ipairs(self._tabsButtons) do
			e:stateToNormal()
		end
		self._tabsButtons[tabsType]:stateToPressed()
		self:updateItems()
	end
end

function wnd_channel_pay:refresh(info ,back, openType)
	self.backDaily = back
	self.info = info
	self:setShowVipTime()
	self:setTopInfo(info.vipLvl, info.pointsTotal)
	local tabsType = self._tabsType == 0 and g_CHANNEL_DIAMOD_TYPE or self._tabsType
	self:onTypeChanged(nil, openType or tabsType)
	self._layout.vars.longhunTip:setText(i3k_get_string(1744))
end

function wnd_channel_pay:setShowVipTime()
	if g_i3k_game_context:GetPracticalVipLevel() ~= 0 and  g_i3k_game_context:GetPracticalVipLevel() >= g_i3k_game_context:GetVipExperienceLevel() then
		self.vipTips:setVisible(false)
		self.vipTimes:setVisible(false)
	else
		if g_i3k_game_context:GetVipExperienceLevel() ~= 0 then
			self.vipTimes:setVisible(true)
			self.vipTips:setVisible(true)
			self.vipTimes:setText(i3k_get_string(491, g_i3k_game_context:GetVipExperienceLevel()))
		else
			self.vipTips:setVisible(false)
			self.vipTimes:setVisible(false)
		end
	end
end

function wnd_channel_pay:setTopInfo(vipLvl, pointsTotal)
	self.info.vipLvl = vipLvl
	self.info.pointsTotal = pointsTotal

	local curLvl = self.info.vipLvl
	local curPoints = self.info.pointsTotal
	local nextLvlNeedPoints = 1
	if curLvl + 1 <= i3k_table_length(i3k_db_kungfu_vip) - 1 then
		nextLvlNeedPoints = i3k_db_kungfu_vip[curLvl + 1].points
	end
	local fullLvl = curLvl >= i3k_table_length(i3k_db_kungfu_vip) - 1
	if curPoints > nextLvlNeedPoints then
		curPoints = nextLvlNeedPoints
	end

	self.percent:setPercent(curPoints / nextLvlNeedPoints * 100)
	self.percentText:setText(curPoints .. " / " .. nextLvlNeedPoints)

	if not fullLvl then
		self.title:setText(i3k_get_string(l_nTitle, nextLvlNeedPoints - curPoints, curLvl + 1))
	else
		self.percentText:hide()
		self.title:setText(i3k_get_string(l_nFullTip))
	end

	self.vipLvl:setImage(string.format(l_sVipLvl, curLvl))

	l_nCurLvl = vipLvl
	local showRed = false
	local newRewards = self.info.newRewards[1]
	
	for i = 1, vipLvl do	
		if newRewards == nil or not newRewards.takedRewards[i] then
			showRed = true
			l_nCurLvl = i
			break
		end
	end
	
	self.redDot:setVisible(showRed)	
end

function wnd_channel_pay:updateItems()
	local pays = i3k_db_channel_pay[self.info.id]
	if not pays then
		return
	end
	local payLevels = self.info.payLevels
	local yuanbao = {}
	local dragonCoin = {}
	for i, e in ipairs(payLevels) do
		if e.level ~= LONGHUN_LEVEL_ONE and e.level ~= LONGHUN_LEVEL_TWO then
			table.insert(yuanbao, e)
		else
			table.insert(dragonCoin, e)
		end
	end
	local payLvlLogs = self.info.payLvlLogs
	local count = self._tabsType == g_CHANNEL_DIAMOD_TYPE and #yuanbao or #dragonCoin
	local coins = self._tabsType == g_CHANNEL_DIAMOD_TYPE and yuanbao or dragonCoin
	local allBars = self.scroll:addChildWithCount(l_sBarName, 3, count)
	for i, e in ipairs(coins) do
		local bar = allBars[i]
		local lvl = e.level
		local payCfg = pays[lvl]
		local payLvlLog = payLvlLogs[lvl]
		self:setOneItem(lvl, bar, e, payCfg, payLvlLog, self.info.id)
	end
end

function wnd_channel_pay:setOneItem(lvl, bar, payLevel, payCfg, payLvlLog,id)
	local icon = bar.vars.item_icon
	local diamondShow = bar.vars.diamondShow
	local price = bar.vars.money_count
	local buy = bar.vars.buy
	local mark = bar.vars.mark
	local add_desc = bar.vars.add_desc 
	local add_value = bar.vars.add_value
	local add_root = bar.vars.add_root
	add_root:hide()
	local desc = ""
	local tmp_add_desc = ""
	local tmp_add_value = ""
	buy:enable()
		desc = string.format(payCfg.add_desc,payLevel.worth).."\n"
		payLvlLog = payLvlLog and payLvlLog + 1 or 1
		
		if payLevel.rebates[payLvlLog] then
			local addtion = ""
			if payLvlLog == 1 then
				addtion = payCfg.firstRebateDesc
			else
				addtion = payCfg.followRebateDesc
			end
			tmp_add_desc = addtion
			tmp_add_value = payLevel.rebates[payLvlLog]
			--desc = desc .. string.format(addtion, payLevel.rebates[payLvlLog])
			add_root:show()
			add_desc:setText(tmp_add_desc)
			add_value:setText(tmp_add_value)
		end
		if lvl == 0 then
			add_root:show()
			add_desc:setText(payCfg.firstRebateDesc)
			add_value:setText(payLevel.rebates[1])	
		end
	
	if i3k_db_icons[payCfg.itemIcon] then
		icon:setImage(i3k_db_icons[payCfg.itemIcon].path)
	end
	diamondShow:setText(desc)
	
	price:setText(payCfg.currency .. payLevel.priceShow)
	buy:onClick(self, self.onBuyBtnClick, {lvl = lvl, id = id, payLevelCfg = payLevel})
	mark:hide()
end

function wnd_channel_pay:updateAfterBuy(lvl)
	local bar = self.scroll:getAllChildren()[lvl + 1]
	local payLvlLog = self.info.payLvlLogs[lvl] or 0
	payLvlLog = payLvlLog + 1
	self.info.payLvlLogs[lvl] = payLvlLog
	self:updateItems()
end

function wnd_channel_pay:onBuyBtnClick(sender, args)
	local lvl = args.lvl
	local id = args.id
	if lvl == 0 then        --月卡
        local now  = i3k_game_get_time()
        local endtime = g_i3k_game_context:GetMonthlyCardEndTime()
        local valid = (endtime - now) > l_nThreeDaySecond
        if valid then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(l_nMoonCard, l_nThreeDay))
            return
        end
    end
	if lvl == LONGHUN_LEVEL_ONE or  lvl == LONGHUN_LEVEL_TWO then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1755), function(flag)
			if flag then
				i3k_sbean.goto_channel_pay(id, args.payLevelCfg, callback)
			end
		end)
		return
	end
	i3k_sbean.goto_channel_pay(id, args.payLevelCfg, callback)
end

function wnd_channel_pay:onViewVip(sender)
	local payInfo = self.info
	g_i3k_ui_mgr:CloseUI(eUIID_ChannelPay)
	g_i3k_logic:OpenVipSystemUI(payInfo, l_nCurLvl)
end

function wnd_channel_pay:onCloseUI(sender)
	if self.backDaily then
		self.backDaily()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_ChannelPay)	
end

function wnd_create(layout, ...)
	local wnd = wnd_channel_pay.new()
		wnd:create(layout, ...)

	return wnd
end
