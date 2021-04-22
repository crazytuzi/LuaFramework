-- @Author: xurui
-- @Date:   2019-05-16 15:05:30
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-05-23 11:53:22
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulLetterActiveSuccess = class("QUIDialogSoulLetterActiveSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogSoulLetterActiveSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_AchieveHeroNew.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulLetterActiveSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._info = options.info
    end

	QSetDisplayFrameByPath(self._ccbOwner.sp_title_1, QResPath("soul_letter_title"))
	QSetDisplayFrameByPath(self._ccbOwner.sp_title_2, QResPath("soul_letter_title"))
end

function QUIDialogSoulLetterActiveSuccess:viewDidAppear()
	QUIDialogSoulLetterActiveSuccess.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogSoulLetterActiveSuccess:viewWillDisappear()
  	QUIDialogSoulLetterActiveSuccess.super.viewWillDisappear(self)
end

function QUIDialogSoulLetterActiveSuccess:setInfo()
	self._ccbOwner.professionalNode:setVisible(false)
	self._ccbOwner.node_aptitude:setVisible(false)
	self._ccbOwner.node_btn_doComment:setVisible(false)
	self._ccbOwner.node_btn_detail:setVisible(false)

	self._ccbOwner.tf_award_title1:setString(self._info.name or "")

	local offset = 15
	local icon = CCSprite:create(QResPath("soul_letter_elite"))
	icon:setPositionY(offset)
	self._ccbOwner.node_hero:addChild(icon)

	self._refreshEffect = QUIWidgetFcaAnimation.new("fca/zl_yj_icon_effect", "res")
	self._refreshEffect:playAnimation("animation", true)
	self._refreshEffect:setPosition(ccp(120, 120))
	self._refreshEffect:setEndCallback(function()
		if self._refreshEffect then
			self._refreshEffect:removeFromParent()
			self._refreshEffect = nil
		end
		self._showEffect = false
		if callback then
			callback()
		end
	end)
	icon:addChild(self._refreshEffect)

	local ccArray = CCArray:create()
	ccArray:addObject(CCEaseSineOut:create(CCMoveTo:create(1, ccp(0, -offset))))
	ccArray:addObject(CCMoveTo:create(1, ccp(0, offset)))

	icon:runAction(CCRepeatForever:create(CCSequence:create(ccArray)))

end

function QUIDialogSoulLetterActiveSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulLetterActiveSuccess:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulLetterActiveSuccess:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulLetterActiveSuccess
