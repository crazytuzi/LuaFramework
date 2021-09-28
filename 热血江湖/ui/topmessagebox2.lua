-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_msg_box2 = i3k_class("wnd_msg_box2", ui.wnd_base)

function wnd_msg_box2:ctor()
end

function wnd_msg_box2:configure()
	local ok = self._layout.vars.ok
	ok:onClick(self, self.onOK)
	local cancel = self._layout.vars.cancel
	cancel:onClick(self, self.onCancel)
end

function wnd_msg_box2:onShow()
end

function wnd_msg_box2:onHide()
end


function wnd_msg_box2:onOK(sender)
	local callback = self.__callback
	self:onCloseUI()
	if callback then
		callback(true)
	end
end

function wnd_msg_box2:onCancel(sender)
	local callback = self.__callback
	self:onCloseUI()
	if callback then
		callback(false)
	end
end

function wnd_msg_box2:refresh(yesName, noName, msgText, callback)
	local yesLabel = self._layout.vars.yes_name
	yesLabel:setText(yesName)
	local noLabel = self._layout.vars.no_name
	noLabel:setText(noName)
	local desc = self._layout.vars.desc
	desc:setText(msgText)
	self.__callback = callback
end

function wnd_create(layout)
	local wnd = wnd_msg_box2.new()
	wnd:create(layout)
	return wnd
end
