------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_set_evil_point = i3k_class("wnd_gm_set_evil_point", ui.wnd_base)

local value = 
{
	[g_SET_EVIL_POINT] = {1, 5, 10},
	[g_ADD_CHARM] = {200, 500, 1000},
	[g_ADD_WUXUN] = {200, 500, 1000},
	[g_ADD_HONOR] = {200, 500, 1000},
}

function wnd_gm_set_evil_point:ctor()
	self.gmType = 1
	self.underwear = {false, false, false}
end

function wnd_gm_set_evil_point:configure()
	local widget = self._layout.vars
	widget.evilBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_set_evil_point:refresh(gmType)
	self.gmType = gmType
	local widget = self._layout.vars
	for k = 1, 3 do
		widget["addEvilBtn"..k]:onClick(self, self.addEvil, k)
		widget["addValue"..k]:setText(string.format("+%s", value[gmType][k]))
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_set_evil_point:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmSetEvilPoint)
end

function wnd_gm_set_evil_point:addEvil(sender, id)
	local text = g_GM_COMMAND[self.gmType]
	i3k_sbean.world_msg_send_req(string.format(text, value[self.gmType][id]))
end

function wnd_gm_set_evil_point:onSend(sender, gmType)
	local evil = self._layout.vars.evilBox:getText() or ""
	if evil == "" then
		g_i3k_ui_mgr:PopupTipMessage("未输入")
	end
	local text = g_GM_COMMAND[gmType]
	i3k_sbean.world_msg_send_req(string.format(text, tonumber(evil)))
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_set_evil_point.new()
	wnd:create(layout, ...);
	return wnd
end
