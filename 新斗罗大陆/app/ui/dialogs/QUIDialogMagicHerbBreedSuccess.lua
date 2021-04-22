local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbBreedSuccess = class("QUIDialogMagicHerbBreedSuccess", QUIDialog)
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMagicHerbBreedSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_BreedSuccess.ccbi"
	local callBacks = {}
	QUIDialogMagicHerbBreedSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")
	self._isEnd = false
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._callback = options.callback
	self._sid = options.sid
	local magicHerbInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local itemConfig = db:getItemByID(magicHerbInfo.itemId)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbInfo.itemId)

	if not magicHerbInfo or not magicHerbConfig or not itemConfig then return end
	self._breedLv = magicHerbInfo.breedLevel or 1
	self._magicHerbId = magicHerbConfig.id

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	local oldIcon = QUIWidgetMagicHerbBox.new()
	self._ccbOwner.old_head:addChild(oldIcon)
    oldIcon:setInfo(self._sid)
    --由于培育仙品永远为S所以这里写死Qsy
    oldIcon:setItemFrame(APTITUDE.S)
    oldIcon:_showSabc(APTITUDE.S)
	oldIcon:hideName()
	local newIcon = QUIWidgetMagicHerbBox.new()
	self._ccbOwner.new_head:addChild(newIcon)
    newIcon:setInfo(self._sid)
	newIcon:hideName()
	local name = magicHerbConfig.name

    local berforeBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._magicHerbId, self._breedLv - 1 )
    local curBreedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._magicHerbId, self._breedLv )

    local props = remote.magicHerb:setPropInfo(berforeBreedConfig ,true,true,false)	
	local index = 1
	for i, prop in ipairs(props) do
		if self._ccbOwner["prop_node_"..index] then
			self._ccbOwner["old_prop_"..index]:setString("+"..prop.value)
		end
		index = index + 1
	end


   	props = remote.magicHerb:setPropInfo(curBreedConfig ,true,true,false)	
	index = 1
	for i, prop in ipairs(props) do
		if self._ccbOwner["prop_node_"..index] then
			self._ccbOwner["name_"..index]:setString(prop.name..":")
			self._ccbOwner["new_prop_"..index]:setString("+"..prop.value)
			if self._breedLv == 1 then
				if self._ccbOwner["prop_node_"..index] then
					self._ccbOwner["old_prop_"..index]:setString("+"..0)
				end
			end
		end
		index = index + 1
	end
	for i=index,5 do
		self._ccbOwner["prop_node_"..i]:setVisible(false)
	end
	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]

	if self._breedLv == 1 then
    	self._ccbOwner.tf_old_name:setString(name)
		self._ccbOwner.tf_old_name:setColor(fontColor)
		self._ccbOwner.tf_old_name = setShadowByFontColor(self._ccbOwner.tf_old_name, fontColor)

	else
		self._ccbOwner.tf_old_name:setString(name.."+"..berforeBreedConfig.breed_level)
		self._ccbOwner.tf_old_name:setColor(fontColor)
		self._ccbOwner.tf_old_name = setShadowByFontColor(self._ccbOwner.tf_old_name, fontColor)
	end	

	if self._breedLv == remote.magicHerb.BREED_LV_MAX then
    	self._ccbOwner.tf_new_name:setString(name)
    	fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour + 1]]
		self._ccbOwner.tf_new_name:setColor(fontColor)
		self._ccbOwner.tf_new_name = setShadowByFontColor(self._ccbOwner.tf_new_name, fontColor)
	else
		self._ccbOwner.tf_new_name:setString(name.."+"..curBreedConfig.breed_level)
		self._ccbOwner.tf_new_name:setColor(fontColor)
		self._ccbOwner.tf_new_name = setShadowByFontColor(self._ccbOwner.tf_new_name, fontColor)
	end


	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)
	self._skillProcess = 0
	self._skillIndex = 0
end

function QUIDialogMagicHerbBreedSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogMagicHerbBreedSuccess:skillHandler()
	self._animationStage = "3"
	local mountGradeConfig = db:getGradeByHeroActorLevel(self._godarmInfo.id, self._godarmInfo.grade)
	if mountGradeConfig and mountGradeConfig.god_arm_skill_sz ~= nil and mountGradeConfig.god_arm_skill_sz ~= "" then
		local skillIds = string.split(mountGradeConfig.god_arm_skill_sz, ":")
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
			print("下一步---self._skillProcess=",self._skillProcess)
			self._ccbOwner.node_status2:setVisible(true)
			self:setIconPath(skillConfig.icon)
			local actionArrayIn = CCArray:create()
			actionArrayIn:addObject(CCFadeIn:create(0.5))
			actionArrayIn:addObject(CCCallFunc:create(function ()
			  	self._actionHandler = nil
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "效果更新："..skillConfig.name, function ()
					local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
			        skillDesc = QColorLabel.removeColorSign(skillDesc)
			  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
						self._skillProcess = self._skillProcess + 2	
						if self._skillProcess == 6 then
							self._isEnd = true
						end
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

function QUIDialogMagicHerbBreedSuccess:skillHandler2()
	self._animationStage = "3"
	local mountGradeConfig = db:getGradeByHeroActorLevel(self._godarmInfo.id, self._godarmInfo.grade)
	if mountGradeConfig and mountGradeConfig.god_arm_skill_sz ~= nil and mountGradeConfig.god_arm_skill_yz ~= "" then
		local skillIds = string.split(mountGradeConfig.god_arm_skill_yz, ":")
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
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "效果更新："..skillConfig.name, function ()
					local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
			        skillDesc = QColorLabel.removeColorSign(skillDesc)
			  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
						self._skillProcess = self._skillProcess + 2	
						if self._skillProcess == 6 then
							self._isEnd = true
						end
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

function QUIDialogMagicHerbBreedSuccess:wordTypewriterEffect(tf, word, callback)
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

function QUIDialogMagicHerbBreedSuccess:setIconPath(path)
	if not path then
		return
	end
    self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogMagicHerbBreedSuccess:_onTriggerClose()
	if self._isEnd == true then
		if self._callback ~= nil then
			self._callback()
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
			self._isEnd = true
			if self._callback ~= nil then
				self._callback()
			end
			if self._scheduler then
				scheduler.unscheduleGlobal(self._scheduler)
				self._scheduler = nil
			end
			self:playEffectOut()
			-- scheduler.performWithDelayGlobal(function()
			-- 		self._isEnd = true
			-- 	end, 1)								
		end
	end
end

function QUIDialogMagicHerbBreedSuccess:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogMagicHerbBreedSuccess