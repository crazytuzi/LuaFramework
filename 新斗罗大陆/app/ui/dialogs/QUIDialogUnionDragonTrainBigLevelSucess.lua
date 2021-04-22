local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonTrainBigLevelSucess = class("QUIDialogUnionDragonTrainBigLevelSucess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogUnionDragonTrainBigLevelSucess:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_advancesuccess.ccbi"
	local callBacks = {}
	QUIDialogUnionDragonTrainBigLevelSucess.super.ctor(self,ccbFile,callBacks,options)

	app.sound:playSound("hero_breakthrough")
    self.isAnimation = true --是否动画显示
	self._isEnd = false
	self._callback = options.callback
	self._dragonLevel = options.level
	self._oldLevel = options.oldLevel

	self._skillIds = {}
	self._skillIndex = 0

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
    self._animationStage = "0"
    self._ccbOwner.node_close_tips:setVisible(false)

    self:setPropInfo()
end

function QUIDialogUnionDragonTrainBigLevelSucess:viewDidAppear()
	QUIDialogUnionDragonTrainBigLevelSucess.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainBigLevelSucess:viewWillDisappear()
	QUIDialogUnionDragonTrainBigLevelSucess.super.viewWillDisappear(self)

    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
end

function QUIDialogUnionDragonTrainBigLevelSucess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogUnionDragonTrainBigLevelSucess:setPropInfo()
    local dragon = remote.dragon:getDragonInfo()
    if not self._dragonLevel then
    	self._dragonLevel = dragon.level
    end
	local str1 = "武魂"
	local str2 = "武魂"
	local oldLevel = self._oldLevel or self._dragonLevel - 1
	local dragonConfig = db:getUnionDragonConfigById(dragon.dragonId)
	if dragonConfig.type == remote.dragon.TYPE_WEAPON then
		str1 = string.format("lv.%d %s", oldLevel, dragonConfig.dragon_name or "")
		str2 = string.format("lv.%d %s", self._dragonLevel, dragonConfig.dragon_name or "")
	else
		str1 = string.format("lv.%d %s", oldLevel, dragonConfig.dragon_name or "")
		str2 = string.format("lv.%d %s", self._dragonLevel, dragonConfig.dragon_name or "")
	end
    self._ccbOwner.tf_old_name:setString(str1)
    self._ccbOwner.tf_new_name:setString(str2)

	local oldConfig = db:getUnionDragonInfoByLevel(oldLevel)
	local newConfig = db:getUnionDragonInfoByLevel(self._dragonLevel)
	local curProp = remote.dragon:getPropInfo(oldConfig)
	local nextProp = remote.dragon:getPropInfo(newConfig)
	for index = 1, 4 do
		if curProp[index] then
			self._ccbOwner["tf_old_value_"..index]:setString(curProp[index].value)
		else
			self._ccbOwner["tf_old_value_"..index]:setString("")
		end
		if nextProp[index] then
			self._ccbOwner["node_title_"..index]:setString(nextProp[index].name.."：")
			self._ccbOwner["tf_new_value_"..index]:setString(nextProp[index].value)
		else
			self._ccbOwner["node_title_"..index]:setString("")
			self._ccbOwner["tf_new_value_"..index]:setString("")
		end
	end
end

function QUIDialogUnionDragonTrainBigLevelSucess:setIconPath(path)
	if not path then
		return
	end
	if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogUnionDragonTrainBigLevelSucess:skillHandler()
	local dragon = remote.dragon:getDragonInfo()
	local skillConfig = db:getUnionDragonSkillByIdAndLevel(dragon.dragonId, self._dragonLevel)
	if skillConfig and skillConfig.new_skill then
		self._skillIds = string.split(skillConfig.new_skill, ";")
	else
		self._isEnd = true
		self:_onTriggerClose()
	end
end

function QUIDialogUnionDragonTrainBigLevelSucess:skillShow()
	local skillConfig = db:getSkillByID(self._skillIds[self._skillIndex])
	if skillConfig ~= nil then
		self:setIconPath(skillConfig.icon)
		local actionArrayIn = CCArray:create()
		actionArrayIn:addObject(CCFadeIn:create(0.5))
		actionArrayIn:addObject(CCCallFunc:create(function ()
		  	self._actionHandler = nil
		  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "新魂技："..skillConfig.name, function ()
        			local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
			        skillDesc = QColorLabel.removeColorSign(skillDesc)
			  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function()
			  				self._animationStage = "4"
			  			end)
			  	end)
		end))
		local ccsequence = CCSequence:create(actionArrayIn)
		self._actionHandler = self._ccbOwner.node_skill:runAction(ccsequence)
	end
end

function QUIDialogUnionDragonTrainBigLevelSucess:wordTypewriterEffect(tf, word, callback)
	if tf == nil or word == nil then
		if callback ~= nil then callback() end
		return false
	end
	if self._typewriterCallback ~= nil then
		if callback ~= nil then callback() end
		return false
	end
	self._typewriterTF = tf
	self._typewriterWord = word or ""
	self._typewriterCallback = callback

	self._sayPosition = 1
	self._typewriterSayWord = ""
	self._typewriterTF:setString(self._typewriterSayWord)
	self._delayTime = TUTORIAL_ONEWORD_TIME * 0.3
	self._isExist = true

	if self._typewriterHandler == nil then
		self._typewriterHandler = function ()
		    if self._typewriterTimeHandler ~= nil then
		    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
		    	self._typewriterTimeHandler = nil
		    end
			if self._isExist ~= true then return end
			local c = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition)
	        local b = string.byte(c) or 0
	        local str = c
	        if b > 128 then
	           str = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition + 2)
	           self._sayPosition = self._sayPosition + 2
	        end
            self._typewriterSayWord = self._typewriterSayWord .. str
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
		    end
		end
	end
	self._typewriterHandler()
end

function QUIDialogUnionDragonTrainBigLevelSucess:jumpSkillAnimation()
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    self._typewriterCallback = nil

	local skillConfig = db:getSkillByID(self._skillIds[self._skillIndex])
	self:setIconPath(skillConfig.icon)
	self._ccbOwner.node_skill:setOpacity(255)
	self._ccbOwner.tf_skill_name:setString("新魂技："..skillConfig.name)
    local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
	skillDesc = QColorLabel.removeColorSign(skillDesc)
	self._ccbOwner.tf_skill_desc:setString(skillDesc)
end

function QUIDialogUnionDragonTrainBigLevelSucess:_onTriggerClose()
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "2" then
			self:skillHandler()
			self._skillIndex = 0
			self._skillIndex = self._skillIndex + 1
			if self._skillIds[self._skillIndex] then
				self:skillShow()
				self._animationStage = "3"
				self._animationManager:runAnimationsForSequenceNamed("3")
			else
				self._isEnd = true
				self:_onTriggerClose()
			end
		elseif self._animationStage == "3" then
			self._animationStage = "4"
			self._animationManager:runAnimationsForSequenceNamed("4")		
		elseif self._animationStage == "4" then
			self._skillIndex = self._skillIndex + 1
			if self._skillIds[self._skillIndex] then
		 		self:jumpSkillAnimation()
    			self._ccbOwner.node_close_tips:setVisible(true)
			else
				self._isEnd = true
				self:_onTriggerClose()
			end
		end
	end
end

function QUIDialogUnionDragonTrainBigLevelSucess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainBigLevelSucess:viewAnimationOutHandler()
	self:popSelf()
   	if self._callback then
		self._callback()
	end
end

return QUIDialogUnionDragonTrainBigLevelSucess