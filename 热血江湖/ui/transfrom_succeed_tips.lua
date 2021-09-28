-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_get_tips = i3k_class("wnd_buy_tips", ui.wnd_base)

function wnd_get_tips:ctor()
	
end



function wnd_get_tips:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_get_tips:onShow()
	
end

--[[function wnd_get_tips:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_TransfromSucceedTips)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_get_tips.new();
		wnd:create(layout, ...);

	return wnd;
end

