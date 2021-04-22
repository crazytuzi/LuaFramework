-- @Author: xurui
-- @Date:   2020-03-15 15:30:16
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-20 17:03:05
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMallSecretarySetting = class("QUIDialogMallSecretarySetting", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroFragmentSecretaryClient = import("..widgets.QUIWidgetHeroFragmentSecretaryClient")
local QListView = import("...views.QListView") 
local QUIWidgetSecretarySettingTitle = import("..widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingItemBuy = import("..widgets.QUIWidgetSecretarySettingItemBuy")
local QVIPUtil = import("...utils.QVIPUtil")


function QUIDialogMallSecretarySetting:ctor(options)
	local ccbFile = "ccb/Dialog_herofragment_secretary.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
    }
    QUIDialogMallSecretarySetting.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("设置")
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	q.setButtonEnableShadow(self._ccbOwner.btn_confirm)
	q.setButtonEnableShadow(self._ccbOwner.btn_cancel)

	if options then
		self._secretaryId = options.secretaryId
		self._callBack = options.callback
	end

	self._isConfirm = false
	self._data = {}
	self._settingData = clone(remote.secretary:getSettingBySecretaryId(self._secretaryId))
	self._dataProxy = remote.secretary:getSecretaryDataProxyById(self._secretaryId)

	self:initListView()
end

function QUIDialogMallSecretarySetting:viewDidAppear()
	QUIDialogMallSecretarySetting.super.viewDidAppear(self)

	self:setInfo()

	self:addBackEvent(true)
end

function QUIDialogMallSecretarySetting:viewWillDisappear()
  	QUIDialogMallSecretarySetting.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogMallSecretarySetting:setInfo()
	self._data = {}
	local shopItems = self._dataProxy:getShopItems()

	for _, value in ipairs(shopItems) do
		local name = ""
		local icon = ""
		if value.itemType == ITEM_TYPE.ITEM then
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(value.id)
			name = itemConfig.name or ""
			icon = itemConfig.icon
		else
			local itemConfig = remote.items:getWalletByType(value.itemType)
			name = itemConfig.nativeName or ""
			icon = itemConfig.icon
		end
		table.insert(self._data, {id = value.id, icon = icon, desc = name, itemInfo = value, settingCallback = handler(self, self._itemCallBack)})
	end


	self:initListView()
end

function QUIDialogMallSecretarySetting:initListView()
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
	     	curOffset = -10,
	      	spaceY = -4,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
	        contentOffsetX = 23,
	        curOffset = 5,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
		self._lastItemNum = #self._data
	elseif self._dataNum ~= #self._data then
		self._listView:reload({totalNumber = #self._data})
	else
		self._listView:refreshData() 
	end
	self._dataNum = #self._data
end

function QUIDialogMallSecretarySetting:_renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetHeroFragmentSecretaryClient.new()
    	item:addEventListener(QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SELECT, handler(self, self._onEvent))
    	item:addEventListener(QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SET, handler(self, self._onEvent))
        isCacheNode = false
    end

    item:setInfo(data)
	local itemId = data.id
	local itemInfo = data.itemInfo or {}
	if itemId == nil or itemId == 0 then
		itemId = itemInfo.itemType
	end

    local setting = self._settingData[tostring(itemId)] or {}
	item:setSelectState(setting.selected)
	item:setSettingStr(string.format("购买%s次", setting.buyCount or 0))

    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_select", "_onTriggerSelect")
    list:registerBtnHandler(index, "btn_set", "_onTriggerSet")

    return isCacheNode
end

function QUIDialogMallSecretarySetting:_itemCallBack(info)
	if info == nil then return end

	self._dropInfo = info.dropInfo or {}
	self._itemInfo = info.itemInfo or {}
	local itemId = info.id
	if itemId == nil or itemId == 0 then
		itemId = self._itemInfo.itemType
	end
	local setting = self._settingData[tostring(itemId)] or {}
	local widgets = {}
	local totalHeight = 0
	self._buyCount = setting.buyCount or 0

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo(info.desc or "")
	local titleHeight = titleWidget:getContentSize().height
	table.insert(widgets, titleWidget)
	totalHeight = totalHeight + titleHeight

	self._currencyInfos = self._dataProxy:getBuyMoneyByBuyCount(self._itemInfo.good_group_id)

	local buyWidget = QUIWidgetSecretarySettingItemBuy.new()
	buyWidget:setInfo(self._itemInfo, self._buyCount, handler(self, self._getBuyCost))
	buyWidget:setMinNum(0)
	buyWidget:setPositionY(-totalHeight)
	table.insert(widgets, buyWidget)
	totalHeight = totalHeight + buyWidget:getContentSize().height + 10


	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroFragmentSecretarySetting", 
		options = {setId = info.id, widgets = widgets, totalHeight = totalHeight, callback = function()
			if self:safeCheck() == false then return end

			if self._settingData[tostring(itemId)] == nil then
				self._settingData[tostring(itemId)] = {}
			end
			self._settingData[tostring(itemId)].buyCount = self._buyCount

			self:setInfo()
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogMallSecretarySetting:_getBuyCost(num)
	self._buyCount = num

	local needMoney = 0
	local currentBuyCount = self._itemInfo.buy_count or 0
	local groupId = self._itemInfo.good_group_id
	local percent = self._itemInfo.sale or 1
	local maxCount = QVIPUtil:getMallItemMaxCountByVipLevel(groupId, QVIPUtil:VIPLevel())
	local haveMoney = remote.user.token

	for i = currentBuyCount + 1, num do
		local data = self._currencyInfos[i] or {}
		if q.isEmpty(data) and q.isEmpty(self._currencyInfos) == false then
			data = self._currencyInfos[#self._currencyInfos]
		end

		needMoney = needMoney + math.floor((data.money_num or 0) * percent)
	end

	return needMoney, maxCount
end

function QUIDialogMallSecretarySetting:_onEvent(event)
	if event == nil then return end

	local info = event.info
	local itemInfo = info.itemInfo or {}
	local itemId = info.id
	if itemId == nil or itemId == 0 then
		itemId = itemInfo.itemType
	end
	if event.name == QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SELECT then
		if self._settingData[tostring(itemId)] == nil then
			self._settingData[tostring(itemId)] = {}
		end
		self._settingData[tostring(itemId)].selected = event.selected
	elseif event.name == QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SET then
		if info.settingCallback then
			info.settingCallback(info)
		end
	end
end

function QUIDialogMallSecretarySetting:_onTriggerConfirm()
  	app.sound:playSound("common_small")

  	self._isConfirm = true
	self:_onTriggerClose()
end

function QUIDialogMallSecretarySetting:_onTriggerCancel()
	self:_onTriggerClose()
end

function QUIDialogMallSecretarySetting:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMallSecretarySetting:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMallSecretarySetting:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if self._isConfirm and callback then
		callback(self._settingData)
	end
end

return QUIDialogMallSecretarySetting
