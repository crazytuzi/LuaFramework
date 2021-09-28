-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamGameReport = i3k_class("wnd_fightTeamGameReport", ui.wnd_base)

local limit_time = 1

function wnd_fightTeamGameReport:ctor()
	self.data = nil
	self._showTime = nil
	self._groupID = g_i3k_game_context:getDefaultGroupID()
end

function wnd_fightTeamGameReport:configure(...)
	self.ui = self._layout.vars
	self.scroll = self.ui.scroll
	for i=1,5,1 do
		local stage = i+1
		self.ui["tab" .. i]:onClick(self,function ()
			if g_i3k_game_context:getScheduleStage() >= stage then
				if self._showTime and i3k_game_get_time() <= (self._showTime + limit_time) then
					g_i3k_ui_mgr:PopupTipMessage("请求过于频繁")
					return
				end
				i3k_sbean.request_tournament_teamgroup_sync_req(stage, self._groupID)
			else
				g_i3k_ui_mgr:PopupTipMessage("该阶段尚未开启")
			end
		end)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_FightTeamAward)
	
	self.ui.myTeam:setVisible(g_i3k_game_context:isShowMyTeamBtn())
	self.ui.myTeam:onClick(self,function ()
		g_i3k_ui_mgr:OpenUI(eUIID_FightTeamInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_FightTeamInfo,nil,true)
	end)
end

-- 其中id表示为武皇武帝分组id
function wnd_fightTeamGameReport:refresh(stage, id)
	self._groupID = id
	i3k_sbean.request_tournament_teamgroup_sync_req(stage, id)
end

function wnd_fightTeamGameReport:show(index, data, id)
	self._showTime = i3k_game_get_time()
	self.data = g_i3k_db.i3k_db_trans_teamgroup(data, id)

	self.scroll:removeAllChildren()
	
	for i=1,5,1 do
		if i == index then
			self.ui["tab" .. i]:stateToPressed()
		else
			self.ui["tab" .. i]:stateToNormal()
		end
	end
	--设置一个队伍的UI
	local setTeamUI = function (cellItem,teamIndex,teamData,offIndex)
		local profile = teamData.team.leader
		if offIndex then
			teamIndex = teamIndex + offIndex
		end
		cellItem.vars["item" .. teamIndex]:setVisible(true)
		cellItem.vars["kong" .. teamIndex]:setVisible(false)
		cellItem.vars["iconType" .. teamIndex]:setImage(g_i3k_get_head_bg_path(profile.bwType, profile.headBorder))
		cellItem.vars["icon" .. teamIndex]:setImage(g_i3k_db.i3k_db_get_head_icon_path(profile.headIcon, false))
		cellItem.vars["lvlTxt" .. teamIndex]:setText(profile.level)
		cellItem.vars["playerName" .. teamIndex]:setText(teamData.team.name)
		cellItem.vars["playerBtn" .. teamIndex]:onClick(self,function ()
			i3k_sbean.request_fightteam_querym_req(teamData.team.id)
		end)
		cellItem.vars["isSign" .. teamIndex]:setVisible(teamData.state == 1)
		cellItem.vars["isFail" .. teamIndex]:setVisible(teamData.state == 2)
	end
	--设置一组队伍的UI
	local setTeamsUI = function (cellItem,teams,offIndex)
		for teamIndex,teamData in ipairs(teams) do
			setTeamUI(cellItem,teamIndex,teamData,offIndex)
		end
		local idx = ""
		if offIndex then
			idx = offIndex / 2
		end
		self:updateIsShowGuardBtn(cellItem.vars["guardBtn"..idx], teams)
	end
	if index == 5 then
		local finalGroup = self.data.finalGroup	
		local widgets = require("ui/widgets/wudaohuisst2")()
		self.scroll:addItem(widgets)
		for k,group in ipairs(self.data.groups) do
			setTeamsUI(widgets,group.teams,4 + 2*(k-1))
			
		end
		self.scroll:jumpToListPercent(100)
		--决赛队伍
		if finalGroup then
			widgets.vars.kongtext2:setText("轮空")
			widgets.vars.kongtext3:setText("轮空")
			setTeamsUI(widgets,finalGroup.teams,2)
			self.scroll:jumpToListPercent(50)
			local winTeam = nil
			for k,v in ipairs(finalGroup.teams) do
				if v.state == 1 then
					winTeam = v
				end
			end
			--决赛结果
			if winTeam then
				setTeamUI(widgets,2,winTeam)
				self.scroll:jumpToListPercent(0)
			end
		end
	else
		local cells = self.scroll:addItemAndChild("ui/widgets/wudaohuisst",2,#self.data.groups)	
		for cellIndex,cellItem in ipairs(cells) do
			setTeamsUI(cellItem,self.data.groups[cellIndex].teams)
		end
	end
end

-- 根据对战双方信息判断是否显示观战按钮
function wnd_fightTeamGameReport:updateIsShowGuardBtn(btn, teams)
	if btn and teams then
		local isShowBtn = false
		local joinTime, fightTime, endTime = g_i3k_game_context:getFightTeamStartTime()
		isShowBtn = i3k_game_get_time() > fightTime and i3k_game_get_time() < endTime
		for i, e in ipairs(teams) do
			btn:onClick(self, self.onEnterGuardBtn, e.team.id)
			if e.state == f_FIGHT_RESULT_WIN or e.state == f_FIGHT_RESULT_LOSE then -- 一方胜利或失败不显示
				isShowBtn = false
				break
			end
		end
		btn:setVisible(isShowBtn and i3k_db_fightTeam_base.display.isShowGuard > 0)
	end
end

function wnd_fightTeamGameReport:onEnterGuardBtn(sender, teamID)
	if g_i3k_game_context:getMatchState() ~= 0 then -- 等待其他活动无法进行匹配
		return g_i3k_ui_mgr:PopupTipMessage(string.format("已有其他活动报名中"))
	end
	i3k_sbean.tournament_guard(teamID)
end

function wnd_create(layout, ...)
	local wnd = wnd_fightTeamGameReport.new();
		wnd:create(layout, ...);
	return wnd;
end
