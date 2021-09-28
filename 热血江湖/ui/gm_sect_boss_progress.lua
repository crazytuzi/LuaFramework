------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_sect_boss_progress = i3k_class("wnd_gm_sect_boss_progress", ui.wnd_base)

function wnd_gm_sect_boss_progress:ctor()
	self.bossId = 0
end

function wnd_gm_sect_boss_progress:configure()
	local widget = self._layout.vars
	widget.inputBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_sect_boss_progress:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 3 do
		widget["bossBtn"..k]:onClick(self, self.changeBoss, k)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_sect_boss_progress:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmSectBossProgress)
end

function wnd_gm_sect_boss_progress:changeBoss(sender, id)
	self.bossId = id
	for k = 1, 3 do
		if k == id then
			self._layout.vars["bossBtn"..k]:stateToPressed(true)
		else
			self._layout.vars["bossBtn"..k]:stateToNormal(true)
		end
	end
end

function wnd_gm_sect_boss_progress:onSend(sender, gmType)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	--i3k_sbean.world_msg_send_req("@#")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_sect_boss_progress.new()
	wnd:create(layout, ...);
	return wnd
end
