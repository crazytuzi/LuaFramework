--
-- Author: Your Name
-- Date: 2015-08-05 10:38:09
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogEquipmentBreakthroughSuccess = class("QUIDialogEquipmentBreakthroughSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetEquipmentBox = import("..widgets.QUIWidgetEquipmentBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIDialogEquipmentBreakthroughSuccess:ctor(options)
	local ccbFile = "ccb/effects/herobreakthough.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
	QUIDialogEquipmentBreakthroughSuccess.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	self.isAnimation = true
	self._isEnd = false
	self._isSaying = false

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:connectScriptHandler(function()
			if self._isEnd == false then
				self._isEnd = true
				QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_EQUIPMENT_BREAKTHROUGH})
			end
		end)
	self._animationManager:runAnimationsForSequenceNamed("one")

	self:resetAll()
	if options ~= nil then 
		self._oldUIModel = options.oldUIModel
		self._newUIModel = options.newUIModel
		self._equipmentPos = options.pos
		self._masterUpGrade = options.masterUpGrade
		self._masterType = options.masterType
		self._successTip = options.successTip
	end
	app.sound:playSound("equipment_breakthrough")
	if self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY1 and  self._equipmentPos ~= EQUIPMENT_TYPE.JEWELRY2 then
		dialog:locking()
	end

	self:setBreakthroughInfo()

    self._isSelected = false
    self:showSelectState()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())

    app.nociceNode:setVisible(false)
end

function QUIDialogEquipmentBreakthroughSuccess:viewDidAppear()
	QUIDialogEquipmentBreakthroughSuccess.super.viewDidAppear(self)
end

function QUIDialogEquipmentBreakthroughSuccess:viewWillDisappear()
	QUIDialogEquipmentBreakthroughSuccess.super.viewWillDisappear(self)
	self._animationManager:disconnectScriptHandler()
	if self._itemEffectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._itemEffectScheduler)
		self._itemEffectScheduler = nil
	end

	if self._itemEffect ~= nil then
		self._itemEffect:disappear()
		self._itemEffect = nil
	end
end

function QUIDialogEquipmentBreakthroughSuccess:resetAll()
	for i = 1, 4, 1 do
		self._ccbOwner["name"..i]:setString("")
		self._ccbOwner["old_prop"..i]:setString("")
		self._ccbOwner["new_prop"..i]:setString("")
		self._ccbOwner["add_prop"..i]:setString("")
		self._ccbOwner["arrow"..i]:setVisible(false)
	end
end

function QUIDialogEquipmentBreakthroughSuccess:setBreakthroughInfo()

	local oldEquipmentInfo = self._oldUIModel:getEquipmentInfoByPos(self._equipmentPos)
	local actorId = self._oldUIModel:getHeroInfo().actorId
	local enchant = oldEquipmentInfo.info.enchants
	local newEquipmentInfo = self._newUIModel:getEquipmentInfoByPos(self._equipmentPos)
	local oldItemConfig = QStaticDatabase:sharedDatabase():getItemByID(oldEquipmentInfo.info.itemId)
	local newItemConfig = QStaticDatabase:sharedDatabase():getItemByID(newEquipmentInfo.info.itemId)
	self._cls = QUIWidgetEquipmentBox
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		self._cls = QUIWidgetEquipmentSpecialBox
	end
	local itemBox = self._cls.new()
	itemBox:setEquipmentInfo(oldItemConfig, actorId)
	itemBox:setEvolution(oldEquipmentInfo.breakLevel)
	itemBox:showStrengthenLevelIcon(false, 0)
	itemBox:showEnchantIcon(true, enchant or 0, 0.7)
	self._ccbOwner.old_head:addChild(itemBox)
	-- set old item name
	local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(actorId, oldItemConfig.id)
	local level, color = remote.herosUtil:getBreakThrough(breaklevel) 
	local name = oldItemConfig.name
	if level > 0 then
		name = name .. "＋".. level
	end
	self._ccbOwner["oldName"]:setString(name)
	self._ccbOwner["oldName"]:setColor(UNITY_COLOR_LIGHT[color])

	local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(actorId, newItemConfig.id)
	local level, color = remote.herosUtil:getBreakThrough(breaklevel) 
	local selectItemBox = self._cls.new()
	selectItemBox:showStrengthenLevelIcon(false, 0)
	selectItemBox:showEnchantIcon(true, enchant or 0, 0.7)

	-- set new item name	
	--xurui: 突破时添加钻石特效，装备名打字效果
	self._newName = newItemConfig.name
	self._newLevel = level
	self._ccbOwner["newName"]:setString("")

	selectItemBox:setEquipmentInfo(newItemConfig, actorId)
	if level > 0 then
		self._newName = self._newName .." + "..level
		selectItemBox:setEvolution(newEquipmentInfo.breakLevel)
		self:setItemBoxEffect(selectItemBox, color)
	else
		selectItemBox:setEvolution(oldEquipmentInfo.breakLevel)
		self._ccbOwner.new_head:addChild(selectItemBox)
	end

	self._isSaying = true
	self._itemEffectScheduler = scheduler.performWithDelayGlobal(function()
			self:typeWriter(self._ccbOwner["newName"])
			if level == 0 then
				self:itemFrameEffect(breaklevel, color, selectItemBox)
			end
		end, 1.0)
	self._ccbOwner["newName"]:setColor(UNITY_COLOR_LIGHT[color])

	local itemInfo = oldItemConfig
	self._index = 1
	self:setTFValue("生    命", math.floor(itemInfo.hp_value or 0), math.floor((newItemConfig.hp_value or 0) - (oldItemConfig.hp_value or 0)))
	self:setTFValue("攻    击", math.floor(itemInfo.attack_value or 0), math.floor((newItemConfig.attack_value or 0) - (oldItemConfig.attack_value or 0)))
	self:setTFValue("命    中", math.floor(itemInfo.hit_rating or 0), math.floor((newItemConfig.hit_rating or 0) - (oldItemConfig.hit_rating or 0)))
	self:setTFValue("闪    避", math.floor(itemInfo.dodge_rating or 0), math.floor((newItemConfig.dodge_rating or 0) - (oldItemConfig.dodge_rating or 0)))
	self:setTFValue("暴    击", math.floor(itemInfo.critical_rating or 0), math.floor((newItemConfig.critical_rating or 0) - (oldItemConfig.critical_rating or 0)))
	self:setTFValue("格    挡", math.floor(itemInfo.block_rating or 0), math.floor((newItemConfig.block_rating or 0) - (oldItemConfig.block_rating or 0)))
	self:setTFValue("急    速", math.floor(itemInfo.haste_rating or 0), math.floor((newItemConfig.haste_rating or 0) - (oldItemConfig.haste_rating or 0)))
	self:setTFValue("物理防御", math.floor(itemInfo.armor_physical or 0), math.floor((newItemConfig.armor_physical or 0) - (oldItemConfig.armor_physical or 0)))
	self:setTFValue("法术防御", math.floor(itemInfo.armor_magic or 0), math.floor((newItemConfig.armor_magic or 0) - (oldItemConfig.armor_magic or 0)))
	self:setTFValue("生命增加", (itemInfo.hp_percent or 0), (newItemConfig.hp_percent or 0) - (oldItemConfig.hp_percent or 0), true)
	self:setTFValue("攻击增加", (itemInfo.attack_percent or 0), (newItemConfig.attack_percent or 0) - (oldItemConfig.attack_percent or 0), true)

	self._ccbOwner.break_node:setVisible(false) 
end

function QUIDialogEquipmentBreakthroughSuccess:setTFValue(name, value, addValue, isPercent)
	if self._index > 4 then return end
	if value == nil then value = 0 end
	if addValue ~= nil then
		if type(addValue) ~= "number" or addValue > 0 then
			if self._ccbOwner["name"..self._index] ~= nil then
				self._ccbOwner["name"..self._index]:setString(name.."：")
				if isPercent == true then
					self._ccbOwner["old_prop"..self._index]:setString(string.format("  %.2f%%",value*100))
					self._ccbOwner["new_prop"..self._index]:setString(string.format("  %.2f%%",(value+addValue)*100))
					-- self._ccbOwner["add_prop"..self._index]:setString(string.format("（＋%.2f%%）",addValue*100))
				else
					self._ccbOwner["old_prop"..self._index]:setString("  "..value)
					self._ccbOwner["new_prop"..self._index]:setString("  "..value+addValue)
					-- self._ccbOwner["add_prop"..self._index]:setString("（＋"..addValue.."）")
				end
				self._ccbOwner["arrow"..self._index]:setVisible(true)
			end
			self._index = self._index + 1
		end
	end
