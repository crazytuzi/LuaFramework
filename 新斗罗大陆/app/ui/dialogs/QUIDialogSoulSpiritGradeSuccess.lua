--
-- Kumo.Wang
-- 魂灵升星成功界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritGradeSuccess = class("QUIDialogSoulSpiritGradeSuccess", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QColorLabel = import("...utils.QColorLabel")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSoulSpiritGradeSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_GradeUp_Success.ccbi"
	local callBacks = {}
	QUIDialogSoulSpiritGradeSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")
	self._isEnd = false

	if options then
		self._callBack = options.callback
		self._id = options.id
	end

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))


	local oldGradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._soulSpiritInfo.id, self._soulSpiritInfo.grade-1) or {}
    local oldBox = QUIWidgetSoulSpiritHead.new()
    oldBox:setInfo(self._soulSpiritInfo)
    oldBox:setStar(self._soulSpiritInfo.grade - 1)
    self._ccbOwner.old_head:addChild(oldBox)
    self._ccbOwner.tf_old_name:setString(self._characterConfig.name)

	local uiPropList = remote.soulSpirit:getUiPropListByConfig(oldGradeConfig, true, false, true)
    local index = 1
	while true do
		local node = self._ccbOwner["prop_node_"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end
	index = 1
	local nameList = {}
	for _, tbl in ipairs(uiPropList) do
		local node = self._ccbOwner["prop_node_"..index]
		if node then
			node:setVisible(true)
			local tfName = self._ccbOwner["name_"..index]
			local tfValue = self._ccbOwner["old_prop_"..index]

			local isPercent = QActorProp._field[tbl.keys[1]].isPercent
        	local str = q.getFilteredNumberToString(tonumber(tbl.num), isPercent, 2) 

			if tfName then
				local name = ""
				if tbl.nameStr then
					name = tbl.nameStr
				else
					for i, key in ipairs(tbl.keys) do
						if name == "" then
							name = QActorProp._field[key].uiName or QActorProp._field[key].name
						else
							name = name.."、"..(QActorProp._field[key].uiName or QActorProp._field[key].name)
						end
					end
				end
				tfName:setString(name.."：")
				nameList[index] = name..tostring(isPercent)
			end
			if tfValue then
				tfValue:setString(str)
			end
			index = index + 1
		else
			break
		end
	end

	self._newGradeConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._soulSpiritInfo.id, self._soulSpiritInfo.grade) or {}
    local newBox = QUIWidgetSoulSpiritHead.new()
    newBox:setInfo(self._soulSpiritInfo)
    newBox:setStarVisible(false)

    local  gradeValue = self._soulSpiritInfo.grade

    if self._characterConfig.aptitude ~= APTITUDE.SS  then
    	gradeValue = self._soulSpiritInfo.grade + 1
    end

	self._newHeadVibrate = QUIWidgetHeroHeadVibrate.new({star = gradeValue, head = newBox, scale = 1})
	self._newHeadVibrate:setStarPosition(0, 0)
	self._ccbOwner.new_head:addChild(self._newHeadVibrate)
	self._scheduler = scheduler.performWithDelayGlobal(function()
		self._newHeadVibrate:playStarAnimation()
	end, 1.7)

    self._ccbOwner.tf_new_name:setString(self._characterConfig.name)

	local uiPropList = remote.soulSpirit:getUiPropListByConfig(self._newGradeConfig, true, false, true)
    local index = 1
	while true do
		local node = self._ccbOwner["prop_node_"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end

	for index, tfName in pairs(nameList) do
		for _, tbl in ipairs(uiPropList) do
			local name = ""
			local isPercent = QActorProp._field[tbl.keys[1]].isPercent
            local str = q.getFilteredNumberToString(tonumber(tbl.num), isPercent, 2)
			if tbl.nameStr then
				name = tbl.nameStr
			else
				for i, key in ipairs(tbl.keys) do
					if name == "" then
						name = QActorProp._field[key].uiName or QActorProp._field[key].name
					else
						name = name.."、"..(QActorProp._field[key].uiName or QActorProp._field[key].name)
					end
				end
			end
			local mark = name..tostring(isPercent)
			if tfName == mark then
				local node = self._ccbOwner["prop_node_"..index]
				if node then
					node:setVisible(true)
					local tfValue = self._ccbOwner["new_prop_"..index]
					if tfValue then
						tfValue:setString(str)
					end
				end
			end
		end
	end
	
	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)
	self._skillProcess = 0
	self._skillKey = ""
end

function QUIDialogSoulSpiritGradeSuccess:viewWillDisappear()
	QUIDialogSoulSpiritGradeSuccess.super.viewWillDisappear(self)
	
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end

	if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
end

function QUIDialogSoulSpiritGradeSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogSoulSpiritGradeSuccess:skillHandler()
	self._animationStage = "3"
	print("QUIDialogSoulSpiritGradeSuccess:skillHandler")
	-- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade + 1)
	if self._newGradeConfig and self._newGradeConfig[self._skillKey] ~= nil and self._newGradeConfig[self._skillKey] ~= "" then

		-- local endTarget = 4
		-- if self._newGradeConfig.soul_combat_succession then
		-- 	endTarget = 8
		-- end

		local skillIds = string.split(self._newGradeConfig[self._skillKey], ":")
		self._skillId = tonumber(skillIds[1])
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
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
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "魂灵技能："..skillConfig.name..rnumSkillLevel, function ()
            		local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
			        skillDesc = QColorLabel.removeColorSign(skillDesc)
			  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
						self._skillProcess = self._skillProcess + 2	
						-- if self._skillProcess == endTarget then
						-- 	self._isEnd = true
						-- end
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

function QUIDialogSoulSpiritGradeSuccess:skillAddCoefficientHandler()
	self._animationStage = "3"
	print("QUIDialogSoulSpiritGradeSuccess:skillAddCoefficientHandler")


	if self._newGradeConfig.soul_combat_succession and self._newGradeConfig.soul_combat_succession > 0 then
		if self._skillProcess == 6 then
			self._animationManager:runAnimationsForSequenceNamed("3")
		elseif self._skillProcess == 7 then
			self._ccbOwner.tf_skill_name:setString("")
			self._ccbOwner.tf_skill_desc:setString("")
			self._ccbOwner.node_skill:setOpacity(0)
		end
		self._ccbOwner.node_status2:setVisible(true)
		self:setIconPath(QResPath("soul_spirit_awaken_skill"))
		local actionArrayIn = CCArray:create()
		actionArrayIn:addObject(CCFadeIn:create(0.5))
		actionArrayIn:addObject(CCCallFunc:create(function ()
		  	self._actionHandler = nil
		  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "魂灵技能：".."魂力同化", function ()

				local addCoefficientGrade = self._newGradeConfig.soul_combat_succession
				local _,addCoefficientAptitude = remote.soulSpirit:getFightCoefficientByAptitude(self._characterConfig.aptitude)
				local skillDesc = "出战属性+"..q.PropPercentHanderFun(addCoefficientAptitude + addCoefficientGrade ).."(初始出战属性为上阵魂师的"..q.PropPercentHanderFun(addCoefficientAptitude)..")"
		
		  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
					self._skillProcess = self._skillProcess + 2	
					self._isEnd = true
		  		end)
		  	end)
		end))
		local ccsequence = CCSequence:create(actionArrayIn)
		self._actionHandler = self._ccbOwner.node_skill:runAction(ccsequence)
	else
		self._isEnd = true
		self:_onTriggerClose()
	end
end


function QUIDialogSoulSpiritGradeSuccess:wordTypewriterEffect(tf, word, callback)
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

function QUIDialogSoulSpiritGradeSuccess:setIconPath(path)
	if not path then
		return
	end
	if self._skillIcon == nil then
        self._skillIcon = CCSprite:create()
        self._ccbOwner.node_icon:addChild(self._skillIcon)
    end
    self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogSoulSpiritGradeSuccess:_onTriggerClose()
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
					self._skillProcess = self._skillProcess + 1
					end, 1)
			elseif self._skillProcess == 6 then
				self._skillProcess = self._skillProcess + 1
				self:skillAddCoefficientHandler()
			elseif self._skillProcess == 7 then
				self._skillProcess = self._skillProcess + 1
				self:skillAddCoefficientAnimation()
				scheduler.performWithDelayGlobal(function()
						self._isEnd = true
					end, 1)
			end		
		end
	end
end

function QUIDialogSoulSpiritGradeSuccess:jumpSkillAnimation( ... )
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    self._typewriterCallback = nil

	-- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade + 1)
	if self._newGradeConfig and self._newGradeConfig[self._skillKey] ~= nil and self._newGradeConfig[self._skillKey] ~= "" then
		local skillIds = string.split(self._newGradeConfig[self._skillKey], ":")
		self._skillId = tonumber(skillIds[1])
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
		self._ccbOwner.node_skill:setOpacity(255)
		self._ccbOwner.tf_skill_name:setString("魂灵技能："..skillConfig.name..rnumSkillLevel)
        local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
  		skillDesc = QColorLabel.removeColorSign(skillDesc)
		self._ccbOwner.tf_skill_desc:setString(skillDesc)
	end
end


function QUIDialogSoulSpiritGradeSuccess:skillAddCoefficientAnimation( ... )
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    self._typewriterCallback = nil

	if self._newGradeConfig.soul_combat_succession and self._newGradeConfig.soul_combat_succession > 0 then
		local addCoefficientGrade = self._newGradeConfig.soul_combat_succession
		local _,addCoefficientAptitude = remote.soulSpirit:getFightCoefficientByAptitude(self._characterConfig.aptitude)
		local skillDesc = "出战属性+"..q.PropPercentHanderFun(addCoefficientAptitude + addCoefficientGrade ).."(初始出战属性为上阵魂师的"..q.PropPercentHanderFun(addCoefficientAptitude)..")"
		self._ccbOwner.node_skill:setOpacity(255)
		self._ccbOwner.tf_skill_name:setString("魂灵技能：魂力同化")
		self._ccbOwner.tf_skill_desc:setString(skillDesc)
	end



end




function QUIDialogSoulSpiritGradeSuccess:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogSoulSpiritGradeSuccess