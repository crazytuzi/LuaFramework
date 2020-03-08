-- 游戏启动
function TeamBattle:Init()
	Battle:RegisterManageMap(TeamBattle.PRE_MAP_ID);
	for _, tbInfo in pairs(TeamBattle.tbFightMapBeginPoint) do
		for _, tbMapInfo in pairs(tbInfo) do
			Battle:RegisterManageMap(tbMapInfo[1]);
		end
	end
end

-- 错误码
function TeamBattle:MsgCode(nCode, ...)
	local szMsg = string.format(TeamBattle.tbMsg[nCode], ...);
	me.CenterMsg(szMsg);
end

-- 准备场同步当前场内人数、倒计时
function TeamBattle:SyncPlayerCountInfo(nPlayerCount, nLastTime)
	if Ui:WindowVisible("QYHLeftInfo") ~= 1 or Ui("QYHLeftInfo").szType ~= "TeamBattlePre" then
		Ui:OpenWindow("QYHLeftInfo", "TeamBattlePre", {nLastTime, nPlayerCount});
	else
		Ui("QYHLeftInfo"):UpdateInfo({nLastTime, nPlayerCount});
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK);
end

-- 每隔三秒一次的伤害、击杀回调
function TeamBattle:SyncPlayerLeftInfo(nMyTeamId, tbDmgInfo)
	local nOtherTeamId = 3 - nMyTeamId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_KILL_INFO,
						tbDmgInfo[nMyTeamId].nKillCount,
						tbDmgInfo[nOtherTeamId].nKillCount,
						tbDmgInfo[nMyTeamId].nTotalDmg,
						tbDmgInfo[nOtherTeamId].nTotalDmg,
						tbDmgInfo.szStateInfo);
end

-- 战斗结束回调
--tbShowInfo[nTeamId] = tbShowInfo[nTeamId] or {};
--tbShowInfo[nTeamId][pPlayer.dwID] = {
--	szName		= pPlayer.szName,
--	nPortrait	= pPlayer.nPortrait,
--	nLevel		= pPlayer.nLevel,
--	nHonorLevel	= pPlayer.nHonorLevel,
--	nFaction	= pPlayer.nFaction,
--	nDamage		= nDamage,
--	nKillCount	= nKillCount,
--};

function TeamBattle:ShowFightResult(nMyTeamId, tbShowInfo, nWinTeamId, bShowTime)
	Ui:OpenWindow("TeamBattleAccount",nMyTeamId,tbShowInfo,nWinTeamId);
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_HIDE_SCORE,bShowTime);
end

function TeamBattle:ShowBeyInfo(nTime, bHideScore, bShowTime)
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_TIME, nTime or 0);
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_KILL_INFO, 0, 0, 0, 0, nTime and "等待匹配" or "比赛结束");

	if bHideScore then
		UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_HIDE_SCORE, bShowTime);
	end
end

-- 开始前的队伍信息服务端回调
function TeamBattle:ShowTeamInfo(nMyTeamId, tbTeamInfo)
	Ui:OpenWindow("TeamBattleAccount",nMyTeamId,tbTeamInfo);
end

-- 状态切换回调
function TeamBattle:SyncFightState(nTime)
	AutoFight:StopFollowTeammate();
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_TIME, nTime);
end

function TeamBattle:DealyShowTeamInfo(nDealyTime)
	if nDealyTime then
		Timer:Register(Env.GAME_FPS * nDealyTime, function ()
			self:DealyShowTeamInfo();
		end)
		return;
	end

	Ui:OpenWindow("HomeScreenTask");
	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK); end);
end

function TeamBattle:GetSeqType()
	local tbType = {TeamBattle.TYPE_MONTHLY, TeamBattle.TYPE_QUARTERLY}
	if not self.bNotOpenYear then
		table.insert(tbType, TeamBattle.TYPE_YEAR)
	end
	return tbType
end

function TeamBattle:OnSyncPlayerPreTime(nPreLastTime)
	TeamBattle.nPreLastTime = nPreLastTime
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_BATTLE_SYN_DATA)
end