------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_artufact_refine = i3k_class("wnd_gm_artufact_refine", ui.wnd_base)

function wnd_gm_artufact_refine:ctor()
	self.step = 0
end

function wnd_gm_artufact_refine:configure()
	local widget = self._layout.vars
	widget.input1:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.input2:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.input3:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_artufact_refine:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 5 do
		widget["stepBtn"..k]:onClick(self, self.changeStep, k)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_artufact_refine:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmArtifactRefine)
end

function wnd_gm_artufact_refine:changeStep(sender, id)
	local widget = self._layout.vars
	self.step = id
	for k = 1, 5 do
		if k == id then
			widget["stepBtn"..k]:stateToPressed(true)
		else
			widget["stepBtn"..k]:stateToNormal(true)
		end
	end
end

function wnd_gm_artufact_refine:onSend(sender)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_artufact_refine.new()
	wnd:create(layout, ...);
	return wnd
end
