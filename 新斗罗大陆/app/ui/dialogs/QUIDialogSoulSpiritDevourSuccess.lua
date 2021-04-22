



local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritDevourSuccess = class("QUIDialogSoulSpiritDevourSuccess", QUIDialog)
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

function QUIDialogSoulSpiritDevourSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Devour_Success.ccbi"
	local callBacks = {}
	QUIDialogSoulSpiritDevourSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
    self._oldLv = nil
	if options then
		self._callBack = options.callback
		self._id = options.id
		self._oldLv = options.oldLv or 0
	end


	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	if not self._soulSpiritInfo then 
		self._isEnd = true
		return 
	end
    self._characterConfig = db:getCharacterByID(self._id)
  	self._curLv = self._soulSpiritInfo.devour_level or 1

    self:setPropInfo()
end


function QUIDialogSoulSpiritDevourSuccess:viewWillDisappear()
	QUIDialogSoulSpiritDevourSuccess.super.viewWillDisappear(self)
	
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
end

function QUIDialogSoulSpiritDevourSuccess:animationEndHandler(name)
	self._animationStage = name
end


function QUIDialogSoulSpiritDevourSuccess:setPropInfo()


    self._nextInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self._curLv ,self._id)

	if  not self._nextInheritMod then return end

	local NUMBERS = {"零","一","二","三","四","五","六"}
	self._ccbOwner.tf_old_name:setString("【传承"..NUMBERS[tonumber(self._oldLv + 1)].."重】")
	self._ccbOwner.tf_new_name:setString("【传承"..NUMBERS[tonumber(self._curLv + 1)].."重】")
	local curPropDesc = {}
	if self._oldLv ~= 0 then
		self._curInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self._oldLv,self._id)
		curPropDesc = remote.soulSpirit:getPropStrList(self._curInheritMod)
	end
    local propDescIndex = {}
    table.insert(propDescIndex, {fieldName = "attack_percent", name = "生命、攻击："})
    table.insert(propDescIndex, {fieldName = "armor_magic_percent", name = "物防、法防："})
    table.insert(propDescIndex, {fieldName = "attack_value", name = "攻     击："})
    table.insert(propDescIndex, {fieldName = "hp_value", name = "生     命："})
    table.insert(propDescIndex, {fieldName = "armor_magic", name = "物防、法防："})

	local nextPropDesc = remote.soulSpirit:getPropStrList(self._nextInheritMod)

   for i,v in ipairs(propDescIndex) do
        local isVisible = false
        self._ccbOwner["name_"..i]:setString(v.name)
		if self._oldLv == 0 then
			self._ccbOwner["old_prop_"..i]:setString("+0")
		else
	        for k,prop in pairs(curPropDesc) do
	            if prop.fieldName == v.fieldName then
					self._ccbOwner["old_prop_"..i]:setString("+"..prop.value)
	                break
	            end
	        end
    	end
		self._ccbOwner["name_"..i]:setVisible(true)
		self._ccbOwner["old_prop_"..i]:setVisible(true)
    end

   	for i,v in ipairs(propDescIndex) do
        local isVisible = false
        for k,prop in pairs(nextPropDesc) do
            if prop.fieldName == v.fieldName then
                isVisible = true
				self._ccbOwner["new_prop_"..i]:setString("+"..prop.value)
                break
            end
        end
		self._ccbOwner["new_prop_"..i]:setVisible(true)
    end


	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local iconOld = QUIWidgetSoulSpiritHead.new()
    self._ccbOwner.old_head:addChild(iconOld)
    iconOld:setInfo(soulSpiritInfo)
    iconOld:setInherit(self._oldLv)
    iconOld:setScale(0.9)
    

	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local iconNew = QUIWidgetSoulSpiritHead.new()
    self._ccbOwner.new_head:addChild(iconNew)
    iconNew:setInfo(soulSpiritInfo)
    iconNew:setInherit(self._curLv)
    iconNew:setScale(0.9)

	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)
	self._skillProcess = 0
	self._skillKey = ""
end


function QUIDialogSoulSpiritDevourSuccess:setIconPath(path)
	if not path then
		return
	end
	if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    	-- self._ccbOwner.node_icon:setScale(0.8)

    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogSoulSpiritDevourSuccess:skillHandler()
	self._animationStage = "3"
	local inheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self._curLv ,self._id)
	local rnumSkillLevel = inheritMod.level
	rnumSkillLevel = q.getRomanNumberalsByInt(rnumSkillLevel)
 

	if inheritMod and inheritMod[self._skillKey] ~= nil and inheritMod[self._skillKey] ~= "" then
		local skillIds = string.split(inheritMod[self._skillKey], ":")
		self._skillId = tonumber(skillIds[1])
		local skillConfig = db:getSkillByID(self._skillId)
		if skillConfig ~= nil then
			if self._skillProcess == 1 then
				self._animationManager:runAnimationsForSequenceNamed("3")
			elseif self._skillProcess == 4 then
				self._ccbOwner.tf_skill_name:setString("")
				self._ccbOwner.tf_skill_desc:setString("")
				self._ccbOwner.node_skill:setOpacity(0)
			end
			self._ccbOwner.node_status2:setVisible(true)
			self:setIconPath(skillConfig.icon)
			local actionArrayIn = CCArray:create()
			actionArrayIn:addObject(CCFadeIn:create(0.5))
			actionArrayIn:addObject(CCCallFunc:create(function ()
			  	self._actionHandler = nil
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "传承技能："..skillConfig.name..rnumSkillLevel, function ()
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

function QUIDialogSoulSpiritDevourSuccess:wordTypewriterEffect(tf, word, callback)
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
	self._delayTime = TUTORIAL_ONEWORD_TIME * 0.3
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

function QUIDialogSoulSpiritDevourSuccess:jumpSkillAnimation( ... )
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    self._typewriterCallback = nil

	local inheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self._curLv ,self._id)
	local rnumSkillLevel = inheritMod.level
	rnumSkillLevel = q.getRomanNumberalsByInt(rnumSkillLevel)
 
    
	if inheritMod and inheritMod[self._skillKey] ~= nil and inheritMod[self._skillKey] ~= "" then
		local skillIds = string.split(newGradeConfig[self._skillKey], ":")
		self._skillId = tonumber(skillIds[1])
		local skillConfig = db:getSkillByID(self._skillId)
		self._ccbOwner.node_skill:setOpacity(255)
		self._ccbOwner.tf_skill_name:setString("传承技能："..skillConfig.name..rnumSkillLevel)
        local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
  		skillDesc = QColorLabel.removeColorSign(skillDesc)
		self._ccbOwner.tf_skill_desc:setString(skillDesc)
	end
end


function QUIDialogSoulSpiritDevourSuccess:_onTriggerClose()
	if self._isEnd == true then
		if self._callBack ~= nil then
			self._callBack()
		end
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end

		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			return
		else
			if self._skillProcess == 0 then
				self._skillProcess = self._skillProcess + 1
				self._skillKey = "skill"
				self:skillHandler()
			-- elseif self._skillProcess == 1 then
			-- 	self._skillProcess = self._skillProcess + 1
			-- 	self:jumpSkillAnimation()
			-- 	scheduler.performWithDelayGlobal(function()
			-- 		self._isEnd = true
			-- 		end, 1)
			end		
		end
	end
end

function QUIDialogSoulSpiritDevourSuccess:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogSoulSpiritDevourSuccess