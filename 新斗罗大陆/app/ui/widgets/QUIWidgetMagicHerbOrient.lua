-- 
-- zxs
-- 仙品宝箱
-- 
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbOrient = class("QUIWidgetMagicHerbOrient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")
local QVIPUtil = import("...utils.QVIPUtil")

QUIWidgetMagicHerbOrient.BUY_SUCCESSED_EVENT = "BUY_SUCCESSED_EVENT"
QUIWidgetMagicHerbOrient.TIME_TO_REFRESH = "TIME_TO_REFRESH"

function QUIWidgetMagicHerbOrient:ctor(options)
	local ccbFile = "ccb/Widget_fumo_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, self._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerBuyTen", callback = handler(self, self._onTriggerBuyTen)},
	}
	QUIWidgetMagicHerbOrient.super.ctor(self, ccbFile, callBacks, options)
	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()


	if self._chestEffect == nil then
		self._chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(self._chestEffect)
		self._chestEffect:playAnimation("ccb/effects/fofm_baoxiang.ccbi", function()end, function()end, false)
	end

	self._ccbOwner.node_synthesis:setVisible(false)
	self._ccbOwner.node_buy:setVisible(false)
	self._oldPositionX = self._ccbOwner.tf_one_money:getPositionX()
	self._oldScore = remote.user.magicherbMoney or 0
	self._ccbOwner.btn_exchange:setVisible(false)
	self._ccbOwner.tf_exchange:setVisible(false)

	self._isEffect = false
	
	local config = db:getConfiguration()
	self._itemId = MAGIC_HERB_ID
	self._oneMoney = config["MAGIC_HERB_ZHAOHUAN_DANZHAO"].value or 10
	self._tenMoney = config["MAGIC_HERB_ZHAOHUAN_SHILIANZHAO"].value or 580

	self:setAwardsInfo()
	self:setMoneyInfo()
end

function QUIWidgetMagicHerbOrient:onEnter()
end

function QUIWidgetMagicHerbOrient:onExit()
 	if self._refreshScheduler ~= nil then
 		scheduler.unscheduleGlobal(self._refreshScheduler)
 		self._refreshScheduler = nil
 	end
end

function QUIWidgetMagicHerbOrient:setAwardsInfo()
	local tavernInfo = db:getTavernOverViewInfoByTavernType("32") or {}
	local awardsInfo = {}
	if tavernInfo["item_1"] then
		awardsInfo = string.split(tavernInfo["item_1"], ";")
	end

	for i = 1, 4 do
		if awardsInfo[i] then
			local itemId = tonumber(awardsInfo[i])
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setGoodsInfo(itemId, "item", 0)
			itemBox:setPromptIsOpen(true)
			self._ccbOwner["node_item"..i]:addChild(itemBox)
		else
			self._ccbOwner["node_item"..i]:setVisible(false)
		end
	end
end
function QUIWidgetMagicHerbOrient:_onClick(event)
	app.tip:itemTip(ITEM_TYPE.ITEM, event.itemId)
end

function QUIWidgetMagicHerbOrient:setMoneyInfo()

	local callCardNum = remote.items:getItemsNumByID(self._itemId)
	local isFree = remote.user.magicHerbIsFree
	self._ccbOwner.token:setVisible(true)
	self._ccbOwner.tf_ten_money:setString(callCardNum.."/10")
	self._ccbOwner.tf_ten_tips:setString("10连抽必定A级或以上仙品")

	-- 设置抽一次价格
	if isFree then
		self._ccbOwner.tf_one_money:setString("免费")
		self._ccbOwner.tf_one_money:setPositionX(self._oldPositionX-20)
		self._ccbOwner.token:setVisible(false)
	else
		self._ccbOwner.tf_one_money:setPositionX(self._oldPositionX)
		self._ccbOwner.tf_one_money:setString(callCardNum.."/1")

		self:_startScheduler()
	end

	local itemConfig = db:getItemByID(self._itemId)
	if itemConfig.icon_1 then
		local texture = CCTextureCache:sharedTextureCache():addImage(itemConfig.icon_1)
		self._ccbOwner.token:setTexture(texture)
		self._ccbOwner.token_ten:setTexture(texture)
	end

	self:updateActivityCount()
end

function QUIWidgetMagicHerbOrient:updateActivityCount()
	local activityInfo = remote.activity:getActivityDataByTagetId(710)
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

function QUIWidgetMagicHerbOrient:_startScheduler()
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
			self:dispatchEvent({name = QUIWidgetMagicHerbOrient.TIME_TO_REFRESH})
   		end, (refreshTime+DAY)-currentTime + 5)
end


function QUIWidgetMagicHerbOrient:buySuccessed(data, isTen, isAgain)


	local cost = remote.items:getItemsNumByID(self._itemId)
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
	options.oldHeros = {}
	options.confirmBack = handler(self, self._confirmCallBack)

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbTavernAchieve", 
		options = options}, {isPopCurrentDialog = false})

	self:dispatchEvent({name = QUIWidgetMagicHerbOrient.BUY_SUCCESSED_EVENT})
end

function QUIWidgetMagicHerbOrient:buyItem(count, isAgain)
	local isTen = count > 1

	remote.magicHerb:magicHerbSummonRequest(isTen, function(data)
			self._isEffect = false
			if self._ccbView then
				if isTen then
	 				remote.activity:updateLocalDataByType(710, 1)
				end
				self:buySuccessed(data, isTen, isAgain)
			end
		end, function()
			self._isEffect = false
			if self._ccbView then
				self._ccbOwner.btn_one:setEnabled(true)
				self._ccbOwner.btn_ten:setEnabled(true)
			end
		end)
end

function QUIWidgetMagicHerbOrient:_checkMoney(cost)
	if remote.user.token < cost then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return false
	end
	return true
end

function QUIWidgetMagicHerbOrient:_confirmCallBack()
	if self.class ~= nil then
		self._ccbOwner.btn_one:setEnabled(true)	
		self._ccbOwner.btn_ten:setEnabled(true)	
		self:setMoneyInfo()
	end
end

function QUIWidgetMagicHerbOrient:_onTriggerPreview()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestPreview", 
		options = {previewType = 31, title = {"仙品", "升级和转生道具"}}})
end

function QUIWidgetMagicHerbOrient:_onTriggerBuyOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_one) == false then return end
	if self._isEffect then return end

    app.sound:playSound("common_small")

	local actionFunc = function( )
		self._isEffect = true
		if self._chestEffect then 
			self._chestEffect:setVisible(false)
		end

		local chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(chestEffect)
		chestEffect:playAnimation("ccb/effects/xianpin_baoxiang_normal.ccbi", function()end, function()
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
	local callCardNum = remote.items:getItemsNumByID(self._itemId)
	local isFree = remote.user.magicHerbIsFree
	self._ccbOwner.btn_one:setEnabled(true)
	self._ccbOwner.btn_ten:setEnabled(true)
	if callCardNum > 0 or isFree == true  then
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
			options={itemId = self._itemId, buyNum = 1, price = self._oneMoney, buyType = DAILY_TIME_TYPE.ENCHANT_ORIENT, callback = function()
				if self:_checkMoney(self._oneMoney) == true then
					-- self:buyItem(1, event.isAgain)
					actionFunc()
				end
			end}}, {isPopCurrentDialog = false})
		self._ccbOwner.btn_one:setEnabled(true)
	end
end

function QUIWidgetMagicHerbOrient:_onTriggerBuyTen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ten) == false then return end
	if self._isEffect then return end
    app.sound:playSound("common_small")

	local actionFunc = function( )
		self._isEffect = true
		if self._chestEffect then 
			self._chestEffect:setVisible(false)
		end

		local chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(chestEffect)
		chestEffect:playAnimation("ccb/effects/xianpin_baoxiang_normal.ccbi", function()end, function()
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
	self._ccbOwner.btn_one:setEnabled(true)
	self._ccbOwner.btn_ten:setEnabled(true)	
	local callCardNum = remote.items:getItemsNumByID(self._itemId)	
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
			options={itemId = self._itemId, buyNum = 10, price = self._tenMoney, buyType = DAILY_TIME_TYPE.ENCHANT_ORIENT, callback = function()
				if self:_checkMoney(self._tenMoney) == true then
					-- self:buyItem(10, event.isAgain)
					actionFunc()
				end
			end}}, {isPopCurrentDialog = false})
		self._ccbOwner.btn_ten:setEnabled(true)
	end
end

function QUIWidgetMagicHerbOrient:_onTriggerHelp()
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCountHelp", 
		options = {helpType = "magic_herb_draw"}})
end

return QUIWidgetMagicHerbOrient