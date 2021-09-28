-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionResearch = i3k_class("wnd_factionResearch", ui.wnd_base)


function wnd_factionResearch:ctor()
	
end

function wnd_factionResearch:configure()
	self._layout.vars.arena_btn:onClick(self, self.arenaBtn)
	self._layout.vars.colorhock_btn:onClick(self, self.colorhockBtn)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_factionResearch:refresh()
	
end

function wnd_factionResearch:arenaBtn(sender)
	local data = i3k_sbean.sect_aurasync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_aurasync_res.getName())
	--g_i3k_ui_mgr:CloseUI(eUIID_FactionResearch)
end

function wnd_factionResearch:colorhockBtn(sender)
	if g_i3k_game_context:GetFactionSectId() == 0 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("已经不在帮派中"))
		g_i3k_ui_mgr:CloseUI(eUIID_FactionResearch)
		return
	end
	i3k_sbean.getDiySkillSync()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionResearch)
end

--[[function wnd_factionResearch:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionResearch)
end--]]

function wnd_create(layout)
	local wnd = wnd_factionResearch.new()
	wnd:create(layout)
	return wnd
end

