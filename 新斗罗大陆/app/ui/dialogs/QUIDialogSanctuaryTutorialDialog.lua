-- 
-- zxs
-- 全大陆精英赛玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSanctuaryTutorialDialog = class("QUIDialogSanctuaryTutorialDialog", QUIDialog)
local QColorLabel = import("...utils.QColorLabel")

local DESC_TEXT = {
	"全大陆精英赛赛程安排",
	"##e全大陆精英赛##l每两周##e开启一次，##l周一##e开启报名",
	"##e海选积分##l前64名##e进入淘汰赛，淘汰赛单局淘汰##l残酷竞争",
	"##e押注选手获取大量精英币，精英币可以换取##l海量资源",
	"##e2小队战斗模式，##l强者为王",
}

function QUIDialogSanctuaryTutorialDialog:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogSanctuaryTutorialDialog.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._callback = options.callback
	self._helpPic = QResPath("sanctuary_help_pic")
	self._maxNum = #self._helpPic
	
	self._curIndex = 1
	self:updateShowImage()
end

function QUIDialogSanctuaryTutorialDialog:updateShowImage()
	self._ccbOwner.tf_desc:setString("")
	self._ccbOwner.node_desc:removeAllChildren()

	local desc = DESC_TEXT[self._curIndex] or ""
	local text = QColorLabel:create(desc, 1000, nil, nil, 22, nil, nil, false, true)
	text:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_desc:addChild(text)

	if self._helpPic[self._curIndex] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._helpPic[self._curIndex])
	end
end

function QUIDialogSanctuaryTutorialDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSanctuaryTutorialDialog:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSanctuaryTutorialDialog:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogSanctuaryTutorialDialog:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSanctuaryTutorialDialog:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

function QUIDialogSanctuaryTutorialDialog:viewAnimationOutHandler()
    self:popSelf()

    if self._callback then
    	self._callback()
    end
end

return QUIDialogSanctuaryTutorialDialog
