-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_msg_box1 = i3k_class("wnd_msg_box1", ui.wnd_base)

function wnd_msg_box1:ctor()
end

function wnd_msg_box1:configure()
	local ok = self._layout.vars.ok
	ok:onClick(self, self.onOK)

	-- local bk = self._layout.vars.imgBK
	-- bk:onClick(self, self.onOK)
end

function wnd_msg_box1:onShow()
end

function wnd_msg_box1:onHide()
end

function wnd_msg_box1:onOK(sender)
	local callback = self.__callback
	g_i3k_ui_mgr:CloseUI(eUIID_MessageBox1)

	if callback then
		callback()
	end
end

function wnd_msg_box1:refresh(btnName, msgText, callback)
	self._layout.vars.btnName:setText(btnName)
	local desc = self._layout.vars.desc
	desc:setText(msgText)
	self.__callback = callback
end

function wnd_msg_box1:onUpdate(dTime)
end

function wnd_create(layout)
	local wnd = wnd_msg_box1.new()
	wnd:create(layout)
	return wnd
end
