--
-- Author: Kumo.Wang
-- 大富翁炼药成功界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolySuccess = class("QUIDialogMonopolySuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

function QUIDialogMonopolySuccess:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_success.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogMonopolySuccess.super.ctor(self, ccbFile, callBack, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	self._callback = options.callBack
    self:resetAll()
end

function QUIDialogMonopolySuccess:viewDidAppear()
	QUIDialogMonopolySuccess.super.viewDidAppear(self)
end

function QUIDialogMonopolySuccess:viewWillDisappear()
	QUIDialogMonopolySuccess.super.viewWillDisappear(self)
end

function QUIDialogMonopolySuccess:resetAll()
	local curDebuffId = remote.monopoly.monopolyInfo.removePoisonCount
    local curPoisonConfig = remote.monopoly:getPoisonConfigById(curDebuffId)
    self._poisonName = curPoisonConfig and (curPoisonConfig.poison or "") or ""
    self._ccbOwner.tf_poisonName:setString(self._poisonName)

    local removePoisonCount = remote.monopoly.monopolyInfo.removePoisonCount or 0
	self._ccbOwner.node_curPoison:removeAllChildren()
    local curPoisonImg = remote.monopoly:getPoisonImgById(removePoisonCount)
    self._ccbOwner.node_curPoison:addChild(curPoisonImg)
end

function QUIDialogMonopolySuccess:_onTriggerOK()
	app.sound:playSound("common_small")
	self:playEffectOut()
end

function QUIDialogMonopolySuccess:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogMonopolySuccess:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
    if self._callback then
    	self._callback()
    end
end

return QUIDialogMonopolySuccess