if not MODULE_GAMESERVER then
    Activity.MedalFightAct = Activity.MedalFightAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("MedalFightAct") or Activity.MedalFightAct

tbAct.nSaveGroup = 154
tbAct.nSaveKeyJoinCount = 1
tbAct.nSaveKeyJoinTime = 2
tbAct.nSaveKeyScore = 3
tbAct.nSaveKeyTotalWin = 4
tbAct.nSaveKeyTotalJoin = 5

tbAct.szMainKey = "MedalFightAct"

tbAct.nJoinLevel = 20
tbAct.nActDuration = 30*60	--每天活动持续x秒

tbAct.nMedalItemId = 7699	--奖章道具id
tbAct.tbActiveAward = { -- 活跃奖励个数
	[1] = 0,
	[2] = 0,
	[3] = 1,
	[4] = 1,
	[5] = 2,
}
tbAct.nDailyCount = 6	--每日最多参与x场
tbAct.nNewDayTime = 4*3600	--新的一天偏移秒数

tbAct.tbWinAward = { {"BasicExp", 45}, {"Contrib", 200} }
tbAct.tbLoseAward = { {"BasicExp", 20}, {"Contrib", 100} }

tbAct.nRoundPrepareTime = 8	--每局准备时间
tbAct.nRoundTime = 10	--每局x秒
tbAct.nRoundTimeScore = {	--答对，耗时得分
	{0.1, 10},	--耗时百分比（含），得分
	{0.2, 9},
	{0.3, 8},
	{0.4, 7},
	{0.5, 6},
	{0.6, 5},
	{0.7, 4},
	{0.8, 3},
	{0.9, 2},
	{1, 1},
}
tbAct.nWrongScore = 0	--答错得分

tbAct.szMailText = "您在[FFFE0D]奖章争夺战[-]中位列第[FFFE0D]%d[-]名，附件为奖励，请查收！"
tbAct.tbRankAward = {
	{1, {"Item", 7700, 1}},
    {10, {"Item", 7701, 1}},
    {50, {"Item", 7702, 1}},
    {100, {"Item", 7703, 1}},
}
tbAct.nBaseRewardScoreMin = 10	--满x个奖章获得基础奖励
tbAct.tbBaseReward = {"Item", 7704, 1} --基础奖励

function tbAct:LoadSetting()
	self.tbQuestions = Lib:LoadTabFile("Setting/Activity/MedalFightQuestions.tab", {nId=1, nAnswerId=1})
end
tbAct:LoadSetting()

function tbAct:IsAnswerRight(nId, nAnswerId)
	local tbQuestion = self:GetQuestion(nId)
	if not tbQuestion then
		Log("[x] MedalFightAct:IsAnswerRight", nId, nAnswerId)
		return false
	end
	return tbQuestion.nAnswerId==nAnswerId
end

function tbAct:GetQuestion(nId)
	return self.tbQuestions[nId]
end

function tbAct:RandomQuestionIds(nCount)
	local fn = Lib:GetRandomSelect(#self.tbQuestions)
	local tbRet = {}
	for i=1, nCount do
		table.insert(tbRet, fn())
	end
	return tbRet
end

function tbAct:CheckPlayer(pPlayer)
	if pPlayer.nLevel < self.nJoinLevel then
        return false, string.format("请先将等级提升至%d", self.nJoinLevel)
	end
	return true
end

function tbAct:GetScore(pPlayer)
	return pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyScore) or 0
end

function tbAct:AddScore(pPlayer, nAdd)
    if pPlayer.nLevel<self.nJoinLevel then
        return
    end
	local nScore = self:GetScore(pPlayer)+nAdd
	pPlayer.SetUserValue(self.nSaveGroup, self.nSaveKeyScore, nScore)
    RankBoard:UpdateRankVal(self.szMainKey, pPlayer.dwID, nScore)
	return nScore
end

function tbAct:GetJoinCount(pPlayer)
	local nLastJoinTime = pPlayer.GetUserValue(tbAct.nSaveGroup, tbAct.nSaveKeyJoinTime)
    local nJoinCount = pPlayer.GetUserValue(tbAct.nSaveGroup, tbAct.nSaveKeyJoinCount) or 0
    if Lib:IsDiffDay(self.nNewDayTime, GetTime(), nLastJoinTime) then
    	return 0, self.nDailyCount
    end
	return nJoinCount, self.nDailyCount
end

function tbAct:GetWinRate(pPlayer)
	local nTotalWin = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyTotalWin)
	local nTotalJoin = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyTotalJoin)
	if nTotalJoin<=0 then
		return 100, nTotalWin, nTotalJoin
	end
	return math.min(100, math.ceil(100*nTotalWin/nTotalJoin)), nTotalWin, nTotalJoin
end

function tbAct:AddJoinCount(pPlayer, bWin)
	local nTotalJoin = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyTotalJoin)
	pPlayer.SetUserValue(self.nSaveGroup, self.nSaveKeyTotalJoin, nTotalJoin+1)
	local nJoinCount = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyJoinCount)
	pPlayer.SetUserValue(self.nSaveGroup, self.nSaveKeyJoinCount, nJoinCount+1)
	if bWin then
		local nTotalWin = pPlayer.GetUserValue(self.nSaveGroup, self.nSaveKeyTotalWin)
		pPlayer.SetUserValue(self.nSaveGroup, self.nSaveKeyTotalWin, nTotalWin+1)
	end
end

function tbAct:CheckJoinCount(pPlayer)
    local nLastJoinTime = pPlayer.GetUserValue(tbAct.nSaveGroup, tbAct.nSaveKeyJoinTime)
    local nJoinCount = pPlayer.GetUserValue(tbAct.nSaveGroup, tbAct.nSaveKeyJoinCount)
    local nNow = GetTime()
    if Lib:IsDiffDay(self.nNewDayTime, nNow, nLastJoinTime) then
    	if MODULE_GAMESERVER then
	        pPlayer.SetUserValue(tbAct.nSaveGroup, tbAct.nSaveKeyJoinCount, 0)
	        pPlayer.SetUserValue(tbAct.nSaveGroup, tbAct.nSaveKeyJoinTime, nNow)
	    end
        return true
    end
    return nJoinCount<self.nDailyCount
end

if MODULE_GAMECLIENT then
	function tbAct:OnUpdateStatus(tbData, nServerNow)
		if Ui:WindowVisible("MedalFightWaitPanel")~=1 then
			return
		end
		tbData.nEndTime = tbData.nEndTime-(nServerNow-GetTime())
		Ui("MedalFightWaitPanel"):OnUpdate(tbData)
	end

	function tbAct:OnNewMatch(tbMatch, tbPlayer1, tbPlayer2, nServerNow)
		Ui:CloseWindow("MedalFightWaitPanel")
		self.tbMatch = tbMatch
		self.tbMatch.nRoundDeadline = self.tbMatch.nRoundDeadline-(nServerNow-GetTime())
		self.tbPlayers = {tbPlayer1, tbPlayer2}
		if Ui:WindowVisible("MedalFightPanel")~=1 then
			Ui:OpenWindow("MedalFightPanel")
			return
		end
		Ui("MedalFightPanel"):OnNewMatch()
	end

	function tbAct:OnMatchOver(nResult)
		if nResult==1 then
			me.CenterMsg("恭喜大侠获得胜利，赢得一枚奖章！", true)
		elseif nResult==-1 then
			me.CenterMsg("很遗憾，大侠输掉了一枚奖章！", true)
		else
			me.CenterMsg("此局为平局", true)
		end
		Ui:CloseWindow("MedalFightPanel")

		if self:CheckJoinCount(me) and self:GetScore(me)>0 then
			Ui:OpenWindow("MedalFightWaitPanel", true)
		end
	end

	function tbAct:OnSyncAnswered(nPlayerId, nScore)
		if not self.tbMatch then
			return
		end
		self.tbMatch.tbPlayers[nPlayerId].nScore = nScore
		if Ui:WindowVisible("MedalFightPanel")~=1 then
			return
		end
		Ui("MedalFightPanel"):OnScoreChanged()
	end

	function tbAct:OnNextRound(nRound, nDeadline, nServerNow)
		if not self.tbMatch or not self.tbPlayers then
			return
		end

		self.tbMatch.nCurRound = nRound
		self.tbMatch.nRoundDeadline = nDeadline-(nServerNow-GetTime())
		if Ui:WindowVisible("MedalFightPanel")~=1 then
			Ui:OpenWindow("MedalFightPanel")
			return
		end
		Ui("MedalFightPanel"):OnNewRound()
	end
end