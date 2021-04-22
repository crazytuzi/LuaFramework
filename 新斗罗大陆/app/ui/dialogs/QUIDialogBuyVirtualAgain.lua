--
-- Author: Your Name
-- Date: 2015-02-14 12:26:57
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBuyVirtualAgain = class("QUIDialogBuyVirtualAgain", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogBuyVirtualAgain:ctor(options)
	local ccbFile = "ccb/Dialog_BuyAgain.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogBuyVirtualAgain._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogBuyVirtualAgain._onTriggerCancel)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogBuyVirtualAgain._onTriggerClose)},

	}
	QUIDialogBuyVirtualAgain.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

	self._typeName = options.typeName
	self._count = options.count
	self._remainingCount = options.remainingCount
	self._callBack = options.callBack

	self._token = 0
	local count = 0
	local money = 0
	local token_cost = nil
	local teamExpLvlConfig = QStaticDatabase:sharedDatabase():getTeamConfigByTeamLevel(remote.user.level)
	while true do
		if count >= 5 then break end
		self._count = self._count + 1
		local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._count)
		if config ~= nil then
			if (token_cost == nil or token_cost == config.money_num) and count < self._remainingCount then
				if token_cost == nil then token_cost = config.money_num end
				count = count + 1
				self._token = self._token + config.money_num
				money = money + math.floor(config.return_count * teamExpLvlConfig.token_to_money)
			else
				break
			end
		else
			break
		end
	end
	self._ccbOwner.tf_count:setString(count)
	self._ccbOwner.tf_need_num:setString("x "..self._token)
	self._ccbOwner.tf_receive_num:setString("x "..money)
end

function QUIDialogBuyVirtualAgain:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.button_ok) == false then return end
  	app.sound:playSound("common_confirm")
  	self._isConfrim = true
	self:playEffectOut()
end

function QUIDialogBuyVirtualAgain:_onTriggerCancel(event)
	if q.buttonEventShadow(event, self._ccbOwner.bt_closeTips) == false then return end
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBuyVirtualAgain:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBuyVirtualAgain:_backClickHandler()
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBuyVirtualAgain:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
	if self._isConfrim ~= nil and self._callBack ~= nil then
		self._callBack()
	end
end

return QUIDialogBuyVirtualAgain