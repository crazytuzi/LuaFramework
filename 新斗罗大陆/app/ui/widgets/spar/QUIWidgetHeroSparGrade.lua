-- @Author: xurui
-- @Date:   2017-04-07 16:12:37
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-22 16:49:22
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparGrade = class("QUIWidgetHeroSparGrade", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetSparBox = import("...widgets.spar.QUIWidgetSparBox")
local QQuickWay = import("....utils.QQuickWay")
local QUIWidgetHeroSparMaxLevel = import("...widgets.spar.QUIWidgetHeroSparMaxLevel")
local QUIHeroModel = import("....models.QUIHeroModel")

function QUIWidgetHeroSparGrade:ctor(options)
	local ccbFile = "ccb/Widget_spar_grade.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerEvolution", callback = handler(self, QUIWidgetHeroSparGrade._onTriggerGrade)},
	}
	QUIWidgetHeroSparGrade.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self.materials = {}
	self._sparItem = {}
end

function QUIWidgetHeroSparGrade:onEnter()
	if self._dialog ~= nil then
		self._dialog:removeAllEventListeners()
		self._dialog = nil
	end

	for i = 1, 4 do
		self._ccbOwner["tf_old_name"..i]:setVisible(false)
		self._ccbOwner["tf_old_value"..i]:setVisible(false)
		self._ccbOwner["tf_new_name"..i]:setVisible(false)
		self._ccbOwner["tf_new_value"..i]:setVisible(false)
	end
end

function QUIWidgetHeroSparGrade:onExit()
end

function QUIWidgetHeroSparGrade:setInfo(actorId, sparId, index)
	self._actorId = actorId
	self._sparId = sparId
	self._index = index
	
	self._ccbOwner.tf_button_name:setString("升 星")
	self._ccbOwner.tf_title:setString("升星所需")

	local heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self.sparInfo = heroUIModel:getSparInfoByPos(self._index).info

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.sparInfo.itemId)

	local gradeConfig1 = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.sparInfo.itemId, self.sparInfo.grade)
	local gradeConfig2 = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.sparInfo.itemId, self.sparInfo.grade+1)

	if gradeConfig2 == nil then--已经升星到顶级了
		self._ccbOwner.node_composite:setVisible(false)
		self._ccbOwner.tf_break_tips:setVisible(false)
		if self._maxWidget == nil then
			self._maxWidget = QUIWidgetHeroSparMaxLevel.new()
			self:getView():addChild(self._maxWidget)
		end
		self._maxWidget:setInfo(self._actorId, self._sparId, self._index, "grade")
		return
	end

	self._ccbOwner.node_composite:setVisible(true)
	if self._maxWidget ~= nil then
		self._maxWidget:removeFromParent()
		self._maxWidget = nil
	end

	self._ccbOwner.node_composite:setVisible(true)
	self._ccbOwner.tf_break_tips:setVisible(false)
	self._needMoney = gradeConfig2.money
	self._ccbOwner.tf_money:setString(self._needMoney)
	if self._needMoney > remote.user.money then
		self._ccbOwner.tf_money:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_money:setColor(COLORS.k)
	end
	local index = 1
	index = self:setOldTFValue("生    命:", math.floor(gradeConfig1.hp_value or 0), index)
	index = self:setOldTFValue("攻    击:", math.floor(gradeConfig1.attack_value or 0), index)
	index = self:setOldTFValue("物理防御:", math.floor(gradeConfig1.armor_physical or 0), index)
	index = self:setOldTFValue("法术防御:", math.floor(gradeConfig1.armor_magic or 0), index)
	index = self:setOldTFValue("生命百分比:", (gradeConfig1.hp_percent or 0), index, true)
	index = self:setOldTFValue("攻击百分比:", (gradeConfig1.attack_percent or 0), index, true)
	index = self:setOldTFValue("物防百分比:", (gradeConfig1.armor_physical_percent or 0), index, true)
	index = self:setOldTFValue("法防百分比:", (gradeConfig1.armor_magic_percent or 0), index, true)

	if self._oldItemAvatar == nil then
		self._oldItemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_old_icon:addChild(self._oldItemAvatar)
	end
	self._oldItemAvatar:setSparInfo(itemConfig, 19)
	self._oldItemAvatar:setStar(self.sparInfo.grade)

	local index = 1
	index = self:setNewTFValue("生    命:", math.floor(gradeConfig2.hp_value or 0), index)
	index = self:setNewTFValue("攻    击:", math.floor(gradeConfig2.attack_value or 0), index)
	index = self:setNewTFValue("物理防御:", math.floor(gradeConfig2.armor_physical or 0), index)
	index = self:setNewTFValue("法术防御:", math.floor(gradeConfig2.armor_magic or 0), index)
	index = self:setNewTFValue("生命百分比:", (gradeConfig2.hp_percent or 0), index, true)
	index = self:setNewTFValue("攻击百分比:", (gradeConfig2.attack_percent or 0), index, true)
	index = self:setNewTFValue("物防百分比:", (gradeConfig2.armor_physical_percent or 0), index, true)
	index = self:setNewTFValue("法防百分比:", (gradeConfig2.armor_magic_percent or 0), index, true)

	if self._newItemAvatar == nil then
		self._newItemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_new_icon:addChild(self._newItemAvatar)
	end
	self._newItemAvatar:setSparInfo(itemConfig, 19)
	self._newItemAvatar:setStar(self.sparInfo.grade+1)

	--突破所需材料
	local items = {}
	if gradeConfig2.soul_gem ~= nil then
		table.insert(items, {info = {itemId = gradeConfig2.soul_gem, grade = 0, content = ""}, needNum = gradeConfig2.soul_gem_count})
	end
	local posX = -(#items - 1) * 153/2

	for i = 1, #items do
		if self._sparItem[i] == nil then
			self._sparItem[i] = QUIWidgetSparBox.new()
			self._ccbOwner.node_item:addChild(self._sparItem[i])
			self._sparItem[i]:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self._itemClickHandler))
			self._sparItem[i]:setScale(0.8)
		end
		self._sparItem[i]:setPositionX(posX)
		self._sparItem[i]:setGemstoneInfo(items[i].info, self._index)
		local haveNum, isStrength = remote.spar:checkSparCanUpGrade(self.sparInfo.sparId, self._index)
		self._sparItem[i]:setName(haveNum.."/"..(items[i].needNum or 0), 1.2)
		self._sparItem[i]:setNamePositionOffset(0, -10)
		
		posX = posX + 153

		if haveNum >= items[i].needNum then
			self._sparItem[i]:setNameColor(UNITY_COLOR.green)
		else
			self._sparItem[i]:setNameColor(UNITY_COLOR.red)
		end
	end
	self._needMateril = items[1]
end

