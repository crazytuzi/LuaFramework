------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_five_unique_activity = i3k_class("wnd_gm_five_unique_activity", ui.wnd_base)

function wnd_gm_five_unique_activity:ctor()
	self.fiveUnique = {false, false, false, false, false}
end

function wnd_gm_five_unique_activity:configure()
	local widget = self._layout.vars
	widget.inputBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_five_unique_activity:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 5 do
		widget["fiveUnique"..k]:onClick(self, self.changeBoss, k)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_five_unique_activity:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmFiveUniqueActivity)
end

function wnd_gm_five_unique_activity:changeBoss(sender, id)
	if self.fiveUnique[id] then
		self.fiveUnique[id] = false
		self._layout.vars["fiveUnique"..id]:stateToNormal(true)
	else
		self.fiveUnique[id] = true
		self._layout.vars["fiveUnique"..id]:stateToPressed(true)
	end
end

function wnd_gm_five_unique_activity:onSend(sender, gmType)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	--i3k_sbean.world_msg_send_req("@#")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_five_unique_activity.new()
	wnd:create(layout, ...);
	return wnd
end
