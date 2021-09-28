-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_qq = i3k_class("wnd_faction_qq", ui.wnd_base)

function wnd_faction_qq:ctor()
	
end

function wnd_faction_qq:configure(...)
	self.input_label = self._layout.vars.input_label 
	self.input_label:setMaxLength(i3k_db_common.faction.faction_qq_lengh)
	local ensure_btn = self._layout.vars.ensure_btn 
	ensure_btn:onClick(self,self.onEnsure)
	local cancel_btn = self._layout.vars.cancel_btn 
	cancel_btn:onClick(self,self.onCancel)
end

function wnd_faction_qq:onShow()
	
end

function wnd_faction_qq:refresh()

end 

function wnd_faction_qq:onHide()

end 

function wnd_faction_qq:onCancel(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionQq)
end 

function wnd_faction_qq:onEnsure(sender)
	local str = self.input_label:getText()
	str =  tonumber(str)
	if str and  str ~= "" then
		i3k_sbean.set_faction_qq(str)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionQq)
	else
		g_i3k_ui_mgr:PopupTipMessage("格式错误")
	end
end 


function wnd_create(layout, ...)
	local wnd = wnd_faction_qq.new();
		wnd:create(layout, ...);

	return wnd;
end

