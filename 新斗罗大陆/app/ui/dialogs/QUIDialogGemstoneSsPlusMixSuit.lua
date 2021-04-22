-- @Author: liaoxianbo
-- @Date:   2019-09-17 19:02:32
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 15:44:58
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneSsPlusMixSuit = class("QUIDialogGemstoneSsPlusMixSuit", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGemstoneSsPlusMixSuit:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_taozhuangjihuo.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
    }
	QUIDialogGemstoneSsPlusMixSuit.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	app.sound:playSound("hero_grow_up")
	self._isEnd = false
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))	
	self._animationManager:runAnimationsForSequenceNamed("1")
	self._only_skill = false
	local suits ={}
	if options then
		self.callback = options.callback
		if options.onlySkill then
			self._only_skill = options.onlySkill
		end
		self._skillId = options.skillId
		suits= options.suits or {}
	end
	local count = #suits
	self._ccbOwner.node_icon:setPositionX(-(count - 1) * 115 + 345)
	self._ccbOwner.node_status1:setVisible(false)
	self._ccbOwner.node_status2:setVisible(false)
	self:initSuitIconDisplay(suits)
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

function QUIDialogGemstoneSsPlusMixSuit:initSuitIconDisplay(suits)

	for i=1,4 do
		self._ccbOwner["node_"..i]:setVisible(false)
		self._ccbOwner["node_suit"..i]:setVisible(false)
		self._ccbOwner["tf_name"..i]:setVisible(false)
		if self._ccbOwner["node_plus"..i] ~= nil then
			self._ccbOwner["node_plus"..i]:setVisible(false)
		end
	end
	for index,gemstone in ipairs(suits) do
		local itemConfig = db:getItemByID(gemstone.itemId)
		local box = QUIWidgetGemstonesBox.new()
		box:setGemstoneInfo(gemstone)
		box:setStrengthVisible(false)
		self._ccbOwner["node_"..index]:addChild(box)
		self._ccbOwner["node_"..index]:setVisible(true)
		self._ccbOwner["tf_name"..index]:setString("SS+"..itemConfig.name)
		self._ccbOwner["tf_name"..index]:setVisible(true)
		if self._ccbOwner["node_plus"..index] ~= nil then
			self._ccbOwner["node_plus"..index]:setVisible(true)
		end
	end
end



function QUIDialogGemstoneSsPlusMixSuit:initSuitPropDisplay(suits)
	local count = #suits
	if count > 0 then
    	local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(suits[1].itemId, 1)
		if mixConfig and mixConfig.gem_suit then
			self._ccbOwner.node_status1:setVisible(true)
			for i=1,3 do
				if i + 1 <= count then
					local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, i + 1,1)
					if suitSkill then
						self._ccbOwner["node_suit"..i]:setVisible(true)
        				self._ccbOwner["tf_num"..i]:setString(i + 1)
        				self._ccbOwner["tf_value"..i]:setString(suitSkill.set_desc)
					end
				end
			end
		end
	end
end

function QUIDialogGemstoneSsPlusMixSuit:initSuitSkillDisplay()
	self:skillHandler(true)
end


function QUIDialogGemstoneSsPlusMixSuit:skillHandler(_five)
	local str_index = "3"
	if _five then str_index = "5" end
	self._animationStage = str_index


	if self._skillId then
		local skillConfig = db:getSkillByID(self._skillId)
		if skillConfig ~= nil then
			self._animationManager:runAnimationsForSequenceNamed(str_index)
			self._ccbOwner.node_status2:setVisible(true)

			local skillIcon = self:_getSkillIcon(self._skillId)
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



function QUIDialogGemstoneSsPlusMixSuit:_getSkillIcon(skillId)
	local skillItemBox = nil
	if skillId ~= nil then
		local skillData = db:getSkillByID(skillId)
		skillItemBox = QUIWidgetHeroSkillBox.new()
		skillItemBox:setColor("orange")
		skillItemBox:setSkillID(skillId)
		skillItemBox:setLock(false)
	end

	return skillItemBox
end


function QUIDialogGemstoneSsPlusMixSuit:wordTypewriterEffect(tf, word, callback)
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



function QUIDialogGemstoneSsPlusMixSuit:animationEndHandler(name)
	self._animationStage = name
end


function QUIDialogGemstoneSsPlusMixSuit:viewDidAppear()
	QUIDialogGemstoneSsPlusMixSuit.super.viewDidAppear(self)

end

function QUIDialogGemstoneSsPlusMixSuit:viewWillDisappear()
  	QUIDialogGemstoneSsPlusMixSuit.super.viewWillDisappear(self)

end

function QUIDialogGemstoneSsPlusMixSuit:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGemstoneSsPlusMixSuit:_backClickHandler()
	-- if self._isEnd == false then 
	-- 	return 
	-- end
    self:_onTriggerClose()
end
function QUIDialogGemstoneSsPlusMixSuit:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGemstoneSsPlusMixSuit:_onTriggerClose()
	if self._isEnd == true then
  		app.sound:playSound("common_close")
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			self:skillHandler(false)
		elseif self._animationStage == "2" then
			self:skillHandler(false)
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
		   
			if self._skillId then
			    local skillConfig = db:getSkillByID(self._skillId)
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

function QUIDialogGemstoneSsPlusMixSuit:viewAnimationOutHandler()
	if self.callback ~= nil then 
		self.callback()
	end
    if self._isSelected == true then
		app.master:setMasterShowState(self._successTip)
    end
	self:popSelf()
end

return QUIDialogGemstoneSsPlusMixSuit
