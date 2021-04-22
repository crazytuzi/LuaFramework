--
-- Author: Your Name
-- Date: 2015-10-13 19:03:56
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodHeroSkillCell = class("QUIWidgetGodHeroSkillCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetGodHeroSkillCell:ctor(options)
	local ccbFile = "ccb/Widget_HeroSkillUpgarde_client3.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetGodHeroSkillCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._actorId = options.actorId

	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
	self._progressWidth = self._ccbOwner.sp_progress:getContentSize().width
	self._progressStencil = progress:getStencil()
	self:initSkill()
end

function QUIWidgetGodHeroSkillCell:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
end

function QUIWidgetGodHeroSkillCell:onExit()
    self._remoteProxy:removeAllEventListeners()
end

function QUIWidgetGodHeroSkillCell:getHeight()
	return self._ccbOwner.node_mask:getContentSize().height
end

function QUIWidgetGodHeroSkillCell:onEvent(event)
	if event.name == remote.HERO_UPDATE_EVENT then
		if self.initSkill then
			self:initSkill()
		end
	end
end

function QUIWidgetGodHeroSkillCell:initSkill()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local godSkillGrade = heroInfo.godSkillGrade
	local godSkillConfig = db:getGodSkillByIdAndGrade(self._actorId, godSkillGrade)
    local skillIds = string.split(godSkillConfig.skill_id, ";")
    self._skillId = skillIds[1]
	self._skillInfo = db:getSkillByID(self._skillId)
	self._ccbOwner.tf_name:setString("神技·"..(self._skillInfo.name or ""))

	local skillIcon = QUIWidgetHeroSkillBox.new()
	skillIcon:setLock(false)
	skillIcon:setSkillID(self._skillId)
	skillIcon:setGodSkillShowLevel(godSkillGrade, self._actorId)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(skillIcon)

	-- @godSkillGrade ： 是神技的真实等级，godSkillLevel是神技的显示等级。
	-- @godSkillLevel ： 没有神技-1，ss+ 0～5级， ss 1～5级，对应显示神0～神5
	local godSkillLevel = remote.herosUtil:getGodSkillLevelByActorId(self._actorId)
	-- 星星月亮太阳
	local system = 5
	local index = 1
	while true do
		local bgNode = self._ccbOwner["node_bg_"..index]
		local lightNode = self._ccbOwner["node_light_"..index]
		if bgNode and lightNode then
			if (index == 1 and godSkillLevel == 0) or (godSkillLevel > (system * (index - 1)) and godSkillLevel <= system * index) then
				bgNode:setVisible(true)
				lightNode:setVisible(true)

				for i = 1, system do
					local sp = self._ccbOwner["sp_"..index.."_"..i]
					if sp then
						sp:setVisible(i <= (godSkillLevel - system * (index - 1)))
					end
				end
			else
				bgNode:setVisible(false)
				lightNode:setVisible(false)
			end
			index = index + 1
		else
			break
		end
	end

	-- 显示魂力精魄
    local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, 1)
    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(gradeConfig.soul_gem, ITEM_TYPE.ITEM, 0)
    itemBox:hideSabc()
    itemBox:hideTalentIcon()
    itemBox:setScale(0.4)
	self._ccbOwner.node_hero_icon:removeAllChildren()
    self._ccbOwner.node_hero_icon:addChild(itemBox)

	local newGodSkillConfig = db:getGodSkillByIdAndGrade(self._actorId, godSkillGrade+1)
    if newGodSkillConfig then
	    local soulNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
	   	local value = soulNum/newGodSkillConfig.stunt_num
	   	if value > 1 then
	   		value = 1
	   	end
	    local progressStr = string.format("%d/%d", soulNum, newGodSkillConfig.stunt_num)
	    self._progressStencil:setPositionX(value*self._progressWidth - self._progressWidth)
	    self._ccbOwner.tf_progress:setString(progressStr)
	    self._ccbOwner.node_tips:setVisible(value==1)
    else
    	self._ccbOwner.tf_progress:setString("已进阶到上限")
    	self._ccbOwner.node_tips:setVisible(false)
    	self._progressStencil:setPositionX(0)
    end
end

function QUIWidgetGodHeroSkillCell:_onTriggerClick(event)
    app.sound:playSound("common_common")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSuperHeroGodSkill", 
		options = {actorId = self._actorId}},{isPopCurrentDialog = false})
end

return QUIWidgetGodHeroSkillCell