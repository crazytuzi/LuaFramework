-- 
-- Kumo.Wang
-- 魂灵玩法说明
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritHelp = class("QUIDialogSoulSpiritHelp", QUIDialog)
local QColorLabel = import("...utils.QColorLabel")

local DESC_TEXT = {
	"魂灵可以护佑给一个魂师，增加大量属性",
	"护佑的魂灵可以上阵，无敌作战单位，持续造成输出",
}

function QUIDialogSoulSpiritHelp:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogSoulSpiritHelp.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._callback = options.callback
	self._helpPic = QResPath("soulSpirit_help_pic")
	self._maxNum = #self._helpPic
	
	self._curIndex = 1
	self:updateShowImage()
end

function QUIDialogSoulSpiritHelp:updateShowImage()
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

function QUIDialogSoulSpiritHelp:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulSpiritHelp:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulSpiritHelp:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogSoulSpiritHelp:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSoulSpiritHelp:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

function QUIDialogSoulSpiritHelp:viewAnimationOutHandler()
    self:popSelf()

    if self._callback then
    	self._callback()
    end
end

return QUIDialogSoulSpiritHelp
