-- @Author: xurui
-- @Date:   2016-12-21 20:09:13
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-10-22 15:51:08
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBossInvitation = class("QUIDialogWorldBossInvitation", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogWorldBossInvitation:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_Boss_yaoqing.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
	}
	QUIDialogWorldBossInvitation.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIDialogWorldBossInvitation:viewDidAppear()
	QUIDialogWorldBossInvitation.super.viewDidAppear(self)
end

function QUIDialogWorldBossInvitation:viewWillDisappear()
	QUIDialogWorldBossInvitation.super.viewWillDisappear(self)
end

function QUIDialogWorldBossInvitation:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	if self:safeCheck() then
		self:viewAnimationOutHandler()
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogWorldBoss"})
end

function QUIDialogWorldBossInvitation:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogWorldBossInvitation:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogWorldBossInvitation:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogWorldBossInvitation