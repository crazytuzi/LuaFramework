-- @Author: xurui
-- @Date:   2018-08-16 21:54:23
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-30 14:58:20
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalCityTutorialDialog = class("QUIDialogMetalCityTutorialDialog", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogMetalCityTutorialDialog:ctor(options)
	local ccbFile = "ccb/Dialog_tower_illustrate.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMetalCityTutorialDialog.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end
end

function QUIDialogMetalCityTutorialDialog:viewDidAppear()
	QUIDialogMetalCityTutorialDialog.super.viewDidAppear(self)
end

function QUIDialogMetalCityTutorialDialog:viewWillDisappear()
  	QUIDialogMetalCityTutorialDialog.super.viewWillDisappear(self)
end

function QUIDialogMetalCityTutorialDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMetalCityTutorialDialog:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMetalCityTutorialDialog:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMetalCityTutorialDialog
