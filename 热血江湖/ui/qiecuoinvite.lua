-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_qieCuoInvite = i3k_class("wnd_qieCuoInvite", ui.wnd_base)

function wnd_qieCuoInvite:ctor()
end

function wnd_qieCuoInvite:configure()

end

function wnd_qieCuoInvite:refresh(id)
	
end

function wnd_qieCuoInvite:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_QieCuoResult)
end

function wnd_create(layout, ...)
	local wnd = wnd_qieCuoInvite.new()
		wnd:create(layout, ...)
	return wnd
end