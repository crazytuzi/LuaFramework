-- @Author: xurui
-- @Date:   2019-12-30 17:58:56
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-09 16:10:33
local QUIWidgetStormArenaTeamBossInfo = import(".QUIWidgetStormArenaTeamBossInfo")
local QUIWidgetTotemChallengeTeamBossInfo = class("QUIWidgetTotemChallengeTeamBossInfo", QUIWidgetStormArenaTeamBossInfo)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIWidgetTotemChallengeTeamBossInfo:ctor(options)
    QUIWidgetTotemChallengeTeamBossInfo.super.ctor(self, options)
    
    self:setTipState(false)
end

function QUIWidgetTotemChallengeTeamBossInfo:setInfo(fighterInfo, trialNum, isDefence)
    QUIWidgetTotemChallengeTeamBossInfo.super.setInfo(self, fighterInfo, trialNum, isDefence)

	local str = "守护队伍1"
	if self._trialNum == 2 then
		str = "守护队伍2"
	end
    self._ccbOwner.tf_team:setString(str)
end

function QUIWidgetTotemChallengeTeamBossInfo:_onTriggerBossInfo()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTotemChallengeEnemyTeamInfo",
		options = {trialNum = self._trialNum, info = self._fighterInfo, isDefence = self._isDefence}})
end

return QUIWidgetTotemChallengeTeamBossInfo
