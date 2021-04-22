--
-- Author: Your Name
-- Date: 2014-06-18 17:55:35
--
local QUIDialog = import(".QUIDialog")
local QUIDialogArtifactGradeUpSuccess = class("QUIDialogArtifactGradeUpSuccess", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QHeroModel = import("...models.QHeroModel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")


function QUIDialogArtifactGradeUpSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_artifact_tupochenggong.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, QUIDialogArtifactGradeUpSuccess._onTriggerClose)},
	}
	QUIDialogArtifactGradeUpSuccess.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough") 

	self._actorId = options.actorId
	self._callback = options.callback
	self._isEnd = false
	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    self._artifactId = remote.artifact:getArtiactByActorId(self._actorId)
	self._curGradeLevel = options.curGradeLevel or self._heroInfo.artifact.artifactBreakthrough
	self._oldGradeLevel = options.oldGradeLevel or self._curGradeLevel - 1
	self._isShowAutoSkill = (options.learnSkill and options.learnSkill > 0)
	if self._isShowAutoSkill then
		self._ccbOwner.tf_auto_learn_skill:setString(string.format("（已自动学习前%d个技能）", options.learnSkill))
	end

	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	local itemConfig = db:getItemByID(self._artifactId)

	--名字部分
	local oldColor = remote.artifact:getColorByActorId(self._actorId)
	self._ccbOwner.oldName:setColor(oldColor)
	self._ccbOwner.oldName:setString(itemConfig.name)

	local newColor = remote.artifact:getColorByActorId(self._actorId)
	self._ccbOwner.newName:setColor(newColor)
	self._ccbOwner.newName:setString(itemConfig.name)

	self._ccbOwner.node_on_skill:setVisible(self._isShowAutoSkill)
	self._ccbOwner.node_no_skill:setVisible(not self._isShowAutoSkill)
	self._ccbOwner.tf_old_point_1:setString(self._oldGradeLevel)
	self._ccbOwner.tf_old_point_2:setString(self._oldGradeLevel)
	self._ccbOwner.tf_new_point_1:setString(self._curGradeLevel)
	self._ccbOwner.tf_new_point_2:setString(self._curGradeLevel)
	
	--头像部分
	local oldArtifactInfo = clone(self._heroInfo.artifact)
	oldArtifactInfo.artifactBreakthrough = self._oldGradeLevel
	local oldBox = QUIWidgetArtifactBox.new()
	oldBox:setHero(self._actorId)
	oldBox:setArtifactInfo(oldArtifactInfo)
	oldBox:showRedTips(false)
	self._ccbOwner.old_head:addChild(oldBox)

	local newArtifactInfo = clone(self._heroInfo.artifact)
	newArtifactInfo.artifactBreakthrough = self._curGradeLevel
	local newBox = QUIWidgetArtifactBox.new()
	newBox:setHero(self._actorId)
	newBox:setArtifactInfo(newArtifactInfo)
	newBox:showRedTips(false)
	self._ccbOwner.new_head:addChild(newBox)
	
	--属性部分
	local oldBreakConfig = db:getGradeByArtifactLevel(self._artifactId, self._oldGradeLevel)
	self._ccbOwner.tf_old_value1:setString(string.format("%.1f%%", (oldBreakConfig.attack_percent or 0) * 100))
	self._ccbOwner.tf_old_value2:setString(string.format("%.1f%%", (oldBreakConfig.armor_physical_percent or 0) * 100))
	self._ccbOwner.tf_old_value3:setString(oldBreakConfig.hp_value or 0)
	self._ccbOwner.tf_old_value4:setString(oldBreakConfig.attack_value or 0)
	self._ccbOwner.tf_old_value5:setString(oldBreakConfig.armor_physical or 0)

	local newBreakConfig = db:getGradeByArtifactLevel(self._artifactId, self._curGradeLevel)
	self._ccbOwner.tf_new_value1:setString(string.format("%.1f%%", (newBreakConfig.attack_percent or 0) * 100))
	self._ccbOwner.tf_new_value2:setString(string.format("%.1f%%", (newBreakConfig.armor_physical_percent or 0) * 100))
	self._ccbOwner.tf_new_value3:setString(newBreakConfig.hp_value or 0)
	self._ccbOwner.tf_new_value4:setString(newBreakConfig.attack_value or 0)
	self._ccbOwner.tf_new_value5:setString(newBreakConfig.armor_physical or 0)
