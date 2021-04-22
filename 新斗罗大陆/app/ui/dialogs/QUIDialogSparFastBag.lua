-- @Author: xurui
-- @Date:   2017-04-05 10:24:10
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-12 19:49:15
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSparFastBag = class("QUIDialogSparFastBag", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")
local QUIWidgetSparFastBagClient = import("..widgets.spar.QUIWidgetSparFastBagClient")

QUIDialogSparFastBag.TAB_WEAR = "TAB_WEAR"
QUIDialogSparFastBag.TAB_NO_WEAR = "TAB_NO_WEAR"

function QUIDialogSparFastBag:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_zhuangbei.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose",   callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerClick1",  callback = handler(self, self._onTriggerClickNoWear)},
		{ccbCallbackName = "onTriggerClick2",  callback = handler(self, self._onTriggerClickWear)},
		{ccbCallbackName = "onTriggerClickSparShop",    callback = handler(self, self._onTriggerClickSparShop)},
	}
	QUIDialogSparFastBag.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_spar_shop)
	q.setButtonEnableShadow(self._ccbOwner.btn_gemstone_shop)
	
	self._ccbOwner.btn_gemstone_shop:setVisible(false)
	self._ccbOwner.btn_spar_shop:setVisible(true)
	self._ccbOwner.tf_content:setString("魂师大人，当前没有外附魂骨，可以去地狱商店看看哟～")

    self._sparType = ITEM_CONFIG_TYPE.GARNET
    if options then
		self._sparPos = options.pos
		self._tab = options.tab or QUIDialogSparFastBag.TAB_NO_WEAR
		self._actorId = options.actorId
		self._isChangeSparId = options.isChangeSparId
	end
    self._tab = self._tab == nil and QUIDialogSparFastBag.TAB_NO_WEAR or self._tab

    if self._sparPos and self._sparPos == 2 then
    	self._sparType = ITEM_CONFIG_TYPE.OBSIDIAN
    end
    self._client = {}
    self._data = {}

	self:_initListView()
end

function QUIDialogSparFastBag:viewDidAppear()
	QUIDialogSparFastBag.super.viewDidAppear(self)

	self:selectTab()
end

function QUIDialogSparFastBag:viewWillDisappear()
	QUIDialogSparFastBag.super.viewWillDisappear(self)
end

function QUIDialogSparFastBag:selectTab()
	self._ccbOwner.node_no:setVisible(false)
	self._data = {}
	self:setButtonState()

	self._sparInfos = remote.spar:getSparsByType(self._sparType)

	local wearSpar = {}
	local noWearSpar = {}
	for _, value in pairs(self._sparInfos) do
		--排序属性赋值
		local itemInfo = db:getItemByID(value.itemId)
		if itemInfo then
			if value.itemId == 2020001 or value.itemId == 2030001 then
				value.sortValue = 99
			elseif itemInfo.gemstone_quality == APTITUDE.SS then
				value.sortValue = 2
			else
				value.sortValue = 1
			end
		else
			value.sortValue = 0
		end

		if value.actorId and value.actorId ~= 0 then
			if value.actorId ~= self._actorId then
				wearSpar[#wearSpar+1] = value
			end
		else
			noWearSpar[#noWearSpar+1] = value
		end
	end

	local uiHeroModle = remote.herosUtil:getUIHeroByID(self._actorId)
	local index = self._sparPos == 1 and 2 or 1
	self._otherSparInfo = uiHeroModle:getSparInfoByPos(index).info or {}

	if self._tab == QUIDialogSparFastBag.TAB_WEAR then
		self._data = wearSpar
	elseif self._tab == QUIDialogSparFastBag.TAB_NO_WEAR then
		self._data = noWearSpar
	end

	if self._data == nil or next(self._data) == nil then
		self._ccbOwner.node_no:setVisible(true)
	end

	table.sort( self._data, function(a, b)
			if a.sortValue ~= b.sortValue then
				return a.sortValue > b.sortValue
			elseif a.grade ~= b.grade then
				return a.grade > b.grade
			elseif a.level ~= b.level then
				return a.level > b.level
			else
				return a.itemId > b.itemId
			end
		end )

	self:_initListView()
end

function QUIDialogSparFastBag:_initListView()
	local totalNumber = #self._data

    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = totalNumber,
	        enableShadow = false,
	        spaceY = 6,
	        curOffset = 15,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = totalNumber})
	end
end

function QUIDialogSparFastBag:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSparFastBagClient.new()

        isCacheNode = false
    end
    info.item = item
	item:setInfo({info = data, sparPos = self._sparPos, otherSparInfo = self._otherSparInfo, callback = handler(self, self._wearSpar)})
    info.size = item:getContentSize()


    list:registerBtnHandler(index, "btn_wear", "_onTriggerWear", nil, true)
    list:registerBtnHandler(index, "btn_info", "_onTriggerInfo", nil, true)
    item:registerItemBoxPrompt(index, list)

	return isCacheNode
end

function QUIDialogSparFastBag:_wearSpar(event)
	if event == nil or event.info == nil or self._isMoving then return end

	local sparId = event.info.sparId
	local itemId = event.info.itemId
	local isChangeSparId = self._isChangeSparId
	remote.spar:requestSparEquipment(event.info.sparId, self._actorId, true, itemId, function()
			if self:safeCheck() then
				if isChangeSparId then
					local sparInfo = remote.spar:getSparsBySparId(isChangeSparId)
					sparInfo.actorId = 0
					remote.spar:setSpars({sparInfo})
				end
				self:playEffectOut()
			end
		end)
end

function QUIDialogSparFastBag:setButtonState()
	local wearState = self._tab == QUIDialogSparFastBag.TAB_NO_WEAR
	self._ccbOwner.btn_award_1:setEnabled(not wearState)
	self._ccbOwner.btn_award_1:setHighlighted(wearState)

	local noWearState = self._tab == QUIDialogSparFastBag.TAB_WEAR
	self._ccbOwner.btn_award_2:setEnabled(not noWearState)
	self._ccbOwner.btn_award_2:setHighlighted(noWearState)
end

function QUIDialogSparFastBag:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSparFastBag:_onTriggerClickWear(e)
	if e ~= nil then
		app.sound:playSound("common_menu")
	end
	self._tab = QUIDialogSparFastBag.TAB_WEAR
	self:selectTab()
end

function QUIDialogSparFastBag:_onTriggerClickNoWear(e)
	if e ~= nil then
		app.sound:playSound("common_menu")
	end
	self._tab = QUIDialogSparFastBag.TAB_NO_WEAR
	self:selectTab()
end

function QUIDialogSparFastBag:_onTriggerClickSparShop(e)
	if q.buttonEventShadow(e,self._ccbOwner.btn_spar_shop) == false then return end
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	remote.stores:openShopDialog(SHOP_ID.sparShop)
end

function QUIDialogSparFastBag:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSparFastBag:viewAnimationOutHandler()
	self:popSelf()
end

return QUIDialogSparFastBag