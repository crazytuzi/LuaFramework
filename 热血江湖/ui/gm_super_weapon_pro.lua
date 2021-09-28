------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_gm_super_weapon_pro = i3k_class("wnd_gm_super_weapon_pro", ui.wnd_base)

local evilValue = {200, 500, 1000}

function wnd_gm_super_weapon_pro:ctor()
	self.gmType = 1
end

function wnd_gm_super_weapon_pro:configure()
	local widget = self._layout.vars
	widget.inputBox:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	widget.cancelBtn:onClick(self, self.onClose)
	widget.closeBtn:onClick(self, self.onClose)
end

function wnd_gm_super_weapon_pro:refresh(gmType)
	self.gmType = gmType
	local widget = self._layout.vars
	for k = 1, 3 do
		widget["proficiencyBtn"..k]:onClick(self, self.addProficiency, k)
	end
	widget.okBtn:onClick(self, self.onSend)
end

function wnd_gm_super_weapon_pro:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_GmSuperWeaponPro)
end

function wnd_gm_super_weapon_pro:addProficiency(sender, id)
	if self.gmType == g_SUPER_WEAPON_PRO then
		local shenbingId = g_i3k_game_context:GetSelectWeapon()
		if shenbingId ~= 0 then
			i3k_sbean.world_msg_send_req(string.format(g_GM_COMMAND[g_SUPER_WEAPON_PRO], shenbingId, evilValue[id]))
		else
			g_i3k_ui_mgr:PopupTipMessage("暂未装备神兵")
		end
	end
end

function wnd_gm_super_weapon_pro:onSend(sender)
	g_i3k_ui_mgr:PopupTipMessage("暂无此功能")
	local proficiency = self._layout.vars.inputBox:getText() or ""
	if proficiency == "" then
		g_i3k_ui_mgr:PopupTipMessage("未输入")
	end
	--i3k_sbean.world_msg_send_req("@#")
end

function wnd_create(layout, ...)
	local wnd = wnd_gm_super_weapon_pro.new()
	wnd:create(layout, ...);
	return wnd
end