function QUIWidgetHeroSparGrade:setOldTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_old_name"..index] ~= nil then
		self._ccbOwner["tf_old_name"..index]:setString(title)
		self._ccbOwner["tf_old_name"..index]:setVisible(true)
		self._ccbOwner["tf_old_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_old_value"..index]:setString(string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_old_value"..index]:setString(value)
		end
	end
	return index+1
end

function QUIWidgetHeroSparGrade:setNewTFValue(title, value, index, isPercent)
	if value == 0 then return index end
	if self._ccbOwner["tf_new_name"..index] ~= nil then
		self._ccbOwner["tf_new_name"..index]:setString(title)
		self._ccbOwner["tf_new_name"..index]:setVisible(true)
		self._ccbOwner["tf_new_value"..index]:setVisible(true)
		if isPercent == true then
			self._ccbOwner["tf_new_value"..index]:setString(string.format("%0.1f%%",value*100))
		else
			self._ccbOwner["tf_new_value"..index]:setString(value)
		end
	end
	return index+1
end

function QUIWidgetHeroSparGrade:resetAll()
	if self.materials ~= nil and #self.materials > 0 then
		for _,item in ipairs(self.materials) do
			item:removeAllEventListeners()
			item:removeFromParent()
		end
		self.materials = {}
	end
	self._needMoney = 0
	self._isMaterilEnough = true
	self._ccbOwner.node_old_icon:removeAllChildren()
	self._ccbOwner.node_new_icon:removeAllChildren()

	local index = 1
	while true do
		if self._ccbOwner["tf_old_name"..index] ~= nil and self._ccbOwner["tf_new_name"..index] ~= nil then
			self._ccbOwner["tf_old_name"..index]:setString("")
			self._ccbOwner["tf_old_value"..index]:setString("")
			self._ccbOwner["tf_new_name"..index]:setString("")
			self._ccbOwner["tf_new_value"..index]:setString("")
		else
			break
		end
		index = index + 1
	end
end

function QUIWidgetHeroSparGrade:_onTriggerGrade(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_break) == false then return end
	if self._needMoney > remote.user.money then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
		return
	end

	local haveNum, isStrength, strengthCount = remote.spar:checkSparCanUpGrade(self.sparInfo.sparId, self._index)
	if haveNum < self._needMateril.needNum then
		local pieceInfo = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._needMateril.info.itemId)
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack", 
					options = {tab = "TAB_SPAR_PIECE", selectItem = pieceInfo.component_id_1}})
		return 
	end

	if isStrength then
    	app:alert({content="升星所用的一星外附魂骨中有"..strengthCount.."个被强化，继续升星则自动将强化经验转换成强化材料放进背包，是否继续升星？", 
    			btnDesc = {"升 星"}, title = "系统提示", callback = handler(self, self._upgrade) })
    else
    	self:_upgrade()
	end
end

function QUIWidgetHeroSparGrade:_upgrade(callType)
	if callType == nil or callType == ALERT_TYPE.CONFIRM then
		local oldSparInfo = self.sparInfo
		self._oldSuit = self:getSparInfoByActorId(self._actorId)
		remote.spar:requestSparUpgrade(self._sparId,function ()
				local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
				local newSparInfo = newUIModel:getSparInfoByPos(self._index).info
		    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroSparUpGradeSuccess", 
		        	options = {oldSparInfo = oldSparInfo, newSparInfo = newSparInfo, pos = self._index, actorId = self._actorId, callback = handler(self, self._checkSuitIsActive)}}, {isPopCurrentDialog = false})
	    	end)
	end
end

function QUIWidgetHeroSparGrade:_checkSuitIsActive()
    local suits = self:getSparInfoByActorId(self._actorId)
    local isHaveSuit = false
    if next(self._oldSuit) ~= nil then
		if self._oldSuit.id == suits.id and self._oldSuit.star_min == suits.star_min then
			isHaveSuit = true
		end
    end
    
    local successTip = app.master.SPAR_BREAK_TIP
    if next(suits) ~= nil and isHaveSuit == false and app.master:getMasterShowState(successTip) then
    	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparSuitActiveSuccess", 
            options = {suitInfo = suits,successTip = successTip, actorId = self._actorId}}, {isPopCurrentDialog = false})
    end
    
	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
end

function QUIWidgetHeroSparGrade:getSparInfoByActorId(actorId)
    local suits = {}
	local newUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local sparInfo1 = newUIModel:getSparInfoByPos(1).info
	local sparInfo2 = newUIModel:getSparInfoByPos(2).info
	local minGrade = newUIModel:getHeroSparMinGrade()
	if sparInfo1 ~= nil and sparInfo2 ~= nil then
		suits = QStaticDatabase:sharedDatabase():getActiveSparSuitInfoBySparId(sparInfo1.itemId, sparInfo2.itemId, minGrade)
	end
	return suits
end

function QUIWidgetHeroSparGrade:_itemClickHandler(event)
	app.sound:playSound("common_item")

	local pieceInfo = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._needMateril.info.itemId)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGemstoneBackpack", 
			options = {tab = "TAB_SPAR_PIECE", selectItem = pieceInfo.component_id_1}})
end

return QUIWidgetHeroSparGrade