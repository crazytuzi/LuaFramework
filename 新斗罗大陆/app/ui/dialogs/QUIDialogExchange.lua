--
-- Author: Qinyuanji
-- Date: 2014-11-19 
-- This dialog is to show the cd key exchange dialog

local QUIDialog = import(".QUIDialog")
local QUIDialogExchange = class("QUIDialogExchange", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIDialogExchange.NO_INPUT_ERROR = "兑换码不能为空"
QUIDialogExchange.EXCHANGE_SUCCEED = "兑换成功！请前往邮箱领取奖励"

function QUIDialogExchange:ctor(options)
	local ccbFile = "ccb/Dialog_MyInformation_ChangeName&Duihuan.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogExchange._onTriggerCancel)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogExchange._onTriggerConfirm)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogExchange._onTriggerClose)},
	}
	QUIDialogExchange.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	-- update layout 
	self._ccbOwner.tf_changeName:setVisible(false)
	self._ccbOwner.tf_exchangeNode:setVisible(true)

	-- add input text box
    self._exchangeCode = ui.newEditBox({image = "ui/none.png", listener = function () end, size = CCSize(350, 48)})
    self._exchangeCode:setFont(global.font_default, 26)
    self._exchangeCode:setMaxLength(20)
    self._ccbOwner.tf_exchangeInput:addChild(self._exchangeCode)

    if self._ccbOwner.node_welcome then
		self._avatar = QSkeletonActor:create("jm_xiaowu")
    	self._avatar:playAnimation("animation", true)
    	self._avatar:setScale(0.6)
		self._ccbOwner.node_welcome:addChild(self._avatar)
	end
end

function QUIDialogExchange:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogExchange:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_confirm")
	self._cdKey = self._exchangeCode:getText()
	if self._cdKey == nil or self._cdKey == "" then
		app.tip:floatTip(QUIDialogExchange.NO_INPUT_ERROR)
		return
	end

	app:getClient():sendCdKey(self._cdKey, function (data)
			app.tip:floatTip(QUIDialogExchange.EXCHANGE_SUCCEED)
			self:_onTriggerClose()
		end, function ( data )
			local error = QStaticDatabase:sharedDatabase():getErrorCode(data.error)
			if error == nil then
				app.tip:floatTip(data.error)
			else
				self:_showErrorDialog(error)
			end
		end)
end

-- Hide the input cd key and show it up when error dialog is dismissed
function QUIDialogExchange:_showErrorDialog(error)
	if error.type == 1 then
		self._exchangeCode:setText("")
		app:alert({content=error.desc, title="", callback = function (state)
			if state == ALERT_TYPE.CONFIRM then
				self._exchangeCode:setText(self._cdKey)
			end
		end}, false)	
	else
		app.tip:floatTip(error.desc)
	end
end

function QUIDialogExchange:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogExchange:_onTriggerCancel()
	self:_onTriggerClose()
end

function QUIDialogExchange:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	if event then
		app.sound:playSound("common_cancel")
	end
	self._exchangeCode:setText("")
    self:playEffectOut()
end

return QUIDialogExchange
