-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_msg_box4 = i3k_class("wnd_msg_box4", ui.wnd_base)

function wnd_msg_box4:ctor()
end

function wnd_msg_box4:configure()
	local ok = self._layout.vars.ok
	ok:onClick(self, self.onOK)
end

function wnd_msg_box4:onShow()
end

function wnd_msg_box4:onHide()
end

function wnd_msg_box4:onOK(sender)
	local callback = self.__callback
	g_i3k_ui_mgr:CloseUI(eUIID_MessageBox4)
	if callback then
		callback()
	end
end

function wnd_msg_box4:refresh(btnName, msgText, callback)
	self._layout.vars.btnName:setText(btnName)
	local desc = self._layout.vars.desc
	desc:setText(msgText)
	self.__callback = callback
end

function wnd_msg_box4:onUpdate(dTime)
end

function wnd_create(layout)
	local wnd = wnd_msg_box4.new()
	wnd:create(layout)
	return wnd
end
