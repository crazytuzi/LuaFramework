------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_equip_up_level = i3k_class("wnd_gm_equip_up_level", ui.wnd_base)

function wnd_gm_equip_up_level:ctor()
	self.equipId = {false, false, false, false, false, false}
end

function wnd_gm_equip_up_level:configure()
	local widget = self._layout.vars
	
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_equip_up_level:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 6 do
		widget["equipBtn"..k]:onClick(self, self.changeEquip, k)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_equip_up_level:changeEquip(sender, id)
	local widget = self._layout.vars
	if self.equipId[id] then
		self.equipId[id] = false
		widget["equipBtn"..id]:stateToNormal(true)
	else
		self.equipId[id] = true
		widget["equipBtn"..id]:stateToPressed(true)
	end
end

function wnd_gm_equip_up_level:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmEquipUpLevel)
end

function wnd_gm_equip_up_level:onSend(sender, gmType)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_equip_up_level.new()
	wnd:create(layout, ...);
	return wnd
end
