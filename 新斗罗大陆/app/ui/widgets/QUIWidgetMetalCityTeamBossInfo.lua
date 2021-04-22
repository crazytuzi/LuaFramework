-- @Author: xurui
-- @Date:   2018-11-09 17:36:54
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-01-18 11:50:01
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMetalCityTeamBossInfo = class("QUIWidgetMetalCityTeamBossInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

QUIWidgetMetalCityTeamBossInfo.EVENT_BOSSINFO_CLICK = "EVENT_BOSSINFO_CLICK"

function QUIWidgetMetalCityTeamBossInfo:ctor(options)
	local ccbFile = "ccb/Widget_metalCity_teambossinfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTiggerClickTrail", callback = handler(self, self._onTiggerClickTrail)},
		{ccbCallbackName = "onTriggerBossInfo", callback = handler(self, self._onTriggerBossInfo)},
    }
    QUIWidgetMetalCityTeamBossInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetMetalCityTeamBossInfo:onEnter()
end

function QUIWidgetMetalCityTeamBossInfo:onExit()
end

function QUIWidgetMetalCityTeamBossInfo:setInfo(fighterInfo, trialNum)
	self._trialNum = trialNum
	self._fighterInfo = fighterInfo

	local dungeonId = self._fighterInfo["dungeon_id_"..self._trialNum]
	local dungeonConfig = remote.metalCity:getMetalCityMapConfigById(dungeonId)
	local monsterId = dungeonConfig.monster_id
	if monsterId then
		if self._trailBossInfo == nil then
			self._trailBossInfo = QUIWidgetHeroHead.new()
			self._ccbOwner.node_monster_head:addChild(self._trailBossInfo)
			self._trailBossInfo:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onTiggerClickTrail))
		end
		self._trailBossInfo:setHero(monsterId)
		self._trailBossInfo:setBreakthrough(7)
	end

	local bossInfo = QStaticDatabase:sharedDatabase():getCharacterByID(dungeonConfig.monster_id)
	self._ccbOwner.tf_monster_name:setString(bossInfo.name or "")

	local monsterInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID(dungeonConfig.dungeon_id)
    local monster = QStaticDatabase:sharedDatabase():getMonstersById(monsterInfo.monster_id)
	self._ccbOwner.tf_monster_level:setString("LV. "..monster[1].npc_level)

	local str = "试炼1"
	if self._trialNum == 2 then
		str = "试炼2"
	end
	self._ccbOwner.tf_trial_title:setString(str)
end

function QUIWidgetMetalCityTeamBossInfo:setButtonStated(stated)
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

function QUIWidgetMetalCityTeamBossInfo:setTipState(stated)
	if stated == nil then return end

	self._ccbOwner.tf_tip:setVisible(stated)
end

function QUIWidgetMetalCityTeamBossInfo:getContentSize()
	local contentSize = self._ccbOwner.btn_trail:getContentSize()
	return CCSize(contentSize.width - 30, contentSize.height)
end

function QUIWidgetMetalCityTeamBossInfo:_onTiggerClickTrail()
	self:dispatchEvent({name = QUIWidgetMetalCityTeamBossInfo.EVENT_BOSSINFO_CLICK, trialNum = self._trialNum})
end

function QUIWidgetMetalCityTeamBossInfo:_onTriggerBossInfo()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityBossIntroduce",
		options = {trialNum = self._trialNum, info = self._fighterInfo}})
end


return QUIWidgetMetalCityTeamBossInfo
