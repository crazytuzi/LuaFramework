-- @Author: xurui
-- @Date:   2016-12-21 20:09:13
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-04-18 11:12:11
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionPlunderInvitation = class("QUIDialogUnionPlunderInvitation", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogUnionPlunderInvitation:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_yaoqing.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerUnionPlunder", callback = handler(self, self._onTriggerUnionPlunder)},
	}
	QUIDialogUnionPlunderInvitation.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIDialogUnionPlunderInvitation:viewDidAppear()
	QUIDialogUnionPlunderInvitation.super.viewDidAppear(self)
end

function QUIDialogUnionPlunderInvitation:viewWillDisappear()
	QUIDialogUnionPlunderInvitation.super.viewWillDisappear(self)
end

function QUIDialogUnionPlunderInvitation:_onTriggerUnionPlunder(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	remote.union:unionOpenRequest(function (data)
			if self:safeCheck() then
				self:viewAnimationOutHandler()
			end

			if next(data.consortia) then
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia, isTutorialPlunder = true}})
			end
		end)
end

function QUIDialogUnionPlunderInvitation:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionPlunderInvitation:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionPlunderInvitation:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogUnionPlunderInvitation