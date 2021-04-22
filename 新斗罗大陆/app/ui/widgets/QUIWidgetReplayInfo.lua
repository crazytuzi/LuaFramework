--
-- Author: Qinyuanji
-- Date: 2015-03-20
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetReplayInfo = class("QUIWidgetReplayInfo", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUnionAvatar = import("...utils.QUnionAvatar")

QUIWidgetReplayInfo.MIN_HEIGHT = 98
QUIWidgetReplayInfo.ADMIN_HEIGHT = 40
QUIWidgetReplayInfo.FONT_SIZE = 22
QUIWidgetReplayInfo.MARGIN = 5
QUIWidgetReplayInfo.ADMIN_COLOR = ccc3(0, 252, 255)
QUIWidgetReplayInfo.NONADMIN_COLOR = ccc3(253, 234, 183)

function QUIWidgetReplayInfo:ctor(options)
  	local ccbFile = "ccb/Widget_BattleInformationShow_client.ccbi"
  	local callBacks = {
  	}
  	QUIWidgetReplayInfo.super.ctor(self, ccbFile, callBacks, options)
    
    self._ccbOwner.name:setString(options.name or "")
    self._ccbOwner.win_flag:setVisible(options.result == 1)
    self._ccbOwner.lose_flag:setVisible(options.result ~= 1)
    self._ccbOwner.level:setString(options.level or 1)

    if options.isUnion then
        self._ccbOwner.node_info:setPositionX(-80)
        self._ccbOwner.win_flag:setVisible(false)
        self._ccbOwner.lose_flag:setVisible(false)
    end

    local avatar
    if options.isUnionAvatar then
        avatar = QUnionAvatar.new(options.avatar)
        self._ccbOwner.node_level:setVisible(false)
    else
        avatar = QUIWidgetAvatar.new(options.avatar)
        self._ccbOwner.node_level:setVisible(true)
    end
    self._ccbOwner.node_headPicture:addChild(avatar)

    self:setInfo(options.heroes)
end

function QUIWidgetReplayInfo:setInfo(heroes)
    for index, value in ipairs(heroes or {}) do
        local heroHead = QUIWidgetHeroHead.new()
        heroHead:setHeroInfo(value)
        heroHead:showSabc()
        self._ccbOwner["head"..index]:addChild(heroHead)
    end
end

return QUIWidgetReplayInfo