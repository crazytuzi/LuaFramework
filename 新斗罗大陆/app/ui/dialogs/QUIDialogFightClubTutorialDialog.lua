-- 
-- zxs
-- 地狱杀戮场玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFightClubTutorialDialog = class("QUIDialogFightClubTutorialDialog", QUIDialog)
local QRichText = import("...utils.QRichText")

local DESC_TEXT = {
	"同段位十人开房乱斗，掠夺对手的血腥玛丽提升房间排名。",
	"排名高者晋级提升段位，低者降级段位下降。",
	"全新排位系统，争夺最强王者席位。",
}

function QUIDialogFightClubTutorialDialog:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogFightClubTutorialDialog.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._helpPic = QResPath("fight_club_help_pic")
	self._maxNum = #self._helpPic
	
	self._curIndex = 1
	self:updateShowImage()
end

function QUIDialogFightClubTutorialDialog:updateShowImage()
	self._ccbOwner.tf_desc:setString(DESC_TEXT[self._curIndex] or "")

	if self._helpPic[self._curIndex] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._helpPic[self._curIndex])
	end
end

function QUIDialogFightClubTutorialDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogFightClubTutorialDialog:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if event then
  		app.sound:playSound("common_close")
  	end
	self:playEffectOut()
end

function QUIDialogFightClubTutorialDialog:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogFightClubTutorialDialog:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

return QUIDialogFightClubTutorialDialog
