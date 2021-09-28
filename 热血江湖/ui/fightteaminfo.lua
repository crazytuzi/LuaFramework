-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamInfo = i3k_class("wnd_fightTeamInfo", ui.wnd_base)

function wnd_fightTeamInfo:ctor()
	
end

function wnd_fightTeamInfo:configure(...)
	self.ui = self._layout.vars
	self.ui.bgBtn:onClick(self,self.onCloseUI)
end

function wnd_fightTeamInfo:refresh(data,isMy)
	if not isMy and not data.overview then
		self:onCloseUI()
		return
	end
	local widgets = self.ui
	widgets.teamScroll:removeAllChildren()
	local membersInfo 
	local leaderId
	if isMy then
		local info = g_i3k_game_context:getFightTeamInfo()
		leaderId = g_i3k_game_context:getFightTeamLeaderID()
		membersInfo = g_i3k_db.i3k_db_sort_fightteam_member(info.members, g_i3k_game_context:getFightTeamLeaderID(), 1)
		self._layout.vars.recordBtn:onClick(self, function()
			g_i3k_ui_mgr:OpenUI(eUIID_FightTeamRecord)
			g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamRecord)
		end)
		local qualifyingMaxTimes = i3k_db_fightTeam_base.primaries.times
		local eventID, stateDesc = g_i3k_db.i3k_db_get_fight_team_record(true)
		local str = eventID > f_FIGHTTEAM_STAGE_QUALIFY and stateDesc or string.format(stateDesc, qualifyingMaxTimes - info.qualifyingJoinTimes)
		self._layout.vars.state:setText(str)
		self._layout.vars.name:setText(info.name)
		self._layout.vars.score:setText(i3k_get_string(1220, info.score))
		self._layout.vars.honor:setText(i3k_get_string(1221, g_i3k_game_context:getFightTeamHonor()))
	else
		leaderId = data.overview.leader
		membersInfo = g_i3k_db.i3k_db_sort_fightteam_member(data.overview.members, data.overview.leader, 3)
		self._layout.vars.name:setText(data.overview.name)
		self._layout.vars.score:setText(i3k_get_string(1220, data.overview.score or 0))
	end
	self._layout.vars.honor:setVisible(isMy)
	self._layout.vars.recordBtn:setVisible(isMy)
	self._layout.vars.state:setVisible(isMy)
	
	local allWidget = widgets.teamScroll:addChildWithCount("ui/widgets/wudaohuidwt", 5, 5)
	for i, e in ipairs(allWidget) do
		local node = e.vars
		node.playerRoot:setVisible(membersInfo[i] ~= nil)
		if membersInfo[i] == nil then
			node.addRoot:setVisible(true)
			node.addRoot:disableWithChildren()
		end
		if membersInfo[i] then
			local details = membersInfo[i].details
			local profile = details
			if isMy then
				profile = details.overview
			end
			node.leaderIcon:setVisible(leaderId == profile.id)
			node.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[profile.type].classImg))
			node.iconType:setImage(g_i3k_get_head_bg_path(profile.bwType, profile.headBorder))
			node.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(profile.headIcon, false))
			node.lvlTxt:setText(profile.level)
			node.playerName:setText(profile.name)
			node.playerPower:setText(profile.fightPower)
		else
			node.addRoot:onClick(self, self.onAddFriend)
		end
	end
	widgets.teamScroll:stateToNoSlip()
end


function wnd_create(layout, ...)
	local wnd = wnd_fightTeamInfo.new();
		wnd:create(layout, ...);
	return wnd;
end
