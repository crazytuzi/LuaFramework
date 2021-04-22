-- 报名成功界面
-- Author: Qinsiyang
-- 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSignUpSuccess = class("QUIDialogSignUpSuccess", QUIDialog)

function QUIDialogSignUpSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SignUp_Success.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerNext)},
	}
	QUIDialogSignUpSuccess.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	self._backCallback = options.callback
    q.setButtonEnableShadow(self._ccbOwner.btn_next)
end

function QUIDialogSignUpSuccess:viewDidAppear()
	QUIDialogSignUpSuccess.super.viewDidAppear(self)

end

function QUIDialogSignUpSuccess:viewWillDisappear()
	QUIDialogSignUpSuccess.super.viewWillDisappear(self)

end

function QUIDialogSignUpSuccess:_onTriggerNext()
	if q.buttonEventShadow(event, self._ccbOwner.btn_next) == false then return end
	app.sound:playSound("common_cancel")
    if self._backCallback then
    	self._backCallback()
    end	
    self:playEffectOut()	
end

function QUIDialogSignUpSuccess:onTriggerBackHandler()
    self:popSelf()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogSignUpSuccess