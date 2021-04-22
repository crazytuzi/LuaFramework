-- @Author: xurui
-- @Date:   2017-03-31 17:55:57
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-10-25 18:27:38
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparBackPackInfo = class("QUIWidgetSparBackPackInfo", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetSparBox = import(".QUIWidgetSparBox")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("....ui.QUIViewController")
local QQuickWay = import("....utils.QQuickWay")
local QActorProp = import("....models.QActorProp")
local QScrollView = import("....views.QScrollView") 
local QUIWidgetSparBackPackInfoClient = import(".QUIWidgetSparBackPackInfoClient")
local QUIDialogHeroSparDetail = import("...dialogs.QUIDialogHeroSparDetail")
local QUIWidgetSparBackPackInfoClientSuitClient = import(".QUIWidgetSparBackPackInfoClientSuitClient")

QUIWidgetSparBackPackInfo.CLICK_COMPOSE = "SPAR_CLICK_COMPOSE"

function QUIWidgetSparBackPackInfo:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Packsack.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerCompose", callback = handler(self, self._onTirggerCompose)},
		{ccbCallbackName = "onTriggerRecyle", callback = handler(self, self._onTirggerRecyle)},
	}
	QUIWidgetSparBackPackInfo.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    self._equipState = false
end

function QUIWidgetSparBackPackInfo:onEnter()
    self:setScrollView()
end

function QUIWidgetSparBackPackInfo:onExit()
end

function QUIWidgetSparBackPackInfo:setScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	if self._scrollView == nil then
		self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {sensitiveDistance = 10})
		self._scrollView:setVerticalBounce(true)

	    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
	    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
	end
end

function QUIWidgetSparBackPackInfo:setItemId(itemId, selectTab, sparInfo)
	self._itemId = itemId
	self._selectTab = selectTab
	local sparProp = {}
	local suit = {}

	-- set item info
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	if itemInfo == nil then return end

	if self._sparItem == nil then
		self._sparItem = QUIWidgetSparBox.new()
		self._ccbOwner.node_icon:addChild(self._sparItem)
	end
	if self._item == nil then
		self._item = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:addChild(self._item)
	end
	
	if self._selectTab == "TAB_SPAR" then
		self._sparItem:setVisible(true)
		self._item:setVisible(false)
		self._sparInfo = sparInfo or {}
		sparProp = self._sparInfo.prop
		suit = remote.spar:getSparSuitInfosBySparId(self._itemId, 0)
		self._sparItem:setGemstoneInfo(self._sparInfo)
		self._sparItem:setName("")

		if self._sparInfo.actorId ~= nil and self._sparInfo.actorId ~= 0 then
			local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._sparInfo.actorId)
			self._ccbOwner.tf_num:setString(heroInfo.name.."装备")
			self._equipState = true
		else
			self._ccbOwner.tf_num:setString("未装备")
			self._equipState = false
		end
		self._ccbOwner.tf_type_name:setString("强化经验:")
		self._ccbOwner.tf_type:setString(self._sparInfo.exp or "")
		self._ccbOwner.tf_type:setPositionX(50)

		self._ccbOwner.node_money:setVisible(false)
	elseif self._selectTab == "TAB_SPAR_PIECE" then
		self._sparItem:setVisible(false)
		self._item:setVisible(true)

		local info = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
		sparProp = remote.spar:countSparProp({itemId = info.item_id, grade = 0, level = 1}).prop
		
		suit = remote.spar:getSparSuitInfosBySparId(info.item_id, 0)

		self._ccbOwner.tf_content:setString("拥有:")
		local itemNum = remote.items:getItemsNumByID(self._itemId)
		self._ccbOwner.tf_num:setString(itemNum or 0)

		self._ccbOwner.node_money:setVisible(true)
		self._ccbOwner.tf_money:setString(info.price or 0)
		if info.price > remote.user.money then
			self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
		else
			self._ccbOwner.tf_money:setColor(ccc3(66, 13, 0))
		end

		self._ccbOwner.tf_type_name:setString("")
		self._ccbOwner.tf_type:setString("")

		self._item:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0, false)
	end

	self._ccbOwner.tf_name:setString(itemInfo.name or "")
	
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[EQUIPMENT_QUALITY[itemInfo.colour]]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

	-- sparProp = self:setPiecePropInfo(sparProp)
	sparProp = remote.spar:setPropInfo(sparProp , true)
	self:setDetailInfo(sparProp, suit)
	self:setBtnState()

	self:checkRedTip()
end

function QUIWidgetSparBackPackInfo:setDetailInfo(sparProp, suit)
	self._scrollView:runToTop()

	if self._detailInfo == nil then
		self._detailInfo = QUIWidgetSparBackPackInfoClient.new()
		self._scrollView:addItemBox(self._detailInfo)
	end
	self._detailInfo:setDetailInfo(sparProp, suit)
	local contentSize = self._detailInfo:getContentSize()
	self._detailInfo:setPositionX(contentSize.width/2 - 20)
	self._scrollView:setRect(0, -contentSize.height-20, 0, contentSize.width/2)

	local siutClient = self._detailInfo:getSuitClient()
	for _, value in pairs(siutClient) do
		value:addEventListener(QUIWidgetSparBackPackInfoClientSuitClient.EVENT_CLICK_BOX, handler(self, self._onEvent))
		value:addEventListener(QUIWidgetSparBackPackInfoClientSuitClient.EVENT_SKILL, handler(self, self._onEvent))
	end
end

function QUIWidgetSparBackPackInfo:_onEvent(event)
	if self._isMoving then return end

	if event.name == QUIWidgetSparBackPackInfoClientSuitClient.EVENT_CLICK_BOX then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemId, nil, nil, false)
	elseif event.name == QUIWidgetSparBackPackInfoClientSuitClient.EVENT_SKILL then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparGradeSkillDetail",
	    	options = {suitInfo = event.suitInfo, minGrade = event.minGrade}})
	end
end

function QUIWidgetSparBackPackInfo:_onScrollViewMoving()
	self._isMoving = true
end

function QUIWidgetSparBackPackInfo:_onScrollViewBegan()
	self._isMoving = false
end

function QUIWidgetSparBackPackInfo:setBtnState()
	if self._selectTab == "TAB_SPAR" then
		if self._equipState then
			self._ccbOwner.tf_compose:setString("查看")
		else
			self._ccbOwner.tf_compose:setString("装备")
		end
	else
		self._ccbOwner.tf_compose:setString("合成")
	end
end

function QUIWidgetSparBackPackInfo:checkRedTip()
	local isShowTips = false
	if self._selectTab == "TAB_SPAR_PIECE" then
		local sparInfo = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
		isShowTips = remote.items:getItemsNumByID(self._itemId) >= sparInfo.component_num_1 and remote.user.money > sparInfo.price
	end
	self._ccbOwner.compose_tips:setVisible(isShowTips)
end

function QUIWidgetSparBackPackInfo:addProp(prop1, prop2)
	local propInfo = {}
	for name,filed in pairs(QActorProp._field) do
		if prop1[name] ~= nil or prop2[name] ~= nil then
			if propInfo[name] == nil then
				propInfo[name] = (prop1[name] or 0) + (prop2[name] or 0)
			else
				propInfo[name] = propInfo[name] + (prop1[name] or 0) + (prop2[name] or 0)
			end
		end
	end
	return propInfo
end 

-- function QUIWidgetSparBackPackInfo:setPiecePropInfo(itemInfo)
-- 	local prop = {}
-- 	local index = 1
-- 	if itemInfo.attack_value and itemInfo.attack_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.attack_value
-- 		prop[index].name = "攻击"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.attack_percent and itemInfo.attack_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.attack_percent * 100).."%"
-- 		prop[index].name = "攻击"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.hp_value and itemInfo.hp_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.hp_value
-- 		prop[index].name = "生命"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.hp_percent and itemInfo.hp_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.hp_percent * 100).."%"
-- 		prop[index].name = "生命"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_physical and itemInfo.armor_physical > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.armor_physical
-- 		prop[index].name = "物防"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_physical_percent and itemInfo.armor_physical_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.armor_physical_percent * 100).."%"
-- 		prop[index].name = "物防"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_magic and itemInfo.armor_magic > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.armor_magic
-- 		prop[index].name = "法防"
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_magic_percent and itemInfo.armor_magic_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.armor_magic_percent * 100).."%"
-- 		prop[index].name = "法防"
-- 		index = index + 1
-- 	end

-- 	return prop 
-- end 

function QUIWidgetSparBackPackInfo:_onTirggerRecyle(e)
	if q.buttonEventShadow(e, self._ccbOwner.button_recyle) == false then return end
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	
	if app.unlock:checkLock("UNLOCK_ZHUBAO", true) == false then
		local config = app.unlock:getConfigByKey("UNLOCK_ZHUBAO")
		app.tip:floatTip("外附魂骨功能将在"..config.team_level.."级开启，魂师大人努力提示自己吧！")
		return
	end

	if self._selectTab == "TAB_SPAR" then
		if remote.spar:checkSparIsInitial(self._sparInfo) == true then
			app.tip:floatTip("魂师大人，这个外附魂骨已经是初始状态，不需要重生了～")
			return
		end
		if self._equipState == false then
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", 
				options = {tab = "sparReborn", sparInfo = self._sparInfo}})
		else
			app.tip:floatTip("装备中无法回收")
		end
	else
		if remote.items:getItemsNumByID(self._itemId) <= 0 then
			app.tip:floatTip("没有碎片可以回收")
			return 
		end
		local  config = db:getItemByID(self._itemId)
		if not config.item_recycle then
			app.tip:floatTip("SS碎片无法回收")
			return 
		end
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", 
			options = {tab = "sparPieceReborn", itemId = self._itemId}})
	end
end

function QUIWidgetSparBackPackInfo:_onTirggerCompose(e)
	if q.buttonEventShadow(e, self._ccbOwner.button_compose) == false then return end
	if e ~= nil then
		app.sound:playSound("common_small")
	end

	if app.unlock:checkLock("UNLOCK_ZHUBAO", true) == false then
		local config = app.unlock:getConfigByKey("UNLOCK_ZHUBAO")
		app.tip:floatTip("外附魂骨功能将在"..config.team_level.."级开启，魂师大人努力提示自己吧！")
		return
	end

	if self._selectTab == "TAB_SPAR" then
		local sparInfo, index = remote.spar:getSparsIndexBySparId(self._sparInfo.sparId)
		if self._equipState then
			local heros = remote.herosUtil:getHaveHero()
			local pos = 1
			for i = 1, #heros do
				if heros[i] == self._sparInfo.actorId then
					pos = i
					break
				end
			end
	        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSparDetail", 
	            options = {index = index, heros = heros, pos = pos, initTab = QUIDialogHeroSparDetail.TAB_DETAIL}})
			return 
		else
			local heroId = self:checkHeroSpar(index)
			if heroId == nil then
				app.tip:floatTip("当前没有魂师可以装备此魂骨")
				return
			end
			local heros = remote.herosUtil:getHaveHero()
			local pos = 1
			for i = 1, #heros do
				if heros[i] == heroId then
					pos = i
					break
				end
			end
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
				options = {hero = heros, pos = pos, isQuickWay = true, swtichState = true}})
		end
	else
		local craftInfo = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
		if craftInfo.item_id == nil then return end

		if (craftInfo.component_num_1 or 0) > remote.items:getItemsNumByID(self._itemId) then
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, craftInfo.component_id_1, nil, nil, false)
			return 
		end
		if (craftInfo.price or 0) > remote.user.money then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
			return 
		end

		self:setItemId(self._itemId, self._selectTab)

		self:dispatchEvent({name = QUIWidgetSparBackPackInfo.CLICK_COMPOSE, itemId = craftInfo.item_id})
	end
end

function QUIWidgetSparBackPackInfo:checkHeroSpar(index)
	local heroInfos, count = remote.herosUtil:getMaxForceHeros()
	for i = 1, #heroInfos do
		local heroModel = remote.herosUtil:getUIHeroByID(heroInfos[i].id)
		if heroModel:checkSparCanWear(index) then
			return heroInfos[i].id
		end
	end
	return nil
end

return QUIWidgetSparBackPackInfo