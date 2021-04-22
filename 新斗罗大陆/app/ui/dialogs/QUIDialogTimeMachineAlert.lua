
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTimeMachineAlert = class("QUIDialogTimeMachineAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")

function QUIDialogTimeMachineAlert:ctor(options) 
	assert(options ~= nil, "alert dialog options is nil !")
 	local ccbFile = "ccb/Dialog_timemachine_sd.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogTimeMachineAlert._onTriggerCancel)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogTimeMachineAlert._onTriggerConfirm)},
	}
	QUIDialogTimeMachineAlert.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = options.isAnimation == nil and true or false

	self._maxWidth = 380

	self._text = options.text
	self._type = options.type

	self:_init()
end

function QUIDialogTimeMachineAlert:_init()
	local index = 1
	while true do
		local node = self._ccbOwner["sp_"..index]
		if node then
			if self._type == index then
				node:setVisible(true)
			else
				node:setVisible(false)
			end
			index = index + 1
		else
			break
		end
	end

	self:_showText()
end


function QUIDialogTimeMachineAlert:_showText()
    if self._colorfulText then 
        self._colorfulText:removeFromParent()
        self._colorfulText = nil
    end

    self._colorfulText = QRichText.new(self._text, self._maxWidth, {stringType = 1, defaultColor = defaultFontColor, defaultSize = defaultFontSize--[[, lineSpacing = 10]]})
    self._ccbOwner.node_textContent:addChild(self._colorfulText)

    self._colorfulText:setAnchorPoint(0, 1)
end

function QUIDialogTimeMachineAlert:_onTriggerClose()
	self._type = ALERT_TYPE.COLSE
	self:close()
end

function QUIDialogTimeMachineAlert:_onTriggerCancel()
	self._type = ALERT_TYPE.CANCEL
	self:close()
end

function QUIDialogTimeMachineAlert:_onTriggerConfirm(e)
	self._type = ALERT_TYPE.CONFIRM
	self:close()
end

function QUIDialogTimeMachineAlert:_backClickHandler()
	local options = self:getOptions()
	if options.canBackClick ~= false then
		self._type = ALERT_TYPE.CLOSE
    	self:close()
    end
end

function QUIDialogTimeMachineAlert:close()
	if app.sound ~= nil then
		app.sound:playSound("common_confirm")
	end
	self:playEffectOut()
end

function QUIDialogTimeMachineAlert:viewAnimationOutHandler()
	local options = self:getOptions()
	local callback = options.callback
	local callType = self._type
	self:popSelf()

	if callback ~= nil then
		callback(callType)
	end
end

return QUIDialogTimeMachineAlert