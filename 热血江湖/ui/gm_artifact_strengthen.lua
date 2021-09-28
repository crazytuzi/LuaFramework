------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_artifact_strengthen = i3k_class("wnd_gm_artifact_strengthen", ui.wnd_base)

local strengthenDegree = {5, 8, 10}

function wnd_gm_artifact_strengthen:ctor()
	
end

function wnd_gm_artifact_strengthen:configure()
	local widget = self._layout.vars
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_artifact_strengthen:refresh(gmType)
	local widget = self._layout.vars
	for k = 1, 3 do
		widget["strengthen"..k]:onClick(self, self.addProficiency, k)
	end
	widget.okBtn:onClick(self, self.onSend, gmType)
end

function wnd_gm_artifact_strengthen:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmArtifactSrengthen)
end

function wnd_gm_artifact_strengthen:addProficiency(sender, id)
	g_i3k_ui_mgr:PopupTipMessage("暂未开放")
	--i3k_sbean.world_msg_send_req("@#")
end

function wnd_gm_artifact_strengthen:onSend(sender)
	
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_artifact_strengthen.new()
	wnd:create(layout, ...);
	return wnd
end
