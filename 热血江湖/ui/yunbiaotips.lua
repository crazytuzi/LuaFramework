-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_yunbiaoTips = i3k_class("wnd_yunbiaoTips", ui.wnd_base)

---滚动广播
local broadcast_timerTask = {}

function wnd_yunbiaoTips:ctor()
end

function wnd_yunbiaoTips:configure()
	local widgets = self._layout.vars
	widgets.cancel:onClick(self,self.onCloseUI)
	widgets.ok:onClick(self, self.onOk)
end
function wnd_yunbiaoTips:onOk(sender)
	if self.callback then
		self.callback()
		g_i3k_ui_mgr:CloseUI(eUIID_YunbiaoTips)
	end
end 
function wnd_yunbiaoTips:refresh(callback)
	self.callback = callback
end

function wnd_create(layout)
	local wnd = wnd_yunbiaoTips.new();
	wnd:create(layout);
	return wnd;
end
