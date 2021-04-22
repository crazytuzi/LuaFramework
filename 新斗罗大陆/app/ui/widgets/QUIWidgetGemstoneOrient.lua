-- 
-- zxs
-- 魂骨宝箱
-- 
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneOrient = class("QUIWidgetGemstoneOrient", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIDialogTavernAchieve = import("..dialogs.QUIDialogTavernAchieve")
local QNavigationController = import("...controllers.QNavigationController")
local QQuickWay = import("...utils.QQuickWay")
local QVIPUtil = import("...utils.QVIPUtil")

QUIWidgetGemstoneOrient.BUY_SUCCESSED_EVENT = "BUY_SUCCESSED_EVENT"
QUIWidgetGemstoneOrient.TIME_TO_REFRESH = "TIME_TO_REFRESH"

function QUIWidgetGemstoneOrient:ctor(options)
	local ccbFile = "ccb/Widget_fumo_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
	}
	QUIWidgetGemstoneOrient.super.ctor(self, ccbFile, callBacks, options)
	
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._effectNode = options.effectNode
	end

	self._ccbOwner.node_synthesis:setVisible(false)
	if self._chestEffect == nil then
		self._chestEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_chest:addChild(self._chestEffect)
		self._chestEffect:playAnimation("ccb/effects/hungu_baoxiang.ccbi", function()end, function()end, false)
	end
	self._isEffect = false

	self._itemInfo = {}
	local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
	for i, v in pairs(shopItems) do
		if v.id == GEMSTONE_SHOP_ID then
			self._itemInfo = v
			break
		end
	end
	self._sale = 0
	self:setAwardsInfo()
	self:setMoneyInfo()
	self:_startScheduler()
end

function QUIWidgetGemstoneOrient:onEnter()
	self._mainPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if self._mainPage.topBar then
		self._mainPage.topBar:setUpdateDataByManual(TOP_BAR_TYPE.ENCHANT_SCORE, true)
	end
end

function QUIWidgetGemstoneOrient:onExit()
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

function QUIWidgetGemstoneOrient:setAwardsInfo()
	local tavernInfo = db:getTavernOverViewInfoByTavernType("30")
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

function QUIWidgetGemstoneOrient:setMoneyInfo()
	self._ccbOwner.node_buy_one:setVisible(false)
	self._ccbOwner.node_buy_ten:setVisible(false)
	self._ccbOwner.btn_exchange:setVisible(false)
	self._ccbOwner.tf_exchange:setVisible(false)
	self._ccbOwner.node_buy:setVisible(true)

	local money = self:getBuyMoneyByBuyCount(self._itemInfo.buy_count)
	local sale = self:calculaterDiscount(money)
	--self._ccbOwner.tf_money:setString(money)
	self:setSaleState(sale)
	self._sale = sale

	self:updateActivityCount()
end

function QUIWidgetGemstoneOrient:updateActivityCount()
	local activityInfo = remote.activity:getActivityDataByTagetId(556)
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
			self._ccbOwner.tf_choujiang_name:setString("活动期间开箱次数：")
		end
		q.autoLayerNode({self._ccbOwner.tf_choujiang_name,self._ccbOwner.tf_choujiang_count},"x",0)		
	else
		self._ccbOwner.node_choujiangCount:setVisible(false)
	end
end

function QUIWidgetGemstoneOrient:hidAllDiscountLabel()
	self._ccbOwner.sale:setVisible(false)
	self._ccbOwner.chengDisCountBg:setVisible(false)
	self._ccbOwner.lanDisCountBg:setVisible(false)
	self._ccbOwner.ziDisCountBg:setVisible(false)
	self._ccbOwner.hongDisCountBg:setVisible(false)
end

function QUIWidgetGemstoneOrient:setSaleState(sale)
	self:hidAllDiscountLabel()
	if sale == 0 then 
		self._ccbOwner.tf_cur_cost:setString("免费")
		self._ccbOwner.tf_cur_cost:setPositionX(0)
		self._ccbOwner.new_token:setVisible(false)
		return 
	end

	if sale < 10 then
		self._ccbOwner.sale:setVisible(true)
		self._ccbOwner.new_token:setVisible(true)
		self._ccbOwner.tf_cur_cost:setPositionX(32)
		if sale < 4 then
			self._ccbOwner.hongDisCountBg:setVisible(true)
		elseif sale < 7 then
			self._ccbOwner.ziDisCountBg:setVisible(true)
		else
			self._ccbOwner.lanDisCountBg:setVisible(true)
		end
		self._ccbOwner.discountStr:setString(string.format("%s折", sale))
		self._ccbOwner.node_new:setPositionX(90)
		self._ccbOwner.node_old:setVisible(true)
	else
		self._ccbOwner.node_new:setPositionX(0)
		self._ccbOwner.node_old:setVisible(false)
	end
end

function QUIWidgetGemstoneOrient:getBuyMoneyByBuyCount(buyCount)
	local tokeNum = 0
	local moneyInfo = db:getTokenConsumeByType(tostring(self._itemInfo.good_group_id)) or {}
	for _, value in pairs(moneyInfo) do
		if value.consume_times == buyCount + 1 then
			return value.money_num
		end
	end
	return moneyInfo[#moneyInfo].money_num
end

function QUIWidgetGemstoneOrient:calculaterDiscount(realMoney)
	local discount = {0, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5}
	local config = db:getConfiguration()["GEMSTONE_BOX_COST"] or {}
	local money = config.value or 10

	self._ccbOwner.tf_old_cost:setString(money)
	self._ccbOwner.tf_cur_cost:setString(realMoney)
	local maxCount = QVIPUtil:getMallItemMaxCountByVipLevel(self._itemInfo.good_group_id, QVIPUtil:VIPLevel())
	local curCount = maxCount - self._itemInfo.buy_count
	self._ccbOwner.tf_buy_count:setString(curCount.."次")

	-- 按任意折
	local sale = math.floor(realMoney/money * 100)/10
	
	return sale
end

function QUIWidgetGemstoneOrient:_startScheduler()
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
			self:dispatchEvent({name = QUIWidgetGemstoneOrient.TIME_TO_REFRESH})
   		end, (refreshTime+24*3600)-currentTime + 5)
end


function QUIWidgetGemstoneOrient:_confirmCallBack()
	self:setMoneyInfo()
end

function QUIWidgetGemstoneOrient:_onTriggerPreview()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestPreview", 
		options = {previewType = 29, title = {"稀有道具", "高级道具"}}})
end

function QUIWidgetGemstoneOrient:_onTriggerBuy(event)
	if q.buttonEventShadow(event,self._ccbOwner.button_buy) == false then return end
	if self._isEffect then return end

    app.sound:playSound("common_small")

	local buySuccessed = function(data, num)
		if not data.items or not data.items[1] then
			return
		end
		
		local item = data.items[1]
		local callback = function(data)
			local options = {}
			options.items = data.luckyDrawItemReward
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneTavernAchieve", 
				options=options}, {isPopCurrentDialog = false})
		end
		-- 开启个数限制
		if num > item.count then
			num = item.count
		end
		app:getClient():openItemPackage(item.type, num, 
			function(data)
				self._isEffect = false
				callback(data)
			end, function()
				self._isEffect = false
			end)
	end

    local buyItem = function(info)
		local itemId = tostring(self._itemInfo.id)
    	app:getClient():buyShopItem(SHOP_ID.itemShop, self._itemInfo.position, itemId, self._itemInfo.count, info.num, function(data)
    		self._isEffect = true
 			if itemId == "160" then
 				remote.activity:updateLocalDataByType(556, info.num)
 			end

			if self._chestEffect then 
				self._chestEffect:setVisible(false)
			end

			local chestEffect = QUIWidgetAnimationPlayer.new()
			self._ccbOwner.node_chest:addChild(chestEffect)
			chestEffect:playAnimation("ccb/effects/hungu_baoxiang_normal.ccbi", function()end, function()
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
				buySuccessed(data, info.num)
	    	end, 1.3)

			

    		if self._ccbOwner then
				self._itemInfo = {}
				local shopItems = remote.stores:getStoresById(SHOP_ID.itemShop)
				for i, v in pairs(shopItems) do
					if v.id == GEMSTONE_SHOP_ID then
						self._itemInfo = v
						break
					end
				end
				self:setMoneyInfo()
				self:dispatchEvent({name = QUIWidgetGemstoneOrient.BUY_SUCCESSED_EVENT})
			end
		end)
	end

	local maxCount = QVIPUtil:getMallItemMaxCountByVipLevel(self._itemInfo.good_group_id, QVIPUtil:VIPLevel())
	if self._itemInfo.buy_count >= maxCount then
		app.tip:floatTip("购买次数不足~")
		return
	end

	-- 免费时直接够买
	if self._sale == 0 then
		buyItem({num = 1})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallDetail", 
			options = {shopId = SHOP_ID.itemShop, itemInfo = self._itemInfo, maxNum = maxCount, sale = self._sale, pos = self._itemInfo.position, isGemstone = true, callback = buyItem }}, {isPopCurrentDialog = false})
	end
end

function QUIWidgetGemstoneOrient:_onTriggerHelp()
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCountHelp", 
		options = {helpType = "hungu_1_baoxiang_1"}})
end

return QUIWidgetGemstoneOrient