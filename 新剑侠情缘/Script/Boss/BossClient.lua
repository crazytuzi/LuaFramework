Boss._DataCache = Boss._DataCache or {tbVersion = {}};

local tbData = Boss._DataCache;

function Boss:CacheData(szType, data, nVersion)
	tbData[szType] = data;
	tbData.tbVersion[szType] = nVersion;
end

function Boss:GetData(szType)
	return tbData[szType], tbData.tbVersion[szType];
end

function Boss:ClearData()
	Boss._DataCache = {tbVersion = {}};
	tbData = Boss._DataCache;
end

function Boss:IsOpen()
	local tbBossData = Boss:GetBossData();
	if not tbBossData then
		return false;
	end

	if tbBossData.nEndTime < GetTime() then
		Boss:ClearData();
		return false;
	end

	return true;
end

function Boss:GetBossData()
	return Boss:GetData("Boss");
end

function Boss:OnMyMsg(szMsg)
	local tbMsgs = Boss:GetData("MyMsg");
	if not tbMsgs then
		Boss:CacheData("MyMsg", {});
		tbMsgs = Boss:GetData("MyMsg");
	end

	table.insert(tbMsgs, 1, szMsg);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "MyMsg");
end

function Boss:GetMyMsg()
	return Boss:GetData("MyMsg") or {};
end

function Boss:GetMyKinData()
	return Boss:GetData("MyKin");
end

function Boss:OnSyncMyData(tbPlayerData)
	Boss:CacheData("MyData", tbPlayerData);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "MyData");
end

function Boss:GetMyData()
	return Boss:GetData("MyData") or {};
end

function Boss:UpdateBossData()
	local tbBossData = Boss:GetBossData() or {};
	local tbMyData = Boss:GetMyData();

	if Boss:IsInCross() then
		RemoteServer.OnZCBossRequest("ZCSyncBossInfo", tbBossData.nEndTime, tbMyData.nRank, tbMyData.nScore);
	else
		RemoteServer.OnBossRequest("SyncBossInfo", tbBossData.nEndTime, tbMyData.nRank);
	end
end

function Boss:GetPlayerRankData()
	return Boss:GetData("PlayerRank");
end

function Boss:UpdatePlayerRankData()
	if Boss:IsInCross() then
		RemoteServer.OnZCBossRequest("ZCSyncPlayerRank");
	else
		RemoteServer.OnBossRequest("SyncPlayerRank");
	end
end

function Boss:OnSyncPlayerRank(tbPlayerRankData, nVersion)
	Boss:CacheData("PlayerRank", tbPlayerRankData, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "PlayerRank");
end

function Boss:GetKinRankData()
	return Boss:GetData("KinRank");
end

function Boss:UpdateKinRankData()
	if Boss:IsInCross() then
		RemoteServer.OnZCBossRequest("ZCSyncKinRank");
	else
		RemoteServer.OnBossRequest("SyncKinRank");
	end
end

function Boss:OnSyncKinRank(tbKinRankData, nVersion, tbMyKin)
	Boss:CacheData("KinRank", tbKinRankData, nVersion);
	Boss:CacheData("MyKin", tbMyKin);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "KinRank");
end

function Boss:UpdateRobList()
	if Boss:IsInCross() then
		RemoteServer.OnZCBossRequest("ZCSyncRobList");
	else
		RemoteServer.OnBossRequest("SyncRobList");
	end
end

function Boss:OnSyncRobList(tbRobList)
	table.sort(tbRobList, function (a, b)
		return a.nRank < b.nRank;
	end)

	Boss:CacheData("RobList", tbRobList);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "RobList");
end

function Boss:GetRobList()
	return Boss:GetData("RobList");
end

function Boss:ChallengeBoss()
	self.tbFightBossResult = nil;
	if Boss:IsInCross() then
		RemoteServer.OnZCBossRequest("ZCFightBoss");
	else
		RemoteServer.OnBossRequest("FightBoss");
	end
end

function Boss:Rob(tbTargetData)
	self.tbRobResult = nil;
	self.bLeaveRob = false;
	if Boss:IsInCross() then
		RemoteServer.OnZCBossRequest("ZCRobPlayer", tbTargetData.nPlayerUid, tbTargetData.nPlayerId, tbTargetData.nServerId);
	else
		RemoteServer.OnBossRequest("RobPlayer", tbTargetData.nPlayerId);
	end
end

function Boss:OnSyncBossTime(nStartTime, nEndTime)
	local tbBossData = Boss:GetBossData();
	if not tbBossData then
		return;
	end
	tbBossData.nStartTime = nStartTime or 0;
	tbBossData.nEndTime = nEndTime or 0;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "BossHp");
end

function Boss:OnSyncBossData(tbBossData)
	Boss:ClearData();
	Boss:CacheData("Boss", tbBossData);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "BossHp");
end

function Boss:IsInCross()
	local tbBossData = Boss:GetBossData() or {};
	return tbBossData.tbKins and tbBossData.tbKins[me.dwKinId];
end

function Boss:OnRobResult(tbResult)
	if self.bLeaveRob then
		Ui:OpenWindow("BossRobResult", tbResult);
	else
		self.tbRobResult = tbResult;
	end
end

function Boss:EnterBossBattle(nUiState)
	UiNotify.OnNotify(UiNotify.emNOTIFY_BOSS_ROB_BATTLE, true);
	if nUiState then
		Ui:ChangeUiState(nUiState, false);
	end
end

function Boss:LeaveBossBattle()
	UiNotify.OnNotify(UiNotify.emNOTIFY_BOSS_ROB_BATTLE, false);
end

function Boss:LeaveRobBattle()
	self.bLeaveRob = true;
	if self.tbRobResult then
		Ui:OpenWindow("BossRobResult", self.tbRobResult);
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_BOSS_ROB_BATTLE, false);
end

function Boss:NotifyFinish()
	if me.nMapId == Boss.Def.nRobFightMap or me.nMapId == Boss.Def.nBossFightMap then
		if AsyncBattle.tbBattle and AsyncBattle.tbBattle.CloseBossBattle then
			AsyncBattle.tbBattle:CloseBossBattle();
		end
		return;
	end

	if Ui:WindowVisible("BossPanel") == 1 then
		me.MsgBox("挑战武林盟主已结束, 现正在结算中...", {{"确定", function ()
			Ui:CloseWindow("BossPanel");
		end}});
	end
end

function Boss:OnFightBossResult(tbResult)
	self.tbFightBossResult = tbResult;
end

function Boss:GetFightBossResult()
	local tb = self.tbFightBossResult;
	self.tbFightBossResult = nil;
	return tb;
end

function Boss:SyncFinalResult(tbMyRank, tbMyKin, tbTop10Player, tbTop10Kin)
	Boss:ClearData();

	if Ui:WindowVisible("BossPanel") == 1 then
		Ui:CloseWindow("MessageBox");
		Ui:OpenWindow("BossResult", tbMyRank, tbMyKin, tbTop10Player, tbTop10Kin);
	else
		Ui:SynNotifyMsg({
				szType = "BossResult";
				nTimeOut = GetTime() + 60;
				tbResult = {tbMyRank, tbMyKin or {}, tbTop10Player or {}, tbTop10Kin or {}};
			});
	end
end

function Boss:UpdateRobLeaveState(bShow)
	if bShow then
		Ui:OpenWindow("LeavePanel", "认输", "您确认要投降认输么？", {
		function ()
			RemoteServer.EndAsyncBattle()
		end})
	else
		Ui:CloseWindow("LeavePanel")
	end
end