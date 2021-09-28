-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_ChangeText = i3k_class("wnd_ChangeText", ui.wnd_base)

function wnd_ChangeText:ctor()
	self.oldContent = nil
	self.message = nil
end

function wnd_ChangeText:configure()
	local widgets = self._layout.vars
	local ok_btn = widgets.ok
	local cancel_btn = widgets.cancel
	self.editbox = self._layout.vars.editbox
	ok_btn:onClick(self,self.certain)
	cancel_btn:onClick(self,self.onClose)
	self:changeMaxlength(i3k_db_common.friends_about.friendStatelength)
end

function wnd_ChangeText:refresh(content)
	self.oldContent = content
	self.message = content
	self.editbox:setText(content)
end

function wnd_ChangeText:changeMaxlength(length)
	self.editbox:setMaxLength(length)
end

function wnd_ChangeText:certain(sender)
	local content = self.editbox:getText()
	if content ~= self.oldContent then 
		local textcount = i3k_get_utf8_len(content)
		if textcount == 0 then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(298))
		end		
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends,"changePersonalMsg",content)
	end
	self:onClose()
end

function wnd_ChangeText:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ChangePersonState)
end

function wnd_create(layout,...)
	local wnd = wnd_ChangeText.new();
		wnd:create(layout,...)
	return wnd;
end
