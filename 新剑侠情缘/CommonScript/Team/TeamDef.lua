TeamMgr.MAX_MEMBER_COUNT = 4;
TeamMgr.OPEN_LEVEL       = 5;

TeamMgr.TEAM_ACTIVITY_NAME = {
	RandomFuben = "凌绝峰";
	TeamFuben   = "组队副本";
	PunishTask  = "惩恶任务";
}

TeamMgr.Def = TeamMgr.Def or {};

TeamMgr.Def.AUTO_AGREE_GROUP = 117; -- 队伍自动同意保存在玩家身上
TeamMgr.Def.AUTO_AGREE_KEY   = 1;

TeamMgr.Def.nApplyBeCaptainWaitingTime   = 20; -- 申请成为队长等待时间
TeamMgr.Def.nFollowFightStateLastingTime = 10; -- 跟战状态持续显示时长

TeamMgr.QUICK_TEAM_FULL_CHECK = {
	AdventureFuben = true;
	RandomFuben = true;
	TeamFuben = true;
	WuLinDaShiFuben = true;
}

TeamMgr.forbidden_make_and_operation_team  = 1;			-- 某些地图不允许组队，进入地图会自动拆除队伍
TeamMgr.forbidden_operation_team_in_client = 2;			-- 禁止玩家进行组队相关操作，只能保持现有状态
TeamMgr.forbidden_operation_but_callfollow = 3;			-- 禁止玩家进行组队相关操作，只保留召回

TeamMgr.Def.tbCallFollowType = {
	AskTeammate2Follow    = true;
	AskTeammateNot2Follow = true;
};

TeamMgr.Def.tbServerReqAlwaysAllowType = {
	UpdateFollowState = true;
};

function TeamMgr:CanTeam(nMapTemplateId)
	local tbMapSetting = Map:GetMapSetting(nMapTemplateId)
	return tbMapSetting.TeamForbidden ~= self.forbidden_make_and_operation_team;
end

function TeamMgr:CanClientOperTeam(nMapTemplateId)
	local tbMapSetting = Map:GetMapSetting(nMapTemplateId)
	return tbMapSetting.TeamForbidden ~= self.forbidden_operation_team_in_client 
			and tbMapSetting.TeamForbidden ~= self.forbidden_operation_but_callfollow;
end

TeamMgr.QUICK_TEAM_JOIN_COUNT_DEGREE = {
	AdventureFuben = "AdventureFuben";
	RandomFuben    = "RandomFuben";
	PunishTask     = "PunishTask";
	TeamFuben      = "TeamFuben";
};

function TeamMgr:GetTeamActivityCountInfo(szActivityType, pPlayer)
	local szDegreeName = TeamMgr.QUICK_TEAM_JOIN_COUNT_DEGREE[szActivityType];
	if not szDegreeName then
--[[		Log("TeamMgr:GetTeamActivityCountInfo", szActivityType)
		Log(debug.traceback())--]]
		return 1, -1;
	end

	local nMaxCount = DegreeCtrl:GetMaxDegree(szDegreeName, pPlayer);
	local nCurCount = DegreeCtrl:GetDegree(pPlayer, szDegreeName);
	return nCurCount, nMaxCount;
end
