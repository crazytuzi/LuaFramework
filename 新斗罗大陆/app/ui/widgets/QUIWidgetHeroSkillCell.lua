--
-- Author: wkwang
-- Date: 2014-10-21 10:41:36
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroSkillCell = class("QUIWidgetHeroSkillCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetHeroSkillCell.SHOW_EFFECT = "SHOW_EFFECT"
QUIWidgetHeroSkillCell.EVENT_BEGAIN = "SKILL_EVENT_BEGAIN"
QUIWidgetHeroSkillCell.EVENT_END = "SKILL_EVENT_END"
QUIWidgetHeroSkillCell.EVENT_BUY = "SKILL_EVENT_BUY"
QUIWidgetHeroSkillCell.EVENT_ADD = "SKILL_EVENT_ADD"

function QUIWidgetHeroSkillCell:ctor(options)
	self._skillSlot = options.skillSlot
	self._actorId = options.actorId
	self._content = options.content

	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._heroInfo = self._heroUIModel:getHeroInfo()
	self._skillInfo = self._heroUIModel:getSkillBySlot(self._skillSlot)
	self._skillId = self._skillInfo.skillId
	local ccbFile = ""
	local callBacks = {}
	if self._skillInfo.info ~= nil then
		ccbFile = "ccb/Widget_HeroSkillUpgarde_client.ccbi"
		table.insert(callBacks,  {ccbCallbackName = "onPlus", callback = handler(self, QUIWidgetHeroSkillCell._onPlus)})
	else
		ccbFile = "ccb/Widget_HeroSkillUpgarde_gray.ccbi"
	end

	QUIWidgetHeroSkillCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if self._skillInfo.info ~= nil then
		self:initSkillForHave()
	else
		self:initSkillForNone()
	end
	self._effectPlay = false
	self._parentMoveState = false
	if self._skillInfo.info then
		self.nums = self._skillInfo.info.slotLevel or 0
		self.costMoneyArr,self.maxCount = self:costMoneyTable()
	else
		self.nums = 0
		self.costMoneyArr = nil
		self.maxCount = 0
	end
	
	self.maxNum = self._heroInfo.level
	self.count = 0
	self.totalCost = 0
	self.clickCount = 0
end

function QUIWidgetHeroSkillCell:getHeight()
	return self._ccbOwner.node_mask:getContentSize().height
end

function QUIWidgetHeroSkillCell:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
    self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))
    self._ccbOwner.node_layer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.node_layer:setTouchEnabled(true)
    self._ccbOwner.node_layer:setTouchSwallowEnabled(false)
    self._ccbOwner.node_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetHeroSkillCell._onTouch))
end

function QUIWidgetHeroSkillCell:onExit()
    self._remoteProxy:removeAllEventListeners()
    self._userProxy:removeAllEventListeners()
    self._ccbOwner.node_icon:setTouchEnabled(false)
    self._ccbOwner.node_icon:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)

	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end
end

function QUIWidgetHeroSkillCell:onEvent(event)
	if event.name == remote.user.EVENT_USER_PROP_CHANGE then
		-- if self._skillInfo.info ~= nil then
		-- 	self._ccbOwner.node_tips:setVisible(self:checkCanUp())
		-- end
	elseif event.name == QRemote.HERO_UPDATE_EVENT then
		if self._skillInfo and self._skillInfo.info ~= nil then
			self._skillInfo = self._heroUIModel:getSkillBySlot(self._skillSlot)
			self:initSkillForHave()
		end
	end
end

--[[
	拥有该魂技
]]
function QUIWidgetHeroSkillCell:initSkillForHave()
	self._ccbOwner.node_tips:setVisible(false)
	local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
	if self._skillId == nil or skillConfig == nil or self._skillInfo.info == nil then return end
	self:setText("tf_name", skillConfig.name)
	self:setText("tf_level", "Lv:"..self._skillInfo.info.slotLevel)
	self:setIconPath(skillConfig.icon)
	local nextSkillConfig = self._skillInfo.nextConfig	
	if nextSkillConfig == nil or nextSkillConfig.hero_level > self._heroInfo.level then
		makeNodeFromNormalToGray(self._ccbOwner.btn_plus)
		if nextSkillConfig ~= nil then
  			if self._ccbOwner.sp_money ~= nil then
  				self._ccbOwner.sp_money:setVisible(true)
  			end
  			self:setText("tf_money", nextSkillConfig.item_cost or 0)
  		else
  			self:setText("tf_money", "")
  			if self._ccbOwner.sp_money ~= nil then
  				self._ccbOwner.sp_money:setVisible(false)
  			end
  		end
	else
  		self:setText("tf_money", nextSkillConfig.item_cost or 0)
	end

	--隐藏魂技格子上的小红点
	-- self._ccbOwner.node_tips:setVisible(self:checkCanUp())
end

--[[
	没有该魂技
]]
function QUIWidgetHeroSkillCell:initSkillForNone()
	local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
	self:setText("tf_name", skillConfig.name)
	self:setText("tf_unlock", "")
	-- self:setText("tf_level", "Lv：0")
	-- self:setText("tf_money", "0")
	self:setIconPath(skillConfig.icon)
	local breakthroughConfig = self._skillInfo.breakConfig	
    if breakthroughConfig ~= nil then
    	self:setText("tf_unlock", breakthroughConfig.desc or "")
    end
    makeNodeFromNormalToGray(self)
	self._ccbOwner.ly_bg_1:setStartColor(ccc3(10, 10, 10))
	self._ccbOwner.ly_bg_2:setStartColor(ccc3(10, 10, 10))
	self._ccbOwner.ly_bg_1:setStartOpacity(30)
	self._ccbOwner.ly_bg_2:setStartOpacity(30)
    q.setNodeShadow(self, true)
end

function QUIWidgetHeroSkillCell:setIconPath(path)
	if path == nil then
		return
	end
	if self._skillIcon == nil then
		self._skillIcon = CCSprite:create()
		self._ccbOwner.node_iconContent:addChild(self._skillIcon)
	end
	self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIWidgetHeroSkillCell:setText(name, text)
	if self._ccbOwner[name] then
		self._ccbOwner[name]:setString(text)
	end
end

function QUIWidgetHeroSkillCell:skillUpgradeSucc(addLevel)
	app.sound:playSound("hero_skill_up")
  	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_SKILL_SUCCESS})
	if self.initSkillForHave == nil or self._skillInfo.info == nil then return end
	self:initSkillForHave()
	local skillId = self._skillId
	local slotLevel = self._skillInfo.info.slotLevel
	self:dispatchEvent({name = QUIWidgetHeroSkillCell.EVENT_ADD, skillId = skillId, slotLevel = slotLevel, addLevel = addLevel})
	if self._effect == nil then
		self._effect = 	QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_iconContent:addChild(self._effect)
	end
	self._effect:setVisible(false)
	self._effect:playAnimation("ccb/effects/SkillUpgarde.ccbi")
end

function QUIWidgetHeroSkillCell:setOnPlusState(state)
	if state == false then 
    	makeNodeFromNormalToGray(self._ccbOwner.btn_plus)
	end
end

function QUIWidgetHeroSkillCell:checkCanUp(isTip)
    if app.unlock:getUnlockSkill(isTip) == false then
        return false
    end
    
    local canUpGrade, state = self._heroUIModel:checkSkillCanUpgradeBySlotId(self._skillSlot)
    if canUpGrade == false then
    	if state == self._heroUIModel.SKILL_STATE_TOP then
			if isTip == true then
	    		app.tip:floatTip("魂技已升级到顶级")
	    	end
	    elseif state == self._heroUIModel.SKILL_STATE_NO_LEVEL then
			if isTip == true then
	    		app.tip:floatTip("魂技等级已至上限，请升级魂师等级！")
	    	end
	    elseif state == self._heroUIModel.SKILL_STATE_NO_MONEY then
			if isTip == true then
    			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
	    	end
    	end
    	return false
    end

	local point, lastTime = remote.herosUtil:getSkillPointAndTime()
	if point > 0 then
		return true
	else
		if app.unlock:getUnlockUnlimitedSkillPoint() then
			return true
		else
			if isTip == true then
	        	self:dispatchEvent({name = QUIWidgetHeroSkillCell.EVENT_BUY})
	        end
	        return false
       	end
	end
	return false
end

function QUIWidgetHeroSkillCell:_onPlus(event)
	if app.unlock:getUnlockLongClickSkill() then
		if self:checkCanUp(true) == true then
			if tonumber(event) == CCControlEventTouchDown then
				self._ccbOwner.button_plus:setColor(ccc3(210, 210, 210))
				if self.count == 0 then
					self:_onDownHandler(1)
				end
			else
				self._ccbOwner.button_plus:setColor(ccc3(255, 255, 255))
				app.sound:playSound("common_increase")
				self:_onUpHandler(1)
			end
		end
	else
		if self:checkCanUp(true) == true then
			app:getClient():improveSkill(self._actorId, {{slotId = self._skillSlot, count = 1}}, function (data)
				local level = data.skillImproveYield 
				remote.user:addPropNumForKey("todaySkillImprovedCount", 1)
				if self.skillUpgradeSucc then
					self:skillUpgradeSucc(level)
				end
			end)
		end
	end
end

function QUIWidgetHeroSkillCell:_onDownHandler(num)
	self._isDown = true
	self._isUp = false
	self.costMoneyArr, self.maxCount = self:costMoneyTable()
	self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.5)
end

function QUIWidgetHeroSkillCell:_onUpHandler(num)
	self._isDown = false	
	self._isUp = true
	self:_subBuyNums(num)
end

function QUIWidgetHeroSkillCell:_subBuyNums(num)
	if self._calculatorScheduler then
		scheduler.unscheduleGlobal(self._calculatorScheduler)
		self._calculatorScheduler = nil
	end

	if self._isDown or self._isUp then
		self.totalCost = self.totalCost + (self.costMoneyArr[self.count+1] or 0)
		local point, lastTime = remote.herosUtil:getSkillPointAndTime()
		if self.totalCost > remote.user.money then
			self.nums = self.nums
			self.totalCost = self.totalCost - (self.costMoneyArr[self.count+1] or 0)
			self.count = self.count
		elseif self.nums <= 0 then
			self.nums = 1
			self.count = 0
		elseif self.nums >= self.maxNum then 
			self.nums = self.maxNum
			self.count = self.count
		elseif self.count >= point then
			if not app.unlock:getUnlockUnlimitedSkillPoint() then
				self.nums = self.nums
				self.count = self.count
			else
				self.nums = self.nums + num
				self.count = self.count + num
				self:playSkillUpAnimation()
			end
		else
			self.nums = self.nums + num
			self.count = self.count + num
			self:playSkillUpAnimation()
		end

		self:setText("tf_level", "Lv:"..self.nums)
		self:setText("tf_money", self.costMoneyArr[self.count+1] or 0)
		
		if self._isUp then 
			app:getClient():improveSkill(self._actorId, {{slotId = self._skillSlot, count = tonumber(self.count)}}, function (data)
				local level = data.skillImproveYield 
				remote.user:addPropNumForKey("todaySkillImprovedCount", self.count)
				if self.skillUpgradeSucc then
					self:skillUpgradeSucc(self.count)
					if self.count == 1 then
						if self.clickCount ~= -1 then
							self.clickCount = self.clickCount + 1
						end
					end
					if self.clickCount >= 5 then
						app.tip:floatTip("长按技能升级按钮可以快速升级噢~")
						self.clickCount = -1
					end
					self.costMoneyArr,self.maxCount = self:costMoneyTable()
					self.totalCost = 0
					self.count = 0
					self.nums = self._skillInfo.info.slotLevel or 0
				end
			end)
			return
		end
		self._calculatorScheduler = scheduler.performWithDelayGlobal(function()
			self:_subBuyNums(num)
		end, 0.05)
	end
end

function QUIWidgetHeroSkillCell:playSkillUpAnimation()
	if self._effect == nil then
        self._effect =  QUIWidgetAnimationPlayer.new()
        local topDialog = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        self._effect:setPosition(display.cx, display.cy)
        topDialog:getView():addChild(self._effect)
    end
    self._effect:setVisible(true)
    self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
        ccbOwner.title_skill:setString("魂技等级＋1")
        ccbOwner.node_1:setVisible(false)
    end, function ()
        
    end,false)
end

function QUIWidgetHeroSkillCell:costMoneyTable()
	local level = self._skillInfo.info.slotLevel
	-- local maxLevel = remote.user.level
	local maxLevel = self._heroInfo.level
	local cost = 0
	local costMoneyArr = {}
	local maxCount = 0
	if level <= maxLevel then
		maxCount = maxLevel - level
		for i = level, maxLevel, 1 do
			local config = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(self._skillId, i+1)
			cost = config.item_cost
			costMoneyArr[#costMoneyArr+1] = cost
		end
	end
	return costMoneyArr,maxCount 
end

function QUIWidgetHeroSkillCell:_onTouch(event)
	if event.name == "ended" or event.name == "cancelled" then
		if self._parentMoveState == false then 
			-- local slot = self._skillInfo.info or {slotLevel = 1, slotId = self._skillSlot}
			local slotLevel = 1
			if self._skillInfo.info ~= nil then
				slotLevel = self._skillInfo.info.slotLevel
			end
			app.tip:skillTip(self._skillId, slotLevel, nil, {actorId = self._actorId})
		end
	end
end

function QUIWidgetHeroSkillCell:setParentMoveState(state)
	self._parentMoveState = state
	if self._parentMoveState then
		app.tip:refreshTip()
	end
end	

return QUIWidgetHeroSkillCell