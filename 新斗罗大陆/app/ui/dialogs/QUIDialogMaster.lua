--
-- Author: xurui
-- Date: 2015-10-28 17:31:34
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaster = class("QUIDialogMaster", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetMasterCell = import("..widgets.QUIWidgetMasterCell")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogHeroEquipmentDetail = import("..dialogs.QUIDialogHeroEquipmentDetail")
local QUIHeroModel = import("...models.QUIHeroModel")
local QScrollContain = import("..QScrollContain")
local QUIWidgetMasterPropClient = import("..widgets.QUIWidgetMasterPropClient")
local QUIDialogHeroInformation = import("..dialogs.QUIDialogHeroInformation")
local QUIDialogHeroGemstoneDetail = import("..dialogs.QUIDialogHeroGemstoneDetail")
local QUIDialogHeroSparDetail = import("..dialogs.QUIDialogHeroSparDetail")
local QUIDialogMagicHerbDetail = import("..dialogs.QUIDialogMagicHerbDetail")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")
local QListView = import("...views.QListView")

function QUIDialogMaster:ctor(options)
	local ccbFile = "ccb/Dialog_HeroMaster_Client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerEquipMaster", callback = handler(self, self._onTriggerEquipMaster)},
		{ccbCallbackName = "onTriggerEquipEnchantMaster", callback = handler(self, self._onTriggerEquipEnchantMaster)},
		{ccbCallbackName = "onTriggerJewelryBreakMaster", callback = handler(self, self._onTriggerJewelryBreakMaster)},
		{ccbCallbackName = "onTriggerGemstoneStrength", callback = handler(self, self._onTriggerGemstoneStrength)},
		{ccbCallbackName = "onTriggerGemtoneBreak", callback = handler(self, self._onTriggerGemtoneBreak)},
		{ccbCallbackName = "onTriggerJewlryMaster", callback = handler(self, self._onTriggerJewlryMaster)},
		{ccbCallbackName = "onTriggerJewelryEnchantMaster", callback = handler(self, self._onTriggerJewelryEnchantMaster)},
		{ccbCallbackName = "onTriggerHeroTrainMaster", callback = handler(self, self._onTriggerHeroTrainMaster)},
		{ccbCallbackName = "onTriggerSparStrengthMaster", callback = handler(self, self._onTriggerSparStrengthMaster)},
		{ccbCallbackName = "onTriggerMagicHerbUpLevel", callback = handler(self, self._onTriggerMagicHerbUpLevel)},
	}
	QUIDialogMaster.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:showWithHeroDetail()

	if options then
		self._masterType = options.masterType
		self._actorId = options.actorId
		self._pos = options.pos
		self._parentOptions = options.parentOptions
		self._heros = options.heros
		self._isPopParentDialog = options.isPopParentDialog or false
		self._isQuickWay = options.isQuickWay
	end
	self._equipBox = {}
	self._currMasterInfo = {}
	self._nextMasterInfo = {}

	local btnList = {
		{id = 1, btnName = "装备强化", tabType = QUIHeroModel.EQUIPMENT_MASTER, unlock = app.master:checkEquipStrengMasterUnlock(self._actorId), word = "强化", name = "装备"}, 
		{id = 2, btnName = "装备觉醒", tabType = QUIHeroModel.EQUIPMENT_ENCHANT_MASTER, unlock = app.master:checkEquipEnchantMasterUnlock(self._actorId), word = "觉醒", name = "装备"}, 
		{id = 3, btnName = "饰品突破", tabType = QUIHeroModel.JEWELRY_BREAK_MASTER, unlock = app.master:checkJewelryBreakMasterUnlock(self._actorId), word = "突破", name = "饰品"}, 
		{id = 4, btnName = "饰品强化", tabType = QUIHeroModel.JEWELRY_MASTER, unlock = app.master:checkJewelryStrengMasterUnlock(self._actorId), word = "强化", name = "饰品"}, 
		{id = 5, btnName = "饰品觉醒", tabType = QUIHeroModel.JEWELRY_ENCHANT_MASTER, unlock = app.master:checkJewelryEnchantMasterUnlock(self._actorId), word = "觉醒", name = "饰品"},
		{id = 6, btnName = "魂师培养", tabType = QUIHeroModel.HERO_TRAIN_MASTER, unlock = app.unlock:getUnlockTraining(), word = "培养", name = "魂师"}, 
		{id = 7, btnName = "魂骨突破", tabType = QUIHeroModel.GEMSTONE_BREAK_MASTER, unlock = app.master:checkGemstoneBreakMasterUnlock(self._actorId), word = "突破", name = "魂骨"},
		{id = 8, btnName = "魂骨强化", tabType = QUIHeroModel.GEMSTONE_MASTER, unlock = app.master:checkGemstoneStrengthMasterUnlock(self._actorId), word = "强化", name = "魂骨"},
		{id = 9, btnName = "外附魂骨强化", tabType = QUIHeroModel.SPAR_STRENGTHEN_MASTER, unlock = app.master:checkSparStrengthMasterUnlock(self._actorId), word = "强化", name = "外附魂骨"},
		{id = 10, btnName = "仙品升级", tabType = QUIHeroModel.MAGICHERB_UPLEVEL_MASTER, unlock = app.master:checkMagicHerbUpLevelMasterUnlock(self._actorId), word = "升级", name = "仙品"},
	}
	self._btnList = {}
	for i, btn in pairs(btnList) do
		if btn.unlock then
			table.insert(self._btnList, btn)
		end
	end
	self._ccbOwner.frame_tf_title:setString("成长大师")

	self:initInfo()
	self:initTopButtonList()
end

function QUIDialogMaster:viewDidAppear()
	QUIDialogMaster.super.viewDidAppear(self)
	self:addBackEvent()
end 

function QUIDialogMaster:viewWillDisappear()
	QUIDialogMaster.super.viewWillDisappear(self)
    self:removeBackEvent()
end

function QUIDialogMaster:initTopButtonList()
	for i, v in pairs(self._btnList) do
		v.isSelected = self._masterType == v.tabType
		if v.isSelected then
			self._ccbOwner.box_dec:setString("点击"..v.name.."可直接去"..(v.word or "强化"))
		end
	end
	-- body
	if not self._btnlistViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._btnList[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetSelectBtn.new()
            		item:addEventListener(QUIWidgetSelectBtn.EVENT_CLICK, handler(self, self.btnItemClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	            return isCacheNode
	        end,
	        curOriginOffset = 5,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 5,
	        totalNumber = #self._btnList,
		}
		self._btnlistViewLayout = QListView.new(self._ccbOwner.sheet_menu, cfg)
	else
		self._btnlistViewLayout:refreshData()
	end
end

function QUIDialogMaster:initInfo()
	self.heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._masterLevel = self.heroUIModel:getMasterLevelByType(self._masterType)

	if self._masterType == self.heroUIModel.HERO_TRAIN_MASTER then
		local config = QStaticDatabase:sharedDatabase():getTrainingBonus(self._actorId)
		local forceChanged = app.master:getForceChanges(self._actorId)
		self._forceChanged = forceChanged
		local trainLevel = 0
		local masterForce = 0
		self._currMasterInfo = {}
		for _, obj in ipairs(config) do
			self._nextMasterInfo = obj
			if obj.standard > forceChanged then
				break
			else
				trainLevel = trainLevel + 1
				self._currMasterInfo = obj
				masterForce = masterForce + app.master:getTrainMasterForce(obj, self._actorId)
			end
		end 
		self._masterLevel = trainLevel
		self._isMax = self._masterLevel >= #config and true or false

		self._maxForce = self._nextMasterInfo.standard + masterForce
		self._forceChanged = self._forceChanged + masterForce
        self._currMasterInfo = app.master:countCurrentTrainMasterProp(self._currMasterInfo, self._actorId)
        self._nextMasterInfo = app.master:countCurrentTrainMasterProp(self._nextMasterInfo, self._actorId)
    elseif self._masterType == self.heroUIModel.MAGICHERB_UPLEVEL_MASTER then
    	self._currMasterInfo, self._nextMasterInfo, _, self._isMax = self.heroUIModel:getMasterInfo()
	else
		local masterType = self.heroUIModel:getSuperMasterTypeByType(self._masterType)
		self._currMasterInfo, self._nextMasterInfo, self._isMax = QStaticDatabase:sharedDatabase():getStrengthenMasterByMasterLevel(masterType, self._masterLevel)	
	end

	if self._masterType == self.heroUIModel.JEWELRY_MASTER then
		self._isMax = self._masterLevel >= 18 and true or self._isMax
	end
	QPrintTable(self._nextMasterInfo)
	self:setBoxInfos()
	self:setPropInfo()
end

function QUIDialogMaster:setBoxInfos()
	if next(self._equipBox) then
		for i = 1, #self._equipBox, 1 do
			self._equipBox[i]:removeFromParent()
			self._equipBox[i] = nil
		end
	end

	if self._masterType == self.heroUIModel.JEWELRY_MASTER or self._masterType == self.heroUIModel.JEWELRY_ENCHANT_MASTER or self._masterType == self.heroUIModel.JEWELRY_BREAK_MASTER then
		for i = 1, 2 do
			self._equipBox[i] = QUIWidgetMasterCell.new()
			self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
		end
		self._equipBox[1]:setType(EQUIPMENT_TYPE.JEWELRY1)
		self._equipBox[2]:setType(EQUIPMENT_TYPE.JEWELRY2)
	elseif self._masterType == self.heroUIModel.EQUIPMENT_MASTER or self._masterType == self.heroUIModel.EQUIPMENT_ENCHANT_MASTER then
		for i = 1, 4 do
			self._equipBox[i] = QUIWidgetMasterCell.new()
			self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
		end

		self._equipBox[1]:setType(EQUIPMENT_TYPE.WEAPON)
		self._equipBox[2]:setType(EQUIPMENT_TYPE.BRACELET)
		self._equipBox[3]:setType(EQUIPMENT_TYPE.CLOTHES)
		self._equipBox[4]:setType(EQUIPMENT_TYPE.SHOES)
	end

	for i = 1, #self._equipBox, 1 do
		local equipmentInfo = self.heroUIModel:getEquipmentInfoByPos(self._equipBox[i]:getType())
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(equipmentInfo.info.itemId)
		self._equipBox[i]:setItemInfo(itemInfo, equipmentInfo, self._nextMasterInfo, self._masterType)
		self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	end

	if self._masterType == self.heroUIModel.HERO_TRAIN_MASTER then
		self._equipBox[1] = QUIWidgetMasterCell.new()
		self._ccbOwner["box_node"..1]:addChild(self._equipBox[1])
		self._equipBox[1]:setForceIcon(true)
		self._equipBox[1]:setForceInfo(self._forceChanged, self._maxForce)
		self._equipBox[1]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
	elseif self._masterType == self.heroUIModel.GEMSTONE_MASTER or self._masterType == self.heroUIModel.GEMSTONE_BREAK_MASTER then
		for i = 1, 4 do
			self._equipBox[i] = QUIWidgetMasterCell.new()
			self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
			local genstoneInfo = self.heroUIModel:getGemstoneInfoByPos(i)
			if genstoneInfo.info ~= nil then
				local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(genstoneInfo.info.itemId)
				self._equipBox[i]:setType(i)
				self._equipBox[i]:setItemInfo(itemInfo, genstoneInfo, self._nextMasterInfo, self._masterType)
			else
				self._equipBox[i]:showEmpty(self._nextMasterInfo)
			end
			self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
		end
	elseif self._masterType == self.heroUIModel.SPAR_STRENGTHEN_MASTER then
		for i = 1, 2 do
			self._equipBox[i] = QUIWidgetMasterCell.new()
			self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
			local sparInfo = self.heroUIModel:getSparInfoByPos(i)
			if sparInfo.info ~= nil then
				local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(sparInfo.info.itemId)
				self._equipBox[i]:setType(i)
				self._equipBox[i]:setItemInfo(itemInfo, sparInfo, self._nextMasterInfo, self._masterType)
			else
				self._equipBox[i]:showEmpty(self._nextMasterInfo, self._masterType)
			end
			self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
		end
	elseif self._masterType == self.heroUIModel.MAGICHERB_UPLEVEL_MASTER then
		for i = 1, 3 do
			self._equipBox[i] = QUIWidgetMasterCell.new()
			self._ccbOwner["box_node"..i]:addChild(self._equipBox[i])
			local magicHerbWearedInfo = self.heroUIModel:getMagicHerbWearedInfoByPos(i)
			if magicHerbWearedInfo then
				local maigcHerb = remote.magicHerb:getMaigcHerbItemBySid(magicHerbWearedInfo.sid)
				local itemInfo = db:getItemByID(maigcHerb.itemId)
				self._equipBox[i]:setType(i)
				self._equipBox[i]:setItemInfo(itemInfo, magicHerbWearedInfo, self._nextMasterInfo, self._masterType)
			else
				self._equipBox[i]:showEmpty(self._nextMasterInfo, self._masterType)
			end
			self._equipBox[i]:addEventListener(QUIWidgetMasterCell.EVENT_CLICK_BOX, handler(self, self._eventClickBox))
		end
	end
end

function QUIDialogMaster:setPropInfo()
	if self._propClient == nil then
		self._propClient = QUIWidgetMasterPropClient.new()
		self._ccbOwner.sheet:addChild(self._propClient)
	end
	self._propClient:setClientInfo(self._masterLevel, self._isMax, self._currMasterInfo, self._nextMasterInfo, self._masterType)
end 

function QUIDialogMaster:btnItemClickHandler(event)
	local info = event.info or {}
	local tabType = QUIHeroModel.EQUIPMENT_MASTER
	for i, v in pairs(self._btnList) do
		if v.id == info.id then
			tabType = v.tabType
			break
		end
	end

	local callback = function()
		self._masterType = tabType
		self:initInfo()
		self:initTopButtonList()
	end

	if tabType == QUIHeroModel.JEWELRY_MASTER or tabType == QUIHeroModel.JEWELRY_BREAK_MASTER or tabType == QUIHeroModel.JEWELRY_ENCHANT_MASTER then
		if self.heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY1) and self.heroUIModel:getEquipmentInfoByPos(EQUIPMENT_TYPE.JEWELRY2) then
			callback()
		else
			app.tip:floatTip("饰品全部解锁开启饰品成长大师")
		end
	else
		callback()
	end
end

function QUIDialogMaster:_eventClickBox(event)
	if event.itemId == nil then
		if self._masterType == QUIHeroModel.GEMSTONE_MASTER or self._masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER then
			app.tip:floatTip("请先装备魂骨")
			return
		elseif self._masterType == QUIHeroModel.SPAR_STRENGTHEN_MASTER then
			app.tip:floatTip("请先装备外附魂骨")
			return
		elseif self._masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
			app.tip:floatTip("请先携带仙品")
			return
		end
	end
	self:viewAnimationOutHandler()

	if self._isPopParentDialog then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	if self._masterType == QUIHeroModel.HERO_TRAIN_MASTER then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
						 options = {hero = self._heros, pos = self._pos, detailType = QUIDialogHeroInformation.HERO_TRAINING, isQuickWay = self._isQuickWay}})
	elseif self._masterType == QUIHeroModel.GEMSTONE_MASTER or self._masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER then
		if self._masterType == QUIHeroModel.GEMSTONE_MASTER then
			initTab = QUIDialogHeroGemstoneDetail.TAB_STRONG
		elseif self._masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER then
			initTab = QUIDialogHeroGemstoneDetail.TAB_EVOLUTION
		end
	  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroGemstoneDetail", 
            options = {gemstonePos = event.euqipPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions, initTab = initTab}})
	elseif self._masterType == QUIHeroModel.SPAR_STRENGTHEN_MASTER then
	  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSparDetail", 
            options = {index = event.euqipPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions, initTab = QUIDialogHeroSparDetail.TAB_STRONG}})
	elseif self._masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbDetail", 
            options = {heroList = self._heros, heroPos = self._pos, pos = event.euqipPos, parentOptions = self._parentOptions, tabType = QUIDialogMagicHerbDetail.TAB_UPLEVEL}})
	else
		local initTab = QUIDialogHeroEquipmentDetail.TAB_STRONG
		if self._masterType == QUIHeroModel.EQUIPMENT_ENCHANT_MASTER or  self._masterType == QUIHeroModel.JEWELRY_ENCHANT_MASTER then
			initTab = QUIDialogHeroEquipmentDetail.TAB_MAGIC
		elseif self._masterType == QUIHeroModel.JEWELRY_BREAK_MASTER then
			initTab = QUIDialogHeroEquipmentDetail.TAB_EVOLUTION
		end
	  	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroEquipmentDetail", 
	        options = {itemId= event.itemId, equipmentPos = event.euqipPos, heros = self._heros, pos = self._pos, parentOptions = self._parentOptions,
	         initTab = initTab, isQuickWay = self._isQuickWay}})
  	end
end


function QUIDialogMaster:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogMaster:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogMaster:_onTriggerBack(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogMaster:_onTriggerHome(tag, menuItem)
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMaster