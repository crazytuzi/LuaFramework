-- @Author: xurui
-- @Date:   2019-12-30 17:57:30
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-14 11:29:30
local QUIDialogStormArenaEnemyTeamInfo = import(".QUIDialogStormArenaEnemyTeamInfo")
local QUIDialogTotemChallengeEnemyTeamInfo = class("QUIDialogTotemChallengeEnemyTeamInfo", QUIDialogStormArenaEnemyTeamInfo)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogTotemChallengeEnemyTeamInfo:ctor(options)
	local ccbFile = "Dialog_totemChallengeBattle_change.ccbi"
	if options == nil then
		options = {}
	end
	options.ccbFile = ccbFile
    QUIDialogTotemChallengeEnemyTeamInfo.super.ctor(self, options)
end

function QUIDialogTotemChallengeEnemyTeamInfo:setInfo()
    QUIDialogTotemChallengeEnemyTeamInfo.super.setInfo(self)

	local str = "守护队伍1"
	if self._trialNum == 2 then
		str = "守护队伍2"
	end
    self._ccbOwner.name:setString(str)

    local buffNum = self._fighterInfo.buffNum or 1
    local strFunc = function(heros, str)
        if buffNum then
            local actorId = 1001
            for index, value in ipairs(heros) do
                if index <= tonumber(buffNum) then
                    actorId = value.actorId
                end
            end

            local heroConfig = db:getCharacterByID(actorId)
            if heroConfig then
                local strs = string.split(str, "#HERO_NAME#")
                if strs[2] then
                    str = (strs[1] or "")..(heroConfig.name or "")..(strs[2] or "")
                end
            end
        end

        return str
    end

    local buffConfig = remote.totemChallenge:getBuffConfigById(self._fighterInfo.buffId or 1)
    local str = buffConfig["ruletext"..self._trialNum]

    if self._trialNum == 1 then
        str = strFunc(self._fighterInfo.heros, str)
    else
        str = strFunc(self._fighterInfo.main1Heros, str)
    end
    local lineWidth = 520
    if self._richText == nil then
        self._richText = QRichText.new("", lineWidth, {stringType = 1, defaultSize = 22, defaultColor = COLORS.a})
        self._richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc:addChild(self._richText)
    end
    self._richText:setString(str or "")
end

return QUIDialogTotemChallengeEnemyTeamInfo
