-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_invite_layer = i3k_class("wnd_invite_layer", ui.wnd_base)

function wnd_invite_layer:ctor()
	
end



function wnd_invite_layer:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_invite_layer:onShow()
	
end

--[[function wnd_invite_layer:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_InviteLayer)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_invite_layer.new();
		wnd:create(layout, ...);

	return wnd;
end

