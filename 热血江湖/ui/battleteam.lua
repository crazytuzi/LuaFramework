module(..., package.seeall)

local require = require;

local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_battleTeam = i3k_class("wnd_battleTeam", ui.taskBase)

function wnd_battleTeam:ctor()

end

function wnd_battleTeam:configure()
    BASE.configure(self)
    BASE.setTabState(self, 2)
    local widget=self._layout.vars
    --左侧队友信息
	local team = {}
	team.root = self._layout.vars.teamRoot
	local team1 = {}
	team1.root = widget.teamRoot1
	team1.btn = widget.teamBtn1
	team1.blood = widget.teamBlood1
	team1.icon = widget.teamIcon1
	team1.captainImage = widget.teamCaptain
	team1.levelLabel = widget.teamLevel1
	team1.nameLabel = widget.teamName1
	team1.iconType = widget.teamIconType1
	team1.line = widget.line1
	team1.life = {
		[1] = widget.life11,
		[2] = widget.life12,
	}
	team1.lifeCount = 0
	team1.assist_mark = widget.assist_mark1
	team[1] = team1

	local team2 = {}
	team2.root = widget.teamRoot2
	team2.btn = widget.teamBtn2
	team2.blood = widget.teamBlood2
	team2.icon = widget.teamIcon2
	team2.levelLabel = widget.teamLevel2
	team2.nameLabel = widget.teamName2
	team2.iconType = widget.teamIconType2
	team2.line = widget.line2
	team2.life = {
		[1] = widget.life21,
		[2] = widget.life22,
	}
	team2.lifeCount = 0
	team2.assist_mark = widget.assist_mark2
	team[2] = team2

	local team3 = {}
	team3.root = widget.teamRoot3
	team3.btn = widget.teamBtn3
	team3.blood = widget.teamBlood3
	team3.icon = widget.teamIcon3
	team3.levelLabel = widget.teamLevel3
	team3.nameLabel = widget.teamName3
	team3.iconType = widget.teamIconType3
	team3.line = widget.line3
	team3.life = {
		[1] = widget.life31,
		[2] = widget.life32,
	}
	team3.lifeCount = 0
	team3.assist_mark = widget.assist_mark3
	team[3] = team3
    self._widgets = {}
	self._widgets.team = team

end

function wnd_battleTeam:refresh()
    self:updateTeamMemberProfiles(g_i3k_game_context:GetRoleId(), g_i3k_game_context:GetTeamLeader(), g_i3k_game_context:GetTeamOtherMembersProfile())
end


-----------------队友信息-----------------
function wnd_battleTeam:updateTeamMemberProfiles(selfId, leaderId, profiles)
	local index = 1
	for i,v in pairs(profiles) do
		local state = g_i3k_game_context:GetTeamMemberState(v.overview.id)
		self:updateTeamMemberProfile(index, leaderId, v, state>0)
		index = index + 1
	end
	while index <= 3 do
		self:updateTeamMemberProfile(index, leaderId, nil)
		index = index + 1
	end
    -- check show team or not
    if (profiles == nil) or (next(profiles) == nil )then
		local mapType = i3k_game_get_map_type()
        g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
		if  g_FIELD == mapType then
            if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
                g_i3k_ui_mgr:OpenUI(eUIID_SpringBuff)
                g_i3k_ui_mgr:RefreshUI(eUIID_SpringBuff)
            elseif not g_i3k_game_context:IsOnHugMode() then
                g_i3k_logic:OpenBattleTaskUI()
            end
		elseif g_FACTION_TEAM_DUNGEON == mapType or g_ANNUNCIATE == mapType then
			g_i3k_logic:OpenBattleTaskUI(true)
		elseif mapType == g_FACTION_GARRISON then
			g_i3k_logic:OpenGarrisonTeam()
		else
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
		end
    else
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "setTabState", 2)
        BASE.setTabState(self, 2)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleTask)
    end
end

function wnd_battleTeam:updateTeamMemberProfile(index, leaderId, profile, isConnect)
	local widget = self._widgets.team[index]

	if profile then
		self._widgets.team.root:show()
		-- self:updateMapInfo()
		widget.root:setTag(profile.overview.id)
		local mapType = i3k_game_get_map_type()
		local world = i3k_game_get_world()
		local tType = g_i3k_db.i3k_db_get_tournament_type(world._cfg.id)
		if mapType==g_TOURNAMENT and tType == g_TOURNAMENT_4V4 then
			widget.lifeCount = 2
		end
		for i,v in ipairs(widget.life) do
			v:setVisible(i<=widget.lifeCount)
		end
		--帮派助战者
		if profile.overview.id < 0 then
			widget.blood:setPercent(100)
		else
			widget.blood:setPercent(100* profile.curHp/profile.maxHp)
		end
		widget.levelLabel:setText(profile.overview.level)
		widget.iconType:setImage(g_i3k_get_head_bg_path(profile.overview.bwType, profile.overview.headBorder))
		widget.icon:setImage(g_i3k_db.i3k_db_get_role_head_icon(profile.overview.id, profile.overview.headIcon))
		widget.nameLabel:setText(profile.overview.name)
		if widget.captainImage then
			widget.captainImage:setVisible(leaderId == profile.overview.id)
		end
		widget.root:show()
		if not isConnect then
			widget.root:disableWithChildren()
		end
		widget.assist_mark:setVisible(profile.overview.id < 0)
		self:updateTeamMemberLine(profile.overview.id, widget)
	else
		widget.root:hide()
        -- 若空表则关闭这个界面
        -- g_i3k_ui_mgr:CloseUI(eUIID_BattleTeam)
	end
end

function wnd_battleTeam:getTeamMemberControl(roleId)
	for i, e in ipairs(self._widgets.team) do
		if e.root and e.root:getTag() == roleId then
			return e
		end
	end
end

function wnd_battleTeam:setMembersLife(roleId, lifeCount)
	local widget = self:getTeamMemberControl(roleId)
	if widget then
		widget.lifeCount = lifeCount
		for i,v in ipairs(widget.life) do
			v:setVisible(i<=lifeCount)
		end
	end
end

function wnd_battleTeam:updateTeamMemberHp(roleId, curHp, maxHp)
	local widget = self:getTeamMemberControl(roleId)
	if widget then
		widget.blood:setPercent(100* curHp/maxHp)

		local mapType = i3k_game_get_map_type()
		if mapType==g_TOURNAMENT and curHp/maxHp*100<=0 then
			widget.lifeCount = widget.lifeCount-1

			for i,v in ipairs(widget.life) do
				v:setVisible(i<=widget.lifeCount)
			end
		end
	end
end

function wnd_battleTeam:updateTeamMemberState(roleId, isConnect)
	local widget = self:getTeamMemberControl(roleId)
	if widget then
		local location = g_i3k_game_context:GetTeamMemberPosition(roleId)
		if isConnect then
			widget.root:enableWithChildren()
		else
			widget.root:disableWithChildren()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SceneMap,"onUpdateTeamMate",roleId, location.mapId, location.pos)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTeamDungeonMap,"onUpdateTeamMate",roleId, location.mapId, location.pos)
	end
end

function wnd_battleTeam:updateTeamMemberLocation(roleId, mapId, pos, line)
	local location = g_i3k_game_context:GetTeamMemberPosition(roleId)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SceneMap,"onUpdateTeamMate",roleId, location.mapId, location.pos)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTeamDungeonMap,"onUpdateTeamMate",roleId, location.mapId, location.pos)
	self:updateTeamMemberLine(roleId, self:getTeamMemberControl(roleId))
end

function wnd_battleTeam:updateTeamMemberLine(roleId, widget)
	if widget then
		local mapType = i3k_game_get_map_type()
		local location = g_i3k_game_context:GetTeamMemberPosition(roleId)
		if mapType == g_FIELD then
			local str = string.format("%s线", location.line ~= g_WORLD_KILL_LINE and location.line or "争夺分")
			widget.line:setText(str)
		end
		widget.line:setVisible(mapType == g_FIELD)
	end
end

function wnd_battleTeam:memberChangeName(roleId, roleName)
	local widget = self:getTeamMemberControl(roleId)
	if widget then
		widget.nameLabel:setText(roleName)
	end
end

function wnd_battleTeam:setTeamBtnAnis(isAnis)
	local team = self._layout.vars.team
	if team then
		team:stopAllActions()
		team:setRotation(0)
		if isAnis then
			local rotate1 = team:createRotateBy(0.1, -20)
			local rotate2 = team:createRotateBy(0.1, 20)
			local seq1 = team:createSequence(rotate1, rotate1:reverse(), rotate2, rotate2:reverse())
			local forever = team:createRepeatForever(seq1)
			team:runAction(forever)
		end
	end
end

--刷新队友头像
function wnd_battleTeam:updataHeadIcon()
	local profiles = g_i3k_game_context:GetTeamOtherMembersProfile()
	for i, e in ipairs(profiles) do
		local node = self:getTeamMemberControl(e.overview.id)	
		if node then	
			node.icon:setImage(g_i3k_db.i3k_db_get_role_head_icon(e.overview.id, e.overview.headIcon))
		end
	end
end
-------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleTeam.new();
		wnd:create(layout);
	return wnd;
end
