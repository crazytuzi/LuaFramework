--
-- Author: Kumo
-- Date: 2016-02-18 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVipAlert = class("QUIDialogVipAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogVipAlert:ctor(options) 
	assert(options ~= nil, "alert dialog options is nil !")
 	local ccbFile = "ccb/Dialog_VipChongzhi_client.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
	    {ccbCallbackName = "onTriggerBack", callback = handler(self, self._onTriggerBack)},
	}
	QUIDialogVipAlert.super.ctor(self, ccbFile, callBacks, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_back)
	q.setButtonEnableShadow(self._ccbOwner.btn_recharge)
	self.isAnimation = options.isAnimation or false
    self._ccbOwner.frame_tf_title:setString("充 值")

	self._closeCallBack = options.callBack
	if options.comfirmBack then
		self._comfirmBack = options.comfirmBack
	else
		self._comfirmBack = nil
	end

	self._showVipLevel = false
	if options.showVipLevel then
		self._showVipLevel = options.showVipLevel
	end

	self._textTbl = {} 
	self._richText = nil
	self:getView():setVisible(false)

	if options.content then
		self._content = options.content
		self._ccbOwner.tf_content:setString(self._content)
		self:_changeText()
	else
		-- 这个部分主要解决提升vip不一定可以提升count的情况，然后把这部分的逻辑统一放在一起处理。目前出现这样的问题，只有NOT_ENOUGH类型。
		--textType NOT_ENOUGH  :  [title].."不足，VIP达到"..<vip level>.."级可将次数提升到"..<count by vip level>.."次，是否前往充值提升VIP等级？"
		--textType OPEN_FUNC  :  [title].."功能，VIP达到"..<vip level>.."级后可开启是否前往充值提升VIP等级？"
		--textType NO_TOKEN  :  "魂师大人，当前钻石不足，是否前往充值？"

		self._title = options.title
		self._textType = options.textType
		self._model = options.model
		self._vipField = options.vipField
		self:_setText()
	end

	self:_showText()

	self:_setShowVipLevel()
end

function QUIDialogVipAlert:_setText()

	if not self._textType then
		self:_errorFix()
		return
	end

	if self._textType == VIPALERT_TYPE.NOT_ENOUGH then
		--textType NOT_ENOUGH  :  [title].."不足，VIP达到"..<vip level>.."级可将次数提升到"..<count by vip level>.."次，是否前往充值提升VIP等级？"
		if not self._title then
			self:_errorFix()
			return
		end
		local level, count = self:_getVipLevelAndCount()
		if level then
			table.insert(self._textTbl, "魂师大人，今日")
			table.insert(self._textTbl, self._title)
			table.insert(self._textTbl, "已达到上限，")
			table.insert(self._textTbl, "VIP"..level)
			table.insert(self._textTbl, "可提升上限到")
			table.insert(self._textTbl, count.."次")
			self:_setColor()
		else
			self._noAlert = true
		end
	elseif self._textType == VIPALERT_TYPE.FIRST_RECHARGE then
		table.insert(self._textTbl, "充值")
		table.insert(self._textTbl, "任意金额")
		table.insert(self._textTbl, "可领取首充奖励，是否前往充值？")
		self:_setColor()
	elseif self._textType == VIPALERT_TYPE.OPEN_FUNC then
		--textType OPEN_FUNC  :  [title].."功能，VIP达到"..<vip level>.."级后可开启是否前往充值提升VIP等级？"
		-- local level, count = self:_getVipLevelAndCount()
		-- table.insert(self._textTbl, self._title)
		-- table.insert(self._textTbl, "功能，VIP达到")
		-- table.insert(self._textTbl, level)
		-- table.insert(self._textTbl, "级后可开启是否前往充值提升VIP等级？")
		-- self:_setColor()
		self:_errorFix()
	elseif self._textType == VIPALERT_TYPE.NO_TOKEN then
		--textType NO_TOKEN  :  "魂师大人，当前钻石不足，是否前往充值？"
	
		table.insert(self._textTbl, "魂师大人，钻石不足了，现在充值会")
		table.insert(self._textTbl, "额外赠送")
		table.insert(self._textTbl, "更多的")
		table.insert(self._textTbl, "钻石")
		table.insert(self._textTbl, "哦！")

		self:_setColor()
		-- self._ccbOwner.confirmText:setString("魂师大人，当前钻石不足，是否前往充值？")
	elseif self._textType == VIPALERT_TYPE.NO_RUSH_BUY_MONEY then
		--textType NO_TOKEN  :  "魂师大人，当前钻石不足，是否前往充值？"
	
		table.insert(self._textTbl, "魂师大人，")
		table.insert(self._textTbl, "夺宝币")
		table.insert(self._textTbl, "不足了，是否前往充值？")
		self:_setColor()
	elseif self._textType == VIPALERT_TYPE.NOT_ENOUGH_FOR_SKILL then
		--textType NOT_ENOUGH_FOR_SKILL  :  "VIP达到"..<vip level>.."可将魂技点数上限从10点提升为"..<count by vip level>.."点，是否前往充值提升VIP等级？"
		table.insert(self._textTbl, "VIP达到")
		table.insert(self._textTbl, "4级")
		table.insert(self._textTbl, "可将魂技点数上限从10点提升为")
		table.insert(self._textTbl, "20点")
		table.insert(self._textTbl, "，是否前往充值提升VIP等级？")
		self:_setColor()
	end
end

function QUIDialogVipAlert:_getVipLevelAndCount()
	local level = QVIPUtil:VIPLevel()
	local maxLevel = QVIPUtil:getMaxLevel()
	local count = self:_getCountByVip()
	local preCount = self:_getCountByVip()

	if self._textType == VIPALERT_TYPE.NOT_ENOUGH then
		if self:_getCountByVip(maxLevel) <= count then
			-- 当前VIP level获得的count已经是最大了。
			level = nil
			count = nil
		else
			local addLevel = 0
			while(count <= preCount) do
				addLevel = addLevel + 1
				print("####", level, addLevel)
				count = self:_getCountByVip(level + addLevel)
			end
			level = level + addLevel
		end
	elseif self._textType == VIPALERT_TYPE.OPEN_FUNC then
	elseif self._textType == VIPALERT_TYPE.NO_TOKEN then
	elseif self._textType == VIPALERT_TYPE.NO_RUSH_BUY_MONEY then
	end

	return level, count
end

function QUIDialogVipAlert:_getCountByVip( level )
	local lv = level or QVIPUtil:VIPLevel()
	if self._model == 1 then
		return QVIPUtil:getArenaRefreshCount( lv )
	elseif self._model == 2 then
		return QVIPUtil:getArenaResetCount( lv )
	elseif self._model == 3 then
		return QVIPUtil:getBarMaxCount( lv )
	elseif self._model == 4 then
		return QVIPUtil:getSeaMaxCount( lv )
	elseif self._model == 5 then
		return QVIPUtil:getStengthMaxCount( lv )
	elseif self._model == 6 then
		return QVIPUtil:getIntellectMaxCount( lv )
	elseif self._model == 7 then
		return QVIPUtil:getInvasionTokenBuyCount( lv )
	elseif self._model == 8 then
		return QVIPUtil:getBuyVirtualCount(ITEM_TYPE.MONEY, lv)
	elseif self._model == 9 then
		return QVIPUtil:getBuyVirtualCount(ITEM_TYPE.ENERGY, lv)
	elseif self._model == 10 then
		return QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(lv).ptshop_limit
	elseif self._model == 11 then
		return QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(lv).gnshop_limit
	elseif self._model == 12 then
		return QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(lv).ylshop_limit
	elseif self._model == 13 then
		return QStaticDatabase:sharedDatabase():getVipContnentByVipLevel(lv).hsshop_limit
	elseif self._model == 14 then
		return QVIPUtil:getTowerBuyCount( lv )
	elseif self._model == 15 then
		return QVIPUtil:getResetEliteDungeonCount( lv )
	elseif self._model == 16 then
		return QVIPUtil:getSunWarBuyReviveCount( lv )
	elseif self._model == 17 then
		return QVIPUtil:getSocietyDungeonBuyFightCount( lv )
	elseif self._model == 18 then
		return QVIPUtil:getSilverMineBuyFightCount( lv )
	elseif self._model == 19 then
		return QVIPUtil:getGloryArenaRefreshCount(lv)
	elseif self._model == 20 then
		return QVIPUtil:getGloryArenaResetCount(lv)
	elseif self._model == 21 then
		return QVIPUtil:getStormArenaRefreshCount(lv)
	elseif self._model == 22 then
		return QVIPUtil:getStormArenaResetCount(lv)
	elseif self._model == 23 then
		return QVIPUtil:getGoldPickaxeCount(lv)
	elseif self._model == 24 then
		return QVIPUtil:getBlackRockBuyAwardsCount(lv)
	elseif self._model == 25 then
		return QVIPUtil:getPlunderLootCount(lv)
	elseif self._model == 26 then
		return QVIPUtil:getMaritimeRobberyCount(lv)
	elseif self._model == 27 then
		return QVIPUtil:getMaritimeTransportCount(lv)
	elseif self._model == 28 then
		return QVIPUtil:getWorldBossBuyFightCount(lv)
	elseif self._model == 29 then
		return QVIPUtil:getDragonWarCount(lv)
	elseif self._model == 30 then
		return QVIPUtil:getSotoTeamRefreshCount(lv)
	elseif self._model == 31 then
		return QVIPUtil:getSotoTeamResetCount(lv)
	elseif self._vipField then
		return QVIPUtil:getCountByWordField(self._vipField, lv)
	else
		return nil
	end
end

--根据字段获取次数
function QVIPUtil:getCountByWordField(field, level)
	local lv = level or self:VIPLevel()
	if lv > self:getMaxLevel() then
		lv = self:getMaxLevel()
	end
	return QStaticDatabase:sharedDatabase():getVIP()[tostring(lv)][field] or 0
end

function QUIDialogVipAlert:_changeText()
	local temp = self._content
	local isFind = false
	local tbl = {}
	while (string.find(temp, "(%d+级)")) do
		-- 给所有（XX级）着色
		local s,e,v = string.find(temp, "(%d+级)")
		
		table.insert(tbl, string.sub(temp, 1, s - 1))
		table.insert(tbl, v)

		temp = string.sub(temp, e + 1)
		isFind = true
	end
	table.insert(tbl, temp)
	-- printTable(tbl)
	for _, value in pairs(tbl) do
		temp = value
		while (string.find(temp, "(%d+次)")) do
			-- 给所有（XX级）着色
			local s,e,v = string.find(temp, "(%d+次)")
			
			table.insert(self._textTbl, string.sub(temp, 1, s - 1))
			table.insert(self._textTbl, v)

			temp = string.sub(temp, e + 1)
			isFind = true
		end
		table.insert(self._textTbl, temp)
	end
	-- printTable(self._textTbl)
	self:_setColor()
	if isFind then 
		self._ccbOwner.tf_content:setVisible(false)
	end
end

function QUIDialogVipAlert:_showText()
	if self._noAlert then
		return
	end

	self:getView():setVisible(true)

	if self._richText then
		local text = QColorLabel:create(self._richText, 320, 170)
    	self._ccbOwner.node_text:addChild(text)
		self._ccbOwner.node_text:setVisible(true)
		self._ccbOwner.tf_content:setVisible(false)
	else
		self._ccbOwner.tf_content:setVisible(true)
		self._ccbOwner.node_text:setVisible(false)
	end
end

function QUIDialogVipAlert:_setShowVipLevel( ... )
	self._ccbOwner.node_vip_tip:setVisible(false)
	if self._showVipLevel then
		self._ccbOwner.node_vip_tip:setVisible(true)
		self._ccbOwner.bf_vip_level:setString(self._showVipLevel)
	end
end

function QUIDialogVipAlert:_setColor()
	if not self._textTbl or table.nums(self._textTbl) == 0 then 
		self:_errorFix()
		return 
	end
	self._richText = ""
	local isColor = false
	for _, value in pairs(self._textTbl) do
		if isColor then
			-- self._richText = self._richText .. "##o" .. value 强调文字改成 ##e
			self._richText = self._richText .. "##e" .. value
		else
			self._richText = self._richText .. "##n" .. value
		end
		isColor = not isColor
	end

	self._textTbl = nil
	self._textTbl = {}
end

function QUIDialogVipAlert:_errorFix()
	self._ccbOwner.confirmText:setString("魂师大人，VIP等级不足或钻石余量不足")
	self._richText = nil
	self:_showText()
end

function QUIDialogVipAlert:viewWillAppear()
	QUIDialogVipAlert.super.viewWillAppear(self)
end

function QUIDialogVipAlert:viewDidAppear()
	QUIDialogVipAlert.super.viewDidAppear(self)
	if self._noAlert then
		self:_delayClose()
	end
end

function QUIDialogVipAlert:_delayClose()
	self._scheduler = scheduler.performWithDelayGlobal(function()
		if self:getEffectPlay() then
			self:_delayClose()
		else
			self:close()
		end
	end, 0)
end

function QUIDialogVipAlert:viewWillDisappear()
    QUIDialogVipAlert.super.viewWillDisappear(self)
    if self._scheduler then
    	scheduler.unscheduleGlobal(self._scheduler)
    	self._scheduler = nil
    end
end

function QUIDialogVipAlert:viewDidDisappear()
	QUIDialogVipAlert.super.viewDidDisappear(self)
	if self._noAlert then
		if self._title then
			app.tip:floatTip("魂师大人，当前"..self._title.."已用完。")
		else
			app.tip:floatTip("魂师大人，当前购买次数已用完。")
		end
		
	end
end

function QUIDialogVipAlert:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	self._type = "close"
	if app.sound ~= nil then
		app.sound:playSound("common_cancel")
	end

	self:close()
end

function QUIDialogVipAlert:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_recharge) == false then return end
	self._type = "confrim"
	self:close()
end

function QUIDialogVipAlert:_onTriggerBack( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end

	self:_onTriggerClose()
end

function QUIDialogVipAlert:_backClickHandler()
	-- local options = self:getOptions()
	-- if options.canBackClick ~= false then
    	self:close()
    -- end
end

function QUIDialogVipAlert:close()
	self:playEffectOut()
end

function QUIDialogVipAlert:viewAnimationOutHandler()
	local options = self:getOptions()
	if options.layer ~= nil then
		app:getNavigationManager():popViewController(options.layer, QNavigationController.POP_TOP_CONTROLLER)
	end

	if self._closeCallBack ~= nil then
		self._closeCallBack(self._type)
	end
	if self._type == "confrim" then
		if self._comfirmBack ~= nil then
			self._comfirmBack(self._type)
		end

		if ENABLE_CHARGE() then
		    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
		else
			app.tip:floatTip("暂未开启")
		end
	elseif self._type == "tips" then
		app.tip:floatTip("魂师大人，当前购买次数已用完。")
	end
end

return QUIDialogVipAlert