-- @Author: xurui
-- @Date:   2019-09-18 15:09:07
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-01 16:52:09
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneQuickChange = class("QUIDialogGemstoneQuickChange", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView") 
local QUIWidgetGemstoneHeroQucikExchange = import("..widgets.QUIWidgetGemstoneHeroQucikExchange")
local QUIWidgetGemstoneQuickExchange = import("..widgets.QUIWidgetGemstoneQuickExchange")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QGemstoneController = import("..controllers.QGemstoneController")

QUIDialogGemstoneQuickChange.TAB_EQUIPMENT = "TAB_EQUIPMENT"
QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT = "TAB_UNEQUIPMENT"

function QUIDialogGemstoneQuickChange:ctor(options)
	local ccbFile = "ccb/Dialog_gemstone_exchange.ccbi" 
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerEquipment", callback = handler(self, self._onTriggerEquipment)},
		{ccbCallbackName = "onTriggerUnequipment", callback = handler(self, self._onTriggerUnequipment)},
		{ccbCallbackName = "onTriggerQuickExchange", callback = handler(self, self._onTriggerQuickExchange)},
    }
    QUIDialogGemstoneQuickChange.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._actorId = options.actorId
    	self._selectTab = options.tab
    	self._callBack = options.callBack
    end

    if self._selectTab == nil then
    	self._selectTab = QUIDialogGemstoneQuickChange.TAB_EQUIPMENT
    end
	self._data = {}
	self._gemstoneBoxs = {}
	self._sparBoxs = {}
	self._selectGemstons = {}   --选择的未装备魂骨列表
	self._selectGemstonPos = {}   --选择的未装备魂骨位置
	self._selectSpars = {}		--选择的未装备外附魂骨列表
	self._isShowEffect = 0
end

function QUIDialogGemstoneQuickChange:viewDidAppear()
	QUIDialogGemstoneQuickChange.super.viewDidAppear(self)

	self:setSelectInfo()
end

function QUIDialogGemstoneQuickChange:viewAnimationInHandler()
	QUIDialogGemstoneQuickChange.super.viewDidAppear(self)

	self:initListView()
end

function QUIDialogGemstoneQuickChange:viewWillDisappear()
  	QUIDialogGemstoneQuickChange.super.viewWillDisappear(self)
end

function QUIDialogGemstoneQuickChange:setSelectInfo()
	self:setButtonState()
	self._selectGemstonPos = {}

	if self._selectTab == QUIDialogGemstoneQuickChange.TAB_EQUIPMENT then
		self._data = {}
		local heroIds = remote.herosUtil:getHaveHero()
		for _, actorId in pairs(heroIds) do
			if actorId ~= self._actorId then
				local heroInfo = remote.herosUtil:getHeroByID(actorId)
				if heroInfo.gemstones or heroInfo.spar then
					table.insert(self._data, {heroInfo = heroInfo, selectGemstone = false, selectSpar = false})
				end
			end
		end
		self._ccbOwner.node_btn_exchange:setVisible(false)
	elseif self._selectTab == QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT then
		self._data = {}
		local gemstones = remote.gemstone:getGemstoneByWear(false)
		local ssGemstoneLevel = GEMSTONE_MAXADVANCED_LEVEL
		table.sort(gemstones, function(a, b)
			local config1 = db:getItemByID(a.itemId)
			local config2 = db:getItemByID(b.itemId)

			if (a.godLevel >= ssGemstoneLevel and b.godLevel < ssGemstoneLevel) or (a.godLevel < ssGemstoneLevel and b.godLevel >= ssGemstoneLevel) then
				return a.godLevel >= ssGemstoneLevel
			elseif config1.gemstone_quality ~= config2.gemstone_quality then
				return config1.gemstone_quality > config2.gemstone_quality
			elseif a.itemId ~= b.itemId then
				return a.itemId < b.itemId
			elseif a.craftLevel ~= b.craftLevel then
				return a.craftLevel > b.craftLevel
			elseif a.level ~= b.level then
				return a.level > b.level
			else
				return false
			end
		end)
		for i, v in ipairs(gemstones) do
			local config = db:getItemByID(v.itemId)
			table.insert(self._data, {gemstoneInfo = v, isSelect = false, isDuplicate = false, gemstoneType = config.gemstone_type})
		end
		local spars1 = remote.spar:getSparsByType(ITEM_CONFIG_TYPE.GARNET)
		local sortSparFunc = function(a, b)
			if a.itemId ~= b.itemId then
				return a.itemId < b.itemId
			elseif a.grade ~= b.grade then
				return a.grade > b.grade
			elseif a.level ~= b.level then
				return a.level > b.level
			else
				return false
			end
		end
		table.sort(spars1, sortSparFunc)
		for i, v in ipairs(spars1) do
			if v.actorId == nil or v.actorId == 0 then
				table.insert(self._data, {sparInfo = v, isSelect = false, isDuplicate = false, sparType = 1})
			end
		end
		local spars2 = remote.spar:getSparsByType(ITEM_CONFIG_TYPE.OBSIDIAN)
		table.sort(spars2, sortSparFunc)
		for i, v in ipairs(spars2) do
			if v.actorId == nil or v.actorId == 0 then
				table.insert(self._data, {sparInfo = v, isSelect = false, isDuplicate = false, sparType = 2})
			end
		end

		self._ccbOwner.node_btn_exchange:setVisible(true)
	end

	self:setCurrentHeroInfo()

	self:initListView()