end

function QUIDialogArtifactGradeUpSuccess:viewDidAppear()
	QUIDialogArtifactGradeUpSuccess.super.viewDidAppear(self)
end

function QUIDialogArtifactGradeUpSuccess:viewWillDisappear()
	QUIDialogArtifactGradeUpSuccess.super.viewWillDisappear(self)
	if self._itemEffect ~= nil then
		self._itemEffect:disappear()
		self._itemEffect = nil
	end
end

function QUIDialogArtifactGradeUpSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogArtifactGradeUpSuccess:skillHandler()
	self._animationStage = "3"

	local skillConfigs = remote.artifact:getSkillByArtifactId(self._artifactId)
	local skillId = nil
	for _, skillConfig in ipairs(skillConfigs) do
		if skillConfig.skill_order == self._curGradeLevel then
			skillId = skillConfig.skill_id
			break
		end
	end
	if skillId ~= nil then
		local skillConfig = db:getSkillByID(skillId)
		if skillConfig ~= nil then
			self._animationManager:runAnimationsForSequenceNamed("3")
			self._ccbOwner.node_status2:setVisible(true)
			self:setIconPath(skillConfig.icon)
			local actionArrayIn = CCArray:create()
			actionArrayIn:addObject(CCFadeIn:create(0.5))
			actionArrayIn:addObject(CCCallFunc:create(function ()
			  	self._actionHandler = nil
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "可学习特技："..skillConfig.name, function ()
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

function QUIDialogArtifactGradeUpSuccess:wordTypewriterEffect(tf, word, callback)
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
	        local b = string.byte(c)
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

function QUIDialogArtifactGradeUpSuccess:setIconPath(path)
	self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogArtifactGradeUpSuccess:viewWillDisappear()
	QUIDialogArtifactGradeUpSuccess.super.viewWillDisappear(self)
    self._isExist = false
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

-------event--------------
function QUIDialogArtifactGradeUpSuccess:_onTriggerClose()
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == nil then
		elseif self._animationStage == "1" then
			self._animationStage = nil
			self._animationManager:runAnimationsForSequenceNamed("2")
			self._ccbOwner.node_on_skill:setVisible(self._isShowAutoSkill)
			self._ccbOwner.node_no_skill:setVisible(not self._isShowAutoSkill)
		elseif self._animationStage == "2" then
			self:skillHandler()
		else
    		self._animationManager:runAnimationsForSequenceNamed("4")
		    if self._typewriterTimeHandler ~= nil then
		    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
		    	self._typewriterTimeHandler = nil
		    end
		    if self._actionHandler ~= nil then
		    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
		    	self._actionHandler = nil
		    end
			local skillConfigs = remote.artifact:getSkillByArtifactId(self._artifactId)
			local skillId = nil
			for _, skillConfig in ipairs(skillConfigs) do
				if skillConfig.skill_order == self._curGradeLevel then
					skillId = skillConfig.skill_id
					break
				end
			end
			if skillId ~= nil then
				local skillConfig = db:getSkillByID(skillId)
				self._ccbOwner.tf_skill_name:setString("可学习特技："..skillConfig.name)
        		local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
				skillDesc = QColorLabel.removeColorSign(skillDesc)
				self._ccbOwner.tf_skill_desc:setString(skillDesc)
			end

			scheduler.performWithDelayGlobal(function()
					self._isEnd = true
				end, 1)
		end
	end
end

function QUIDialogArtifactGradeUpSuccess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogArtifactGradeUpSuccess:viewAnimationOutHandler()
	local callback = self._callback
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end
end

return QUIDialogArtifactGradeUpSuccess