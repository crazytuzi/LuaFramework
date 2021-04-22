--
-- zxs
-- 搏击俱乐部快速胜利
--
local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubQuickFightResult = class("QUIDialogFightClubQuickFightResult", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogFightClubQuickFightResult:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_jieshu.ccbi"
	local callBacks = {}
	QUIDialogFightClubQuickFightResult.super.ctor(self,ccbFile,callBacks,options)
    CalculateUIBgSize(self._ccbOwner.ly_bg)
	
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
	self._isEnd = false

	self._callback = options.callback

    self._ccbOwner.win_count:setString("")
	self._ccbOwner.win_add:setString("")
	self._ccbOwner.server_rank:setString("")
	self._ccbOwner.server_add:setString("")
	self._ccbOwner.ranking:setString("")
	self._ccbOwner.ranking_add:setString("")

	local mainInfo = remote.fightClub:getMainInfo()
    local mainLastInfo = remote.fightClub:getMainLastInfo()
    -- local winAdd = mainInfo.winCount - mainLastInfo.winCount
    -- if winAdd < 0 then
    -- 	self._ccbOwner.win_add:setColor(COLORS.e)
    -- end
    -- winAdd = self:scoreChangeStr(winAdd)
    self._ccbOwner.win_count:setString(mainLastInfo.winCount)
	self._ccbOwner.win_add:setString(mainInfo.winCount)

    -- local rankingAdd = mainInfo.roomRank - mainLastInfo.roomRank
    -- if rankingAdd < 0 then
    -- 	self._ccbOwner.ranking_add:setColor(COLORS.e)
    -- end
    -- rankingAdd = self:scoreChangeStr(rankingAdd)
	self._ccbOwner.ranking:setString(mainInfo.roomRank)
	--self._ccbOwner.ranking_add:setString(rankingAdd)

    local rankAdd = mainInfo.envRank - mainLastInfo.envRank
    if rankAdd < 0 then
    	self._ccbOwner.server_add:setColor(COLORS.e)
    end
    rankAdd = self:scoreChangeStr(rankAdd)
	self._ccbOwner.server_rank:setString(mainInfo.envRank)
	--self._ccbOwner.server_add:setString(rankAdd)

  	if options.isWin then
		self._audioHandler = app.sound:playSound("battle_complete")
	else
		self._audioHandler = app.sound:playSound("battle_failed")
	end
end

--分数变化（+4）
function QUIDialogFightClubQuickFightResult:scoreChangeStr(num)
    if not num then
        return "" 
    end
    if num >= 0 then 
        return "( +"..num.." )"
    else
        return "( "..num.." )"
    end
end

function QUIDialogFightClubQuickFightResult:animationEndHandler(name)
   self._isEnd = true
   self._animationManager:disconnectScriptHandler()
end

function QUIDialogFightClubQuickFightResult:_backClickHandler()
	if self._isEnd then
		self:_onTriggerClose()
	end
end

function QUIDialogFightClubQuickFightResult:_onTriggerClose()
  	app.sound:playSound("common_item")

	if self._audioHandler then
		audio.stopSound(self._audioHandler)
	end
	
  	self:viewAnimationOutHandler()
	if self._callback then
		self._callback()
	end
	remote.fightClub:requestFightClubInfo()
end

return QUIDialogFightClubQuickFightResult