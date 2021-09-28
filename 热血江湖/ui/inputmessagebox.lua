-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_msg_inputBox = i3k_class("wnd_msg_box2", ui.wnd_base)

function wnd_msg_inputBox:ctor()
	self.inputNum = 0
end

function wnd_msg_inputBox:configure()
	local widgets = self._layout.vars
	self.ok_btn = widgets.ok_btn
	self.ok_btn:onClick(self, self.Confirm)
	self.cancel_btn = widgets.cancel_btn
	self.cancel_btn:onClick(self, self.onCancel)

	self.yes_name = widgets.yes_name
	self.no_name =  widgets.no_name
	self.desc = widgets.desc
	self.inputHint = widgets.inputHint
	self.input_label = widgets.input_label
	self.input_label:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
end


function wnd_msg_inputBox:onCancel(sender)
	local callback = self.__callback
	g_i3k_ui_mgr:CloseUI(eUIID_InputMessageBox)
	
	if callback then
		callback(false)
	end
end

function wnd_msg_inputBox:refresh(yesName, noName, msgText, inputNum, callback)
	self.inputNum = inputNum
	self.yes_name:setText(yesName)
	self.no_name:setText(noName)
	self.desc:setText(msgText)
	self.inputHint:setText(i3k_get_string(4105, inputNum))
	self.__callback = callback
end

function wnd_msg_inputBox:Confirm(sender)
	local message = self.input_label:getText()
	if tonumber(message) == self.inputNum then
		local callback = self.__callback
		g_i3k_ui_mgr:CloseUI(eUIID_InputMessageBox)
		if callback then
			callback(true)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18307))
	end
end

function wnd_create(layout)
	local wnd = wnd_msg_inputBox.new()
	wnd:create(layout)
	return wnd
end

