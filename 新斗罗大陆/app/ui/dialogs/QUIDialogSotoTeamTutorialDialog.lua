-- @Author: zhouxiaoshu
-- @Date:   2019-09-20 15:05:58
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-09-20 16:06:47
-- 地狱杀戮场玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSotoTeamTutorialDialog = class("QUIDialogSotoTeamTutorialDialog", QUIDialog)
local QRichText = import("...utils.QRichText")

local DESC_TEXT = {
	"云顶之巅，争夺巅峰排名。获取魂骨进阶材料",
	"7人团战，主力死亡后替补上阵。击杀主力和替补7人获得胜利",
}

function QUIDialogSotoTeamTutorialDialog:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogSotoTeamTutorialDialog.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._helpPic = QResPath("soto_team_help_pic")
	self._maxNum = #self._helpPic
	
	self._curIndex = 1
	self:updateShowImage()
end

function QUIDialogSotoTeamTutorialDialog:updateShowImage()
	self._ccbOwner.tf_desc:setString(DESC_TEXT[self._curIndex] or "")

	if self._helpPic[self._curIndex] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._helpPic[self._curIndex])
	end
end

function QUIDialogSotoTeamTutorialDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSotoTeamTutorialDialog:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSotoTeamTutorialDialog:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogSotoTeamTutorialDialog:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

return QUIDialogSotoTeamTutorialDialog
