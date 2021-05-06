module(..., package.seeall)

--GS2C--

function GS2CAddTeam(pbdata)
	local teamid = pbdata.teamid
	local leader = pbdata.leader
	local member = pbdata.member
	local target_info = pbdata.target_info
	local posinfo = pbdata.posinfo
	local type = pbdata.type
	local auto_match = pbdata.auto_match
	--todo
	if type == 2 then	
		g_ActivityCtrl:DailyCultivateAddTeam(teamid, leader, member, target_info)
	else
		g_TeamCtrl:AddTeam(teamid, leader, member,target_info)
	end
end

function GS2CDelTeam(pbdata)
	--todo
	g_TeamCtrl:DelTeam()
	g_ActivityCtrl:DailyCultivateDelTeam()
end

function GS2CAddTeamMember(pbdata)
	local mem_info = pbdata.mem_info
	--todo
	if g_ActivityCtrl:IsDailyCultivating() then
		g_ActivityCtrl:DailyCultivateAddTeamMember(mem_info)
	else
		g_TeamCtrl:UpdateMember(mem_info)
	end
end

function GS2CRefreshTeamStatus(pbdata)
	local team_status = pbdata.team_status
	local posinfo = pbdata.posinfo
	--todo
	if g_ActivityCtrl:IsDailyCultivating() then
		g_ActivityCtrl:DailyCultivateRefreshTeamStatus(team_status, posinfo)
	else
		g_TeamCtrl:UpdateTeamStatus(team_status, posinfo)
	end
end

function GS2CRefreshMemberInfo(pbdata)
	local pid = pbdata.pid
	local status_info = pbdata.status_info
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(status_info, "team")
	if g_ActivityCtrl:IsDailyCultivating() then
		g_ActivityCtrl:DailyCultivateUpdateMemberAttr(pid, dDecode)
	else
		g_TeamCtrl:UpdateMemberAttr(pid, dDecode)
	end
	
end

function GS2CTeamApplyInfo(pbdata)
	local apply_info = pbdata.apply_info
	--todo
	if next(apply_info) then
		for i, dApply in pairs(apply_info) do
			g_TeamCtrl:AddApply(dApply)
		end
	else
		g_TeamCtrl:ClearApply()
	end
end

function GS2CDelTeamApplyInfo(pbdata)
	local pid = pbdata.pid
	--todo
	g_TeamCtrl:DelApply(pid)
end

function GS2CAddTeamApplyInfo(pbdata)
	local apply_info = pbdata.apply_info
	--todo
	g_TeamCtrl:AddApply(apply_info)
end

function GS2CInviteInfo(pbdata)
	local teaminfo = pbdata.teaminfo
	--todo
	if next(teaminfo) then
		for i, dInvite in pairs(teaminfo) do
			g_TeamCtrl:AddInvite(dInvite)
		end
	else
		g_TeamCtrl:ClearInvite()
	end
end

function GS2CRemoveInvite(pbdata)
	local teamid = pbdata.teamid
	--todo
	g_TeamCtrl:DelInvite(teamid)
end

function GS2CAddInviteInfo(pbdata)
	local teaminfo = pbdata.teaminfo
	--todo
	if teaminfo.type == 1 then
		g_TeamCtrl:AddInvite(teaminfo)
	end
end

function GS2CTargetInfo(pbdata)
	local target_info = pbdata.target_info
	--todo
	g_TeamCtrl:SetTeamTargetInfo(target_info)
end

function GS2CNotifyAutoMatch(pbdata)
	local player_match = pbdata.player_match --1-正在匹配，0-取消匹配
	--todo
	g_TeamCtrl:SetPlayerMatchStatus(player_match)
end

function GS2CTargetTeamInfo(pbdata)
	local teaminfo = pbdata.teaminfo
	--todo
	CTeamInfoView:ShowView(function(oView)
		oView:SetTeamInfo(teaminfo)
	end)
end

function GS2CPlayerMatchTargetInfo(pbdata)
	local target_info = pbdata.target_info
	--todo
	g_TeamCtrl:SetPlayerTargetInfo(target_info)
end

function GS2CTargetTeamInfoList(pbdata)
	local teaminfo = pbdata.teaminfo
	local auto_target = pbdata.auto_target
	--todo
	g_TeamCtrl:ClearTargetTeamList(auto_target)
	if teaminfo ~= nil and next(teaminfo) then
		for k, dTeam in pairs(teaminfo) do
			if dTeam.member and next(dTeam.member) then
				g_TeamCtrl:AddTargetTeam(auto_target, dTeam)
			end			
		end
	else
		g_TeamCtrl:AddTargetTeam(auto_target, nil)
	end
end

function GS2CCountAutoMatch(pbdata)
	local auto_target = pbdata.auto_target
	local member_count = pbdata.member_count
	local team_count = pbdata.team_count
	--todo
	g_TeamCtrl:SetCountAutoMatch(pbdata)
end

function GS2CMemPartnerInfoChange(pbdata)
	local pid = pbdata.pid
	local partner_info = pbdata.partner_info
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(partner_info, "SimplePartner")
	if not g_ActivityCtrl:IsDailyCultivating() then
		g_TeamCtrl:UpdatePartnerAttr(pid, dDecode)
	end
end

function GS2CChangePosInfo(pbdata)
	local posinfo = pbdata.posinfo
	--todo
end

function GS2CPlayerMatchSuccess(pbdata)
	--todo
	g_TeamCtrl:GS2CPlayerMatchSuccess()
end

function GS2CCancelTeamAutoMatch(pbdata)
	--todo
	g_TeamCtrl:CtrlGS2CCancelTeamAutoMatch()
end

function GS2CTeamMingleiInfo(pbdata)
	local minglei_info = pbdata.minglei_info
	--todo
	g_TeamCtrl:CtrlGS2CTeamMingleiInfo(minglei_info)
end

function GS2CTeamTrapmineInfo(pbdata)
	local trapmine_info = pbdata.trapmine_info
	--todo
	g_TeamCtrl:CtrlC2GSTrapmineTeamInfo(trapmine_info)
end

function GS2CInviteFriendList(pbdata)
	local friend_list = pbdata.friend_list
	--todo
	g_TeamCtrl:CtrlGS2CInviteFriendList(friend_list)
end

function GS2CCreateTeam(pbdata)
	local target = pbdata.target --目标id，0-无目标
	--todo
	g_AnLeiCtrl:AnLeiCreateTeam(target)
end

function GS2CTargetMemList(pbdata)
	local info = pbdata.info
	--todo
	g_TeamCtrl:CtrlGS2CTargetMemList(info)
end


--C2GS--

function C2GSCreateTeam(auto_target, min_grade, max_grade)
	local t = {
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
	}
	g_NetCtrl:Send("team", "C2GSCreateTeam", t)
end

function C2GSTeamInfo(teamid)
	local t = {
		teamid = teamid,
	}
	g_NetCtrl:Send("team", "C2GSTeamInfo", t)
end

function C2GSApplyTeam(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("team", "C2GSApplyTeam", t)
end

function C2GSTeamApplyInfo()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTeamApplyInfo", t)
end

function C2GSApplyTeamPass(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("team", "C2GSApplyTeamPass", t)
end

function C2GSClearApply()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSClearApply", t)
end

function C2GSCancelApply(teamid)
	local t = {
		teamid = teamid,
	}
	g_NetCtrl:Send("team", "C2GSCancelApply", t)
end

function C2GSInviteTeam(target, auto_target, min_grade, max_grade)
	local t = {
		target = target,
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
	}
	g_NetCtrl:Send("team", "C2GSInviteTeam", t)
end

function C2GSInviteAll(target_list, auto_target, min_grade, max_grade)
	local t = {
		target_list = target_list,
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
	}
	g_NetCtrl:Send("team", "C2GSInviteAll", t)
end

function C2GSTeamInviteInfo()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTeamInviteInfo", t)
end

function C2GSInvitePass(teamid)
	local t = {
		teamid = teamid,
	}
	g_NetCtrl:Send("team", "C2GSInvitePass", t)
end

function C2GSClearInvite()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSClearInvite", t)
end

function C2GSShortLeave()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSShortLeave", t)
end

function C2GSLeaveTeam()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSLeaveTeam", t)
end

function C2GSLeaveLiLianTeam()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSLeaveLiLianTeam", t)
end

function C2GSKickOutTeam(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("team", "C2GSKickOutTeam", t)
end

function C2GSBackTeam()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSBackTeam", t)
end

function C2GSTeamSummon(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("team", "C2GSTeamSummon", t)
end

function C2GSApplyLeader()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSApplyLeader", t)
end

function C2GSSetLeader(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("team", "C2GSSetLeader", t)
end

function C2GSTeamAutoMatch(auto_target, min_grade, max_grade, team_match)
	local t = {
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
		team_match = team_match,
	}
	g_NetCtrl:Send("team", "C2GSTeamAutoMatch", t)
end

function C2GSTeamCancelAutoMatch()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTeamCancelAutoMatch", t)
end

function C2GSPlayerAutoMatch(auto_target, min_grade, max_grade)
	local t = {
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
	}
	g_NetCtrl:Send("team", "C2GSPlayerAutoMatch", t)
end

function C2GSPlayerCancelAutoMatch(auto_target, tips)
	local t = {
		auto_target = auto_target,
		tips = tips,
	}
	g_NetCtrl:Send("team", "C2GSPlayerCancelAutoMatch", t)
end

function C2GSGetTargetTeamInfo(auto_target)
	local t = {
		auto_target = auto_target,
	}
	g_NetCtrl:Send("team", "C2GSGetTargetTeamInfo", t)
end

function C2GSTakeOverLeader()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTakeOverLeader", t)
end

function C2GSSetTeamTarget(auto_target, min_grade, max_grade)
	local t = {
		auto_target = auto_target,
		min_grade = min_grade,
		max_grade = max_grade,
	}
	g_NetCtrl:Send("team", "C2GSSetTeamTarget", t)
end

function C2GSLeaderSleep(status)
	local t = {
		status = status,
	}
	g_NetCtrl:Send("team", "C2GSLeaderSleep", t)
end

function C2GSChangeTeamSetting(setting_info)
	local t = {
		setting_info = setting_info,
	}
	g_NetCtrl:Send("team", "C2GSChangeTeamSetting", t)
end

function C2GSGetMingleiTeamInfo(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("team", "C2GSGetMingleiTeamInfo", t)
end

function C2GSTrapmineTeamInfo()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSTrapmineTeamInfo", t)
end

function C2GSInviteFriendList()
	local t = {
	}
	g_NetCtrl:Send("team", "C2GSInviteFriendList", t)
end

function C2GSAwardWarBattleCommand(target, op)
	local t = {
		target = target,
		op = op,
	}
	g_NetCtrl:Send("team", "C2GSAwardWarBattleCommand", t)
end

function C2GSGetTargetMemList(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("team", "C2GSGetTargetMemList", t)
end

