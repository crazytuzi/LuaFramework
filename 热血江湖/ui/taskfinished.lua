module(..., package.seeall)

local require = require;

local ui = require("ui/base");


wnd_tashfinished = i3k_class("wnd_tashfinished",ui.wnd_base)

function wnd_tashfinished:ctor()

end
function wnd_tashfinished:configure()
	
end

function wnd_tashfinished:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TaskFinished)
end

function wnd_create(layout, ...)
	local wnd = wnd_tashfinished.new();
		wnd:create(layout, ...);
	return wnd;
end