-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_escort_help_tips = i3k_class("wnd_escort_help_tips", ui.wnd_base)

function wnd_escort_help_tips:ctor()
	
end

function wnd_escort_help_tips:configure(...)
	self.findRoot = self._layout.vars.findRoot 
	self.transBtn = self._layout.vars.transBtn 
	self.transBtn:onClick(self,self.onHelp)
end

function wnd_escort_help_tips:onShow()
	self:updateVisible()
end

function wnd_escort_help_tips:refresh()
	
end 

function wnd_escort_help_tips:updateVisible()
	local str = g_i3k_game_context:GetEscortForHelpStr()
	self.findRoot:setVisible(#str ~= 0 and i3k_game_get_map_type() == g_FIELD)
end 

function wnd_escort_help_tips:onHelp(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_EscortForHelp)
	g_i3k_ui_mgr:RefreshUI(eUIID_EscortForHelp)
end 

function wnd_create(layout, ...)
	local wnd = wnd_escort_help_tips.new();
		wnd:create(layout, ...);

	return wnd;
end