end

function QUIDialogEquipmentBreakthroughSuccess:setItemBoxEffect(newHead, color)
	if self._newLevel == 0 then 
		return 
	end

	self._itemEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.new_head:addChild(self._itemEffect)

	local ccbFile = "ccb/effects/HeroItemzuan"..self._newLevel..".ccbi"
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		ccbFile = "ccb/effects/HeroShiPing"..self._newLevel..".ccbi"
	end

	local path = QResPath("equipment_evolution_icon_"..color)
	local displayFrame
	if path then
		displayFrame = QSpriteFrameByPath(path)
	end
  
	self._itemEffect:playAnimation(ccbFile, function()
			self._itemEffect._ccbOwner.node_item:addChild(newHead)
			local index = 1 
			if displayFrame then
				while self._itemEffect._ccbOwner["sp_icon_"..index] do
					self._itemEffect._ccbOwner["sp_icon_"..index]:setDisplayFrame(displayFrame)
					index = index + 1
				end
	    	end

			for i=1, self._newLevel, 1 do
				local timeHandler = scheduler.performWithDelayGlobal(function ()
					app.sound:playSound("common_star")
				end, 0.3*(i-1)+1.3)
			end
		end, function()
		end, false)
end

function QUIDialogEquipmentBreakthroughSuccess:itemFrameEffect(breaklevel, color, itemBox)
	local itemEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.new_head:addChild(itemEffect)
	local ccbFile = "ccb/effects/kuang_small.ccbi"
	itemEffect:playAnimation(ccbFile, function()	
			itemEffect._ccbOwner.node_equip_frame:setVisible(true)
			local effectName = "equip_effect_"
			if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
				itemEffect._ccbOwner.node_jewelry_frame:setVisible(true)
				itemEffect._ccbOwner.node_equip_frame:setVisible(false)
				effectName = "jewelry_effect_"
			end
			itemEffect._ccbOwner[effectName..color]:setVisible(true)

			scheduler.performWithDelayGlobal(function()
				itemBox:_hideAllColor()
				itemBox:setEvolution(breaklevel)
				app.sound:playSound("common_star")
			end, 1/6)
		end, function ()
		end)
end

function QUIDialogEquipmentBreakthroughSuccess:typeWriter(node)
	local delayTime = TUTORIAL_ONEWORD_TIME
	local word = ""
	local lineNum = 1
	local sayPosition = 1
	local startPosition = 1
	self._func = function()
		if self._isSaying == true then
			local c = string.sub(self._newName,sayPosition,sayPosition)
			local b = string.byte(c)
			local str = c
			if b > 128 then
				str = string.sub(self._newName,sayPosition,sayPosition + 2)
				sayPosition = sayPosition + 2
				word =  word .. str
			else
				word =  word .. c
			end
			sayPosition = sayPosition + 1
			node:setString(word)
		end
		if sayPosition <= #self._newName then
			self._time = scheduler.performWithDelayGlobal(self:safeHandler(handler(self, self._func)),delayTime)
		else
			self._isSaying = false
			if self._time ~= nil then
				scheduler.unscheduleGlobal(self._time)
				self._time = nil
			end
		end
	end
	self._func()
end

function QUIDialogEquipmentBreakthroughSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogEquipmentBreakthroughSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogEquipmentBreakthroughSuccess:_backClickHandler()
	if self._isEnd == false then 
		self._isEnd = true
    	self._animationManager:runAnimationsForSequenceNamed("two")
		return 
	end
	if self._isSaying == false then
		self:_onTriggerClose()
	end
end

function QUIDialogEquipmentBreakthroughSuccess:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogEquipmentBreakthroughSuccess:viewAnimationOutHandler()
	app.nociceNode:setVisible(true)

	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog ~= nil and dialog.class.__cname == "QUIDialogHeroEquipmentDetail" then
		dialog:_refreshBatlleForce( true )
	end
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end
	if self._masterUpGrade ~= nil then
		app.master:upGradeMaster(self._masterUpGrade, self._masterType)
	end
end

return QUIDialogEquipmentBreakthroughSuccess