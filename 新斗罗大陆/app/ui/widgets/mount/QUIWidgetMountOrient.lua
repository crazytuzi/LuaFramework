
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountOrient = class("QUIWidgetMountOrient", QUIWidget)

local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIDialogTavernAchieve = import("...dialogs.QUIDialogTavernAchieve")
local QNavigationController = import("....controllers.QNavigationController")
local QQuickWay = import("....utils.QQuickWay")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")

QUIWidgetMountOrient.BUY_SUCCESSED_EVENT = "BUY_SUCCESSED_EVENT"
QUIWidgetMountOrient.TIME_TO_REFRESH = "TIME_TO_REFRESH"

function QUIWidgetMountOrient:ctor(options)
	local ccbFile = "ccb/Widget_Weapon_shop_13.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerCombination", callback = handler(self, self._onTriggerCombination)},
		{ccbCallbackName = "onTriggerExchange", callback = handler(self, self._onTriggerExchange)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, self._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerBuyTen", callback = handler(self, self._onTriggerBuyTen)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
	}
	QUIWidgetMountOrient.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	if remote.user.mountIsFree or (not app.unlock:getUnlockSeniorRedPoint() and remote.items:getItemsNumByID(162) > 0) then
  		if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MOUNT_MAILL) then
			app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.MOUNT_MAILL)
		end
	end
    
	self._oldPositionX = self._ccbOwner.tf_one_money:getPositionX()
	self._oldScore = remote.user.stormMoney or 0
	
	self._config = QStaticDatabase:sharedDatabase():getConfiguration()
	self._oneMoney = self._config["ZUOQI_ZHAOHUAN_DANZHAO"].value or 10
	self._tenMoney = self._config["ZUOQI_ZHAOHUAN_SHILIANZHAO"].value or 580

	self._oneAward = self._config["ZUOQI_ZHAOHUAN_HUOBI"].value or 60
	self._tenAward = self._config["ZUOQI_SHICIZHAOHUAN_HUOBI"].value or 800

	self._isEffect = false

	if self._chestEffect == nil then
		self._chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:removeAllChildren()
		self._ccbOwner.node_chest:addChild(self._chestEffect)
		self._chestEffect:playAnimation("ccb/effects/anqi_baoxian.ccbi", function()end, function()end, false)
	end

	self:setMoneyInfo()
	self:setAwardsInfo()
end

function QUIWidgetMountOrient:onEnter()
	self._mainPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self._mainPage.topBar then
		self._mainPage.topBar:setUpdateDataByManual(TOP_BAR_TYPE.STORM_MONEY, true)
	end
end

function QUIWidgetMountOrient:onExit()
 	if self._refreshScheduler ~= nil then
 		scheduler.unscheduleGlobal(self._refreshScheduler)
 		self._refreshScheduler = nil
 	end
	if self._mainPage and self._mainPage.topBar then
		self._mainPage.topBar:setUpdateDataByManual(TOP_BAR_TYPE.STORM_MONEY, false)
	end
	
	if self._scheduler then
  		scheduler.unscheduleGlobal(self._scheduler)
  		self._scheduler = nil
	end
end

function QUIWidgetMountOrient:setAwardsInfo()
	local tavernInfo = QStaticDatabase:sharedDatabase():getTavernOverViewInfoByTavernType(tostring(27))
	local awardsInfo = {}
	if tavernInfo["item_1"] then
		awardsInfo = string.split(tavernInfo["item_1"], ";")
	end

	for i = 1, 4, 1 do
		if awardsInfo[i] then
			local itemBox = QUIWidgetItemsBox.new()
			local itemType = ITEM_TYPE.ITEM
			local itemConfig =  QStaticDatabase:sharedDatabase():getItemByID(tonumber(awardsInfo[i]))
			if itemConfig == nil then
				itemConfig = QStaticDatabase:sharedDatabase():getCharacterByID(tonumber(awardsInfo[i]))
				itemType = ITEM_TYPE.HERO
			end
			itemBox:setGoodsInfo(tonumber(awardsInfo[i]), itemType, 0)
			itemBox:setPromptIsOpen(true)
			if itemType == ITEM_TYPE.HERO and itemConfig ~= nil then
				itemBox:showSabc(remote.gemstone:getSABC(itemConfig.aptitude).lower)
			end
			itemBox:hideTalentIcon()
			self._ccbOwner["node_item"..i]:addChild(itemBox)
		else
			self._ccbOwner["node_item"..i]:setVisible(false)
		end
	end
end

function QUIWidgetMountOrient:setMoneyInfo()
	local callCardNum = remote.items:getItemsNumByID(162)
	local isFree = remote.user.mountIsFree

	self._ccbOwner.token:setVisible(true)
	self._ccbOwner.token_ten:setVisible(true)
	self._ccbOwner.callFree_enchant:setVisible(false)
	self._ccbOwner.callFree_enchant_ten:setVisible(false)

	-- 设置抽一次价格
	if isFree then
		self._ccbOwner.tf_one_money:setString("免费")
		self._ccbOwner.tf_one_money:setPositionX(self._oldPositionX-20)
		self._ccbOwner.token:setVisible(false)

		self._ccbOwner.tf_count_one:setString("每日5点重置免费次数")
	else
		self._ccbOwner.tf_one_money:setPositionX(self._oldPositionX)
		self._ccbOwner.tf_one_money:setString(callCardNum.."/1")
		self._ccbOwner.token:setVisible(false)
		self._ccbOwner.callFree_enchant:setVisible(true)

		self._ccbOwner.tf_count_one:setString("必得"..self._oneAward.."暗器币")

		self:_startScheduler()
	end
	self._ccbOwner.tf_count_tips:setString("召唤十次必得"..self._tenAward.."暗器币")

	-- 设置十连抽价格
	self._ccbOwner.token_ten:setVisible(false)
	self._ccbOwner.callFree_enchant_ten:setVisible(true)
	self._ccbOwner.tf_ten_money:setString(callCardNum.."/10")

	self:updateActivityCount()
end

function QUIWidgetMountOrient:updateActivityCount()
	local activityInfo = remote.activity:getActivityDataByTagetId(557)
	if activityInfo and activityInfo.targets then
		self._ccbOwner.node_choujiangCount:setVisible(true)
		local count = 0
		local maxCount = 0
		for _,info in pairs(activityInfo.targets) do
			local infoCount = remote.activity:getTypeNum(info) or 0
			maxCount = math.max(maxCount,(info.value or 0))
			count = math.max(count,infoCount) 
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

function QUIWidgetMountOrient:_startScheduler()
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
			self:dispatchEvent({name = QUIWidgetMountOrient.TIME_TO_REFRESH})
   		end, (refreshTime+24*3600)-currentTime + 5)
end

function QUIWidgetMountOrient:buySuccessed(data, isTen, isAgain)
	self._lastScore = remote.user.stormMoney
	if self._effectShow ~= nil then
		self._effectShow:disappear()
		self._effectShow = nil
	end
	local cost = remote.items:getItemsNumByID(162)
	local itemType = ITEM_TYPE.SUMMONCARD_MOUNT
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

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountChestAchieve", 
		options=options}, {isPopCurrentDialog = false})

	self:dispatchEvent({name = QUIWidgetMountOrient.BUY_SUCCESSED_EVENT})
end

function QUIWidgetMountOrient:_confirmCallBack()
	if self.class ~= nil then
		if self._effectShow ~= nil then
			self._effectShow:disappear()
			self._effectShow = nil
		end
		
		local changeScore = (remote.user.stormMoney or 0) - self._oldScore
		self._effectShow = QUIWidgetAnimationPlayer.new()
		self:getView():addChild(self._effectShow)
		self._effectShow:playAnimation("ccb/effects/fomo_tips.ccbi", function()
				self._effectShow._ccbOwner.add_integnal_num:setString("恭喜您获得"..(changeScore).."暗器币")
			end, 
			function()
				self:_updateCurrency()
				self._lastScore = nil
			end)

		self._ccbOwner.btn_one:setEnabled(true)	
		self._ccbOwner.btn_ten:setEnabled(true)	
		self:setMoneyInfo()
	end
end

function QUIWidgetMountOrient:_updateCurrency()
	if self._mainPage and self._mainPage.topBar and self._mainPage.topBar._bars[TOP_BAR_TYPE.STORM_MONEY] then
		self._oldScore = remote.user.stormMoney or 0
		self._mainPage.topBar._bars[TOP_BAR_TYPE.STORM_MONEY]:update(remote.user.stormMoney or 0)
	end
end

function QUIWidgetMountOrient:_checkMoney(cost)
	if remote.user.token < cost then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return false
	end
	return true
end

function QUIWidgetMountOrient:_onTriggerCombination(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_combination) == false then return end

    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountCombination"})
end

