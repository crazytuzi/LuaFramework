local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalAbyssRewardPerviewTips = class("QUIDialogMetalAbyssRewardPerviewTips", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
function QUIDialogMetalAbyssRewardPerviewTips:ctor(options)
	local ccbFile = "ccb/Dialog_MetalAbyss_RewardPerviewTips.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMetalAbyssRewardPerviewTips.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
end

function QUIDialogMetalAbyssRewardPerviewTips:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMetalAbyssRewardPerviewTips:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMetalAbyssRewardPerviewTips:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogMetalAbyssRewardPerviewTips