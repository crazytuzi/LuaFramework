--
--	qsy
--	搏击俱乐部战斗头像
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightClubBattleQuick = class("QUIWidgetFightClubBattleQuick", QUIWidget)
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetFightClubBattleQuick:ctor(options)
	local ccbFile = "ccb/Widget_fight_club_quick.ccbi"
	QUIWidgetFightClubBattleQuick.super.ctor(self,ccbFile,callBacks,options)

	self._avatar = QUIWidgetAvatar.new(options.avatar)
	self._avatar:setSilvesArenaPeak(options.championCount)
    self._ccbOwner.node_headPicture:addChild(self._avatar)

	self._ccbOwner.tf_name:setString(options.name or "")
	local num, unit = q.convertLargerNumber(options.force or 0)
	self._ccbOwner.tf_force:setString(num..(unit or ""))
    self._ccbOwner.sp_beat:setVisible(false)
    self:_creatFightingAction()
end

function QUIWidgetFightClubBattleQuick:_creatFightingAction()

	self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/tiaozhanzhong_1", "res")
	self._fcaAnimation:playAnimation("animation", true)
	self._ccbOwner.node_fighting:addChild(self._fcaAnimation)	
end

function QUIWidgetFightClubBattleQuick:setDefeated(defeated)
	if defeated then
		makeNodeFromNormalToGray(self._avatar)
		self._ccbOwner.sp_beat:setVisible(true)
	else
		self._avatar:setSelectState(true)
	end
end

function QUIWidgetFightClubBattleQuick:setFightingVisible(_visible)
	self._ccbOwner.node_fighting:setVisible(_visible)
end


return QUIWidgetFightClubBattleQuick