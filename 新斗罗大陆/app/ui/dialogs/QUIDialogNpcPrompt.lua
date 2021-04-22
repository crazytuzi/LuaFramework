--[[	
	文件名称：QUIDialogNpcPrompt.lua
	创建时间：2016-05-03 14:42:39
	作者：nieming
	描述：QUIDialogNpcPrompt
]]

local QUIDialog = import(".QUIDialog")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogNpcPrompt = class("QUIDialogNpcPrompt", QUIDialog)

--初始化
function QUIDialogNpcPrompt:ctor(options)
	local ccbFile = "Dialog_NPC_Prompt.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIDialogNpcPrompt._onTriggerCancel)},
		{ccbCallbackName = "onTriggerconfirm", callback = handler(self, QUIDialogNpcPrompt._onTriggerconfirm)},
		{ccbCallbackName = "onTriggerconfirm2", callback = handler(self, QUIDialogNpcPrompt._onTriggerconfirm2)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogNpcPrompt._onTriggerClose)},
	}
	QUIDialogNpcPrompt.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self.isAnimation = true
	if not options then
		options = {}
	end 
	if options.comfirmCallback then
		self._comfirmCallback = options.comfirmCallback
	end

	if options.cancelCallBack then
		self._cancelCallBack = options.cancelCallBack
	end

	self._content = ""
	if options.content then
		self._content = options.content 
	end
	
	self._ccbOwner.content:setString(self._content)

end

--describe：
function QUIDialogNpcPrompt:_onTriggerCancel(event)
    if q.buttonEventShadow(event, self._ccbOwner.btnCancel) == false then return end
	--代码
	-- app.sound:playSound("common_cancel")
	self._state = "cancel"
	self:close()
	if self._cancelCallBack then
    	self._cancelCallBack()
    end
end

--describe：
function QUIDialogNpcPrompt:_onTriggerconfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btnConfirm) == false then return end
	--代码
	-- app.sound:playSound("common_confirm")
	self._state = "confirm"
	self:close()
end

--describe：
function QUIDialogNpcPrompt:_onTriggerconfirm2(event)
    if q.buttonEventShadow(event, self._ccbOwner.btnConfirm2) == false then return end
	--代码
	-- app.sound:playSound("common_confirm")
	self._state = "confirm"
	self:close()
end 

--describe：
function QUIDialogNpcPrompt:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	--代码
	self:close()
end

--describe：关闭对话框
function QUIDialogNpcPrompt:close( )
	app.sound:playSound("common_close")
	self:playEffectOut()
end

--describe：viewAnimationOutHandler 
function QUIDialogNpcPrompt:viewAnimationOutHandler()
	--代码
	local cancelCallBack = self._cancelCallBack
	local comfirmCallback = self._comfirmCallback
	-- app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	self:popSelf()
	if self._state == "cancel" then
		if cancelCallBack then
	    	cancelCallBack()
	    end
	end
	if self._state == "confirm" then
		if comfirmCallback then
	    	comfirmCallback()
	    end
	end
end

function QUIDialogNpcPrompt:_backClickHandler()
	self._state = "cancel"
	self:close()
end

return QUIDialogNpcPrompt
