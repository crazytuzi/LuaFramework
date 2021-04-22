-- @Author: liaoxianbo
-- @Date:   2019-09-16 12:21:31
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 17:02:48
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemStoneAdvancedSucess = class("QUIDialogGemStoneAdvancedSucess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGemStoneAdvancedSucess:ctor(options)
	local ccbFile = "ccb/Dialog_HeroEnchantSuccess.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
    QUIDialogGemStoneAdvancedSucess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	app.sound:playSound("common_level_up")
    if options then
    	self._callBack = options.callBack
    	self._gemstoneSid = options.gemstoneSid
    	self._itemId = options.itemId
    	self._advancedLevel = options.advancedLevel
    	self._successTip = options.successTip
    	self._advancedType = options.advancedType
    end
    if self._advancedType == remote.gemstone.EVENT_ADVANCED then
    	QSetDisplaySpriteByPath(self._ccbOwner.tf_sprite_title, "ui/tupo/zi_jjcg.png")
    else --化神成功
    	QSetDisplaySpriteByPath(self._ccbOwner.tf_sprite_title, "ui/tupo/zi_hscg.png")
    end
    
	self._ccbOwner.node_status2:setVisible(false)
	self._ccbOwner.btn_close:setVisible(false)

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

    self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)

	self:setGemStoneInfo()

	self:_setProps()

	self._isEnd = false

    self._isSelected = false
    self:showSelectState()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())

end

function QUIDialogGemStoneAdvancedSucess:setGemStoneInfo()

	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)

	local itemConfig = db:getItemByID(gemstone.itemId)
	local mixLevel = gemstone.mix_level or 0
	if gemstone and gemstone.godLevel > 0 then
		local oldItemBox = self:setGemStoneFrame(self._ccbOwner.old_head, itemConfig, gemstone.craftLevel, self._advancedLevel-1 , mixLevel)
		local newItemBox = self:setGemStoneFrame(self._ccbOwner.new_head, itemConfig, gemstone.craftLevel, gemstone.godLevel , mixLevel)
	end 
	
	local level, color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
	local name = itemConfig.name
	local oldname = itemConfig.name
    self._advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	name = remote.gemstone:getGemstoneNameByData(name,self._advancedLevel,mixLevel)
	oldname = remote.gemstone:getGemstoneNameByData(oldname,self._advancedLevel - 1 ,mixLevel)
	
	if level > 0 then
		name = name .. "＋".. level
		oldname = oldname.."+"..level
	end
	self._ccbOwner.oldName:setString(oldname or "")
	self._ccbOwner.newName:setString(name or "")
	self._ccbOwner.oldName:setColor(UNITY_COLOR_LIGHT[color])
	self._ccbOwner.newName:setColor(UNITY_COLOR_LIGHT[color])
end

function QUIDialogGemStoneAdvancedSucess:_setProps()

	for ii = 1,3 do
		self._ccbOwner["name_"..ii]:setString("")
		self._ccbOwner["old_prop_"..ii]:setString("")
		self._ccbOwner["new_prop_"..ii]:setString("")
		if ii > 1 then
			self._ccbOwner["prop_node_"..ii]:setVisible(false)
		end
	end
	
	-- local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)

    local oldPropVlue = {}
    local newPropVlue = {}
    if self._advancedType == remote.gemstone.EVENT_ADVANCED then
	    oldPropVlue = remote.gemstone:getAllAdvancedProp(self._itemId,1,self._advancedLevel-1)

	    newPropVlue = remote.gemstone:getAllAdvancedProp(self._itemId,1,self._advancedLevel)
	else
		oldPropVlue = remote.gemstone:getAllAdvancedProp(self._itemId,GEMSTONE_MAXADVANCED_LEVEL+1,self._advancedLevel-1)
		newPropVlue = remote.gemstone:getAllAdvancedProp(self._itemId,GEMSTONE_MAXADVANCED_LEVEL+1,self._advancedLevel)
	end

    if oldPropVlue and next(oldPropVlue) ~= nil then
		self:setProp(true,oldPropVlue.attack_value, "攻    击：","＋%d")
		self:setProp(true,oldPropVlue.hp_value, "生    命：","＋%d")
		self:setProp(true,oldPropVlue.armor_physical, "物    防：","＋%d")
		self:setProp(true,oldPropVlue.armor_magic, "法    防：","＋%d")
		self:setProp(true,oldPropVlue.attack_percent, "攻击增加：","＋%.1f%%", true)
		self:setProp(true,oldPropVlue.hp_percent, "生命增加：","＋%.1f%%", true)
		self:setProp(true,oldPropVlue.armor_physical_percent, "物防增加：","＋%.1f%%", true)
		self:setProp(true,oldPropVlue.armor_magic_percent, "法防增加：","＋%.1f%%", true)
	else
		self._ccbOwner["old_prop_1"]:setString("0")
	end

	if newPropVlue and next(newPropVlue) ~= nil then
		self:setProp(false,newPropVlue.attack_value, "攻    击：","＋%d")
		self:setProp(false,newPropVlue.hp_value, "生    命：","＋%d")
		self:setProp(false,newPropVlue.armor_physical, "物    防：","＋%d")
		self:setProp(false,newPropVlue.armor_magic, "法    防：","＋%d")
		self:setProp(false,newPropVlue.attack_percent, "攻击增加：","＋%.1f%%", true)
		self:setProp(false,newPropVlue.hp_percent, "生命增加：","＋%.1f%%", true)
		self:setProp(false,newPropVlue.armor_physical_percent, "物防增加：","＋%.1f%%", true)
		self:setProp(false,newPropVlue.armor_magic_percent, "法防增加：","＋%.1f%%", true)		
	end
end

function QUIDialogGemStoneAdvancedSucess:setProp(isOld, prop,value,value1,ispercent)
	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		self._ccbOwner["name_1"]:setString(value)
		if isOld then
			self._ccbOwner["old_prop_1"]:setString(string.format(value1, prop))
		else
			self._ccbOwner["new_prop_1"]:setString(string.format(value1, prop))
		end
	end
end

function QUIDialogGemStoneAdvancedSucess:setGemStoneFrame(node, itemConfig, craftLevel, advancedLevel , mixLevel)
	-- local cls = "QUIWidgetEquipmentAvatar"

	-- local class = import(app.packageRoot .. ".ui.dialogs." .. cls)
	local itemBox = QUIWidgetEquipmentAvatar.new()
	itemBox:setGemstonInfo(itemConfig, craftLevel, 1.0,advancedLevel , mixLevel)
	itemBox:hideAllColor()
	if node ~= nil then
		node:addChild(itemBox)
	end

	local advanced,level = remote.gemstone:getGemsonesAdvanced(advancedLevel)
	itemBox:showAdvancedColor(advanced)

	return itemBox
end

function QUIDialogGemStoneAdvancedSucess:viewDidAppear()
	QUIDialogGemStoneAdvancedSucess.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogGemStoneAdvancedSucess:viewWillDisappear()
  	QUIDialogGemStoneAdvancedSucess.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogGemStoneAdvancedSucess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogGemStoneAdvancedSucess:_getSkillIcon(skillId)
	local skillItemBox = nil
	if skillId ~= nil then
		local skillData = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
		skillItemBox = QUIWidgetHeroSkillBox.new()

		skillItemBox:setColor("orange")

		skillItemBox:setSkillID(skillId)
		skillItemBox:setLock(false)
	end

	return skillItemBox
end

function QUIDialogGemStoneAdvancedSucess:skillHandler()
	self._animationStage = "3"

	local newLevelInfo = db:getGemstoneEvolutionBygodLevel(self._itemId,self._advancedLevel)

	if newLevelInfo and newLevelInfo.gem_evolution_skill then
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(newLevelInfo.gem_evolution_skill)
		if skillConfig ~= nil then
			self._animationManager:runAnimationsForSequenceNamed("3")
			self._ccbOwner.node_status2:setVisible(true)

			local skillIcon = self:_getSkillIcon(newLevelInfo.gem_evolution_skill)
			self._ccbOwner.node_icon:addChild(skillIcon)
			local actionArrayIn = CCArray:create()
			actionArrayIn:addObject(CCFadeIn:create(0.5))
			actionArrayIn:addObject(CCCallFunc:create(function ()
			  	self._actionHandler = nil
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "新技能："..skillConfig.name, function ()
			  		local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
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

function QUIDialogGemStoneAdvancedSucess:wordTypewriterEffect(tf, word, callback)
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

function QUIDialogGemStoneAdvancedSucess:setIconPath(path)
	self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogGemStoneAdvancedSucess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGemStoneAdvancedSucess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGemStoneAdvancedSucess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogGemStoneAdvancedSucess:_onTriggerClose()
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
		    local newLevelInfo = db:getGemstoneEvolutionBygodLevel(self._itemId,self._advancedLevel)
			if newLevelInfo and newLevelInfo.gem_evolution_skill then
			    local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(newLevelInfo.gem_evolution_skill)
				self._ccbOwner.node_skill:setOpacity(255)
				self._ccbOwner.tf_skill_name:setString("新技能："..skillConfig.name)
				local skillDesc = q.getSkillMainDesc(skillConfig.description)
	        	local newText = QColorLabel.removeColorSign(skillDesc) 

				self._ccbOwner.tf_skill_desc:setString(newText or "")
			end

			scheduler.performWithDelayGlobal(function()
					self._isEnd = true
				end, 1)
		end
	end
end

function QUIDialogGemStoneAdvancedSucess:viewAnimationOutHandler()
	local callBack = self._callBack

    if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogGemStoneAdvancedSucess
