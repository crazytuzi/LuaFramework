local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetThunderFail = class("QUIWidgetThunderFail", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetThunderFail:ctor(options)
	local ccbFile = "ccb/Widget_ThunderKing_BattleDefeat_buy.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerShop", callback = handler(self, QUIWidgetThunderFail._onTriggerShop)},  
			{ccbCallbackName = "onTriggerElite", callback = handler(self, QUIWidgetThunderFail._onTriggerElite)},  
			{ccbCallbackName = "onTriggerBox", callback = handler(self, QUIWidgetThunderFail._onTriggerBox)},   
			{ccbCallbackName = "onTriggerConditionInfo", callback = handler(self, QUIWidgetThunderFail._onTriggerConditionInfo)},
			{ccbCallbackName = "onTriggerRank", callback = handler(self, QUIWidgetThunderFail._onTriggerRank)},    
			{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIWidgetThunderFail._onTriggerBuy)},  
			{ccbCallbackName = "onTriggerReset", callback = handler(self, QUIWidgetThunderFail._onTriggerReset)},    
	}
	QUIWidgetThunderFail.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._fighter = remote.thunder:getThunderFighter()
	local awards = self._fighter.thunderFailAward.awards
	if awards ~= nil and #awards > 0 then
		self._award = awards[1]
		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(itemBox)
		itemBox:setGoodsInfo(self._award.id, ITEM_TYPE.ITEM, self._award.count)
		self._ccbOwner.nodeItem:setVisible(true)
	else
		self._ccbOwner.nodeItem:setVisible(false)
	end
	local tokenConfig = QStaticDatabase:sharedDatabase():getTokenConsume("refresh_thunder", self._fighter.thunderResetCount+1)
	if tokenConfig.money_num > 0 then
		self._ccbOwner.tf_money:setString(tokenConfig.money_num)
		self._ccbOwner.tf_free:setVisible(false)
		self._ccbOwner.node_token:setVisible(true)
	else
		self._ccbOwner.node_token:setVisible(false)
		self._ccbOwner.tf_free:setVisible(true)
	end
	if remote.thunder:getIsBattle() == true then
		if not (FinalSDK.isHXShenhe()) then
			self:_onTriggerBuy()
		end
	end

	-- if options and options.arrivalMaxLayer then 
	-- 	self._ccbOwner.tf_buy_info:setString("三哥真棒！您已通\n关了杀戮之都！敬请\n期待后续关卡！")
	-- else
		local lastWinFloor = (self._fighter.thunderLastWinFloor-1)*3+self._fighter.thunderLastWinWave or 1
		local historyCount = self._fighter.thunderMaxHisWave or 1
		if lastWinFloor > historyCount then
			historyCount = lastWinFloor
		end
		self._ccbOwner.tf_pass_count:setString(lastWinFloor.."关")
		self._ccbOwner.tf_max_pass_count:setString("（历史最高"..historyCount.."关）")
		self._ccbOwner.tf_max_star:setString(self._fighter.thunderHistoryMaxStar or 0)

		local myRank = remote.thunder.thunderMyRank or 1
		local upStar = remote.thunder.thunderFormerStar or 0
		if myRank == 1 then
			self._ccbOwner.tf_up_star:setString("真棒！本服最高星数，继续保持哦~")
			self._ccbOwner.tf_max_rank:setString("（排行榜第"..myRank.."名）")
			self._ccbOwner.sp_up_star:setVisible(false)
		elseif 1 < myRank and myRank <= 50 then
			self._ccbOwner.tf_up_star:setString("排行榜前一名星数："..upStar)
			self._ccbOwner.tf_max_rank:setString("（排行榜第"..myRank.."名）")
		else
			self._ccbOwner.tf_max_rank:setString("（暂未入榜）")
			self._ccbOwner.tf_up_star:setString("再接再厉，加油通关吧！")
			self._ccbOwner.sp_up_star:setVisible(false)
		end
	--end
	
	local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	if (self._fighter.thunderResetCount or 0) >= globalConfig.THUNDER_RESET_LIMIT.value then
		self._ccbOwner.node_token:setVisible(false)
		self._ccbOwner.tf_free:setVisible(true)
		self._ccbOwner.tf_free:setString("每日5:00刷新")
	end

	self:setRedTip()
	self._ccbOwner.sp_complete:setVisible(remote.thunder:getThunderFighter().thunderFailAwardhasGet ~= false)
	if FinalSDK.isHXShenhe() then
		self._ccbOwner.nodeItem:setVisible(false)
	end
end

function QUIWidgetThunderFail:setRedTip()
	self._ccbOwner.elite_tips:setVisible(false)
	self._ccbOwner.shop_tips:setVisible(false)

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	if tonumber(configuration["THUNDER_ELITE_DEFAULT"].value) + tonumber(self._fighter.thunderEliteChallengeBuyCount) - tonumber(self._fighter.thunderEliteChallengeTimes) > 0 and 
		self._fighter.thunderHistoryMaxFloor >= 1 then
		self._ccbOwner.elite_tips:setVisible(true)
	end

	if remote.stores:checkFuncShopRedTips(SHOP_ID.thunderShop) then
		self._ccbOwner.shop_tips:setVisible(true)
	end
end

function QUIWidgetThunderFail:_onTriggerShop()
	app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.thunderShop)
end

function QUIWidgetThunderFail:_onTriggerElite()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderElite"})
end

function QUIWidgetThunderFail:_onTriggerBox()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderRewardPreview", options = {floor = self._layerConfig.thunder_floor}})
end

function QUIWidgetThunderFail:_onTriggerConditionInfo()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderHelp"})
end

function QUIWidgetThunderFail:_onTriggerRank() 
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", options = {initRank = "thunder"}}, {isPopCurrentDialog = false})
end

function QUIWidgetThunderFail:_onTriggerBuy() 
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogThunderChestBuy", options = {itemInfo = self._award}})
end

function QUIWidgetThunderFail:_onTriggerReset(event) 
	if q.buttonEventShadow(event, self._ccbOwner.btn_reset) == false then return end
	app.sound:playSound("common_small")
	local globalConfig = QStaticDatabase:sharedDatabase():getConfiguration()
	if (self._fighter.thunderResetCount or 0) < globalConfig.THUNDER_RESET_LIMIT.value then
		remote.thunder:thunderResetRequest(false, function( ... )
			remote.activity:updateLocalDataByType(524, 1) 
			remote.user:addPropNumForKey("c_thunderResetCount")
		end)
	else
		app.tip:floatTip("当日重置次数已用完！")
	end
end

return QUIWidgetThunderFail