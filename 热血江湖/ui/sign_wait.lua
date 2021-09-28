-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sign_wait = i3k_class("wnd_sign_wait", ui.wnd_base)

function wnd_sign_wait:ctor()
	self._joinTime = 0
	self._hideTime = false
end

function wnd_sign_wait:configure()

end

function wnd_sign_wait:onShow()
	
end

function wnd_sign_wait:refresh(joinTime, matchType, actType)
	local nameStr = ""
	if matchType==g_TOURNAMENT_MATCH then
		local cfg = i3k_db_tournament[actType]
		if actType == g_DESERT_BATTLE_MATCH then--决战荒漠
			nameStr = i3k_db_desert_battle_base.gameName
		elseif actType == g_SPY_STORY_MATCH then
			nameStr = "密探风云"
		else
		nameStr = string.format("会武之%s", cfg.name)
		end
	elseif matchType==g_FORCE_WAR_MATCH then
		local cfg = i3k_db_forcewar[actType]
		nameStr = string.format("%s", cfg.name)
	elseif matchType == g_FIGHT_TEAM_MATCH then
		if actType == g_FIGHTTEAM_QUALIFYING_MATCH then
			nameStr = i3k_get_string(1229)
		elseif actType == g_FIGHTTEAM_TOURNAMENT_MATCH then
			self._hideTime = true
			nameStr = i3k_get_string(1230)
			self._layout.vars.signDesc:setText(i3k_get_string(1231))
			self._layout.vars.waitDesc:setText(i3k_get_string(1232))
			self._layout.vars.waitLabel:setText(i3k_get_string(1233))
			self._layout.vars.cancel:hide()
		end
	elseif matchType == g_DUNGEON_MATCH then
		nameStr = i3k_db_new_dungeon[actType].name
	elseif matchType == g_RIGHTHEART_MATCH then
		nameStr = i3k_get_string(1306)
	elseif matchType == g_DEFEND_MATCH then
		nameStr = i3k_db_defend_cfg[actType].descName
	elseif matchType == g_NPC_MATCH then
		nameStr = i3k_db_NpcDungeon[actType].name
	elseif matchType == g_PRINCESS_MARRY_MATCH then
		nameStr = i3k_get_string(i3k_db_princess_marry.nameId)
	elseif matchType == g_MAGIC_MACHINE_MATCH then
		nameStr = i3k_get_string(18136)
	elseif  matchType == g_LONGEVITY_PAVILION_MATCH then
		nameStr = i3k_get_string(18563)
	end
	if g_GLOBAL_MATCH_TEAM[matchType] then
		self._hideTime = true
		self._layout.vars.waitLabel:setText(i3k_get_string(1307))
	end
	self._layout.vars.targetName:setText(nameStr)
	self._layout.vars.waitBtn:onClick(self, self.onWaitBtn, matchType)
	self._layout.vars.closeBtn:onClick(self, self.onWaitBtn, matchType)
	self._layout.vars.cancel:onClick(self, self.onCancel, matchType)
	self._joinTime = joinTime
end

function wnd_sign_wait:onWaitBtn(sender, matchType)
	local usercfg = g_i3k_game_context:GetUserCfg()
	if usercfg:GetMatchIsShow(matchType) then
		g_i3k_ui_mgr:OpenUI(eUIID_WaitTip)
		g_i3k_ui_mgr:RefreshUI(eUIID_WaitTip, matchType)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_SignWait)
end

function wnd_sign_wait:onCancel(sender, matchType)
	if matchType==g_TOURNAMENT_MATCH then
		i3k_sbean.cancel_mate()
	elseif matchType==g_FORCE_WAR_MATCH then
		i3k_sbean.quit_join_forcewar()
	elseif matchType == g_FIGHT_TEAM_MATCH then
		if not g_i3k_game_context:getIsFightTeamLeader() then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1234))
		end
		i3k_sbean.fightteam_quitqualifying_request()
	elseif matchType == g_PRINCESS_MARRY_MATCH then
		i3k_sbean.princess_marry_quit_up()
	elseif matchType == g_MAGIC_MACHINE_MATCH then
		i3k_sbean.magic_machine_quit_up()
	elseif g_GLOBAL_MATCH_TEAM[matchType] then
		i3k_sbean.globalmap_quit_request()
	elseif g_LONGEVITY_PAVILION_MATCH then
		i3k_sbean.longevity_loft_quit()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_SignWait)
	--去协议里关闭此界面
end

function wnd_sign_wait:onUpdate(dTime)
	if self._joinTime~=0 and not self._hideTime then
		local timeDis = i3k_game_get_time() - self._joinTime
		local min = timeDis/60
		local second = timeDis%60
		self._layout.vars.waitLabel:setText(string.format("已等待%d分%d秒", min, second))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_sign_wait.new()
	wnd:create(layout, ...)
	return wnd;
end
