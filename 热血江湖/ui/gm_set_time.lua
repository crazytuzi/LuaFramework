------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_set_time = i3k_class("wnd_gm_set_time", ui.wnd_base)

local btnValue = {0.5, 1, 5, 10, 24, 48}

function wnd_gm_set_time:ctor()
	
end

function wnd_gm_set_time:configure()
	local widget = self._layout.vars
	self.inputBox = widget.inputBox
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_set_time:refresh(gmType)
	local widget = self._layout.vars
	self.inputBox:setText("输入")
	for k = 1, 6 do
		widget["addValue"..k]:setText(btnValue[k])
		widget["addBtn"..k]:onClick(self, self.addTime, btnValue[k])
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_set_time:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmSetTime)
end

function wnd_gm_set_time:addTime(sender, value)
	i3k_sbean.world_msg_send_req(string.format("@#addtimeoffset %s", value * 3600))
end

function wnd_gm_set_time:onSend(sender, gmType)
	local input = self.inputBox:getText() or ""
	if input == "" then
		g_i3k_ui_mgr:PopupTipMessage("请输入信息")
		return
	end
	local text = string.format(g_GM_COMMAND[gmType], input) or ""
	i3k_sbean.world_msg_send_req(text)
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_set_time.new()
	wnd:create(layout, ...);
	return wnd
end
