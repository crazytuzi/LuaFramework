--
-- Author: xurui
-- Date: 2016-03-01 17:30:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogEquipmentEnchantSuccess = class("QUIDialogEquipmentEnchantSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetEquipmentSpecialBox = import("..widgets.QUIWidgetEquipmentSpecialBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QUIViewController = import("...ui.QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogEquipmentEnchantSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_HeroEnchantSuccess.ccbi" -- by kumo
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, QUIDialogEquipmentEnchantSuccess._onTriggerClose)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogEquipmentEnchantSuccess.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	if options then
		self._props = options.props
		self._callBack = options.callBack
		self._actorId = options.actorId
		self._itemId = options.itemId
		self._equipmentPos = options.equipmentPos
		self._successTip = options.successTip
	end

	self._ccbOwner.node_status2:setVisible(false)
	self._ccbOwner.btn_close:setVisible(false)

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

    self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)

	-- set equipment frame and name
	self:setEquipmentInfo()

	-- set equipment enchant prop 
	self:_setProps()

	self._isEnd = false

    self._isSelected = false
    self:showSelectState()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
end

function QUIDialogEquipmentEnchantSuccess:viewDidAppear()
	QUIDialogEquipmentEnchantSuccess.super.viewDidAppear(self)
end

function QUIDialogEquipmentEnchantSuccess:viewWillDisappear()
	QUIDialogEquipmentEnchantSuccess.super.viewWillDisappear(self)
	self._isExist = false
	if self._scheduler ~= nil then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	if self._effectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._effectScheduler)
		self._effectScheduler = nil
	end
	if self._itemEffect ~= nil then
		self._itemEffect:disappear()
		self._itemEffect = nil
	end
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end

	if self._itemEffectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._itemEffectScheduler)
		self._itemEffectScheduler = nil
	end
end

function QUIDialogEquipmentEnchantSuccess:setEquipmentInfo()
	local equipment = remote.herosUtil:getWearByItem(self._actorId, self._itemId)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	local heroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local equipmentInfo = heroModel:getEquipmentInfoByPos(self._equipmentPos)

	local oldItemBox = self:setEquipmentFrame(self._ccbOwner.old_head, itemConfig, equipment.enchants-1, equipmentInfo.breakLevel)
	local newItemBox = self:setEquipmentFrame(nil, itemConfig, 0, equipmentInfo.breakLevel)

	self._newHeadVibrate = QUIWidgetHeroHeadVibrate.new({star = equipment.enchants, head = newItemBox, isEquipment = true, iconPath = "ui/common/zuan_s.png"}) 
	self._ccbOwner.new_head:addChild(self._newHeadVibrate)
	self._effectScheduler = scheduler.performWithDelayGlobal(function ( ... )
		self._newHeadVibrate:playStarAnimation()
	end, 1.5)

	local level, color = remote.herosUtil:getBreakThrough(equipmentInfo.breakLevel or 0) 
	local name = itemConfig.name
	if level > 0 then
		name = name .. "＋".. level
	end
	self._ccbOwner.oldName:setString(name or "")
	self._ccbOwner.newName:setString(name or "")
	self._ccbOwner.oldName:setColor(UNITY_COLOR_LIGHT[color])
	self._ccbOwner.newName:setColor(UNITY_COLOR_LIGHT[color])

    -- set effect title
	-- self._ccbOwner.enchant:setVisible(true)
	-- self._ccbOwner.wake:setVisible(false)
    -- if equipment.enchants-1 ~= 0 and (equipment.enchants-1) % GRAD_MAX == 0 then
    -- 	self._ccbOwner.enchant:setVisible(false)
    -- 	self._ccbOwner.wake:setVisible(true)
    -- end
end

function QUIDialogEquipmentEnchantSuccess:setEquipmentFrame(node, itemConfig, enchantLevel, breakLevel)
	local cls = "QUIWidgetEquipmentBox"
	if self._equipmentPos == EQUIPMENT_TYPE.JEWELRY1 or self._equipmentPos == EQUIPMENT_TYPE.JEWELRY2 then
		cls = "QUIWidgetEquipmentSpecialBox"
	end
	local class = import(app.packageRoot .. ".ui.dialogs." .. cls)
	local itemBox = class.new()
	itemBox:setEquipmentInfo(itemConfig, self._actorId)
	itemBox:setEvolution(breakLevel or 0)
	itemBox:showStrengthenLevelIcon(false, 0)
	itemBox:showEnchantIcon(true, enchantLevel or 0, 0.7)
	if node ~= nil then
		node:addChild(itemBox)
	end

	return itemBox
end

function QUIDialogEquipmentEnchantSuccess:_setProps()
	for i = 1, 3, 1 do
		if self._props[1][i] ~= nil then
			local name = self._props[1][i].name or self._props[2][i].name
			self._ccbOwner["name_"..i]:setString(string.format("%s：", name))

			local value1 = self._props[1][i].value or 0
			local value2 = self._props[2][i].value or 0
			if name ~= nil and (name == "攻击百分比" or name == "生命百分比") then
				value1 = string.format("%0.1f%%", value1*100)
				value2 = string.format("%0.1f%%", value2*100)
			end
			self._ccbOwner["old_prop_"..i]:setString(value1)
			self._ccbOwner["new_prop_"..i]:setString(value2)
		else
			self._ccbOwner["prop_node_"..i]:setVisible(false)
		end
	end
end

function QUIDialogEquipmentEnchantSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogEquipmentEnchantSuccess:_getSkillIcon(enchant, level)
	local skillItemBox = nil
	if enchant.skill_show ~= nil then
		local skillData = QStaticDatabase:sharedDatabase():getSkillByID(enchant.skill_show)
		skillItemBox = QUIWidgetHeroSkillBox.new()
		if level % 2 == 1 then
			print("[Kumo] QUIDialogEquipmentEnchantSuccess:_getSkillIcon ", level, "orange")
			skillItemBox:setColor("orange")
		else
			print("[Kumo] QUIDialogEquipmentEnchantSuccess:_getSkillIcon ", level, "purple")
			skillItemBox:setColor("purple")
		end
		skillItemBox:setSkillID(enchant.skill_show)
		skillItemBox:setLock(false)
	end

	return skillItemBox
end

function QUIDialogEquipmentEnchantSuccess:skillHandler()
	self._animationStage = "3"
	local equipment = remote.herosUtil:getWearByItem(self._actorId, self._itemId)
	local enchantLevel = equipment.enchants
	local enchant = QStaticDatabase:sharedDatabase():getEnchant(self._itemId, enchantLevel , self._actorId)
	if enchant.skill_show then
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(enchant.skill_show)
		if skillConfig ~= nil then
			QPrintTable(skillConfig)
			self._animationManager:runAnimationsForSequenceNamed("3")
			self._ccbOwner.node_status2:setVisible(true)

			local skillIcon = self:_getSkillIcon(enchant, enchant.enchant_level)
			self._ccbOwner.node_icon:addChild(skillIcon)
			local actionArrayIn = CCArray:create()
			actionArrayIn:addObject(CCFadeIn:create(0.5))
			actionArrayIn:addObject(CCCallFunc:create(function ()
			  	self._actionHandler = nil
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "新天赋："..skillConfig.name, function ()
			  		local skillDesc = q.getSkillMainDesc(enchant.describe or "")
			  		skillDesc = QColorLabel.removeColorSign(skillDesc) 
			  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
						self._isEnd = true
			  		end)
			  	end)
			end))
			local ccsequence = CCSequence:create(actionArrayIn)
			self._actionHandler = self._ccbOwner.node_skill:runAction(ccsequence)
			return
		else 
			self._isEnd = true
			self:_onTriggerClose()
		end
	else
		self._isEnd = true
		self:_onTriggerClose()
	end
end

function QUIDialogEquipmentEnchantSuccess:wordTypewriterEffect(tf, word, callback)
	if tf == nil or word == nil then
		if callback ~= nil then callback() end
		return false
	end
	if self._typewriterCallback ~= nil then
		if callback ~= nil then callback() end
		return false
	end
	self._typewriterTF = tf
	self._typewriterWord = word
	self._typewriterCallback = callback

	self._sayPosition = 1
	self._typewriterSayWord = ""
	self._typewriterTF:setString(self._typewriterSayWord)
	self._delayTime = TUTORIAL_ONEWORD_TIME
	self._isExist = true

	if self._typewriterHandler == nil then
		self._typewriterHandler = function ()
			if self._isExist ~= true then return end
			local c = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition)
	        local b = string.byte(c) or 0
	        local str = c
	        if b > 128 then
	           str = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition + 2)
	           self._sayPosition = self._sayPosition + 2
	        end
            self._typewriterSayWord =  self._typewriterSayWord .. str
			self._typewriterTF:setString(self._typewriterSayWord)
        	self._sayPosition = self._sayPosition + 1

        	if self._sayPosition <= #self._typewriterWord then
		        self._typewriterTimeHandler = scheduler.performWithDelayGlobal(self._typewriterHandler,self._delayTime)
		    else
		        if self._typewriterCallback ~= nil then
		        	local callBack = self._typewriterCallback
		            self._typewriterCallback = nil
		            callBack()
		        end
		        self._typewriterTimeHandler = nil
		    end
		end
	end
	self._typewriterHandler()
end

function QUIDialogEquipmentEnchantSuccess:setIconPath(path)
	self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogEquipmentEnchantSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

------------------------ event handler -----------------------------

function QUIDialogEquipmentEnchantSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogEquipmentEnchantSuccess:_onTriggerClose()
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			return 
		elseif self._animationStage == "2" then
			self:skillHandler()
		else
		    if self._typewriterTimeHandler ~= nil then
		    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
		    	self._typewriterTimeHandler = nil
		    end
		    if self._actionHandler ~= nil then
		    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
		    	self._actionHandler = nil
		    end

		    local equipment = remote.herosUtil:getWearByItem(self._actorId, self._itemId)
			local enchantLevel = equipment.enchants
			local enchant = QStaticDatabase:sharedDatabase():getEnchant(self._itemId, enchantLevel , self._actorId)
		    local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(enchant.skill_show)
			self._ccbOwner.node_skill:setOpacity(255)
			self._ccbOwner.tf_skill_name:setString("新天赋："..skillConfig.name)
	  		local text = skillConfig.description
			local s, e = string.find(skillConfig.description, "天赋，")
	  		if e then
	  			text = string.sub(skillConfig.description, e + 1)
	  		end
			local skillDesc = q.getSkillMainDesc(text)
        	local newText = QColorLabel.removeColorSign(skillDesc) 

			self._ccbOwner.tf_skill_desc:setString(newText or "")

			scheduler.performWithDelayGlobal(function()
					self._isEnd = true
				end, 1)
		end
	end
end

function QUIDialogEquipmentEnchantSuccess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogEquipmentEnchantSuccess:viewAnimationOutHandler()
	local callBack = self._callBack

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end

	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogEquipmentEnchantSuccess