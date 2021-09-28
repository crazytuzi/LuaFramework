-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_invite_entrance = i3k_class("wnd_invite_entrance", ui.wnd_base)

function wnd_invite_entrance:configure()
	self._layout.vars.btn:onClick(self, self.onBtnClick)
end

function wnd_invite_entrance:onBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_InviteList)
	g_i3k_ui_mgr:RefreshUI(eUIID_InviteList)
end

function wnd_create(layout)
	local wnd = wnd_invite_entrance.new()
	wnd:create(layout)
	return wnd
end
