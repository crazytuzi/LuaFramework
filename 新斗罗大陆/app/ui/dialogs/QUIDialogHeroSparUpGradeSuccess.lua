-- @Author: xurui
-- @Date:   2017-04-07 18:50:43
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 17:10:48
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSparUpGradeSuccess = class("QUIDialogHeroSparUpGradeSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogHeroSparUpGradeSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SparGradeSuccess.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, QUIDialogHeroSparUpGradeSuccess._onTriggerClose)},
	}
	QUIDialogHeroSparUpGradeSuccess.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    self.isAnimation = true --是否动画显示
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(false)

    self._isEnd = false
	self.actorId = options.actorId
	self.callback = options.callback
	self.oldSparInfo = options.oldSparInfo
	self.newSparInfo = options.newSparInfo
	self._index = options.index

	self._oldProp = {}
	self._newProp = {}
	self._needPlusProp = false
	app.sound:playSound("task_complete")
end

function QUIDialogHeroSparUpGradeSuccess:viewDidAppear()
	QUIDialogHeroSparUpGradeSuccess.super.viewDidAppear(self)

	self:setOldSparInfo()

	self:setNewSparInfo()
	self._animationStage = "1"
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
end

function QUIDialogHeroSparUpGradeSuccess:viewWillDisappear()
	QUIDialogHeroSparUpGradeSuccess.super.viewWillDisappear(self)
end

function QUIDialogHeroSparUpGradeSuccess:viewAnimationEndHandler(name)
	if self._needPlusProp then
		self._animationStage = name
	else
		self._isEnd = true
	end
end

function QUIDialogHeroSparUpGradeSuccess:setOldSparInfo()
	if self._sparOldItem == nil then
		self._sparOldItem = QUIWidgetSparBox.new()
		self._ccbOwner.old_head:addChild(self._sparOldItem)
	end
	self._sparOldItem:setGemstoneInfo(self.oldSparInfo, self._index)
	self._sparOldItem:setName("")
	self._sparOldItem:setStrengthVisible(false)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.oldSparInfo.itemId)
	self._ccbOwner.oldName:setString(itemConfig.name or "")

	local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.oldSparInfo.itemId, self.oldSparInfo.grade)

	-- self._oldProp = self:checkProp(gradeConfig)
	self._oldProp = remote.spar:setPropInfo(gradeConfig)

	for i = 1, 8 do
		if self._oldProp[i] then
			self._ccbOwner["node_title_"..i]:setString(self._oldProp[i].name.."：")
			self._ccbOwner["tf_old_value_"..i]:setString(self._oldProp[i].value)
		else
			self._ccbOwner["tf_old_value_"..i]:setString(0)
		end
	end
end

function QUIDialogHeroSparUpGradeSuccess:setNewSparInfo()
	if self._sparNewItem == nil then
		self._sparNewItem = QUIWidgetSparBox.new()
		self._ccbOwner.new_head:addChild(self._sparNewItem)
	end
	self._sparNewItem:setGemstoneInfo(self.newSparInfo, self._index)
	self._sparNewItem:setName("")
	self._sparNewItem:setStrengthVisible(false)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self.newSparInfo.itemId)
	self._ccbOwner.newName:setString(itemConfig.name or "")

	local gradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.oldSparInfo.itemId, self.newSparInfo.grade)

	-- self._newProp = self:checkProp(gradeConfig)
	self._newProp = remote.spar:setPropInfo(gradeConfig)
	
	self._needPlusProp = #self._newProp > 4 
	for i = 1, 8 do
		if self._newProp[i] then
			self._ccbOwner["tf_new_value_"..i]:setString(self._newProp[i].value)
		else
			self._ccbOwner["node_prop_"..i]:setVisible(false)
		end
	end
end

-- function QUIDialogHeroSparUpGradeSuccess:checkProp(itemInfo)
-- 	local prop = {}
-- 	local index = 1
-- 	if itemInfo.attack_value and itemInfo.attack_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "attack"
-- 		prop[index].value = itemInfo.attack_value
-- 		prop[index].name = "攻    击："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.hp_value and itemInfo.hp_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "hp"
-- 		prop[index].value = itemInfo.hp_value
-- 		prop[index].name = "生    命："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_physical and itemInfo.armor_physical > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "armor_physical"
-- 		prop[index].value = itemInfo.armor_physical
-- 		prop[index].name = "物    防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_magic and itemInfo.armor_magic > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "armor_magic"
-- 		prop[index].value = itemInfo.armor_magic
-- 		prop[index].name = "法    防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.hp_percent and itemInfo.hp_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.hp_percent * 100).."%"
-- 		prop[index].name = "生命百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.attack_percent and itemInfo.attack_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.attack_percent * 100).."%"
-- 		prop[index].name = "攻击百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_physical_percent and itemInfo.armor_physical_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.armor_physical_percent * 100).."%"
-- 		prop[index].name = "物防百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_magic_percent and itemInfo.armor_magic_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.armor_magic_percent * 100).."%"
-- 		prop[index].name = "法防百分比："
-- 		index = index + 1
-- 	end


-- 	--全队属性
-- 	if itemInfo.team_hp_value and itemInfo.team_hp_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_hp_value"
-- 		prop[index].value = itemInfo.team_hp_value
-- 		prop[index].name = "全队生命："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_hp_percent and itemInfo.team_hp_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_hp_percent"
-- 		prop[index].value = (itemInfo.team_hp_percent * 100).."%"
-- 		prop[index].name = "全队生命百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_attack_value and itemInfo.team_attack_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_attack_value"
-- 		prop[index].value =itemInfo.team_attack_value
-- 		prop[index].name = "全队攻击："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_attack_percent and itemInfo.team_attack_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_attack_percent"
-- 		prop[index].value = (itemInfo.team_attack_percent * 100).."%"
-- 		prop[index].name = "全队攻击百分比："
-- 		index = index + 1
-- 	end


-- 	if itemInfo.team_armor_physical and itemInfo.team_armor_physical > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_physical"
-- 		prop[index].value = itemInfo.team_armor_physical
-- 		prop[index].name = "全队物防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_armor_physical_percent and itemInfo.team_armor_physical_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_physical_percent"
-- 		prop[index].value = (itemInfo.team_armor_physical_percent * 100).."%"
-- 		prop[index].name = "全队物防百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_armor_magic and itemInfo.team_armor_magic > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_magic"
-- 		prop[index].value =itemInfo.team_armor_magic
-- 		prop[index].name = "全队法防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_armor_magic_percent and itemInfo.team_armor_magic_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_magic_percent"
-- 		prop[index].value = (itemInfo.team_armor_magic_percent * 100).."%"
-- 		prop[index].name = "全队法防百分比："
-- 		index = index + 1
-- 	end
-- 	return prop 
-- end

function QUIDialogHeroSparUpGradeSuccess:getLevel()
	local heroInfos = remote.herosUtil:getHeroByID(self.actorId)
	return heroInfos.level
end

function QUIDialogHeroSparUpGradeSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHeroSparUpGradeSuccess:_onTriggerClose()
	print("self._animationStage = "..self._animationStage )
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "2"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			self._animationStage = "2"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "2" then
			self._animationStage = "3"
			self._animationManager:runAnimationsForSequenceNamed("3")	
		else
			self._animationStage = "4"
			self._animationManager:runAnimationsForSequenceNamed("4")
			self._isEnd = true
		end
	end
end

function QUIDialogHeroSparUpGradeSuccess:viewAnimationOutHandler()
	local callback = self.callback
	self:popSelf()
    if callback ~= nil then
    	callback()
    end
end


return QUIDialogHeroSparUpGradeSuccess