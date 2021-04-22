-- @Author: liaoxianbo
-- @Date:   2019-09-17 19:02:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 15:44:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodGemstoneActivitySuit = class("QUIDialogGodGemstoneActivitySuit", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGodGemstoneActivitySuit:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_taozhuangjihuo.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
	QUIDialogGodGemstoneActivitySuit.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	app.sound:playSound("hero_grow_up")
	self._isEnd = false
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))	
	self._animationManager:runAnimationsForSequenceNamed("1")

	self.callback = options.callback
	self._only_skill = false
	if options.only_skill then
		self._only_skill = options.only_skill
	end
	local suits = options.suits
	local count = #suits
	self._ccbOwner.node_icon:setPositionX(-(count - 1) * 115 + 345)

	self._ccbOwner.node_status1:setVisible(false)
	self._ccbOwner.node_status2:setVisible(false)

	self:initSuitIconDisplay(suits)
	self.god_skill = db:getGemstoneGodSkillByGemstones(suits,true)

	if not self._only_skill then
		self:initSuitPropDisplay(suits)
	else
		self:initSuitSkillDisplay()
	end

	self._successTip = options.successTip
	self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
    self._isSelected = false
    self:showSelectState()
end

function QUIDialogGodGemstoneActivitySuit:initSuitIconDisplay(suits)

	for i=1,4 do
		self._ccbOwner["node_"..i]:setVisible(false)
		self._ccbOwner["node_suit"..i]:setVisible(false)
		self._ccbOwner["tf_name"..i]:setVisible(false)
		if self._ccbOwner["node_plus"..i] ~= nil then
			self._ccbOwner["node_plus"..i]:setVisible(false)
		end
	end
	for index,gemstone in ipairs(suits) do
		local gemstoneInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL)

		local itemConfig = db:getItemByID(gemstoneInfo.gem_evolution_new_id)
		local realItemConfig = db:getItemByID(gemstone.itemId)

		local box = QUIWidgetGemstonesBox.new()
		box:setItemId(gemstoneInfo.gem_evolution_new_id)

		local godLevel = gemstone.godLevel or 0
		if gemstone.mix_level > 0 then
			godLevel = GEMSTONE_MAXADVANCED_LEVEL
		end

		box:setQuality(remote.gemstone:getSABC(realItemConfig.gemstone_quality).lower, godLevel)
		box:setGodLevel(gemstone.godLevel or 0)
		box:setStrengthVisible(false)
		self._ccbOwner["node_"..index]:addChild(box)
		self._ccbOwner["node_"..index]:setVisible(true)
		self._ccbOwner["tf_name"..index]:setString(itemConfig.name)
		self._ccbOwner["tf_name"..index]:setVisible(true)
		if self._ccbOwner["node_plus"..index] ~= nil then
			self._ccbOwner["node_plus"..index]:setVisible(true)
		end
	end
end



function QUIDialogGodGemstoneActivitySuit:initSuitPropDisplay(suits)
	local count = #suits
	if count > 0 then
		local gemstoneInfo = db:getGemstoneEvolutionBygodLevel(suits[1].itemId,GEMSTONE_MAXADVANCED_LEVEL)
		self._ccbOwner.node_status1:setVisible(true)
		-- local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(suits[1].itemId)
		local suitInfos = QStaticDatabase:sharedDatabase():getGemstoneSuitEffectBySuitId(gemstoneInfo.gem_evolution_new_set)
		for index,config in ipairs(suitInfos) do
			if config.set_number <= count then
				self._ccbOwner["node_suit"..index]:setVisible(true)
	        	self._ccbOwner["tf_num"..index]:setString(config.set_number)
	        	self._ccbOwner["tf_value"..index]:setString(config.set_desc)	        	
			end
	    end
	end
end

function QUIDialogGodGemstoneActivitySuit:initSuitSkillDisplay()
	self:skillHandler(true)
end


function QUIDialogGodGemstoneActivitySuit:skillHandler(_five)
	local str_index = "3"
	if _five then str_index = "5" end
	self._animationStage = str_index


	if self.god_skill then
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self.god_skill)
		if skillConfig ~= nil then
			self._animationManager:runAnimationsForSequenceNamed(str_index)
			self._ccbOwner.node_status2:setVisible(true)

			local skillIcon = self:_getSkillIcon(self.god_skill)
			self._ccbOwner.node_icon_skill:addChild(skillIcon)
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



function QUIDialogGodGemstoneActivitySuit:_getSkillIcon(skillId)
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


function QUIDialogGodGemstoneActivitySuit:wordTypewriterEffect(tf, word, callback)
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



function QUIDialogGodGemstoneActivitySuit:animationEndHandler(name)
	self._animationStage = name
end


function QUIDialogGodGemstoneActivitySuit:viewDidAppear()
	QUIDialogGodGemstoneActivitySuit.super.viewDidAppear(self)

end

function QUIDialogGodGemstoneActivitySuit:viewWillDisappear()
  	QUIDialogGodGemstoneActivitySuit.super.viewWillDisappear(self)

end

function QUIDialogGodGemstoneActivitySuit:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGodGemstoneActivitySuit:_backClickHandler()
	-- if self._isEnd == false then 
	-- 	return 
	-- end
    self:_onTriggerClose()
end
function QUIDialogGodGemstoneActivitySuit:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGodGemstoneActivitySuit:_onTriggerClose()
	if self._isEnd == true then
  		app.sound:playSound("common_close")
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			self:skillHandler()
		elseif self._animationStage == "2" then
			self:skillHandler()
		elseif self._animationStage == "5" then
			return 
		else
		    if self._typewriterTimeHandler ~= nil then
		    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
		    	self._typewriterTimeHandler = nil
		    end
		    if self._actionHandler ~= nil then
		    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
		    	self._actionHandler = nil
		    end
		   
			if self.god_skill then
			    local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self.god_skill)
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

function QUIDialogGodGemstoneActivitySuit:viewAnimationOutHandler()
	if self.callback ~= nil then 
		self.callback()
	end
    if self._isSelected == true then
		app.master:setMasterShowState(self._successTip)
    end
	self:popSelf()
end

return QUIDialogGodGemstoneActivitySuit
