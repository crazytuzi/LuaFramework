QunYingHuiCross.tbMatchData = QunYingHuiCross.tbMatchData or {}
QunYingHuiCross.tbChooseFaction = QunYingHuiCross.tbChooseFaction or {}
function QunYingHuiCross:SyncFightState(nTime)
	Ui:OpenWindow("ArenaBattleInfo", nTime)
	Timer:Register(Env.GAME_FPS, function () UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_TIME_DATA, nTime); end)
end

function QunYingHuiCross:OnFightingState(nTime)
	Ui:CloseWindow("RoleHeadPop");
	self:SyncFightState(nTime)
end

function QunYingHuiCross:SyncPlayerLeftInfo(nMyCampId, tbDmgInfo)
	local nOtherCampId = 3 - nMyCampId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_ARENA_DMAGE_DATA,
						tbDmgInfo[nMyCampId].nKillCount,
						tbDmgInfo[nOtherCampId].nKillCount,
						tbDmgInfo[nMyCampId].nTotalDmg,
						tbDmgInfo[nOtherCampId].nTotalDmg,
						tbDmgInfo.szStateInfo);
end

function QunYingHuiCross:OnShowTeamInfo(nCampId, tbCampInfo, nWinCamp, nStayTime, bSingleTeam)
	local tbShowBtn = bSingleTeam and {"BtnContinue"}
	local tbParam = {
		tbShowBtn = tbShowBtn;
		szKey = "QYHCross";
		nStayTime = nStayTime;
	}
	Ui:OpenWindow("ArenaAccount", nCampId, tbCampInfo, nWinCamp, tbParam);
end

function QunYingHuiCross:SynMatchData()
	local nRequestTime = me.nRequestSynMatchDataTime or 0
	local nNowTime = GetTime()
	if nNowTime - nRequestTime >= 30 then
		RemoteServer.QYHCrossClientCall("RequestMatchData")
		me.nRequestSynMatchDataTime = nNowTime
	else
		RemoteServer.QYHCrossClientCall("RequestMatchTime")
	end
 	
end

function QunYingHuiCross:OnSynMatchData(tbData)
	for k, v in pairs(tbData or {}) do
		self.tbMatchData[k] = v
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_QYHCROSS_SYN_MATCH_DATA)
	self:CheckRedPoint()
end

function QunYingHuiCross:CheckRedPoint()
	local nWinCount = self.tbMatchData.nWinCount or 0
	local nFightCount = self.tbMatchData.nFightCount or 0
	local tbMyGetWinAwardFlag = self.tbMatchData.tbGetWinAwardFlag or {}
	local tbMyGetJoinAwardFlag = self.tbMatchData.tbGetJoinAwardFlag or {}
	local _, nWinId = QunYingHuiCross:GetWinAward(QunYingHuiCross.nShowWinCount)
	local _, nJoinId = QunYingHuiCross:GetJoinAward(QunYingHuiCross.nShowJoinCount)
	if nWinCount >= QunYingHuiCross.TYPE_NORMAL and not tbMyGetWinAwardFlag[nWinId] then
		Ui:SetRedPointNotify("QYHCross_GetWin");
	else
		Ui:ClearRedPointNotify("QYHCross_GetWin");
	end
	if nFightCount >= QunYingHuiCross.nShowJoinCount and not tbMyGetJoinAwardFlag[nJoinId] then
		Ui:SetRedPointNotify("QYHCross_GetJoin");
	else
		Ui:ClearRedPointNotify("QYHCross_GetJoin");
end
	end

function QunYingHuiCross:GetMatchData()
	return self.tbMatchData
end

function QunYingHuiCross:OnEnterMap(nTemplateID)
	if QunYingHuiCross.nPreMapTID == nTemplateID then
		Ui:CloseWindow("QYHNewEntrance")
	end
end

function QunYingHuiCross:OnLeaveMap(nTemplateID)
	if QunYingHuiCross.nPreMapTID == nTemplateID then
		self:CloseAllRelateUi()
		me.bChoosingFaction = nil
	end
end

function QunYingHuiCross:CloseAllRelateUi()
	for _, szUiName in ipairs(QunYingHuiCross.tbRelateUi) do
		Ui:CloseWindow(szUiName)
	end
end

function QunYingHuiCross:OnLeaveFight()
	Ui:CloseWindow("ArenaBattleInfo")
	Ui:CloseWindow("ArenaAccount")
	Ui:CloseWindow("MessageBox")
	-- ui层级问题延迟调用
	Timer:Register(Env.GAME_FPS, function () Ui:OpenWindow("QYHMatchingPanel") end);
end

function QunYingHuiCross:OnEnterFight()
	Timer:Register(Env.GAME_FPS, function () 
		Ui:CloseWindow("MessageBox")
		Ui:CloseWindow("QYHMatchingPanel") 
	end);
end

function QunYingHuiCross:OnChooseFaction(tbFaction, nType, nUpdateTime, szKinName)
	me.bChoosingFaction = true
	local tbSortFaction = self:GetSortFaction(tbFaction)
	Ui:OpenWindow("QYHChoicePanel", tbSortFaction, nUpdateTime, nType, szKinName)
end

function QunYingHuiCross:IsChoosingFaction()
	return me.bChoosingFaction
end

function QunYingHuiCross:OnPreMapLogin(bChoosingFaction)
	me.bChoosingFaction = bChoosingFaction
end

function QunYingHuiCross:GetSortFaction(tbFaction)
	local tbSortFaction = {}
	for nFaction in pairs(tbFaction) do
		table.insert(tbSortFaction, {nFaction = nFaction})
	end
	table.sort(tbSortFaction, function (a, b) return a.nFaction < b.nFaction end)
	return tbSortFaction
end

function QunYingHuiCross:OnFinishChooseFaction()
	Ui:CloseWindow("QYHChoicePanel")
	Ui:CloseWindow("ChatLargePanel")
	me.bChoosingFaction = nil
	AutoFight:ChangeState(AutoFight.OperationType.Auto);
end

function QunYingHuiCross:OnChooseFactionChange(tbChooseFaction)
	self.tbChooseFaction = tbChooseFaction
	UiNotify.OnNotify(UiNotify.emNOTIFY_QYHCROSS_CHOOSE_FACTION)
end

function QunYingHuiCross:GetChooseFaction()
	return self.tbChooseFaction
end

function QunYingHuiCross:ClearChooseFaction()
	self.tbChooseFaction = {}
end

function QunYingHuiCross:OnUpdatePlayerUi(tbParam)
	-- 因为ui打开是有预加载过程的，为了保证先打开QYHLeftInfo再打开QYHLeavePanel的顺序先销毁
	Ui.UiManager.DestroyUi("QYHLeavePanel")
	local nType = tbParam[1] or 4
	local nRestTime = tbParam[2] or 0
	local nWinCount = tbParam[3] or 0
	local nFightCount = tbParam[4] or 0
	local szWinRate = string.format("%s/%s([FFFE0D]%s[-])", nWinCount, nFightCount, string.format("%.2f%%", (nFightCount == 0 and 0 or (nWinCount / nFightCount * 100))))
	local szKey = "QYHCross" ..nType
	if Ui:WindowVisible("QYHLeftInfo") == 1 then
		Ui:DoLeftInfoUpdate({nRestTime, szWinRate}, szKey)
	else
		Ui:OpenWindow("QYHLeftInfo", szKey, {nRestTime, szWinRate})
	end
	Ui:CloseWindow("RoleHeadPop")
end

function QunYingHuiCross:OnUpdateLeaveUi(bShow)
	if bShow then
		Ui:OpenWindow("QYHLeavePanel", "QYHCross", {BtnSports = true, BtnLeave = true})
	else
		Ui:CloseWindow("QYHLeavePanel")
	end
end

function QunYingHuiCross:CheckGetWinAward(nWin)
	local tbAward, nId = QunYingHuiCross:GetWinAward(nWin)
	if not tbAward then
		return false, "找不到相关奖励"
	end
	local nWinCount = self.tbMatchData.nWinCount or 0
	if nWinCount < nWin then
		return false, string.format("少侠尚未取得%d场胜利", nWin)
	end
	local tbMyGetWinAwardFlag = self.tbMatchData.tbGetWinAwardFlag or {}
	if tbMyGetWinAwardFlag[nId] then
		return false, "少侠已经领过此奖励了"
	end
	return true
end

function QunYingHuiCross:CheckGetJoinAward(nJoin)
	local tbAward, nId = QunYingHuiCross:GetJoinAward(nJoin)
	if not tbAward then
		return false, "找不到相关奖励"
	end
	local nFightCount = self.tbMatchData.nFightCount or 0
	if nFightCount < nJoin then
		return false, string.format("少侠尚未完成%d场对战", nJoin)
	end
	local tbGetJoinAwardFlag = self.tbMatchData.tbGetJoinAwardFlag or {}
	if tbGetJoinAwardFlag[nId] then
		return false, "少侠已经领过此奖励了"
	end
	return true
end

function QunYingHuiCross:IsNoShowQuitTeamTip()
	if me.nMapTemplateId == QunYingHuiCross.nPreMapTID or me.nMapTemplateId == QunYingHuiCross.nFightMapTID then
		return true
	end
end