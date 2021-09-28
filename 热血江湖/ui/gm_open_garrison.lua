------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_open_garrison = i3k_class("wnd_gm_open_garrison", ui.wnd_base)

function wnd_gm_open_garrison:ctor()
	
end

function wnd_gm_open_garrison:configure()
	local widget = self._layout.vars
	widget.cancel:onClick(self, self.onClose)
	widget.imgBK:onClick(self, self.onClose)
	widget.ok:onClick(self, self.onSend)
end

function wnd_gm_open_garrison:refresh(gmType)
	local widget = self._layout.vars
	widget.desc:setText("直接解锁帮派驻地")
end

function wnd_gm_open_garrison:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmOpenGarrison)
end

function wnd_gm_open_garrison:onSend(sender)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	--[[local callback = function (isOk)
		if isOk then
			i3k_sbean.world_msg_send_req("@#")
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2("确定直接解锁帮派驻地？", callback)--]]
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_open_garrison.new()
	wnd:create(layout, ...);
	return wnd
end
