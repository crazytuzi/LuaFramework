--
-- Author: Your Name
-- Date: 2015-10-13 19:03:56
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAssistHeorSkillCell = class("QUIWidgetAssistHeorSkillCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")

QUIWidgetAssistHeorSkillCell.SHOW_EFFECT = "SHOW_EFFECT"
QUIWidgetAssistHeorSkillCell.EVENT_BEGAIN = "SKILL_EVENT_BEGAIN"
QUIWidgetAssistHeorSkillCell.EVENT_END = "SKILL_EVENT_END"
QUIWidgetAssistHeorSkillCell.EVENT_BUY = "SKILL_EVENT_BUY"
QUIWidgetAssistHeorSkillCell.EVENT_ADD = "SKILL_EVENT_ADD"
QUIWidgetAssistHeorSkillCell.SHORT_SKILL_CELL_TYPE = "SHORT_SKILL_CELL_TYPE"
QUIWidgetAssistHeorSkillCell.BIG_SKILL_CELL_TYPE = "BIG_SKILL_CELL_TYPE"

function QUIWidgetAssistHeorSkillCell:ctor(options)
	local ccbFile = "ccb/Widget_HeroSkillUpgarde_client2.ccbi"
	local callBack = {
	{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)}}
	QUIWidgetAssistHeorSkillCell.super.ctor(self, ccbFile, callBack, options)

	self._skillSlot = options.skillSlot
	self._actorId = options.actorId
	self._assistSkill = options.assistSkill

	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)

	if self._heroUIModel ~= nil then
		self._skillInfo = self._heroUIModel:getSkillBySlot(self._skillSlot)
	else
		local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(self._actorId, self._skillSlot)
		self._skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
	end
	self._skillId = self._assistSkill.Super_skill or self._skillInfo.skillId or self._skillInfo.id

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._effectPlay = false
	self.isHave = false
	self._isShadow = false

	self:initSkillForHave()
end

function QUIWidgetAssistHeorSkillCell:getHeight()
	return self._ccbOwner.node_mask:getContentSize().height
end

function QUIWidgetAssistHeorSkillCell:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
    self._userProxy = cc.EventProxy.new(remote.user)
    self._userProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))

    self._ccbOwner.node_layer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.node_layer:setTouchEnabled(true)
    self._ccbOwner.node_layer:setTouchSwallowEnabled(false)
    self._ccbOwner.node_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetAssistHeorSkillCell._onTouch))
end

function QUIWidgetAssistHeorSkillCell:onExit()
    self._remoteProxy:removeAllEventListeners()
    self._userProxy:removeAllEventListeners()
    self._ccbOwner.node_icon:setTouchEnabled(false)
    self._ccbOwner.node_icon:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
end

function QUIWidgetAssistHeorSkillCell:onEvent(event)
	if event.name == remote.user.EVENT_USER_PROP_CHANGE then
		-- if self._skillInfo.info ~= nil then
		-- 	self._ccbOwner.node_tips:setVisible(self:checkCanUp())
		-- end
	elseif event.name == remote.HERO_UPDATE_EVENT then
		if self._skillInfo and self._skillInfo.info ~= nil then
			self._skillInfo = self._heroUIModel:getSkillBySlot(self._skillSlot)
			self:initSkillForHave()
		end
	end
end

--[[
	拥有该魂技
]]
function QUIWidgetAssistHeorSkillCell:initSkillForHave()
	self._ccbOwner.node_tips:setVisible(false)
	local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
	if skillConfig == nil then return end
	local text = "【融合·"..(skillConfig.name or "").."】"
	self._ccbOwner.tf_name:setString(text)

	local skillIcon = QUIWidgetHeroSkillBox.new()
	skillIcon:setLock(false)
	skillIcon:setSuperSkill(true)
	skillIcon:setSkillID(self._skillId)
	self._ccbOwner.node_iconContent:removeAllChildren()
	self._ccbOwner.node_iconContent:addChild(skillIcon)
	self._ccbOwner.tf_content:setString(self._assistSkill.super_skill_postil or "")

	local assistHero = false
	assistHero, self.isHave = remote.herosUtil:checkHeroHaveAssistHero(self._actorId)

	if self.isHave == false then 
	    if self._timeScheduler ~= nil then
	    	scheduler.unscheduleGlobal(self._timeScheduler)
	    	self._timeScheduler = nil
	    end
		makeNodeFromNormalToGray(self._ccbOwner.node_iconContent)
		makeNodeFromNormalToGray(self._ccbOwner.node_frame)
	end

	self._ccbOwner.sp_title_normal:setVisible(not self.isHave)
	self._ccbOwner.sp_title_done:setVisible(self.isHave)	
end

function QUIWidgetAssistHeorSkillCell:checkIsHaveAssist()
	local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.INSTANCE_TEAM)
	if q.isEmpty(teamVO) then return end

	local haveHero = false
	local haveAssistHero = true
	local teams = {}
	for i = 1, 2, 1 do
		if haveHeros[i] == nil then break end
		for j = 1, #haveHeros[i], 1 do
			if haveHeros[i][j] ~= nil then
				teams[tostring(haveHeros[i][j])] = haveHeros[i][j]
			end
		end
	end

	for i = 1, 3, 1 do
		if self._assistSkill["Deputy_hero"..i] ~= nil and teams[tostring(self._assistSkill["Deputy_hero"..i])] == nil then
			haveAssistHero = false
		end
	end
	if teams[tostring(self._assistSkill.hero)] then
		haveHero = true
	end

	if haveAssistHero and haveHero then
		self.isHave = true
	end
end

function QUIWidgetAssistHeorSkillCell:setIconPath(node)
	local skillIcon = QUIWidgetHeroSkillBox.new()
	skillIcon:setLock(false)
	skillIcon:setSkillID(skillId)
	node:addChild(skillIcon)
end

function QUIWidgetAssistHeorSkillCell:setText(name, text)
	if self._ccbOwner[name] then
		self._ccbOwner[name]:setString(text)
	end
end

function QUIWidgetAssistHeorSkillCell:checkCanUp(isTip)
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
		if isTip == true then
        	self:dispatchEvent({name = QUIWidgetAssistHeorSkillCell.EVENT_BUY})
        end
        return false
	end
	return false
end

function QUIWidgetAssistHeorSkillCell:_onTouch(event)
	self._skillInfo.info = self._skillInfo.info or {slotLevel = 1, slotId = self._skillSlot, skillId = self._skillId}

  	if event.name == "ended" or event.name == "cancelled" then
        app.sound:playSound("common_common")
   		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
   			options = {actorId = self._actorId, assistSkill = self._assistSkill, skillSlotInfo = self._skillInfo}},{isPopCurrentDialog = false})
  	end
end

return QUIWidgetAssistHeorSkillCell