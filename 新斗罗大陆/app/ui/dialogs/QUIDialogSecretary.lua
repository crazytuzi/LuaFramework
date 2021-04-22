--
-- zxs
-- 小秘书对话框
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSecretary = class("QUIDialogSecretary", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QListView = import("...views.QListView") 
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetSecretaryBtn = import("..widgets.QUIWidgetSecretaryBtn")
local QUIWidgetSecretary = import("..widgets.QUIWidgetSecretary")

function QUIDialogSecretary:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLog", callback = handler(self, self._onTriggerLog)},
		{ccbCallbackName = "onTriggerExecute", callback = handler(self, self._onTriggerExecute)},
		{ccbCallbackName = "onTriggerAllExecute", callback = handler(self, self._onTriggerAllExecute)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerCalendar", callback = handler(self, self._onTriggerCalendar)},
	}
	QUIDialogSecretary.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    page.topBar:showWithHeroOverView()

    q.setButtonEnableShadow(self._ccbOwner.btn_log)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    self._ccbOwner.frame_tf_title:setString("小舞助手")

	self._tabId = options.tabId or 1
	self._oldTab = self._tabId

	self:initButtons()
	self:initListView()

	remote.secretary:setSoulResfresh(remote.items:getItemsNumByID(22))
end

function QUIDialogSecretary:viewDidAppear()
	QUIDialogSecretary.super.viewDidAppear(self)

	self._secretaryEventProxy = cc.EventProxy.new(remote.secretary)
    self._secretaryEventProxy:addEventListener(remote.secretary.SECRETARY_SET_UPDATE, handler(self, self._settingUpdate))    
    self._secretaryEventProxy:addEventListener(remote.secretary.SECRETARY_FINISH, handler(self, self._settingUpdate))    

	self:selectTabs()
		
	remote.secretary:updateDialog(function() 
		self:initListView()
	end)

	self:addBackEvent()
end

function QUIDialogSecretary:viewWillDisappear()
	QUIDialogSecretary.super.viewWillDisappear(self)
	
    self._secretaryEventProxy:removeAllEventListeners()

end

function QUIDialogSecretary:_settingUpdate()
	self:initListView()
end

function QUIDialogSecretary:initButtons()
	self._tabBtns = {}
	local tabConfigs = remote.secretary:getSecretaryTabConfigs()
	local posY = 0
	for k, config in pairs(tabConfigs) do
		local itemBtn = QUIWidgetSecretaryBtn.new()
        itemBtn:addEventListener(QUIWidgetSecretaryBtn.EVENT_CLICK, handler(self, self.btnClickHandler))
		itemBtn:setInfo(config)
		itemBtn:setSelect(self._tabId == k)
		itemBtn:setPositionY(posY)
		self._ccbOwner.node_btns:addChild(itemBtn)
		self._tabBtns[k] = itemBtn
		posY = posY - 75
	end
end

function QUIDialogSecretary:initListView()
	self._data = remote.secretary:getSecretaryByType(self._tabId)
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache()
	            local dataProxy = remote.secretary:getSecretaryDataProxyById(itemData.id)
	            if dataProxy then
		            if not item then
		                item = dataProxy:createSecretaryWidget()
		                isCacheNode = false
		            end
		            info.item = item
		            info.size = item:getContentSize()
		            info.tag = itemData.id

		            dataProxy:refreshWidgetData(item, itemData, index)
		            dataProxy:registerBtnHandler(list, index)
		        end

	            return isCacheNode
	        end,
	        enableShadow = true,
	        spaceY = -10,
	        contentOffsetX = 5,
	        totalNumber = #self._data,
	    }  
    	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	elseif self._oldTab == self._tabId then
		self._listView:refreshData()
	else
		self._listView:reload({totalNumber = #self._data})
	end
	self._oldTab = self._tabId
end

function QUIDialogSecretary:updateButtons()
	for k, itemBtn in pairs(self._tabBtns) do
		itemBtn:setSelect(self._tabId == k)
	end
end

function QUIDialogSecretary:selectTabs()
	self:getOptions().tabId = self._tabId
	self:updateButtons()
	self:initListView()
	
	if self._tabId == remote.secretary.TYPE_SHOP then
	    local showTips = remote.stores:checkNewShopGoodsView(SHOP_ID.soulShop)
	    if showTips then
	        app:getUserOperateRecord():setShopQuickBuyConfiguration(SHOP_ID.soulShop, {})
	        app.tip:floatTip("魂师大人，您在魂师商店可以购买更高级物品，快去重新设置吧~")
	    end
	end

	if self._tabId == remote.secretary.TYPE_RANK then
		local stormInfo = remote.secretary:getSecretaryInfo().stormSecretary
		local showTips = false
		if stormInfo and (stormInfo.rank and stormInfo.rank >= 10000 ) or stormInfo.rank == nil then
			if app:getUserOperateRecord():checkNewWeekCompareWithRecordeTime("stormSecretarySet", 5) then
				app:getUserOperateRecord():recordeCurrentTime("stormSecretarySet")
				remote.secretary:clearnSecretarySetting(304)
				showTips = true
			end
		end

		local sototemInfo = remote.secretary:getSecretaryInfo().sotoTeamSecretary
		if sototemInfo and (sototemInfo.rank and sototemInfo.rank >= 10000) or sototemInfo.rank == nil then
			if app:getUserOperateRecord():checkNewWeekCompareWithRecordeTime("sototemSecretarySet", 5) then
				app:getUserOperateRecord():recordeCurrentTime("sototemSecretarySet")
				remote.secretary:clearnSecretarySetting(305)
				showTips = true
			end
		end

		if showTips then
			app.tip:floatTip("玩法排名已重置，快去提升自己的名次吧！")
		end
	end
end

function QUIDialogSecretary:btnClickHandler(event)
	if not event or not event.tabId then
		return
	end
	self._tabId = event.tabId
	
	self:selectTabs()
end

function QUIDialogSecretary:_onTriggerLog()
    app.sound:playSound("common_switch")
    remote.secretary:secretaryAllLogsRequest(self._tabId, function()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogSecretaryLog", options = {isShowAll = true}},{isPopCurrentDialog = false})
    	end)
end

function QUIDialogSecretary:_onTriggerExecute()
    app.sound:playSound("common_switch")

    remote.secretary:requestSecretary(self._tabId)
end

function QUIDialogSecretary:_onTriggerAllExecute()
    app.sound:playSound("common_switch")

    remote.secretary:requestSecretary(0)
end

function QUIDialogSecretary:_onTriggerCalendar(event)
	if event and q.buttonEventShadow(event, self._ccbOwner.btn_calendar) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGameCalendar"},{isPopCurrentDialog = false})
end

function QUIDialogSecretary:_onTriggerRule()
    app.sound:playSound("common_switch")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass= "QUIDialogSecretaryRule"},{isPopCurrentDialog = false})
end

function QUIDialogSecretary:_onTriggerClose()
    app.sound:playSound("common_switch")
    self:playEffectOut()
end

return QUIDialogSecretary