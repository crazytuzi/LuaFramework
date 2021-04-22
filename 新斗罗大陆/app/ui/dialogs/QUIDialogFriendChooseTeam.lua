-- @Author: xurui
-- @Date:   2019-04-29 17:02:09
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-13 22:17:21
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFriendChooseTeam = class("QUIDialogFriendChooseTeam", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QFriendArrangement = import("...arrangement.QFriendArrangement")

function QUIDialogFriendChooseTeam:ctor(options)
	local ccbFile = "ccb/Dialog_Select_solo.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerTeam", callback = handler(self, self._onTriggerTeam)},
		{ccbCallbackName = "onTriggerMultipleTeam", callback = handler(self, self._onTriggerMultipleTeam)},
    }
    QUIDialogFriendChooseTeam.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._userId = options.userId
    end
end

function QUIDialogFriendChooseTeam:viewDidAppear()
	QUIDialogFriendChooseTeam.super.viewDidAppear(self)
end

function QUIDialogFriendChooseTeam:viewWillDisappear()
  	QUIDialogFriendChooseTeam.super.viewWillDisappear(self)
end

function QUIDialogFriendChooseTeam:_onTriggerTeam()
	app.sound:playSound("common_small")

	app:getClient():arenaQueryDefenseHerosRequest(self._userId, function(data)
		if self:safeCheck() then
			self._fighterInfo = data.arenaResponse.mySelf or {}
			self:startPK()
		end
	end)
end

function QUIDialogFriendChooseTeam:_onTriggerMultipleTeam()
	app.sound:playSound("common_small")

	remote.stormArena:stormArenaQueryDefenseHerosRequest(self._userId, function(data)
		if self:safeCheck() then
			self._fighterInfo = (data.towerFightersDetail or {})[1] or {}
			self:startMuiltipleTeamPK()
		end
	end)
end

function QUIDialogFriendChooseTeam:startPK()
    app:triggerBuriedPoint(21620)
	if q.isEmpty(self._fighterInfo.heros) then
		app.tip:floatTip("魂师大人，对方没有魂师敢出战，饶了他吧！")
		return
	end

	local myInfo = {}
	local dungeonArrangement = QFriendArrangement.new({rivalInfo = self._fighterInfo, myInfo = myInfo, teamKey = remote.teamManager.ARENA_ATTACK_TEAM})
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
     	options = {arrangement = dungeonArrangement, isQuickWay = self.isQuickWay}})
end

function QUIDialogFriendChooseTeam:startMuiltipleTeamPK()
    app:triggerBuriedPoint(21621)
	if q.isEmpty(self._fighterInfo.heros) or q.isEmpty(self._fighterInfo.main1Heros) then
		app.tip:floatTip("对方还未开启两队切磋")
		return
	end

	local myInfo = {avatar = remote.user.avatar, name = remote.user.nickname, level = remote.user.level}
	local arenaArrangement1 = QFriendArrangement.new({myInfo = myInfo, rivalInfo = self._fighterInfo, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM1})
	local arenaArrangement2 = QFriendArrangement.new({myInfo = myInfo, rivalInfo = self._fighterInfo, teamKey = remote.teamManager.STORM_ARENA_ATTACK_TEAM2})
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
		options = {arrangement1 = arenaArrangement1, arrangement2  = arenaArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", 
		fighterInfo = self._fighterInfo}})
end

function QUIDialogFriendChooseTeam:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFriendChooseTeam:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogFriendChooseTeam:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogFriendChooseTeam
