-- @Author: xurui
-- @Date:   2019-10-10 19:21:13
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-18 16:17:47
local QUIDialog = import(".QUIDialog")
local QUIDialogSocietyDungeonFinalPass = class("QUIDialogSocietyDungeonFinalPass", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogSocietyDungeonFinalPass:ctor(options)
	local ccbFile = "ccb/Dialog_GloryTower_zhandoushengli.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSocietyDungeonFinalPass.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    if options then
    	self._callBack = options.callBack
    end

    self._ccbOwner.tf_txt:setString("魂师大人，您的宗门今日已通关所有宗门副本，开启无限关卡，快去挑战吧~")
    self._ccbOwner.sp_title_1:setVisible(false)
    self._ccbOwner.sp_title_2:setVisible(true)
end

function QUIDialogSocietyDungeonFinalPass:viewDidAppear()
	QUIDialogSocietyDungeonFinalPass.super.viewDidAppear(self)
end

function QUIDialogSocietyDungeonFinalPass:viewWillDisappear()
  	QUIDialogSocietyDungeonFinalPass.super.viewWillDisappear(self)
end

function QUIDialogSocietyDungeonFinalPass:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSocietyDungeonFinalPass:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSocietyDungeonFinalPass:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSocietyDungeonFinalPass

