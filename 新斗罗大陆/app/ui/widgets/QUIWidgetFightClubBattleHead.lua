--
--	zxs
--	搏击俱乐部战斗头像
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightClubBattleHead = class("QUIWidgetFightClubBattleHead", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetFightClubBattleHead:ctor(options, num)
	local ccbFile = "ccb/Widget_fight_club_battlerecordinfo_head.ccbi"
	QUIWidgetFightClubBattleHead.super.ctor(self,ccbFile,callBacks,options)

	self._avatar = QUIWidgetAvatar.new(options.avatar)
	self._avatar:setSilvesArenaPeak(options.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)

	self._ccbOwner.tf_nickname:setString(options.name)
    self._ccbOwner.tf_level:setString(num)
    self._ccbOwner.sp_beat:setVisible(false)
end

function QUIWidgetFightClubBattleHead:setSelected( )
	self._avatar:setSelectState(true)
end

function QUIWidgetFightClubBattleHead:setDefeated( )
	makeNodeFromNormalToGray(self._avatar)
	self._ccbOwner.sp_beat:setVisible(true)
end

return QUIWidgetFightClubBattleHead