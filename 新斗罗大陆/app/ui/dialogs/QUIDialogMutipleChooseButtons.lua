-- @Author: zhouxiaoshu
-- @Date:   2019-05-07 11:45:26
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-13 21:18:31
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMutipleChooseButtons = class("QUIDialogMutipleChooseButtons", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIDialogMutipleChooseButtons:ctor(options)
	local ccbFile = "ccb/Dialog_mutiple_choose_btn.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick1", callback = handler(self, self._onTriggerClick1)},
		{ccbCallbackName = "onTriggerClick2", callback = handler(self, self._onTriggerClick2)},
    }
    QUIDialogMutipleChooseButtons.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._callBack1 = options.callback1
	self._callBack2 = options.callback2

	self._name1 = options.name1
	self._name2 = options.name2
	q.setButtonEnableShadow(self._ccbOwner.btn_1)
	q.setButtonEnableShadow(self._ccbOwner.btn_2)
	self:setInfo()
end

function QUIDialogMutipleChooseButtons:setInfo()
    self._ccbOwner.tf_name1:setString(self._name1)
    self._ccbOwner.tf_name2:setString(self._name2)
end

function QUIDialogMutipleChooseButtons:_onTriggerClick1()
    self._callBack = self._callBack1
    self:_onTriggerClose()
end

function QUIDialogMutipleChooseButtons:_onTriggerClick2()
    self._callBack = self._callBack2
    self:_onTriggerClose()
end

function QUIDialogMutipleChooseButtons:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMutipleChooseButtons:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogMutipleChooseButtons:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMutipleChooseButtons
