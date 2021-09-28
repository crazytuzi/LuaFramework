-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_invite_code = i3k_class("wnd_invite_code",ui.wnd_base)

function wnd_invite_code:ctor()
	self.item_id = nil
end

function wnd_invite_code:configure()
	local widgets = self._layout.vars
	
	self.inviteLabel = widgets.inviteLabel
	widgets.ok:onClick(self, self.okButton)
	widgets.cancel:onClick(self, self.closeButton)
end

function wnd_invite_code:refresh(txt)
	if txt then
		self.inviteLabel:setText(txt)
	end
end

function wnd_invite_code:okButton(sender)
	local key = self.inviteLabel:getText()
	if not self:checkCDKey(key) then
		g_i3k_ui_mgr:PopupTipMessage("请输入16位元字母数位元元的邀请码")
	else
		i3k_game_set_invite_code(key)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Login, "confirmClick")
	end
end

function wnd_invite_code:checkCDKey(keycode)
	return string.len(keycode) == 16 and string.find(keycode,"^[%d%a]+$")
end

function wnd_invite_code:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Invite)
end

function wnd_create(layout)
	local wnd = wnd_invite_code.new()
	wnd:create(layout)
	return wnd
end
