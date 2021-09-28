-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_buy_tips = i3k_class("wnd_buy_tips", ui.wnd_base)

function wnd_buy_tips:ctor()
	
end

function wnd_buy_tips:onShow()
	
end

function wnd_buy_tips:configure(...)
	
end


--[[function wnd_buy_tips:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_BuyTips)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_buy_tips.new();
		wnd:create(layout, ...);

	return wnd;
end

