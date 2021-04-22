--
-- Author: Your Name
-- Date: 2016-03-23 15:40:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnchantOrient = class("QUIWidgetEnchantOrient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogTavernAchieve = import("..dialogs.QUIDialogTavernAchieve")
local QNavigationController = import("...controllers.QNavigationController")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetEnchantOrient.BUY_SUCCESSED_EVENT = "BUY_SUCCESSED_EVENT"
QUIWidgetEnchantOrient.TIME_TO_REFRESH = "TIME_TO_REFRESH"

function QUIWidgetEnchantOrient:ctor(options)
	local ccbFile = "ccb/Widget_fumo_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, self._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerBuyTen", callback = handler(self, self._onTriggerBuyTen)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerExchange", callback = handler(self, self._onTriggerExchange)},
		{ccbCallbackName = "onTriggerSynthesis", callback = handler(self, self._onTriggerSynthesis)}
	}
	QUIWidgetEnchantOrient.super.ctor(self, ccbFile, callBacks, options)
	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_buy:setVisible(false)

	q.setButtonEnableShadow(self._ccbOwner.btn_synthesis)
	self._ccbOwner.node_synthesis:setVisible(true)
	if self._chestEffect == nil then
		self._chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(self._chestEffect)
		self._chestEffect:playAnimation("ccb/effects/fomo_baoxiang.ccbi", function()end, function()end, false)
	end

	self._oldPositionX = self._ccbOwner.tf_one_money:getPositionX()
	self._oldScore = remote.user.enchantScore
	
	self._config = QStaticDatabase:sharedDatabase():getConfiguration()
	self._oneMoney = self._config["ENCHANT_BOX_COST"].value or 10
	self._tenMoney = self._config["ENCHANT_BOX_10_COST"].value or 580

	self._isEffect = false

	self:setAwardsInfo()
	self:setMoneyInfo()

end

function QUIWidgetEnchantOrient:onEnter()
	self._mainPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self._mainPage.topBar then
		self._mainPage.topBar:setUpdateDataByManual(TOP_BAR_TYPE.ENCHANT_SCORE, true)
	end
end

function QUIWidgetEnchantOrient:onExit()
 	if self._refreshScheduler ~= nil then
 		scheduler.unscheduleGlobal(self._refreshScheduler)
 		self._refreshScheduler = nil
 	end
	if self._mainPage and self._mainPage.topBar then
		self._mainPage.topBar:setUpdateDataByManual(TOP_BAR_TYPE.ENCHANT_SCORE, false)
	end

	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
		end

end

function QUIWidgetEnchantOrient:setAwardsInfo()
	local tavernInfo = QStaticDatabase:sharedDatabase():getTavernOverViewInfoByTavernType(tostring(25))
	local awardsInfo = {}
	if tavernInfo["item_1"] then
		awardsInfo = string.split(tavernInfo["item_1"], ";")
	end

	for i = 1, 4, 1 do
		if awardsInfo[i] ~= nil then
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setGoodsInfo(tonumber(awardsInfo[i]), "item", 0)
			itemBox:setPromptIsOpen(true)
			self._ccbOwner["node_item"..i]:addChild(itemBox)
		else
			self._ccbOwner["node_item"..i]:setVisible(false)
		end
	end
end

function QUIWidgetEnchantOrient:setMoneyInfo()

	local callCardNum = remote.items:getItemsNumByID(self._config["ENCHANT_BOX_KEY"].value)
	local isFree = remote.user.enchantIsFree

	self._ccbOwner.token:setVisible(true)
	self._ccbOwner.tf_ten_money:setString(callCardNum.."/10")

	-- 设置抽一次价格
	if isFree then
		self._ccbOwner.tf_one_money:setString("免费")
		self._ccbOwner.tf_one_money:setPositionX(self._oldPositionX-35)
		self._ccbOwner.token:setVisible(false)
	else
		self._ccbOwner.tf_one_money:setPositionX(self._oldPositionX)
		self._ccbOwner.tf_one_money:setString(callCardNum.."/1")

		self:_startScheduler()
	end

	local itemConfig = db:getItemByID("99")
	if itemConfig.icon_1 then
		local texture = CCTextureCache:sharedTextureCache():addImage(itemConfig.icon_1)
		self._ccbOwner.token:setTexture(texture)
		self._ccbOwner.token_ten:setTexture(texture)
	end

	self:updateActivityCount()
end

function QUIWidgetEnchantOrient:updateActivityCount()
	local activityInfo = remote.activity:getActivityDataByTagetId(554)
	if activityInfo and activityInfo.targets then
		self._ccbOwner.node_choujiangCount:setVisible(true)
		local count = 0
		local maxCount = 0
		for _,info in pairs(activityInfo.targets) do
			local infoCount = remote.activity:getTypeNum(info) or 0
			count = math.max(count,infoCount) 
			maxCount = math.max(maxCount,(info.value or 0))
		end
		if maxCount ~= 0 and count >= maxCount then
			self._ccbOwner.tf_choujiang_name:setString("已达成宝箱活动抽取目标")
			self._ccbOwner.tf_choujiang_count:setString("")
		else
			self._ccbOwner.tf_choujiang_count:setString(count)
			self._ccbOwner.tf_choujiang_name:setString("活动期间十连抽取次数：")
		end
		q.autoLayerNode({self._ccbOwner.tf_choujiang_name,self._ccbOwner.tf_choujiang_count},"x",0)		
	else
		self._ccbOwner.node_choujiangCount:setVisible(false)
	end
end

function QUIWidgetEnchantOrient:_startScheduler()
	if self._refreshScheduler ~= nil then
 		scheduler.unscheduleGlobal(self._refreshScheduler)
 		self._refreshScheduler = nil
 	end

	local refreshTime = q.date("*t", q.serverTime())
    if refreshTime.hour < 5 then 
    	refreshTime.day = refreshTime.day - 1
    end
    refreshTime.hour = 5
    refreshTime.min = 0
    refreshTime.sec = 0
    refreshTime = q.OSTime(refreshTime) or 0

    local currentTime = q.serverTime()
   	self._refreshScheduler = scheduler.performWithDelayGlobal(function()
			self:setMoneyInfo()
			self:dispatchEvent({name = QUIWidgetEnchantOrient.TIME_TO_REFRESH})
   		end, (refreshTime+24*3600)-currentTime + 5)
end

function QUIWidgetEnchantOrient:buySuccessed(data, isTen, isAgain)
	self._lastScore = remote.user.enchantScore
	if self._effectShow ~= nil then
		self._effectShow:disappear()
		self._effectShow = nil
	end


	local cost = remote.items:getItemsNumByID(self._config["ENCHANT_BOX_KEY"].value)
	local itemType = ITEM_TYPE.SUMMONCARD_ENCHANT
	local againBackClick = handler(self, self._onTriggerBuyOne)
	if isTen then
		againBackClick = handler(self, self._onTriggerBuyTen)
	end

	self:setMoneyInfo()

	local options = {}
	options.cost = cost
	options.againBack = againBackClick
	options.tokenType = itemType
	options.items = data.prizes
	options.oldHeros = self._oldHeros
	options.confirmBack = handler(self, self._confirmCallBack)

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantTavernAchieve", 
		options=options}, {isPopCurrentDialog = false})

	self:dispatchEvent({name = QUIWidgetEnchantOrient.BUY_SUCCESSED_EVENT})
end

function QUIWidgetEnchantOrient:_confirmCallBack()
	if self.class ~= nil then
		if self._effectShow ~= nil then
			self._effectShow:disappear()
			self._effectShow = nil
		end
		
		local changeScore = remote.user.enchantScore - self._oldScore
		self._effectShow = QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._effectShow)
		self._effectShow:playAnimation("ccb/effects/fomo_tips.ccbi", function()
				self._effectShow._ccbOwner.add_integnal_num:setString("恭喜您获得"..(changeScore).."点觉醒积分")
			end, 
			function()
				self:_updateEnchantScore()
				self._lastScore = nil
			end)

		self._ccbOwner.btn_one:setEnabled(true)	
		self._ccbOwner.btn_ten:setEnabled(true)	
		self:setMoneyInfo()
	end
end

function QUIWidgetEnchantOrient:_updateEnchantScore()
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.topBar and page.topBar._bars[TOP_BAR_TYPE.ENCHANT_SCORE] then
		self._oldScore = remote.user.enchantScore
		page.topBar._bars[TOP_BAR_TYPE.ENCHANT_SCORE]:update(remote.user.enchantScore or 0)
	end
end

function QUIWidgetEnchantOrient:_checkMoney(cost)
	if remote.user.token < cost then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return false
	end
	return true
end

function QUIWidgetEnchantOrient:_onTriggerExchange()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantExchange"})
end

function QUIWidgetEnchantOrient:_onTriggerSynthesis( )
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogEnchantSynthesis"})
end

function QUIWidgetEnchantOrient:_onTriggerPreview()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestPreview", 
		options = {previewType = 24, title = {"稀有道具", "高级道具"}}})
end

