-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionFightGroupMsg = i3k_class("wnd_factionFightGroupMsg", ui.wnd_base)

function wnd_factionFightGroupMsg:ctor()
end

function wnd_factionFightGroupMsg:configure()
	self._layout.vars.ok:onClick(self,self.onClose)
end

function wnd_factionFightGroupMsg:refresh(data)
	
end

function wnd_factionFightGroupMsg:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupMsg)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionFightGroupMsg.new()
		wnd:create(layout, ...)
	return wnd
end