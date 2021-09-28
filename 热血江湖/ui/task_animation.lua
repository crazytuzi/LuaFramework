-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_task_animation = i3k_class("wnd_task_animation", ui.wnd_base)

function wnd_task_animation:ctor()
	
end

function wnd_task_animation:onShow()
	
end

function wnd_task_animation:configure(...)
	
	
end

function wnd_task_animation:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_GetTips)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_task_animation.new();
		wnd:create(layout, ...);

	return wnd;
end

