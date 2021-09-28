-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionFightGroupRename = i3k_class("wnd_factionFightGroupRename", ui.wnd_base)

function wnd_factionFightGroupRename:ctor()
end

function wnd_factionFightGroupRename:configure()
	self._layout.vars.cancel_btn:onClick(self,self.onClose)
	self._layout.vars.input_label:setMaxLength(i3k_db_common.inputlen.fightGrouplen)
end

function wnd_factionFightGroupRename:refresh(id)
	local vars = self._layout.vars
	vars.countLabel:setText('X' .. i3k_db_faction_fightgroup.common.renameCost)
	vars.changge_btn:onClick(self, function ()
		if g_i3k_game_context:GetDiamond(true) < i3k_db_faction_fightgroup.common.renameCost then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3090))
		else
			local name = self._layout.vars.input_label:getText();
			local error_code,desc = g_i3k_fightgroup_name_rule(name)
			if error_code ~= 1 then
				g_i3k_ui_mgr:PopupTipMessage(desc)
				return 
			end
			i3k_sbean.request_sect_fight_group_change_name_req(id,name,function ()
				g_i3k_game_context:UseDiamond(i3k_db_faction_fightgroup.common.renameCost, true, AT_RENAME_FIGHT_GROUP)
			end)
		end
	end)
end

function wnd_factionFightGroupRename:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupRename)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionFightGroupRename.new()
		wnd:create(layout, ...)
	return wnd
end