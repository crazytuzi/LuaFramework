-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_email = i3k_class("wnd_faction_email", ui.wnd_base)

function wnd_faction_email:ctor()
	
end

function wnd_faction_email:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local sure_btn = self._layout.vars.sure_btn 
	sure_btn:onClick(self,self.onSure)
	self.input_desc = self._layout.vars.input_desc 
	
end

function wnd_faction_email:onShow()
	
end

function wnd_faction_email:refresh()
	
end 

function wnd_faction_email:onSure(sender)
	local tmp_desc = self.input_desc:getText()
	local is_ok = self:isInputOK(tmp_desc)
	local common_cfg = g_i3k_db.i3k_db_get_common_cfg()
	if is_ok then
		local text = "如果他人已经发送了3次以上邮件，本次服务会被扣费。确定发送？"
		local callback = function(isOk)
			if isOk then
				i3k_sbean.sect_faction_email(tmp_desc)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(text, callback)
	end 
end 

function wnd_faction_email:isInputOK(desc)
	local len = i3k_get_utf8_len(desc)
	
	local common_cfg = g_i3k_db.i3k_db_get_common_cfg()
	if len == 0 then
		g_i3k_ui_mgr:PopupTipMessage("发送内容不能为空")
		return false 
	elseif len > common_cfg.faction_email.desc_len then
		g_i3k_ui_mgr:PopupTipMessage("信件内容过长")
		return false 
	end
	return true 
end 

--[[function wnd_faction_email:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionEmail)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_email.new();
		wnd:create(layout, ...);

	return wnd
end

