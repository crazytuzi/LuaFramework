-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_team_dungeon_btn = i3k_class("wnd_faction_team_dungeon_btn", ui.wnd_base)

function wnd_faction_team_dungeon_btn:ctor()
	
end


function wnd_faction_team_dungeon_btn:configure(...)
	local btn = self._layout.vars.btn 
	btn:onClick(self,self.onBtn)
end

function wnd_faction_team_dungeon_btn:onShow()
	
end

function wnd_faction_team_dungeon_btn:onBtn(sender)
	
	local killNum = g_i3k_game_context:GetFactionTeamKillData()
	local damageRank = g_i3k_game_context:GetFactionTeamRankData()
	local mapId = g_i3k_game_context:GetFactionTeamDungeonId()
	g_i3k_ui_mgr:OpenUI(eUIID_FactionDungeonSchedule)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionDungeonSchedule,mapId,killNum,damageRank)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonSchedule,"updateSchedule",killNum)
end 


function wnd_create(layout, ...)
	local wnd = wnd_faction_team_dungeon_btn.new();
		wnd:create(layout, ...);

	return wnd;
end

