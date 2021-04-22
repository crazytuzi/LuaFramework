-- @Author: xurui
-- @Date:   2020-01-17 10:30:34
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-27 18:55:21
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroFragmentSecretary = class("QUIDialogHeroFragmentSecretary", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroFragmentSecretaryClient = import("..widgets.QUIWidgetHeroFragmentSecretaryClient")
local QListView = import("...views.QListView") 
local QUIWidgetSecretarySettingTitle = import("..widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySetting = import("..widgets.QUIWidgetSecretarySetting")
local QUIWidgetSecretarySettingBuy = import("..widgets.QUIWidgetSecretarySettingBuy")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogHeroFragmentSecretary:ctor(options)
	local ccbFile = "ccb/Dialog_herofragment_secretary.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
    }
    QUIDialogHeroFragmentSecretary.super.ctor(self, ccbFile, callBacks, options)
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

	self:initListView()
end

function QUIDialogHeroFragmentSecretary:viewDidAppear()
	QUIDialogHeroFragmentSecretary.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogHeroFragmentSecretary:viewWillDisappear()
  	QUIDialogHeroFragmentSecretary.super.viewWillDisappear(self)
end

function QUIDialogHeroFragmentSecretary:setInfo()
	local iconRes = QResPath("hero_fragment_secretary_icon")
	self._data = {
		{id = "energy", icon = iconRes[1], desc = "自动补充体力", selected = false, settingCallback = handler(self, self._energyCallBack)},
		{id = "invation", icon = iconRes[2], desc = "魂兽入侵攻打", selected = false, settingCallback = handler(self, self._invasionCallBack)},
	}

	local heroDatas = {}
	local heroIds = {}
	local insertHeroFunc = function(heroId, dropInfo)
		if heroId == nil then return end
		local heroConfig = db:getCharacterByID(heroId)
		table.insert(heroDatas, {id = heroId, icon = heroConfig.icon, dropInfo = dropInfo, desc = (heroConfig.name or "") .. "碎片扫荡", aptitude = heroConfig.aptitude, 
			settingCallback = handler(self, self._heroCallBack)})
		heroIds[tostring(heroId)] = 1
	end

	local haveHeros = remote.herosUtil:getShowHerosKey()
	for _, heroId in ipairs(haveHeros) do
		local heroConfig = QStaticDatabase:sharedDatabase():getCharacterByID(heroId)
		if heroConfig.aptitude >= APTITUDE.S then
			local heroInfo = remote.herosUtil:getHeroByID(heroId)
			local grade = 0
			if heroInfo ~= nil then
				grade = heroInfo.grade
			end
			local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(heroId, grade + 1)
			if config == nil then
				config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(heroId, grade)
			end
			if config then
	    		local dropInfo = remote.instance:getDropInfoByItemId(config.soul_gem, DUNGEON_TYPE.ELITE)
	    		for _, value in ipairs(dropInfo) do
	    			if value.map.isLock and value.map.info then
	    				insertHeroFunc(heroId, dropInfo)
	    				break
	    			end
	    		end
			end
		end
	end

	table.sort(heroDatas, function(a, b)
		if a.aptitude ~= b.aptitude then
			return a.aptitude > b.aptitude
		else
			return a.id > b.id
		end
	end)

	for _, value in ipairs(self._data) do
		if self._settingData[tostring(value.id)] == nil then
			self._settingData[tostring(value.id)] = {}
			self._settingData[tostring(value.id)].selected = false
		end
		value.selected = self._settingData[tostring(value.id)].selected
	end

	for _, value in ipairs(heroDatas) do
		if self._settingData[tostring(value.id)] == nil then
			self._settingData[tostring(value.id)] = {}
			self._settingData[tostring(value.id)].selected = false
		end
		value.selected = self._settingData[tostring(value.id)].selected
		table.insert(self._data, value)
	end

	self:initListView()


	local recordManager = app:getUserOperateRecord()
	local heroListRecord = recordManager:getRecordByType(recordManager.RECORD_TYPES.SECRETARY_HERO_FRAME_NEW_HERO)
	if self:checkHaveNewHero(heroListRecord, heroIds) then
		app.tip:floatTip("可扫荡魂师碎片已增加，魂师大人可以前往设置哦")
		recordManager:setRecordByType(recordManager.RECORD_TYPES.SECRETARY_HERO_FRAME_NEW_HERO, heroIds)
	end
end

function QUIDialogHeroFragmentSecretary:checkHaveNewHero(oldHeroIds, newHeroIds)
	if q.isEmpty(oldHeroIds) then
		if q.isEmpty(newHeroIds) == false then
			return true
		else
			return false
		end
	end

	for key, value in pairs(newHeroIds) do
		if oldHeroIds[key] == nil then
			return true
		end
	end

	return false
end

function QUIDialogHeroFragmentSecretary:initListView()
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

function QUIDialogHeroFragmentSecretary:_renderItemCallBack(list, index, info)
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
	item:setSelectState(self._settingData[tostring(data.id)].selected)
    if data.id == "energy" then
    	local setting = self._settingData[tostring(data.id)] or {}
    	item:setSettingStr(string.format("购买%s次", setting.buyEneryNum or 0))
    elseif data.id == "invation" then
    	item:setSettingStr("自动攻打")
    else
    	local setting = self._settingData[tostring(data.id)] or {}
    	item:setSettingStr(string.format("重置%s次", setting.resetDungeonNum or 0))
    end
   
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_select", "_onTriggerSelect")
    list:registerBtnHandler(index, "btn_set", "_onTriggerSet")

    return isCacheNode
end

function QUIDialogHeroFragmentSecretary:_onEvent(event)
	if event == nil then return end

	local info = event.info
	if event.name == QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SELECT then
		if self._settingData[tostring(info.id)] == nil then
			self._settingData[tostring(info.id)] = {}
		end
		self._settingData[tostring(info.id)].selected = event.selected
	elseif event.name == QUIWidgetHeroFragmentSecretaryClient.EVENT_CLICK_SET then
		if info.settingCallback then
			info.settingCallback(info)
		end
	end
end

function QUIDialogHeroFragmentSecretary:_energyCallBack(info)
	if info == nil then return end

	local setting = self._settingData[tostring(info.id)] or {}
	local widgets = {}
	local totalHeight = 0

	local titleWidget1 = QUIWidgetSecretarySettingTitle.new()
	titleWidget1:setInfo("购买体力设置")
	local titleHeight = titleWidget1:getContentSize().height
	table.insert(widgets, titleWidget1)
	totalHeight = totalHeight + titleHeight

	self._buyEneryNum = setting.buyEneryNum or 0
	local buyWidget = QUIWidgetSecretarySettingBuy.new()
	buyWidget:setResourceIcon(ITEM_TYPE.TOKEN_MONEY)
	buyWidget:setInfo(info.id, self._buyEneryNum, handler(self, self._getBuyEnergyCost))
	buyWidget:setMinNum(0)
	buyWidget:setPositionY(-totalHeight)
	table.insert(widgets, buyWidget)
	height = buyWidget:getContentSize().height
	totalHeight = totalHeight + height + 10

	local titleWidget2 = QUIWidgetSecretarySettingTitle.new()
	titleWidget2:setInfo("自动使用香肠")
	table.insert(widgets, titleWidget2)
	titleWidget2:setPositionY(-totalHeight)
	titleHeight = titleWidget2:getContentSize().height
	totalHeight = totalHeight + titleHeight + 10

	self._firstBuyEnergy = setting.firstBuyEnergy
	local itemWidget = QUIWidgetSecretarySetting.new()
    itemWidget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, handler(self, self._selectFirstBuyEnery))
	itemWidget:setInfo({desc = "自动使用香肠（优先购买体力，再使用香肠）"})
	itemWidget:setPosition(ccp(-10, -totalHeight))
	itemWidget:setTitlePosition(55)
	itemWidget:setTitleAnchorPoint(ccp(0, 0.5))
	itemWidget:setTitleDimensions(CCSize(300, 0))
	itemWidget:setSelected(self._firstBuyEnergy)
	table.insert(widgets, itemWidget)
	height = itemWidget:getContentSize().height
	totalHeight = totalHeight + height

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroFragmentSecretarySetting", 
		options = {setId = info.id, widgets = widgets, totalHeight = totalHeight, callback = function(setting)
			if self:safeCheck() == false then return end

			if self._settingData[tostring(info.id)] == nil then
				self._settingData[tostring(info.id)] = {}
			end
			self._settingData[tostring(info.id)].buyEneryNum = self._buyEneryNum
			self._settingData[tostring(info.id)].firstBuyEnergy = self._firstBuyEnergy

			self:setInfo()
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroFragmentSecretary:_getBuyEnergyCost(num)
	self._buyEneryNum = num
	local buyCount = remote.user.todayEnergyBuyCount or 0
	local totalNum = QVIPUtil:getBuyVirtualCount(ITEM_TYPE.ENERGY)

	local neeNum = 0
	for i = buyCount+1, self._buyEneryNum do
		local config = db:getTokenConsume(ITEM_TYPE.ENERGY, i)
		neeNum = neeNum + config.money_num
	end

	return neeNum, totalNum
end

function QUIDialogHeroFragmentSecretary:_selectFirstBuyEnery(event)
	if event == nil then return end
	self._firstBuyEnergy = event.isSelect
end

function QUIDialogHeroFragmentSecretary:_invasionCallBack(info)
	if info == nil then return end

	local setting = self._settingData[tostring(info.id)] or {}
	local widgets = {}
	local totalHeight = 0

	local createTitleWidget = function(desc, addHeight, offsetY, color, outlineColor)
		local widget = QUIWidgetSecretarySettingTitle.new()
		widget:setInfo(desc)
		widget:setTitleColor(color, outlineColor)
		if offsetY then
			widget:setPositionY(offsetY)
		end
		table.insert(widgets, widget)

		if addHeight then
			totalHeight = totalHeight + widget:getContentSize().height
		end
	end

	local createSettingWidget = function(desc, isSelect, offsetX, isRight, addHeight, callback)
		local widget = QUIWidgetSecretarySetting.new()
	    widget:addEventListener(QUIWidgetSecretarySetting.EVENT_SELECT_CLICK, callback)
		widget:setInfo({desc = desc})
		widget:setPosition(ccp(offsetX, -totalHeight))
		if isRight then
			widget:setTitlePosition(55)
			widget:setTitleAnchorPoint(ccp(0, 0.5))
			widget:setTitleDimensions(CCSize(300, 0))
		end
		widget:setSelected(isSelect)
		
		table.insert(widgets, widget)
		if addHeight then
			totalHeight = totalHeight + widget:getContentSize().height
		end

		return widget
	end

	createTitleWidget("魂兽攻打设置", true)
	self._autoFightInvation = setting.selected
	createSettingWidget("魂兽自动攻打", self._autoFightInvation, 0, true, true, function(data)
		self._autoFightInvation = data.isSelect
	end)
	self._shareInvation = setting.shareInvation
	createSettingWidget("分享魂兽（攻打并分享）", self._shareInvation, 0, true, true, function(data)
		self._shareInvation = data.isSelect
	end)
	self._autoCallInvation = setting.autoCallInvation
	createSettingWidget("自动召唤并攻打传说魂兽", self._autoCallInvation, 0, true, true, function(data)
		self._autoCallInvation = data.isSelect
	end)
	self._useItem = setting.useItem
	createSettingWidget("自动消耗魂兽征讨令", self._useItem, 0, true, true, function(data)
		self._useItem = data.isSelect
	end)

	createTitleWidget("奖励领取设置", true, -totalHeight + 10)
	self._getwardsAndScore = setting.getwardsAndScore
	createSettingWidget("自动领取积分奖励和击杀奖励", self._getwardsAndScore, 0, true, true, function(data)
		self._getwardsAndScore = data.isSelect
	end)
	createTitleWidget("开箱设置", true, -totalHeight + 10)
	self._openBox = setting.openBox or 1
	self._openBox1Widget = createSettingWidget("仅完成任务", self._openBox == 1, -50, true, false, function(data)
		self._openBox = data.isSelect == true and 1 or 2
		self._openBox2Widget:setSelected(self._openBox == 2)
	end)
	self._openBox2Widget = createSettingWidget("全部打开", self._openBox == 2, 180, true, true, function(data)
		self._openBox = data.isSelect == true and 2 or 1
		self._openBox1Widget:setSelected(self._openBox == 1)
	end)


	createTitleWidget("普通魂兽", true, -totalHeight + 10, COLORS.c, COLORS.P)
	self._normalFight = setting.normalFight or 1
	self._normalFight1Widget = createSettingWidget("普通攻击", self._normalFight == 1, -50, true, false, function(data)
		self._normalFight = data.isSelect == true and 1 or 2
		self._normalFight2Widget:setSelected(self._normalFight == 2)
	end)
	self._normalFight2Widget = createSettingWidget("2.5倍攻击", self._normalFight == 2, 180, true, true, function(data)
		self._normalFight = data.isSelect == true and 2 or 1
		self._normalFight1Widget:setSelected(self._normalFight == 1)
	end)

	createTitleWidget("精英魂兽", true, -totalHeight + 10, COLORS.Z, COLORS.Q)
	self._eliteFight = setting.eliteFight or 1
	self._eliteFight1Widget = createSettingWidget("普通攻击", self._eliteFight == 1, -50, true, false, function(data)
		self._eliteFight = data.isSelect == true and 1 or 2
		self._eliteFight2Widget:setSelected(self._eliteFight == 2)
	end)
	self._eliteFight2Widget = createSettingWidget("2.5倍攻击", self._eliteFight == 2, 180, true, true, function(data)
		self._eliteFight = data.isSelect == true and 2 or 1
		self._eliteFight1Widget:setSelected(self._eliteFight == 1)
	end)

	createTitleWidget("史诗魂兽", true, -totalHeight + 10, COLORS.D, COLORS.R)
	self._welfareFight = setting.welfareFight or 1
	self._welfareFight1Widget = createSettingWidget("普通攻击", self._welfareFight == 1, -50, true, false, function(data)
		self._welfareFight = data.isSelect == true and 1 or 2
		self._welfareFight2Widget:setSelected(self._welfareFight == 2)
	end)
	self._welfareFight2Widget = createSettingWidget("2.5倍攻击", self._welfareFight == 2, 180, true, true, function(data)
		self._welfareFight = data.isSelect == true and 2 or 1
		self._welfareFight1Widget:setSelected(self._welfareFight == 1)
	end)

	createTitleWidget("传说魂兽", true, -totalHeight + 10, COLORS.E, COLORS.H)
	self._legendFight = setting.legendFight or 1
	self._legendFight1Widget = createSettingWidget("普通攻击", self._legendFight == 1, -50, true, false, function(data)
		self._legendFight = data.isSelect == true and 1 or 2
		self._legendFight2Widget:setSelected(self._legendFight == 2)
	end)
	self._legendFight2Widget = createSettingWidget("2.5倍攻击", self._legendFight == 2, 180, true, true, function(data)
		self._legendFight = data.isSelect == true and 2 or 1
		self._legendFight1Widget:setSelected(self._legendFight == 1)
	end)

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroFragmentSecretarySetting", 
		options = {setId = info.id, widgets = widgets, totalHeight = totalHeight, callback = function(setting)
			if self:safeCheck() == false then return end

			if self._settingData[tostring(info.id)] == nil then
				self._settingData[tostring(info.id)] = {}
			end
			self._settingData[tostring(info.id)].selected = self._autoFightInvation
			self._settingData[tostring(info.id)].shareInvation = self._shareInvation
			self._settingData[tostring(info.id)].autoCallInvation = self._autoCallInvation
			self._settingData[tostring(info.id)].useItem = self._useItem
			self._settingData[tostring(info.id)].getwardsAndScore = self._getwardsAndScore
			self._settingData[tostring(info.id)].openBox = self._openBox
			self._settingData[tostring(info.id)].normalFight = self._normalFight
			self._settingData[tostring(info.id)].eliteFight = self._eliteFight
			self._settingData[tostring(info.id)].welfareFight = self._welfareFight
			self._settingData[tostring(info.id)].legendFight = self._legendFight

			self:setInfo()
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroFragmentSecretary:_heroCallBack(info)
	if info == nil then return end

	local setting = self._settingData[tostring(info.id)] or {}
	local widgets = {}
	local totalHeight = 0

	local titleWidget = QUIWidgetSecretarySettingTitle.new()
	titleWidget:setInfo("重置次数设置")
	local titleHeight = titleWidget:getContentSize().height
	table.insert(widgets, titleWidget)
	totalHeight = totalHeight + titleHeight

	self._dropInfo = info.dropInfo or {}
	self._resetDungeonNum = setting.resetDungeonNum or 0
	local buyWidget = QUIWidgetSecretarySettingBuy.new()
	buyWidget:setResourceIcon(ITEM_TYPE.TOKEN_MONEY)
	buyWidget:setInfo(info.id, self._resetDungeonNum, handler(self, self._getResetDungeonCost))
	buyWidget:setMinNum(0)
	buyWidget:setPositionY(-totalHeight)
	table.insert(widgets, buyWidget)
	totalHeight = totalHeight + buyWidget:getContentSize().height + 10

	local tip = "将按照设置自动重置魂师碎片对应精英副本"
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroFragmentSecretarySetting", 
		options = {setId = info.id, widgets = widgets, tipStr = tip, totalHeight = totalHeight, callback = function(setting)
			if self:safeCheck() == false then return end

			if self._settingData[tostring(info.id)] == nil then
				self._settingData[tostring(info.id)] = {}
			end
			self._settingData[tostring(info.id)].resetDungeonNum = self._resetDungeonNum

			self:setInfo()
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroFragmentSecretary:_getResetDungeonCost(num)
	self._resetDungeonNum = num

	local needNum = 0
	local totalNum = QVIPUtil:getResetEliteDungeonCount()
	local tokenConfig = db:getTokenConsumeByType("dungeon_elite")
	local resetCountList = {}

	for _, value in ipairs(self._dropInfo) do
		local mapInfo = value.map or {}
		if mapInfo.isLock and mapInfo.info then
			local isPassed = mapInfo.info.lastPassAt ~= 0
			if isPassed then
				local buyCount = mapInfo.info.todayReset or 0
				for i = buyCount+1, self._resetDungeonNum do
					local config = tokenConfig[i] or {}
					needNum = needNum + (config.money_num or 0)
				end
			end
		end
	end

	return needNum, totalNum
end

function QUIDialogHeroFragmentSecretary:_onTriggerConfirm()
  	app.sound:playSound("common_small")

  	self._isConfirm = true
	self:_onTriggerClose()
end

function QUIDialogHeroFragmentSecretary:_onTriggerCancel()
	self:_onTriggerClose()
end

function QUIDialogHeroFragmentSecretary:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHeroFragmentSecretary:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogHeroFragmentSecretary:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if self._isConfirm and callback then
		callback(self._settingData)
	end
end

return QUIDialogHeroFragmentSecretary