function QUIWidgetEnchantOrient:_onTriggerBuyOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_one) == false then return end
	if self._isEffect then return end
    app.sound:playSound("common_small")
	if self._lastScore ~= nil then
		self:_updateEnchantScore()
	end
	self._oldHeros = clone(remote.herosUtil:getHaveHero())

	local actionFunc = function( )
		self._isEffect = true
		if self._chestEffect then 
			self._chestEffect:setVisible(false)
		end

		local chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(chestEffect)
		chestEffect:playAnimation("ccb/effects/fomo_bxbz_normal.ccbi", function()end, function()
			chestEffect:disappear()
			if self._chestEffect then
				self._chestEffect:setVisible(true)
			end		
		end, false)

		if self._scheduler then
	  		scheduler.unscheduleGlobal(self._scheduler)
	  		self._scheduler = nil
  		end
    	self._scheduler = scheduler.performWithDelayGlobal(function()
			self:buyItem(1, event.isAgain)
    	end, 1.3)
	end

	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ENCHANT_ORIENT)
	local callCardNum = remote.items:getItemsNumByID(self._config["ENCHANT_BOX_KEY"].value)
	local isFree = remote.user.enchantIsFree
	self._ccbOwner.btn_one:setEnabled(true)
	self._ccbOwner.btn_ten:setEnabled(true)
	if callCardNum > 0 or isFree == true then

		self._ccbOwner.btn_one:setEnabled(false)
		self._ccbOwner.btn_ten:setEnabled(false)
		actionFunc()
	elseif  isShowDialog == false then
		if self:_checkMoney(self._oneMoney) == true then
			self._ccbOwner.btn_one:setEnabled(false)	
			self._ccbOwner.btn_ten:setEnabled(false)
			actionFunc()
		end
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = self._config["ENCHANT_BOX_KEY"].value, buyNum = 1, price = self._oneMoney, buyType = DAILY_TIME_TYPE.ENCHANT_ORIENT, callback = function()
				
			if self:_checkMoney(self._oneMoney) == true then
				actionFunc()
			end

			end}}, {isPopCurrentDialog = false})
		self._ccbOwner.btn_one:setEnabled(true)
	end
end

function QUIWidgetEnchantOrient:_onTriggerBuyTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ten) == false then return end
	if self._isEffect then return end
    app.sound:playSound("common_small")
	if self._lastScore ~= nil then
		self:_updateEnchantScore()
	end
	self._oldHeros = clone(remote.herosUtil:getHaveHero())

	local actionFunc = function( )
		self._isEffect = true
		if self._chestEffect then 
			self._chestEffect:setVisible(false)
		end

		local chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(chestEffect)
		chestEffect:playAnimation("ccb/effects/fomo_bxbz_normal.ccbi", function()end, function()
			chestEffect:disappear()
			if self._chestEffect then
				self._chestEffect:setVisible(true)
			end
		end, false)

		if self._scheduler then
	  		scheduler.unscheduleGlobal(self._scheduler)
	  		self._scheduler = nil
  		end
    	self._scheduler = scheduler.performWithDelayGlobal(function()
			self:buyItem(10, event.isAgain)
    	end, 1.3)
	end
	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.ENCHANT_ORIENT)
	local callCardNum = remote.items:getItemsNumByID(self._config["ENCHANT_BOX_KEY"].value)
	self._ccbOwner.btn_one:setEnabled(true)
	self._ccbOwner.btn_ten:setEnabled(true)
	if callCardNum >= 10 then
		self._ccbOwner.btn_one:setEnabled(false)	
		self._ccbOwner.btn_ten:setEnabled(false)

		actionFunc()
	elseif  isShowDialog == false then
		if self:_checkMoney(self._tenMoney) == true then
			self._ccbOwner.btn_one:setEnabled(false)	
			self._ccbOwner.btn_ten:setEnabled(false)
			actionFunc()
		end
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = self._config["ENCHANT_BOX_KEY"].value, buyNum = 10, price = self._tenMoney, buyType = DAILY_TIME_TYPE.ENCHANT_ORIENT, callback = function()

			if self:_checkMoney(self._tenMoney) == true then
				-- self:buyItem(10, event.isAgain)
				actionFunc()
			end

			end}}, {isPopCurrentDialog = false})
		self._ccbOwner.btn_ten:setEnabled(true)
	end
end

function QUIWidgetEnchantOrient:buyItem(count, isAgain)
	local isTen = false
	if count > 1 then
		isTen = true
	end
	app:getClient():luckyDrawEnchantRequest(isTen, function(data)
			self._isEffect = false
			if isTen then
				remote.activity:updateLocalDataByType(554, 1)
			end
			if self.class then
				self:buySuccessed(data, isTen, isAgain)
			end
		end, function()
			self._isEffect = false
		end)
end

function QUIWidgetEnchantOrient:_onTriggerHelp()
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCountHelp", 
		options = {helpType = "fumo_1_baoxiang_1"}})
end

return QUIWidgetEnchantOrient