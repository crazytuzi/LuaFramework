if not MODULE_GAMESERVER then
    Activity.KinElect = Activity.KinElect or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("KinElect") or Activity.KinElect

tbAct.szPaperUrl = "https://jxqy.qq.com/act/1380/a20190718jzpx/index.shtml?platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$&rroleid=%s&rpartition=%s"

tbAct.LEVEL_LIMIT = 40
tbAct.SIGNUP_ITEM_FIRST = 11191  --初赛宣传单道具
tbAct.VOTE_ITEM = 11120
tbAct.VOTE_ITEM_SPECIAL = 11235	--特殊投票道具，不计入个人累计投票

tbAct.szScriptDataKey = "KinElect"
--41-80可用
tbAct.SAVE_GROUP = 68
tbAct.VERSION = 126
tbAct.VOTE_COUNT = 127
tbAct.VOTE_AWARD_1 = 128
tbAct.VOTE_AWARD_2 = 129
tbAct.VOTE_AWARD_3 = 130
tbAct.VOTE_AWARD_4 = 131
tbAct.VOTE_AWARD_5 = 132
tbAct.VOTE_AWARD_6 = 133
tbAct.VOTE_AWARD_7 = 134
tbAct.VOTE_AWARD_8 = 135
tbAct.VOTE_AWARD_9 = 136
tbAct.VOTE_AWARD_10 = 137

tbAct.STATE_TYPE =
{
	END = 0,	--结束/未开始
	FIRST_1 = 1,	--初赛报名、内容展示及投票
	FIRST_2 = 2,	--初赛复核
	FIRST_3 = 3,	--初赛结果公布及发奖
	SECOND_1 = 4, --复赛报名、内容展示及投票
	SECOND_2 = 5, --复赛复核
	SECOND_3 = 6, --复赛结果公布及发奖
	THIRD_1 = 7,	--决赛报名、内容展示及投票
	THIRD_2 = 8,	--决赛复核
	THIRD_3 = 9,	--决赛展示及最终发奖
}

tbAct.STATE_TIME =
{
	[tbAct.STATE_TYPE.END] = {Lib:ParseDateTime("2019-07-19 10:00:00"), Lib:ParseDateTime("2019-07-26 3:59:59")},
	[tbAct.STATE_TYPE.FIRST_1] = {Lib:ParseDateTime("2019-07-26 4:00:00"), Lib:ParseDateTime("2019-07-31 20:00:00")},
	[tbAct.STATE_TYPE.FIRST_2] = {Lib:ParseDateTime("2019-07-31 20:00:01"), Lib:ParseDateTime("2019-08-01 12:00:00")},
	[tbAct.STATE_TYPE.FIRST_3] = {Lib:ParseDateTime("2019-08-01 12:00:01"), Lib:ParseDateTime("2019-08-02 12:00:00")},
	[tbAct.STATE_TYPE.SECOND_1] = {Lib:ParseDateTime("2019-08-02 12:00:01"), Lib:ParseDateTime("2019-08-08 20:00:00")},
	[tbAct.STATE_TYPE.SECOND_2] = {Lib:ParseDateTime("2019-08-08 20:00:01"), Lib:ParseDateTime("2019-08-09 12:00:00")},
	[tbAct.STATE_TYPE.SECOND_3] = {Lib:ParseDateTime("2019-08-09 12:00:01"), Lib:ParseDateTime("2019-08-10 12:00:00")},
	[tbAct.STATE_TYPE.THIRD_1] = {Lib:ParseDateTime("2019-08-10 12:00:01"), Lib:ParseDateTime("2019-08-13 20:00:00")},
	[tbAct.STATE_TYPE.THIRD_2] = {Lib:ParseDateTime("2019-08-13 20:00:01"), Lib:ParseDateTime("2019-08-14 12:00:00")},
	[tbAct.STATE_TYPE.THIRD_3] = {Lib:ParseDateTime("2019-08-14 12:00:01"), Lib:ParseDateTime("2019-08-15 24:00:00")},
}

-- 主界面按钮描述信息
tbAct.STATE_DESC =
{
	[tbAct.STATE_TYPE.END] = "即将开启",
	[tbAct.STATE_TYPE.FIRST_1] = "初赛进行中",
	[tbAct.STATE_TYPE.FIRST_2] = "初赛复核",
	[tbAct.STATE_TYPE.FIRST_3] = "初赛发奖",
	[tbAct.STATE_TYPE.SECOND_1] = "复赛进行中",
	[tbAct.STATE_TYPE.SECOND_2] = "复赛复核",
	[tbAct.STATE_TYPE.SECOND_3] = "复赛发奖",
	[tbAct.STATE_TYPE.THIRD_1] = "决赛进行中",
	[tbAct.STATE_TYPE.THIRD_2] = "决赛复核",
	[tbAct.STATE_TYPE.THIRD_3] = "决赛发奖",
}