function QUIWidgetMountOrient:_onTriggerExchange(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end

    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIWidgetMountOrient:_onTriggerPreview(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_preview) == false then return end

    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestPreview", 
	options = {previewType = 26, title = {"暗器", "暗器精炼材料", "暗器碎片"}}})
end

function QUIWidgetMountOrient:_onTriggerBuyOne(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_one) == false then return end
	if self._isEffect then return end

    app.sound:playSound("common_small")
	if self._lastScore ~= nil then
		self:_updateCurrency()
	end
	self._oldHeros = clone(remote.herosUtil:getHaveHero())

	local actionFunc = function( )
		self._isEffect = true
		if self._chestEffect then 
			self._chestEffect:setVisible(false)
		end

		local chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(chestEffect)
		chestEffect:playAnimation("ccb/effects/anqi_baoxian_normal.ccbi", function()end, function()
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

	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MOUNT_ORIENT)
	local callCardNum = remote.items:getItemsNumByID(162)
	local isFree = remote.user.mountIsFree
	self._ccbOwner.btn_one:setEnabled(true)
	self._ccbOwner.btn_ten:setEnabled(true)
	if callCardNum > 0 or isFree == true then
		self._ccbOwner.btn_one:setEnabled(false)	
		self._ccbOwner.btn_ten:setEnabled(false)	
		-- self:buyItem(1, event.isAgain)
		actionFunc()
	elseif  isShowDialog == false then
		if self:_checkMoney(self._oneMoney) == true then
			self._ccbOwner.btn_one:setEnabled(false)	
			self._ccbOwner.btn_ten:setEnabled(false)
			actionFunc()
		end			
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = "162", buyNum = 1, price = self._oneMoney, buyType = DAILY_TIME_TYPE.MOUNT_ORIENT, callback = function()
			if self:_checkMoney(self._oneMoney) == true then 
				-- self:buyItem(1, event.isAgain)
				actionFunc()
			end
			end}}, {isPopCurrentDialog = false})
		self._ccbOwner.btn_one:setEnabled(true)
	end
end

function QUIWidgetMountOrient:_onTriggerBuyTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ten) == false then return end
	if self._isEffect then return end

    app.sound:playSound("common_small")
	if self._lastScore ~= nil then
		self:_updateCurrency()
	end
	self._oldHeros = clone(remote.herosUtil:getHaveHero())

	local actionFunc = function( )
		self._isEffect = true
		if self._chestEffect then 
			self._chestEffect:setVisible(false)
		end

		local chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(chestEffect)
		chestEffect:playAnimation("ccb/effects/anqi_baoxian_normal.ccbi", function()end, function()
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

	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MOUNT_ORIENT)
	local callCardNum = remote.items:getItemsNumByID(162)
	self._ccbOwner.btn_one:setEnabled(true)
	self._ccbOwner.btn_ten:setEnabled(true)	
	if callCardNum >= 10 then
		self._ccbOwner.btn_one:setEnabled(false)	
		self._ccbOwner.btn_ten:setEnabled(false)	
		-- self:buyItem(10, event.isAgain)
		actionFunc()
	elseif  isShowDialog == false then
		if self:_checkMoney(self._tenMoney) == true then
			self._ccbOwner.btn_one:setEnabled(false)	
			self._ccbOwner.btn_ten:setEnabled(false)
			actionFunc()
		end			
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = "162", buyNum = 10, price = self._tenMoney, buyType = DAILY_TIME_TYPE.MOUNT_ORIENT, callback = function()
				if self:_checkMoney(self._tenMoney) == true then
					-- self:buyItem(10, event.isAgain)
					actionFunc()
				end
			end}}, {isPopCurrentDialog = false})
		self._ccbOwner.btn_ten:setEnabled(true)
	end
end

function QUIWidgetMountOrient:buyItem(count, isAgain)
	local isFree = remote.user.mountIsFree
	local isTen = false
	if count > 1 then
		isFree = false
		isTen = true
	end

	remote.mount:mountSummonRequest(isFree, isTen, function(data)
			self._isEffect = false
			if isTen then
				remote.activity:updateLocalDataByType(557, 1)
				if data.zuoqiFreeSummonAt ~= nil then
					remote.user:update({zuoqiFreeSummonAt = data.zuoqiFreeSummonAt})
				end
			end
			self:buySuccessed(data, isTen, isAgain)
		end, function()
			self._isEffect = false
		end)
end

function QUIWidgetMountOrient:_onTriggerHelp(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCountHelp", 
		options = {helpType = "zuoqi_baoxiang_1"}})
end

return QUIWidgetMountOrient