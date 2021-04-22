-- @Author: xurui
-- @Date:   2017-04-08 16:06:46
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 17:10:28
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSparSuitActiveSuccess = class("QUIDialogSparSuitActiveSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSparSuitActiveSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_spar_taozhuangjihuo.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogSparSuitActiveSuccess.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	self._actorId = options.actorId
	self._suitInfo = options.suitInfo
	self._callBack = options.callback
	self._successTip = options.successTip 

	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self.sparInfo1 = self._heroUIModel:getSparInfoByPos(1).info
	self.sparInfo2 = self._heroUIModel:getSparInfoByPos(2).info

	self.isEnd = false
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:runAnimationsForSequenceNamed("1")
	self._animationManager:connectScriptHandler(function(name)
			self._animationStage = name
			if self._animationStage == "3" then
				self._animationManager:runAnimationsForSequenceNamed("2")
				self:setSkillInfo(2)
			end
		end)
	app.sound:playSound("common_level_up")

	self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
    self._isSelected = false
    self:showSelectState()
end

function QUIDialogSparSuitActiveSuccess:viewDidAppear()
	QUIDialogSparSuitActiveSuccess.super.viewDidAppear(self)

	self:setSuitInfo()
end

function QUIDialogSparSuitActiveSuccess:viewWillDisappear()
	QUIDialogSparSuitActiveSuccess.super.viewWillDisappear(self)

end

function QUIDialogSparSuitActiveSuccess:setSuitInfo()
	if self._sparItem1 == nil then
		self._sparItem1 = QUIWidgetSparBox.new()
		self._ccbOwner.node_icon_1:addChild(self._sparItem1)
	end
	self._sparItem1:setGemstoneInfo(self.sparInfo1, 1)
	self._sparItem1:setName("")
	self._sparItem1:setStrengthVisible(false)

	if self._sparItem2 == nil then
		self._sparItem2 = QUIWidgetSparBox.new()
		self._ccbOwner.node_icon_2:addChild(self._sparItem2)
	end
	self._sparItem2:setGemstoneInfo(self.sparInfo2, 2)
	self._sparItem2:setName("")
	self._sparItem2:setStrengthVisible(false)

	local itemConfig1 = QStaticDatabase:sharedDatabase():getItemByID(self.sparInfo1.itemId)
	local itemConfig2 = QStaticDatabase:sharedDatabase():getItemByID(self.sparInfo2.itemId)

	self._ccbOwner.tf_spar_name1:setString(itemConfig1.name)
	self._ccbOwner.tf_spar_name2:setString(itemConfig2.name)
	local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(self._suitInfo.star_num)
	self._ccbOwner.tf_suit_name:setString(string.format("%s套装【%s效果】", self._suitInfo.suit_name or "", level..gardeName))


	local skillSzId , skillYzId = remote.spar:getSparSuitSkillShowIds(self._suitInfo)
    self._skillDesc1 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillSzId, self._suitInfo.skill_level)
	self._skillDesc2 = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillYzId, self._suitInfo.skill_level)
	self._skillConfig1 = QStaticDatabase:sharedDatabase():getSkillByID(skillSzId)
	self._skillConfig2 = QStaticDatabase:sharedDatabase():getSkillByID(skillYzId)
	self:setSkillInfo(1)
end

function QUIDialogSparSuitActiveSuccess:setSkillInfo(index)
	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")

	local skillConfig = self["_skillConfig"..index]
	local skillName = "新技能："..(skillConfig.name or "")
	local skillDesc = QColorLabel.removeColorSign(self["_skillDesc"..index].description_1 or "")
	skillDesc = q.getSkillDescByLimitNum(skillDesc or "" ,65)
	if index == 1 then
		self._ccbOwner.tf_skill_name:setString(skillName)
		self._ccbOwner.tf_skill_desc:setString(skillDesc)

		self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
	else
		if skillConfig.icon then
			self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
		end
		self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, skillName, function ()
			self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
				self.isEnd = true
			end)
		end)
	end
end

function QUIDialogSparSuitActiveSuccess:wordTypewriterEffect(tf, word, callback)
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
			local c = string.sub(self._typewriterWord,self._sayPosition, self._sayPosition)
	        local b = string.byte(c)
	        local str = c
	        if b > 128 then
	           str = string.sub(self._typewriterWord,self._sayPosition, self._sayPosition + 2)
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

function QUIDialogSparSuitActiveSuccess:_backClickHandler()
    if self._animationStage == "1" then
    	self._animationStage = "3" 
		self._animationManager:runAnimationsForSequenceNamed("3")
	elseif self.isEnd == true and self._animationStage == "2" then
		self:_onTriggerClose()
	end
end

function QUIDialogSparSuitActiveSuccess:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSparSuitActiveSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogSparSuitActiveSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogSparSuitActiveSuccess:_onTriggerClose()
	if self._callBack ~= nil then 
		self._callBack()
	end
    if self._isSelected == true then
		app.master:setMasterShowState(self._successTip)
    end
	self:popSelf()
end


return QUIDialogSparSuitActiveSuccess