------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_under_wear = i3k_class("wnd_gm_under_wear", ui.wnd_base)

function wnd_gm_under_wear:ctor()
	self.underwear = {false, false, false}
end

function wnd_gm_under_wear:configure()
	local widget = self._layout.vars
	widget.levelBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.forgeBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.levelBox = widget.levelBox
	self.forgeBox = widget.forgeBox
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_under_wear:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 3 do
		widget["underwear"..k]:onClick(self, self.changeUnderwear, k)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_under_wear:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmUnderWear)
end

function wnd_gm_under_wear:changeUnderwear(sender, id)
	local widget = self._layout.vars
	if self.underwear[id] then
		self.underwear[id] = false
		widget["underwear"..id]:stateToNormal(true)
	else
		self.underwear[id] = true
		widget["underwear"..id]:stateToPressed(true)
	end
end

function wnd_gm_under_wear:onSend(sender, gmType)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	local level = self.levelBox:getText() or ""
	local forge = self.forgeBox:getText() or ""
	if level == "" or forge == "" then
		g_i3k_ui_mgr:PopupTipMessage("未输入")
	end
	--i3k_sbean.world_msg_send_req("@#")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_under_wear.new()
	wnd:create(layout, ...);
	return wnd
end
