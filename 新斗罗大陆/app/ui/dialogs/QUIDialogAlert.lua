--
-- Author: wkwang
-- Date: 2014-07-17 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAlert = class("QUIDialogAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")

function QUIDialogAlert:ctor(options) 
	assert(options ~= nil, "alert dialog options is nil !")
 	local ccbFile = "ccb/Dialog_AlertSystem.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAlert._onTriggerClose)},
	    {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogAlert._onTriggerCancel)},
	    {ccbCallbackName = "onTriggerCancelRed", callback = handler(self, QUIDialogAlert._onTriggerCancelRed)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogAlert._onTriggerConfirm)},
	    {ccbCallbackName = "onTriggerConfirmRed", callback = handler(self, QUIDialogAlert._onTriggerConfirmRed)},
	}
	QUIDialogAlert.super.ctor(self, ccbFile, callBacks, options)
	options.btnDesc = options.btnDesc or {}

	self.isAnimation = options.isAnimation == nil and true or false
	self._colorful = options.colorful
	
	self._ccbOwner.frame_tf_title:setString("系统提示")
	if options.title then
		self._title = options.title
		self._ccbOwner.frame_tf_title:setString(self._title)
	end

	self._autoCenter = true
	if options.autoCenter ~= nil then
		self._autoCenter =  options.autoCenter
	end

	self._lineWidth = 400
	if options.lineWidth then
		self._lineWidth =  options.lineWidth
	end
	
	self._fontSize = 24
	if options.fontSize then
		self._fontSize =  options.fontSize
	end

	if options.content then
		self._content = options.content
		if not self._colorful then
			if type(self._content) == "string" then
				self._ccbOwner.tf_content:setString(self._content)
			elseif type(self._content) == "table" then
				self._ccbOwner.tf_content:setString(self._content.desc or "")
			end
		else
			self._ccbOwner.normalText:setVisible(false)
			local richText = QRichText.new(self._content, self._lineWidth, {autoCenter = self._autoCenter, stringType = 1, defaultSize = self._fontSize})
			richText:setAnchorPoint(ccp(0.5,0.5))
			self._ccbOwner.colorfulText:addChild(richText)
		end
	end

	if options.btns == nil then
		options.btns = {ALERT_BTN.BTN_OK, ALERT_BTN.BTN_CANCEL}
	end
	self._ccbOwner.btn_ok:setVisible(false)
	self._ccbOwner.node_btn_ok_red:setVisible(false)
	self._ccbOwner.node_btn_cancel:setVisible(false)
	self._ccbOwner.node_btn_cancel_red:setVisible(false)
	self._ccbOwner.btn_close:setVisible(false)

	for index,btnType in ipairs(options.btns) do
		if btnType == ALERT_BTN.BTN_CLOSE then
			self._ccbOwner.btn_close:setVisible(true)
			table.remove(options.btns, index)
		end
	end

	local cellX = 208
	local startX = 1 + (#options.btns - 1) * cellX/2
	for index,btnType in ipairs(options.btns) do
		local btn = nil
		local btnTf = nil
		if btnType == ALERT_BTN.BTN_OK then
			btn = self._ccbOwner.btn_ok
			btnTf = self._ccbOwner.tf_ok
		elseif btnType == ALERT_BTN.BTN_OK_RED then
			btn = self._ccbOwner.node_btn_ok_red
			btnTf = self._ccbOwner.tf_ok_red
		elseif btnType == ALERT_BTN.BTN_CANCEL then
			btn = self._ccbOwner.node_btn_cancel
			btnTf = self._ccbOwner.tf_cancel
		elseif btnType == ALERT_BTN.BTN_CANCEL_RED then
			btn = self._ccbOwner.node_btn_cancel_red
			btnTf = self._ccbOwner.tf_cancel_red
		end
		if btn ~= nil then
			btn:setVisible(true)
			btn:setPositionX(startX - (index - 1) * cellX)
		end
		local name = options.btnDesc[index] or ""
		if btnTf ~= nil and name ~= "" then
			btnTf:setString(name)
		end
	end
end

function QUIDialogAlert:_onTriggerClose(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	self._type = ALERT_TYPE.COLSE
	self:close()
end

function QUIDialogAlert:_onTriggerCancel(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
	self._type = ALERT_TYPE.CANCEL
	self:close()
end

function QUIDialogAlert:_onTriggerCancelRed(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_cancel_red) == false then return end
	self._type = ALERT_TYPE.CANCEL
	self:close()
end

function QUIDialogAlert:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	self._type = ALERT_TYPE.CONFIRM
	self:close()
end

function QUIDialogAlert:_onTriggerConfirmRed(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok_red) == false then return end
	self._type = ALERT_TYPE.CONFIRM
	self:close()
end

function QUIDialogAlert:_backClickHandler()
	local options = self:getOptions()
	if options.canBackClick ~= false then
		self._type = ALERT_TYPE.CLOSE
    	self:close()
    end
end

function QUIDialogAlert:close()
	if app.sound ~= nil then
		app.sound:playSound("common_confirm")
	end
	self:playEffectOut()
end

function QUIDialogAlert:viewAnimationOutHandler()
	local options = self:getOptions()
	local callback = options.callback
	local callType = self._type
	self:popSelf()

	if callback ~= nil then
		callback(callType)
	end
end

return QUIDialogAlert