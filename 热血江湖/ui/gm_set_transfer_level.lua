------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_set_transfer_level = i3k_class("wnd_gm_set_transfer_level", ui.wnd_base)

function wnd_gm_set_transfer_level:ctor()
	self.translvl = 0
	self.group = 0
end

function wnd_gm_set_transfer_level:configure()
	local widget = self._layout.vars
	
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_set_transfer_level:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 4 do
		widget["transferBtn"..k]:onClick(self, self.changeLvl, k)
	end
	widget.justiceBtn:onClick(self, self.changeGroup, 1)
	widget.evilBtn:onClick(self, self.changeGroup, 2)
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_set_transfer_level:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmSetTransferLevel)
end

function wnd_gm_set_transfer_level:changeLvl(sender, lvl)
	self.translvl = lvl
	local widget = self._layout.vars
	for k = 1, 4 do
		if k == lvl then
			widget["transferBtn"..k]:stateToPressed(true)
		else
			widget["transferBtn"..k]:stateToNormal(true)
		end
	end
end

function wnd_gm_set_transfer_level:changeGroup(sender, group)
	local widget = self._layout.vars
	self.group = group
	if group == 1 then
		widget.justiceBtn:stateToPressed(true)
		widget.evilBtn:stateToNormal(true)
	else
		widget.justiceBtn:stateToNormal(true)
		widget.evilBtn:stateToPressed(true)
	end
end

function wnd_gm_set_transfer_level:onSend(sender, gmType)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	--[[local text = string.format(g_GM_COMMAND[gmType], input) or ""
	i3k_sbean.world_msg_send_req(text)--]]
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_set_transfer_level.new()
	wnd:create(layout, ...);
	return wnd
end
