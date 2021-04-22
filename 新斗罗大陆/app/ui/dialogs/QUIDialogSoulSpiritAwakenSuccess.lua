
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritAwakenSuccess = class("QUIDialogSoulSpiritAwakenSuccess", QUIDialog)
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QUIWidgetSoulSpiritEffectBox = import(".QUIWidgetSoulSpiritEffectBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

QUIDialogSoulSpiritAwakenSuccess.DESC ="出战属性："


function QUIDialogSoulSpiritAwakenSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Awaken_Success.ccbi"
	local callBacks = {}
	QUIDialogSoulSpiritAwakenSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	if options then
		self._callBack = options.callback
		self._id = options.id
	end


	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	if not self._soulSpiritInfo then 
		self._isEnd = true
		return 
	end
	
    self._characterConfig = db:getCharacterByID(self._id)
  	self._curLv= self._soulSpiritInfo.awaken_level or 0
    self:setPropInfo()
end


function QUIDialogSoulSpiritAwakenSuccess:viewWillDisappear()
	QUIDialogSoulSpiritAwakenSuccess.super.viewWillDisappear(self)
	
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
end

function QUIDialogSoulSpiritAwakenSuccess:animationEndHandler(name)
	self._animationStage = name
end


function QUIDialogSoulSpiritAwakenSuccess:setPropInfo()

	local quality = self._characterConfig.aptitude

	local curLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(self._curLv - 1,quality)
	local nextLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(self._curLv,quality)
	if not curLvMod or not nextLvMod then
		return
	end
	self._ccbOwner.name_1:setString(QUIDialogSoulSpiritAwakenSuccess.DESC)
	self._ccbOwner.old_prop_1:setString(q.PropPercentHanderFun(curLvMod.conmbat_succession))
	self._ccbOwner.new_prop_1:setString(q.PropPercentHanderFun(nextLvMod.conmbat_succession))


	local oldAvatar = QUIWidgetSoulSpiritEffectBox.new()
	oldAvatar:setInfo(self._id , true)
	oldAvatar:setStarNum(self._soulSpiritInfo.grade)
	oldAvatar:setScale(0.9)
	self._ccbOwner.old_head:addChild(oldAvatar)
	self._ccbOwner.tf_old_name:setString(self._characterConfig.name .."+"..(self._curLv - 1) )


	local newAvatar = QUIWidgetSoulSpiritEffectBox.new()
	newAvatar:setInfo(self._id, true)
	newAvatar:setStarNum(self._soulSpiritInfo.grade)
	newAvatar:setScale(0.9)
	self._ccbOwner.new_head:addChild(newAvatar)
	self._ccbOwner.tf_new_name:setString(self._characterConfig.name .."+"..(self._curLv) )



	local color = COLORS.B
    for _,value in ipairs(HERO_SABC) do
        if value.aptitude == quality then
            color = value.colour3
        end
    end	
    local colorInfo = nil
    for _,value in ipairs(FONTCOLOR_TO_OUTLINECOLOR) do
        if value.fontColor == color then
            colorInfo = value
        end
    end	

	if colorInfo then
		self._ccbOwner.tf_old_name:setColor(colorInfo.fontColor)
		self._ccbOwner.tf_old_name:setOutlineColor(colorInfo.outlineColor)
		self._ccbOwner.tf_old_name:enableOutline()
		self._ccbOwner.tf_new_name:setColor(colorInfo.fontColor)
		self._ccbOwner.tf_new_name:setOutlineColor(colorInfo.outlineColor)
		self._ccbOwner.tf_new_name:enableOutline()		
	end


	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)
	self._skillProcess = 0
	self._skillKey = ""
end


function QUIDialogSoulSpiritAwakenSuccess:setIconPath(path)
	if not path then
		return
	end
	if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogSoulSpiritAwakenSuccess:skillHandler()
	self._animationStage = "3"

	self._isEnd = true
	self:_onTriggerClose()

	-- local quality = self._characterConfig.aptitude

	-- local curLvMod = remote.soulSpirit:getSoulSpiritAwakenConfig(self._curLv,quality)

	-- local newGradeConfig = db:getGradeByHeroActorLevel(self._soulSpiritInfo.id, self._soulSpiritInfo.grade)
	-- -- 由于配表原因，这里用星级来显示技能等级
 --    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade + 1)
	-- if newGradeConfig and newGradeConfig[self._skillKey] ~= nil and newGradeConfig[self._skillKey] ~= "" then
	-- 	local skillIds = string.split(newGradeConfig[self._skillKey], ":")
	-- 	self._skillId = tonumber(skillIds[1])
	-- 	local skillConfig = db:getSkillByID(self._skillId)
	-- 	if skillConfig ~= nil then
	-- 		if self._skillProcess == 1 then
	-- 			self._animationManager:runAnimationsForSequenceNamed("3")
	-- 		elseif self._skillProcess == 4 then
	-- 			self._ccbOwner.tf_skill_name:setString("")
	-- 			self._ccbOwner.tf_skill_desc:setString("")
	-- 			self._ccbOwner.node_skill:setOpacity(0)
	-- 		end
	-- 		self._ccbOwner.node_status2:setVisible(true)
	-- 		self:setIconPath(skillConfig.icon)
	-- 		local actionArrayIn = CCArray:create()
	-- 		actionArrayIn:addObject(CCFadeIn:create(0.5))
	-- 		actionArrayIn:addObject(CCCallFunc:create(function ()
	-- 		  	self._actionHandler = nil
	-- 		  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "觉醒技能："..skillConfig.name..rnumSkillLevel, function ()
 --            		local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
	-- 		        skillDesc = QColorLabel.removeColorSign(skillDesc)
	-- 		  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
	-- 					self._skillProcess = self._skillProcess + 2	
	-- 					if self._skillProcess == 6 then
	-- 						self._isEnd = true
	-- 					end
	-- 		  		end)
	-- 		  	end)
	-- 		end))
	-- 		local ccsequence = CCSequence:create(actionArrayIn)
	-- 		self._actionHandler = self._ccbOwner.node_skill:runAction(ccsequence)
	-- 		return
	-- 	else
	-- 		self._isEnd = true
	-- 		self:_onTriggerClose()
	-- 	end
	-- else
	-- 	self._isEnd = true
	-- 	self:_onTriggerClose()
	-- end
end

function QUIDialogSoulSpiritAwakenSuccess:wordTypewriterEffect(tf, word, callback)
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

function QUIDialogSoulSpiritAwakenSuccess:jumpSkillAnimation( ... )
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    self._typewriterCallback = nil

	local newGradeConfig = db:getGradeByHeroActorLevel(self._soulSpiritInfo.id, self._soulSpiritInfo.grade)
	-- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade + 1)
	if newGradeConfig and newGradeConfig[self._skillKey] ~= nil and newGradeConfig[self._skillKey] ~= "" then
		local skillIds = string.split(newGradeConfig[self._skillKey], ":")
		self._skillId = tonumber(skillIds[1])
		local skillConfig = db:getSkillByID(self._skillId)
		self._ccbOwner.node_skill:setOpacity(255)
		self._ccbOwner.tf_skill_name:setString("觉醒技能："..skillConfig.name..rnumSkillLevel)
        local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
  		skillDesc = QColorLabel.removeColorSign(skillDesc)
		self._ccbOwner.tf_skill_desc:setString(skillDesc)
	end
end


function QUIDialogSoulSpiritAwakenSuccess:_onTriggerClose()
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
				self._skillKey = "soulspirit_pg"
				self:skillHandler()
			elseif self._skillProcess == 1 then
				self._skillProcess = self._skillProcess + 1
				self:jumpSkillAnimation()
				scheduler.performWithDelayGlobal(function()
					self._skillProcess = self._skillProcess + 1
					end, 1)
			elseif self._skillProcess == 3 then
				self._skillProcess = self._skillProcess + 1
				self._skillKey = "soulspirit_dz"
				self:skillHandler()
			elseif self._skillProcess == 4 then
				self._skillProcess = self._skillProcess + 1
				self:jumpSkillAnimation()
				scheduler.performWithDelayGlobal(function()
						self._isEnd = true
					end, 1)
			end		
		end
	end
end

function QUIDialogSoulSpiritAwakenSuccess:_backClickHandler()
	self:_onTriggerClose()
end




return QUIDialogSoulSpiritAwakenSuccess