tbAct.tbFurnitureSelectAward =
{
}

-- 投票奖励
tbAct.tbVotedAward =
{
	{tbAward={"Coin",10000}, 	nNeedCount = 10, nSaveKey = tbAct.VOTE_AWARD_1, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 6535, 1}, nNeedCount = 30, nSaveKey = tbAct.VOTE_AWARD_2, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 7467, 1}, nNeedCount = 60, nSaveKey = tbAct.VOTE_AWARD_3, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 224, 5}, nNeedCount = 100, nSaveKey = tbAct.VOTE_AWARD_4, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 6535, 2}, nNeedCount = 200, nSaveKey = tbAct.VOTE_AWARD_5, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 2699, 1}, nNeedCount = 500, nSaveKey = tbAct.VOTE_AWARD_6, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 10591, 1}, nNeedCount = 1000, nSaveKey = tbAct.VOTE_AWARD_7, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 6535, 10}, nNeedCount = 3000, nSaveKey = tbAct.VOTE_AWARD_8, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 11236, 1}, nNeedCount = 10000, nSaveKey = tbAct.VOTE_AWARD_9, bIsDirectShow = false, nMaxCount = 1},
}

function tbAct:GetCurState()
	local nNow = GetTime();
	for nState = #tbAct.STATE_TIME, 1, -1 do
		local tbRange = tbAct.STATE_TIME[nState]
		if tbRange[1] <= nNow and nNow <= tbRange[2] then
			return nState;
		end
	end

	return tbAct.STATE_TYPE.END;
end

function tbAct:GetStateLeftTime()
	local nCurState = self:GetCurState();
	if nCurState == tbAct.STATE_TYPE.END then
		return 0;
	end

	local nNow = GetTime();
	local tbRange = tbAct.STATE_TIME[nCurState]
	return tbRange[2] - nNow;
end


function tbAct:GetStateLeftTimeShow()
	local nCurState = self:GetCurState();
	if nCurState ~= tbAct.STATE_TYPE.FIRST_1 and nCurState ~= tbAct.STATE_TYPE.SECOND_1 and nCurState ~= tbAct.STATE_TYPE.THIRD_1  then
		return 0;
	end

	local nNow = GetTime();
	local tbRange = tbAct.STATE_TIME[nCurState]
	return tbRange[2] - nNow;
end

function tbAct:IsInProcess()
	return Activity:__IsActInProcessByType("KinElect")
end

function tbAct:GetVotedCount(pPlayer)
	self:CheckPlayerData(pPlayer);

	return pPlayer.GetUserValue(self.SAVE_GROUP, self.VOTE_COUNT)
end

function tbAct:GetVotedAward(pPlayer, nIndex)
	local tbAwardInfo = self.tbVotedAward[nIndex]
	local tbPreAwardInfo = self.tbVotedAward[nIndex - 1]
	if not tbAwardInfo then
		return
	end

	local nVotedCount = self:GetVotedCount(pPlayer)
	local nGotCount = pPlayer.GetUserValue(self.SAVE_GROUP, tbAwardInfo.nSaveKey)
	local nCanGet = 0;
	if nVotedCount >= tbAwardInfo.nNeedCount then
		if tbAwardInfo.nMaxCount > 0 then
			nCanGet = tbAwardInfo.nMaxCount - nGotCount
		else
			nCanGet = nVotedCount - tbAwardInfo.nNeedCount - nGotCount
		end
	end

	local bIsShow = tbAwardInfo.bIsDirectShow

	if not bIsShow then
		bIsShow = tbPreAwardInfo and nVotedCount >= tbPreAwardInfo.nNeedCount
	end

	local tbAward = Lib:CopyTB(tbAwardInfo.tbAward);

	if tbAward[1] == "Furniture" then
		tbAward = self:GetFurnitureAwardInfo(tbAward)
	end

	if nCanGet  > 0 or tbAwardInfo.nMaxCount <= 0 then
		if tbAward[1] == "Item" then
			tbAward[3] = tbAward[3] * nCanGet
		else
			tbAward[2] = tbAward[2] * nCanGet
		end
	end

	return tbAward, nCanGet, nGotCount, bIsShow, tbAwardInfo
end

function tbAct:GetFurnitureAwardInfo(tbAward)
	local szFrame = self:GetFurnitureAwardFrame()
	local nItemTemplateId = self.tbFurnitureSelectAward[szFrame]

	return {"Item", nItemTemplateId, tbAward[2]}
end