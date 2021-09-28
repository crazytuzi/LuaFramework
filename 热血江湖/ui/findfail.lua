module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_findFail = i3k_class("wnd_findFail", ui.wnd_base)

function wnd_findFail:ctor()
	
end

function wnd_findFail:configure()
	
end

function wnd_findFail:onUpdate(dTime)	
end

function wnd_findFail:refresh()
end

function wnd_findFail:onHide()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FindMooncake, "ifCountine")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ProtectMelon, "ifCountine")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MemoryCard, "ifCountine")
end

function wnd_create(layout)
	local wnd = wnd_findFail.new();
		wnd:create(layout);
	return wnd;
end