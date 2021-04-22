-- 
-- Kumo.Wang
-- 玩法说明图片版
-- 
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPictureHowToPlay = class("QUIDialogPictureHowToPlay", QUIDialog)
local QColorLabel = import("...utils.QColorLabel")

function QUIDialogPictureHowToPlay:ctor(options)
	local ccbFile = "ccb/Dialog_fight_club_wfsm.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerClickRight)},
    }

    QUIDialogPictureHowToPlay.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    if options then
    	self._resPath = options.resPath or ""
    	self._descText = options.descText or {}
    	self._callback = options.callback
    end
	self._helpPic = QResPath(self._resPath)
	if self._helpPic then
		self._maxNum = #self._helpPic
	else
		self._maxNum = #self._descText
	end
	
	self._curIndex = 1
	self:updateShowImage()
end

function QUIDialogPictureHowToPlay:updateShowImage()
	self._ccbOwner.tf_desc:setString("")
	self._ccbOwner.node_desc:removeAllChildren()

	local desc = self._descText[self._curIndex] or ""
	local text = QColorLabel:create(desc, 1000, nil, nil, 22, nil, nil, false, true)
	text:setAnchorPoint(ccp(0.5, 0.5))
	self._ccbOwner.node_desc:addChild(text)

	if self._helpPic[self._curIndex] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_image, self._helpPic[self._curIndex])
		self._ccbOwner.sp_image:setVisible(true)
	else
		self._ccbOwner.sp_image:setVisible(false)
	end
end

function QUIDialogPictureHowToPlay:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPictureHowToPlay:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPictureHowToPlay:_onTriggerClickLeft()
  	app.sound:playSound("common_close")

  	self._curIndex = self._curIndex - 1
  	if self._curIndex < 1 then
  		self._curIndex = self._maxNum
  	end
	self:updateShowImage()
end

function QUIDialogPictureHowToPlay:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogPictureHowToPlay:_onTriggerClickRight()
  	app.sound:playSound("common_close")
	self._curIndex = self._curIndex + 1
  	if self._curIndex > self._maxNum then
  		self._curIndex = 1
  	end
  	self:updateShowImage()
end

function QUIDialogPictureHowToPlay:viewAnimationOutHandler()
    self:popSelf()

    if self._callback then
    	self._callback()
    end
end

return QUIDialogPictureHowToPlay
