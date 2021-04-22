
--
-- qsy
-- 地狱杀戮场一键扫荡结算
--
local QUIDialog = import(".QUIDialog")
local QUIDialogFightClubQuickResult = class("QUIDialogFightClubQuickResult", QUIDialog)


function QUIDialogFightClubQuickResult:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_quick_result.ccbi"
	QUIDialogFightClubQuickResult.super.ctor(self, ccbFile, nil, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    CalculateUIBgSize(self._ccbOwner.ly_bg)

    if options then
    	self._callBack = options.callBack
    	self._winCount = options.winCount or 0
    end	
	self._bef_score_num = 0
	self._cur_score_num = 0
	self._cur_rank = 0
end



function QUIDialogFightClubQuickResult:viewDidAppear()
	QUIDialogFightClubQuickResult.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogFightClubQuickResult:viewWillDisappear()
  	QUIDialogFightClubQuickResult.super.viewWillDisappear(self)
end

function QUIDialogFightClubQuickResult:setInfo()

	local myinfo = remote.fightClub:getMyInfo()
	local roomRank = myinfo.roomRank or 1
	local myFloor = myinfo.fightClubFloor or 0

	local roomState = remote.fightClub:getRoomState(myFloor, roomRank)

	self._cur_score_num = myinfo.fightClubWinCount or 0
	self._bef_score_num = self._cur_score_num - self._winCount
	self._cur_rank = roomRank
	
	self._ccbOwner.tf_score_bef:setString(self._bef_score_num or "0")
	self._ccbOwner.tf_score_cur:setString(self._cur_score_num or "0")
	self._ccbOwner.tf_rank:setString(self._cur_rank or "0")

end

function QUIDialogFightClubQuickResult:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFightClubQuickResult:_onTriggerClose(event)
	self:playEffectOut()
end

function QUIDialogFightClubQuickResult:viewAnimationOutHandler()

	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end

end

return QUIDialogFightClubQuickResult