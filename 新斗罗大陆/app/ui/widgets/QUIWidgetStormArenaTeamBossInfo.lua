-- @Author: xurui
-- @Date:   2018-11-13 11:03:54
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-08 10:43:54
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetStormArenaTeamBossInfo = class("QUIWidgetStormArenaTeamBossInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetStormArenaTeamBossInfo.EVENT_BOSSINFO_CLICK = "EVENT_BOSSINFO_CLICK"

function QUIWidgetStormArenaTeamBossInfo:ctor(options)
	local ccbFile = "ccb/Widget_StormArena_trail.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTiggerClickTrail", callback = handler(self, self._onTiggerClickTrail)},
		{ccbCallbackName = "onTriggerBossInfo", callback = handler(self, self._onTriggerBossInfo)},
    }
    QUIWidgetStormArenaTeamBossInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetStormArenaTeamBossInfo:onEnter()
end

function QUIWidgetStormArenaTeamBossInfo:onExit()
end

function QUIWidgetStormArenaTeamBossInfo:setInfo(fighterInfo, trialNum, isDefence)
	self._trialNum = trialNum
	self._fighterInfo = fighterInfo
	self._isDefence = isDefence

	local heroInfo = {}
	if self._trialNum == 1 and q.isEmpty(self._fighterInfo.heros) == false then
		heroInfo = remote.herosUtil:getMaxForceByHeros(self._fighterInfo)
	elseif self._trialNum == 2 and q.isEmpty(self._fighterInfo.main1Heros) == false then
		heroInfo = remote.herosUtil:getMaxForceBySecondTeamHeros(self._fighterInfo)
	end
	
	if heroInfo then

		local characherDisplay = QStaticDatabase:sharedDatabase():getCharacterByID(heroInfo.actorId)
		if characherDisplay then
			if self._heroHead == nil then
				self._heroHead = QUIWidgetHeroHead.new()
				self._ccbOwner.node_monster_head:addChild(self._heroHead)
				self._heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onTiggerClickTrail))
				self._heroHead:setScale(0.8)
			end
			self._heroHead:setVisible(true)
			self._heroHead:setHeroInfo(heroInfo)
			self._ccbOwner.sp_no_hero:setVisible(false)
		else
			self._ccbOwner.sp_no_hero:setVisible(true)
			if self._heroHead then
				self._heroHead:setVisible(false)
			end
		end
	end

	local str = "敌方队伍1"
	if self._isDefence then
		str = "我方队伍1"
		if trialNum == 2 then
			str = "我方队伍2"
		end
	else
		if trialNum == 2 then
			str = "敌方队伍2"
		end
	end
	self._ccbOwner.tf_team:setString(str)
end

function QUIWidgetStormArenaTeamBossInfo:setButtonStated(stated)
	if stated then
		self:getView():setScale(1)
		self._ccbOwner.btn_trail:setHighlighted(true)
		self._ccbOwner.btn_trail:setEnabled(false)
		self._ccbOwner.sp_gray:setVisible(false)
	else
		self:getView():setScale(0.8)
		self._ccbOwner.btn_trail:setHighlighted(false)
		self._ccbOwner.btn_trail:setEnabled(true)
		self._ccbOwner.sp_gray:setVisible(true)
	end
end

function QUIWidgetStormArenaTeamBossInfo:setTipState(stated)
	if stated == nil then return end

	self._ccbOwner.tf_tip:setVisible(stated)
end

function QUIWidgetStormArenaTeamBossInfo:getContentSize()
	local contentSize = self._ccbOwner.btn_trail:getContentSize()
	return CCSize(contentSize.width - 20, contentSize.height)
end

function QUIWidgetStormArenaTeamBossInfo:_onTiggerClickTrail()
	self:dispatchEvent({name = QUIWidgetStormArenaTeamBossInfo.EVENT_BOSSINFO_CLICK, trialNum = self._trialNum})
end

function QUIWidgetStormArenaTeamBossInfo:_onTriggerBossInfo()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStormArenaEnemyTeamInfo",
		options = {trialNum = self._trialNum, info = self._fighterInfo, isDefence = self._isDefence}})
end

return QUIWidgetStormArenaTeamBossInfo
