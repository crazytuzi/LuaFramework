

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHelperExplain = class("QUIDialogHelperExplain", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogHelperExplain:ctor(options)
	local ccbFile = "ccb/Dialog_AidExplain.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogHelperExplain.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
end

function QUIDialogHelperExplain:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogHelperExplain:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogHelperExplain:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogHelperExplain