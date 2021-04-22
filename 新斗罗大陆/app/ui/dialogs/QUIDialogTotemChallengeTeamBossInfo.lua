-- @Author: xurui
-- @Date:   2019-12-30 17:58:56
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-30 18:14:07
local QUIDialogStormArenaEnemyTeamInfo = import("..dialogs.QUIDialogStormArenaEnemyTeamInfo")
local QUIDialogTotemChallengeTeamBossInfo = class("QUIDialogTotemChallengeTeamBossInfo", QUIDialogStormArenaEnemyTeamInfo)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogTotemChallengeTeamBossInfo:ctor(options)
	local ccbFile = "Dialog_totemChallengeBattle_change.ccbi"
	if options == nil then
		options = {}
	end
	options.ccbFile = ccbFile
    QUIDialogTotemChallengeTeamBossInfo.super.ctor(self, options})
end

function QUIDialogTotemChallengeTeamBossInfo:setInfo()
    QUIDialogTotemChallengeTeamBossInfo.super.setInfo(self)

	local str = "守护队伍1"
	if self._trialNum == 2 then
		str = "守护队伍2"
	end
    self._ccbOwner.name:setString(str)

    local buffConfig = remote.totemChallenge:getBuffConfigById(self._fighterInfo.buffId or 1)
    local str = buffConfig["ruletext"..self._trialNum]

    if self._richText == nil then
        self._richText = QRichText.new("", lineWidth, {stringType = 1, defaultSize = 22, defaultColor = COLORS.a})
        self._richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc:addChild(self._richText)
    end
    self._richText:setString(str or "")
end

return QUIDialogTotemChallengeTeamBossInfo