end

function QUIDialogGemstoneQuickChange:setButtonState()
	local tabEquip = self._selectTab == QUIDialogGemstoneQuickChange.TAB_EQUIPMENT
	self._ccbOwner.btn_equip:setHighlighted(tabEquip)
	self._ccbOwner.btn_equip:setEnabled(not tabEquip)

	local tabUnequip = self._selectTab == QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT
	self._ccbOwner.btn_unequip:setHighlighted(tabUnequip)
	self._ccbOwner.btn_unequip:setEnabled(not tabUnequip)
end

function QUIDialogGemstoneQuickChange:initListView()
	local multiItems = 1
	local spaceY = 0
	if self._selectTab == QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT then
		multiItems = 6
		spaceY = 0
	end

    local totalNumber = #self._data
    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            enableShadow = false,
            ignoreCanDrag = true,
            curOriginOffset = 3,
            curOffset = 5,
            contentOffsetX = 6,
            spaceY = spaceY,
            multiItems = multiItems,
            totalNumber = totalNumber,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:resetTouchRect()
        self._listView:reload({totalNumber = totalNumber, multiItems = multiItems, spaceY = spaceY})
    end
end

function QUIDialogGemstoneQuickChange:_renderItemCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
        isCacheNode = false
		if self._selectTab == QUIDialogGemstoneQuickChange.TAB_EQUIPMENT then
			item = QUIWidgetGemstoneHeroQucikExchange.new()
			item:addEventListener(QUIWidgetGemstoneHeroQucikExchange.EVENT_QUICK_EXCHANGE, handler(self, self._onClickEvent))
			item:addEventListener(QUIWidgetGemstoneHeroQucikExchange.EVENT_CLICK_HERO_SELECT, handler(self, self._onClickEvent))
		elseif self._selectTab == QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT then
			item = QUIWidgetGemstoneQuickExchange.new() 
			item:addEventListener(QUIWidgetGemstoneQuickExchange.EVENT_CLICK_SELECT, handler(self, self._onClickEvent))
		end
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    info.tag = self._selectTab

	if self._selectTab == QUIDialogGemstoneQuickChange.TAB_EQUIPMENT then
		list:registerBtnHandler(index,"btn_select_gemstone", "_onTriggerSelectGemstone")
		list:registerBtnHandler(index,"btn_select_spar", "_onTriggerSelectSpar")
		list:registerBtnHandler(index,"btn_exchange", "_onTriggerExchange", nil, true)
	elseif self._selectTab == QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT then
		list:registerBtnHandler(index,"btn_touch", "_onTriggerTouch")
	end

    return isCacheNode
end

function QUIDialogGemstoneQuickChange:_onClickEvent(event)
	if event == nil then return end

	if event.name == QUIWidgetGemstoneHeroQucikExchange.EVENT_QUICK_EXCHANGE then
		local gemstones = {}
		local spars = {}
		local heroInfo = event.heroInfo or {}
		local info = event.info
		if info.selectGemstone and heroInfo.gemstones then
			for _, value in pairs(heroInfo.gemstones) do
				gemstones[#gemstones+1] = value.sid
			end
		end
		if info.selectSpar and heroInfo.spar then
			for _, value in pairs(heroInfo.spar) do
				spars[#spars+1] = value.sparId
			end
		end
		self:quickExchange(gemstones, spars)
	elseif event.name == QUIWidgetGemstoneHeroQucikExchange.EVENT_CLICK_HERO_SELECT then
		local info = event.info
		for _, value in pairs(self._data) do
			if info.selectGemstone and info.heroInfo and value.heroInfo then
				value.selectGemstone = value.heroInfo.actorId == info.heroInfo.actorId
			end
			if info.selectSpar and info.heroInfo and value.heroInfo then
				value.selectSpar = value.heroInfo.actorId == info.heroInfo.actorId
			end
		end

		for i = 1, 4 do
			if self._gemstoneBoxs[i] ~= nil then
				if info.selectGemstone and self._gemstoneBoxs[i]:getState() == remote.gemstone.GEMSTONE_LOCK then
					app.tip:floatTip("无法装备更多魂骨，请提升魂师等级")
					self._gemstoneBoxs[i]:selected(false)
				else
					self._gemstoneBoxs[i]:selected(info.selectGemstone)
				end
			end
		end
		local sparLockIndex = 0
		for i = 1, 2 do
			if self._sparBoxs[i] ~= nil then
				if info.selectSpar and self._sparBoxs[i]:getState() == remote.spar.SPAR_LOCK then
					sparLockIndex = sparLockIndex + 1
					self._sparBoxs[i]:selected(false)
				else
					self._sparBoxs[i]:selected(info.selectSpar)
				end
			end
		end
		if sparLockIndex == 2 then
			info.selectSpar = false
			app.tip:floatTip("无法装备更多外附魂骨，请提升魂师等级")
		end

		if self._listView then
			self._listView:refreshData()
		end
	elseif event.name == QUIWidgetGemstoneQuickExchange.EVENT_CLICK_SELECT then
		local info = event.info or {}
		if info.gemstoneInfo then
			local isFind = false
			for i = 1, 4 do
				local gemstoneInfo = self._gemstoneBoxs[i]:getGemstoneInfo()
				local config = db:getItemByID(gemstoneInfo.itemId)
				if self._gemstoneBoxs[i] ~= nil and config and config.gemstone_type == info.gemstoneType then
					self._gemstoneBoxs[i]:selected(info.isSelect)
					self._selectGemstonPos[i] = info.gemstoneInfo.sid
					isFind = true
				end
			end
			if isFind == false then
				for i = 1, 4 do
					local gemstoneInfo = self._gemstoneBoxs[i]:getGemstoneInfo()
					if (info.isSelect and q.isEmpty(gemstoneInfo) and self._selectGemstonPos[i] == nil) or (info.isSelect == false and self._selectGemstonPos[i] == info.gemstoneInfo.sid) then
						if self._gemstoneBoxs[i]:getState() == remote.gemstone.GEMSTONE_LOCK then
							info.isSelect = false
							app.tip:floatTip("无法装备更多魂骨，请提升魂师等级")
							if self._listView then
								self._listView:refreshData()
							end
							return
						end
						self._gemstoneBoxs[i]:selected(info.isSelect)
						if info.isSelect then
							self._selectGemstonPos[i] = info.gemstoneInfo.sid
						else
							self._selectGemstonPos[i] = nil
						end
						break
					end
				end
			end

			if info.isSelect then
				self._selectGemstons[info.gemstoneType] = info.gemstoneInfo
			else
				self._selectGemstons[info.gemstoneType] = nil
			end
		elseif info.sparInfo then
			for i = 1, 2 do
				if self._sparBoxs[i] ~= nil and i == info.sparType then
					if self._sparBoxs[i]:getState() == remote.spar.SPAR_LOCK then
						info.isSelect = false
						app.tip:floatTip("无法装备更多外附魂骨，请提升魂师等级")
						if self._listView then
							self._listView:refreshData()
						end
						return
					end
					self._sparBoxs[i]:selected(info.isSelect)
				end
			end
			if info.isSelect then
				self._selectSpars[info.sparType] = info.sparInfo
			else
				self._selectSpars[info.sparType] = nil
			end
		end

		for _, value in pairs(self._data) do
			if info.gemstoneInfo and value.gemstoneInfo then
				if value.gemstoneInfo.sid ~= info.gemstoneInfo.sid and value.gemstoneType == info.gemstoneType then
					value.isDuplicate = self._selectGemstons[value.gemstoneType] ~= nil
				end
			end
			if info.sparInfo and value.sparInfo then
				if value.sparInfo.sparId ~= info.sparInfo.sparId and value.sparType == info.sparType then
					value.isDuplicate = self._selectSpars[value.sparType] ~= nil
				end
			end
		end

		if self._listView then
			self._listView:refreshData()
		end
	end
end

function QUIDialogGemstoneQuickChange:setCurrentHeroInfo()
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
    for i = 1, 4 do
		if self._gemstoneBoxs[i] == nil then
		    self._gemstoneBoxs[i] = QUIWidgetGemstonesBox.new()
		    self._gemstoneBoxs[i]:setScale(0.8)
		    self._gemstoneBoxs[i]:setPositionY(5)
			self._gemstoneBoxs[i]:resetAll()
		    self._gemstoneBoxs[i]:setPos(i)
	    	self._ccbOwner["node_gemstone_"..i]:addChild(self._gemstoneBoxs[i])
		end

		local gemstoneInfo = uiHeroModel:getGemstoneInfoByPos(i)
		self._gemstoneBoxs[i]:setState(gemstoneInfo.state)
	    if q.isEmpty(gemstoneInfo.info) == false then
	    	self._gemstoneBoxs[i]:setGemstoneInfo(gemstoneInfo.info)
		end
		self._gemstoneBoxs[i]:selected(false)
	end
    for i = 1, 2 do
		if self._sparBoxs[i] == nil then
		    self._sparBoxs[i] = QUIWidgetSparBox.new()
		    self._sparBoxs[i]:setScale(0.8)
		    self._sparBoxs[i]:setNameVisible(false)
		    self._sparBoxs[i]:setPositionY(5)
		    self._ccbOwner["node_spar_"..i]:addChild(self._sparBoxs[i])
		end

		local sparInfo = uiHeroModel:getSparInfoByPos(i)
		self._sparBoxs[i]:resetAll()
		self._sparBoxs[i]:setState(sparInfo.state, i)
		self._sparBoxs[i]:setIsSpar()
	    if q.isEmpty(sparInfo.info) == false then
			self._sparBoxs[i]:setGemstoneInfo(sparInfo.info, i)
		end
		self._sparBoxs[i]:selected(false)
	end
end

function QUIDialogGemstoneQuickChange:quickExchange(gemstoneIds, sparIds)
	if q.isEmpty(gemstoneIds) and q.isEmpty(sparIds) then 
		app.tip:floatTip("当前没有可以交换的魂骨")
		return 
	end

	remote.gemstone:gemstoneQuickExchange(self._actorId, gemstoneIds, sparIds, function()
		if self:safeCheck() then
			if #gemstoneIds > 0 and #sparIds > 0 then
				self._isShowEffect = 3
			elseif #gemstoneIds > 0 then
				self._isShowEffect = 1
			elseif #sparIds > 0 then
				self._isShowEffect = 2
			end

			self:_onTriggerClose()
		end
	end)
end

function QUIDialogGemstoneQuickChange:_onTriggerQuickExchange(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_exchange) == false then return end
  	app.sound:playSound("common_small")

	if q.isEmpty(self._selectGemstons) and q.isEmpty(self._selectSpars) then
		app.tip:floatTip("魂师大人，请先选择要替换的魂骨和外附魂骨~")
		return
	end

	local gemstones = {}
	local spars = {}
	for _, value in pairs(self._selectGemstons) do
		gemstones[#gemstones+1] = value.sid
	end
	for _, value in pairs(self._selectSpars) do
		spars[#spars+1] = value.sparId
	end
	self:quickExchange(gemstones, spars)
end

function QUIDialogGemstoneQuickChange:_onTriggerEquipment()
	if self._selectTab == QUIDialogGemstoneQuickChange.TAB_EQUIPMENT then 
		return
	end
  	app.sound:playSound("common_small")

	self._selectTab = QUIDialogGemstoneQuickChange.TAB_EQUIPMENT
	self:setSelectInfo()
end

function QUIDialogGemstoneQuickChange:_onTriggerUnequipment()
	if self._selectTab == QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT then 
		return
	end
  	app.sound:playSound("common_small")

	self._selectTab = QUIDialogGemstoneQuickChange.TAB_UNEQUIPMENT
	self:setSelectInfo()
end

function QUIDialogGemstoneQuickChange:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogGemstoneQuickChange:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGemstoneQuickChange:viewAnimationOutHandler()
	local callback = self._callBack
	local isShowEffect = self._isShowEffect

	self:popSelf()

	if isShowEffect > 0 and callback then
		callback(isShowEffect)
	end
end

return QUIDialogGemstoneQuickChange
