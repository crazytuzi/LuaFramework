-- @Author: xurui
-- @Date:   2016-12-27 14:51:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-12 18:41:35
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeChooseShip = class("QUIDialogMaritimeChooseShip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMaritimeChooseShipClient = import("..widgets.QUIWidgetMaritimeChooseShipClient")
local QMaritimeDefenseArrangement = import("...arrangement.QMaritimeDefenseArrangement")
local QUIDialogBuyCount = import("..dialogs.QUIDialogBuyCount")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QListView = import("...views.QListView")

function QUIDialogMaritimeChooseShip:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
		{ccbCallbackName = "onTriggerBestShip", callback = handler(self, self._onTriggerBestShip)},
		{ccbCallbackName = "onTriggerTopShip", callback = handler(self, self._onTriggerTopShip)},
		{ccbCallbackName = "onTriggerProtect", callback = handler(self, self._onTriggerProtect)},
		{ccbCallbackName = "onTriggerJoinProtect", callback = handler(self, self._onTriggerJoinProtect)},
		{ccbCallbackName = "onTriggerTransport", callback = handler(self, self._onTriggerTransport)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
	}
	QUIDialogMaritimeChooseShip.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page and page.setManyUIVisible then page:setManyUIVisible() end
    if page and page.setScalingVisible then page:setScalingVisible(false) end
    if page and page.topBar then
        page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.MONEY})
    end
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	-- self._ship = {}
	self._selectInfo = {}

	self._ccbOwner.node_right_center:setVisible(false)
	self._ccbOwner.frame_tf_title:setString("运 送")
	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._transportToken = configuration["maritime_cishu"].value
	self._transportNum = configuration["maritime_cishu"].value
	self._refreshToken = configuration["maritime_token"].value
	self._getBestShipToken = configuration["maritime_token_num"].value
	self._refreshCard = configuration["maritime_shuaxin"].value
	self._getBestShipCard = configuration["maritime_shuaxin_num"].value

	self._getTopShipToken = configuration["maritime_token_num_new"].value
	self._getTopShipCard = configuration["maritime_shuaxin_num_new"].value

	self._cardId = 9000001       -- 刷新卡ID

	self._topShipId, self._bestShipId = remote.maritime:getMaritimeTopShipIdAndBestShipId()
	local topShipInfo = remote.maritime:getMaritimeShipInfoByShipId(self._topShipId)
	self._topShipName = topShipInfo.ship_name or ""
	local bestShipInfo = remote.maritime:getMaritimeShipInfoByShipId(self._bestShipId)
	self._bestShipName = bestShipInfo.ship_name or ""
end

function QUIDialogMaritimeChooseShip:viewDidAppear()
	QUIDialogMaritimeChooseShip.super.viewDidAppear(self)

	self:setShipInfo()

    self._maritimeProxy = cc.EventProxy.new(remote.maritime)
    self._maritimeProxy:addEventListener(remote.maritime.EVENT_UPDATE_TRANSPORT_NUM, handler(self, self.setTransportNum))

	self:addBackEvent(false)
end

function QUIDialogMaritimeChooseShip:viewWillDisappear()
	QUIDialogMaritimeChooseShip.super.viewWillDisappear(self)

    self._maritimeProxy:removeAllEventListeners()
    self._maritimeProxy = nil

	self:removeBackEvent()
end

function QUIDialogMaritimeChooseShip:setShipInfo()
	self:setTokenConsumInfo()
	
	self:updateShipInfo()

	self:setTransportNum()

	self:_selectProtecter()
end

function QUIDialogMaritimeChooseShip:setTokenConsumInfo()
	self._cardNum = remote.items:getItemsNumByID(self._cardId)
	local num1 = self._cardNum.."/"..self._refreshCard
	local num2 = 0
	local num3 = 0
	local consumeNum1 = self._refreshToken
	local consumeNum2 = 0
	local consumeNum3 = 0
	local icon1 = QStaticDatabase:sharedDatabase():getItemByID(self._cardId).icon_1
	local icon2 = nil
	local icon3 = nil

	if self._cardNum >= self._getBestShipCard then
		icon2 = QStaticDatabase:sharedDatabase():getItemByID(self._cardId).icon_1
		num2 = self._cardNum.."/"..self._getBestShipCard
		consumeNum2 = self._getBestShipCard
	else
		icon2 = remote.items:getWalletByType("token").alphaIcon
		num2 = self._getBestShipToken
		consumeNum2 = self._getBestShipToken
	end


	if self._cardNum >= self._getTopShipCard then
		icon3 = QStaticDatabase:sharedDatabase():getItemByID(self._cardId).icon_1
		num3 = self._cardNum.."/"..self._getTopShipCard
		consumeNum3 = self._getTopShipCard
	else
		icon3 = remote.items:getWalletByType("token").alphaIcon
		num3 = self._getTopShipToken
		consumeNum3 = self._getTopShipToken
	end

	self._refreshMoney = consumeNum1
	self._bestShipMoney = consumeNum2
	self._topShipMoney = consumeNum3

	self._ccbOwner.tf_refresh_token:setString(num1)
	self._ccbOwner.tf_best_ship_token:setString(num2)
	self._ccbOwner.tf_top_ship_token:setString(num3)
	if icon1 then
		local sprite = CCSprite:create(icon1)
		sprite:setScale(0.7)
		self._ccbOwner.node_refresh_token:removeAllChildren()
		self._ccbOwner.node_refresh_token:addChild(sprite)
	end
	if icon2 then
		local sprite = CCSprite:create(icon2)
		sprite:setScale(0.5)
		self._ccbOwner.node_best_ship_token:removeAllChildren()
		self._ccbOwner.node_best_ship_token:addChild(sprite)
	end
	if icon3 then
		local sprite = CCSprite:create(icon3)
		sprite:setScale(0.5)
		self._ccbOwner.node_top_ship_token:removeAllChildren()
		self._ccbOwner.node_top_ship_token:addChild(sprite)
	end
end

function QUIDialogMaritimeChooseShip:updateShipInfo(isForce)
	self._myInfo = remote.maritime:getMyMaritimeInfo()

	self._itemData = {}
	for i = remote.maritime.startShipId, tonumber(self._topShipId) do
		local selectShip = (self._myInfo.refreshShipId or 2) == i
		table.insert(self._itemData, {shipId = i, isMy = selectShip})
	end
	self._oldSelectId = self._myInfo.refreshShipId or 2

	if isForce and self._listView then
		self._listView:clear(true)
  		self._listView = nil
	end
	self:_initListView()
end

function QUIDialogMaritimeChooseShip:_initListView()
	if not self._listView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local data = self._itemData[index] or {}

	            local item = list:getItemFromCache(tag)

	            if not item then
	                item = QUIWidgetMaritimeChooseShipClient.new()
	                isCacheNode = false
	            end
	            
	            info.item = item
	            info.tag = tag
	            info.size = item:getContentSize()
				item:setInfo(data)
	
				list:registerBtnHandler(index,"btn_click", "_onTriggerClick")

	            return isCacheNode
	        end,
	        isVertical = false,
	        ignoreCanDrag = false,
	        autoCenter = true,
	        totalNumber = #self._itemData,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._itemData})
	end
end

function QUIDialogMaritimeChooseShip:setTransportNum()
	local myInfo = remote.maritime:getMyMaritimeInfo()
	local num = self._transportNum + myInfo.buyMaritimeCnt - myInfo.maritimeCnt
	num = num < 0 and 0 or num
	self._totalCount = num
	self._ccbOwner.tf_free_transport_num:setString(num or "")

    local buyCount = myInfo.buyMaritimeCnt or 0
	local totalVIPNum = QVIPUtil:getCountByWordField("maritime_num", QVIPUtil:getMaxLevel())
	local totalNum = QVIPUtil:getCountByWordField("maritime_num")
	self._ccbOwner.node_btn_plus:setVisible(true)
	if totalVIPNum <= totalNum and totalNum <= buyCount then
		self._ccbOwner.node_btn_plus:setVisible(false)
	end
end

function QUIDialogMaritimeChooseShip:_selectProtecter()
	self._selectInfo = remote.maritime:getProtecter() or {}
	if next(self._selectInfo) == nil then
		self._ccbOwner.tf_protecter:setString("尚未选择保护者")
	else
		self._ccbOwner.tf_protecter:setString((self._selectInfo.name or ""))
	end
end

function QUIDialogMaritimeChooseShip:startTransport()
	local protecter = remote.maritime:getProtecter() or {}
	local shipId = self._myInfo.refreshShipId or 1
	remote.maritime:requestMaritimeShipStart(protecter.userId, function()

			if shipId >= 5 then
        		app.taskEvent:updateTaskEventProgress(app.taskEvent.TRANSPORT_SUPER_SHIP_TASK_EVENT, 1, false, false)
        	end

			if self:safeCheck() then
				remote.user:addPropNumForKey("todayMaritimeShipCount")
				remote.maritime:setProtecter()
				self:popSelf()
			end
		end, function()
			if self:safeCheck() then
				remote.maritime:setProtecter()
				self:_selectProtecter()
			end
		end)
end

function QUIDialogMaritimeChooseShip:_onTriggerRefresh(event)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_refresh) == false then return end
	app.sound:playSound("common_small")
	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MARITIME_ISBEST_REFRESH)
	if self._oldSelectId >= 6 and isShowDialog then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogComCheckAlert", 
			options={dailyTimeType = DAILY_TIME_TYPE.MARITIME_ISBEST_REFRESH, richTextContent = {{oType = "font", content = "当前已经是最高品质的仙品，再次刷新将不会改变品质，是否还要刷新仙品？", size = 20, color = COLORS.j},}, 
				okBtnText = "再次刷新", cancleBtnText = "保留最高", callBack = function()
					self:checkIsBestRefreshShip()
			end}}, {isPopCurrentDialog = false})	
	else
		self:checkIsBestRefreshShip()	
	end

end

function QUIDialogMaritimeChooseShip:_onTriggerBestShip(event) 
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_best_ship) == false then return end
	app.sound:playSound("common_small")
	if self._oldSelectId == 5 then
		app.tip:floatTip("魂师大人，您当前已经是"..self._bestShipName.."了哦~~")
		return
	end
	if self._oldSelectId >= 6 then
		app.tip:floatTip("魂师大人，您当前已经是"..self._topShipName.."了哦~~")
		return
	end
	if self._cardNum < self._getBestShipCard then
		if self:_checkMoney(self._getBestShipToken) == false then
			return
		end
	end

	local content = "是否花费"..self._getBestShipToken.."钻石购买##l拥有大量奖励的"..self._bestShipName.."？"
	if self._cardNum >= self._getBestShipCard then
		content = "是否花费"..self._getBestShipCard.."刷新卡购买##l拥有大量奖励的"..self._bestShipName.."？"
	end
	app:alert({content = content, colorful = true, callback = function(state)
			if state == ALERT_TYPE.CONFIRM then
				self:startRefreshShip(2)
			end
		end, callBack = function ()end})
end

function QUIDialogMaritimeChooseShip:_onTriggerTopShip(event) 
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_top_ship) == false then return end
	app.sound:playSound("common_small")
	if self._oldSelectId >= 6 then
		app.tip:floatTip("魂师大人，您当前已经是"..self._topShipName.."了哦~~")
		return
	end
	if self._cardNum < self._getTopShipCard then
		if self:_checkMoney(self._getTopShipToken) == false then
			return
		end
	end

	local content = "是否花费"..self._getTopShipToken.."钻石购买##l拥有大量奖励的"..self._topShipName.."？"
	if self._cardNum >= self._getTopShipCard then
		content = "是否花费"..self._getTopShipCard.."刷新卡购买##l拥有大量奖励的"..self._topShipName.."？"
	end
	app:alert({content = content, colorful = true, callback = function(state)
			if state == ALERT_TYPE.CONFIRM then
				self:startRefreshShip(3)
			end
		end, callBack = function ()end})
end

function QUIDialogMaritimeChooseShip:checkIsBestRefreshShip()
	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MARITIME_REFRESH)
	if self._cardNum < self._refreshCard and isShowDialog then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCount", 
			options={itemId = self._cardId, buyNum = self._refreshCard, price = self._refreshToken, buyType = DAILY_TIME_TYPE.MARITIME_REFRESH, callback = function()
				if self:_checkMoney(self._refreshToken) == true then
					self:startRefreshShip(1)
				end
			end}}, {isPopCurrentDialog = false})
	else
		self:startRefreshShip(1)
	end
end

function QUIDialogMaritimeChooseShip:startRefreshShip(index)
	remote.maritime:requestMaritimeRefreshShip(index, function (data)
		local shipId = data.maritimeRefreshShipResponse.myInfo.refreshShipId 
		if shipId and self._listView then
			local index = 1
			while true do
				local item = self._listView:getItemByIndex(index)
				if item then
					if item.getInfo then
						local info = item:getInfo()
						if info and info.shipId == shipId then
							item:setRefreshEffect(shipId)
						end
					end
					index = index + 1
				else
					break
				end
			end
		end

		self:setShipInfo()
	end)
end

function QUIDialogMaritimeChooseShip:_checkMoney(cost)
	if remote.user.token < cost then
		QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
		return false
	end
	return true
end

function QUIDialogMaritimeChooseShip:_onTriggerProtect(event)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_protect) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaritimeProtect", 
		options = {selectInfo = self._selectInfo, callBack = handler(self, self.setProtecterSuccess)}})
end

function QUIDialogMaritimeChooseShip:setProtecterSuccess()
	if self:safeCheck() then
		self:_selectProtecter()
		self:setTokenConsumInfo()
	end
end

function QUIDialogMaritimeChooseShip:_onTriggerTransport(event)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_transport) == false then return end
	app.sound:playSound("common_small")

	local myShipInfo = remote.maritime:getMyShipInfo()
	if myShipInfo ~= nil and next(myShipInfo) ~= nil then
		app.tip:floatTip("魂师大人，您正在运送中~")
		return 
	end

	if self._totalCount <= 0 then
		self:_onTriggerPlus()
		return
	end
	local isShowDialog = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MARITIME_ISLAST_REFRESH)
	if self._oldSelectId <= 2 and isShowDialog then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogComCheckAlert", 
			options={dailyTimeType = DAILY_TIME_TYPE.MARITIME_ISLAST_REFRESH, richTextContent = {{oType = "font", content = "当前是最低品质的仙品，只要进行刷新就有可能大幅度提升仙品奖励，是否确认要进行运送？", size = 20, color = COLORS.j},}, 
				okBtnText = "确认运送", cancleBtnText = "取消运送", callBack = function()
					self:startTransport()
			end}}, {isPopCurrentDialog = false})	
	else
		self:startTransport()	
	end	
end

function QUIDialogMaritimeChooseShip:_onTriggerPlus(event)
	if isForce ~= true and q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountMaritimeTransport"}})
end

function QUIDialogMaritimeChooseShip:_onTriggerJoinProtect()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMaritimeJoinProtecter", 
		options = {callBack = handler(self, self._selectProtecter)}})
end

function QUIDialogMaritimeChooseShip:_onTriggerHelp()
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMaritimeHelp"})
end


function QUIDialogMaritimeChooseShip:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogMaritimeChooseShip