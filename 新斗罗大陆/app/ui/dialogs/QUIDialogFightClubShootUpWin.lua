--
-- zxs
-- 搏击俱乐部直升胜利
--
local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubShootUpWin = class("QUIDialogFightClubShootUpWin", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogFightClubShootUpWin:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_zhishengwin.ccbi"
	local callBacks = {}
	QUIDialogFightClubShootUpWin.super.ctor(self,ccbFile,callBacks,options)
	
	CalculateUIBgSize(self._ccbOwner.ly_bg)
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
	self._isEnd = false

	self._callback = options.callback

	local mainInfo = remote.fightClub:getMainInfo()
    local mainLastInfo = remote.fightClub:getMainLastInfo()
	local oldFloor = QUIWidgetFloorIcon.new({floor = mainLastInfo.floor, isLarge = false})
	oldFloor:setScale(1.2)
    self._ccbOwner.old_icon:addChild(oldFloor)

    local newFloor = QUIWidgetFloorIcon.new({floor = mainInfo.floor, isLarge = false })
	newFloor:setScale(1.2)
    self._ccbOwner.new_icon:addChild(newFloor)

	self._audioHandler = app.sound:playSound("battle_complete")
end

function QUIDialogFightClubShootUpWin:animationEndHandler(name)
   self._isEnd = true
   self._animationManager:disconnectScriptHandler()
end

function QUIDialogFightClubShootUpWin:_backClickHandler()
	if self._isEnd then
		self:_onTriggerClose()
	end
end

function QUIDialogFightClubShootUpWin:_onTriggerClose()
  	app.sound:playSound("common_item")

	if self._audioHandler then
		audio.stopSound(self._audioHandler)
	end
	
  	self:viewAnimationOutHandler()
	if self._callback then
		self._callback()
	end
end

return QUIDialogFightClubShootUpWin