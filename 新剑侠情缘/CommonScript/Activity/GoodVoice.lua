if not MODULE_GAMESERVER then
    Activity.GoodVoice = Activity.GoodVoice or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("GoodVoice") or Activity.GoodVoice
tbAct.LEVEL_LIMIT = 30 					-- 参与等级
tbAct.VOTE_ITEM = 7537 			-- 桃花签item id

tbAct.SAVE_GROUP = 68
tbAct.VERSION = 81
tbAct.VOTE_COUNT = 82
tbAct.VOTE_AWARD_1 = 83
tbAct.VOTE_AWARD_2 = 84
tbAct.VOTE_AWARD_3 = 85
tbAct.VOTE_AWARD_4 = 86
tbAct.VOTE_AWARD_5 = 87
tbAct.VOTE_AWARD_6 = 88
tbAct.VOTE_AWARD_7 = 89
tbAct.VOTE_AWARD_8 = 90
tbAct.VOTE_AWARD_9 = 91
tbAct.VOTE_AWARD_10 = 92

tbAct.szScriptDataKey = "GoodVoiceAct"

tbAct.STATE_TYPE = 
{
	END = 0,	--结束/未开始
	SIGN_UP = 1,	--报名
	LOCAL = 2,	--本服比赛
	LOCAL_REST = 3,	--本服比赛间歇期
	SEMI_FINAL = 4, -- 全服复赛
	SEMI_FINAL_REST = 5,  -- 全服复赛间歇期
	FINAL = 6,	--全服决赛
	FINAL_REST = 7,	--全服决赛间歇期
}

tbAct.STATE_TIME = 
{
	[tbAct.STATE_TYPE.SIGN_UP] = {Lib:ParseDateTime("2018-04-27 12:00:00"), Lib:ParseDateTime("2018-05-05 23:59:59")},
	[tbAct.STATE_TYPE.LOCAL] = {Lib:ParseDateTime("2018-04-30 00:00:00"), Lib:ParseDateTime("2018-05-05 23:59:59")},
	[tbAct.STATE_TYPE.LOCAL_REST] = {Lib:ParseDateTime("2018-05-06 00:00:00"), Lib:ParseDateTime("2018-05-07 11:59:59")},
	[tbAct.STATE_TYPE.SEMI_FINAL] = {Lib:ParseDateTime("2018-05-07 12:00:00"), Lib:ParseDateTime("2018-05-12 23:59:59")},
	[tbAct.STATE_TYPE.SEMI_FINAL_REST] = {Lib:ParseDateTime("2018-05-13 00:00:00"), Lib:ParseDateTime("2018-05-14 11:59:59")},
	[tbAct.STATE_TYPE.FINAL] = {Lib:ParseDateTime("2018-05-14 12:00:00"), Lib:ParseDateTime("2018-05-21 11:59:59")},
	[tbAct.STATE_TYPE.FINAL_REST] = {Lib:ParseDateTime("2018-05-21 12:00:00"), Lib:ParseDateTime("2018-05-23 23:59:59")},
}

tbAct.STATE_DESC = 
{
	[tbAct.STATE_TYPE.END] = "评选结束",
	[tbAct.STATE_TYPE.SIGN_UP] = "火热报名",
	[tbAct.STATE_TYPE.LOCAL] = "海选赛阶段",
	[tbAct.STATE_TYPE.LOCAL_REST] = "本服最强声",
	[tbAct.STATE_TYPE.SEMI_FINAL] = "复赛阶段",
	[tbAct.STATE_TYPE.SEMI_FINAL_REST] = "复赛最强声",
	[tbAct.STATE_TYPE.FINAL] = "决赛阶段",
	[tbAct.STATE_TYPE.FINAL_REST] = "武林最强声",
}

tbAct.MSG_CHANNEL_TYPE = 
{
	NORMAL = 1,
	FACTION = 2,
	PRIVATE = 3,
}

tbAct.SIGNUP_ITEM = 7707  --海选赛宣传单道具
tbAct.SIGNUP_ITEM_SEMI_FINAL = 7714  --复赛宣传单道具
tbAct.SIGNUP_ITEM_FINAL = 7715  --决赛宣传单道具

tbAct.tbVotedAward = 
{
	{tbAward={"Coin",10000}, 		nNeedCount = 10, nSaveKey = tbAct.VOTE_AWARD_1, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 6535, 1}, 	nNeedCount = 30, nSaveKey = tbAct.VOTE_AWARD_2, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 7467, 1}, 	nNeedCount = 60, nSaveKey = tbAct.VOTE_AWARD_3, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 224, 5}, 		nNeedCount = 100, nSaveKey = tbAct.VOTE_AWARD_4, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 2699, 1}, 	nNeedCount = 200, nSaveKey = tbAct.VOTE_AWARD_5, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 6535, 4}, 	nNeedCount = 500, nSaveKey = tbAct.VOTE_AWARD_6, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 3693, 1}, 	nNeedCount = 1000, nSaveKey = tbAct.VOTE_AWARD_7, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 6535, 10}, 	nNeedCount = 3000, nSaveKey = tbAct.VOTE_AWARD_8, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 7734, 1}, 	nNeedCount = 10000, nSaveKey = tbAct.VOTE_AWARD_9, bIsDirectShow = false, nMaxCount = 1},
}

tbAct.tbFurnitureSelectAward = 
{
	["OpenDay1"] = 4825,
	["OpenDay224"] = 4826,	--开放4级家具
	["OpenDay339"] = 4827,	--开放5级家具
}

tbAct.LINK_TYPE = 
{
	MAIN = 1;
	SIGNUP = 2;
	PLAYERPAGE = 3;
}
-- 粉丝榜最新消息key
tbAct.szNewInfoFansKey = "fans"
tbAct.szNewInfoFansTtile = "好声音粉丝榜"
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

function tbAct:IsInProcess()
	return Activity:__IsActInProcessByType("GoodVoice")
end

function tbAct:CheckJoin(pPlayer)
	if not self:IsInProcess() then
		return false, "活动未开启"
	end
	if pPlayer.nLevel < self.LEVEL_LIMIT then
		return false, string.format("参与等级%s", self.LEVEL_LIMIT)
	end
	return true
end

function tbAct:GetPlayerPage(dwID, szOpenId, szDes)
	return string.format("[url=openGoodVoiceUrl:%s,%d;%d;%s][-]", szDes or "PlayerPage", self.LINK_TYPE.PLAYERPAGE, dwID, szOpenId)
end

function tbAct:GetMainPage(szDes)
	return string.format("[url=openGoodVoiceUrl:%s,%d][-]", szDes or "MainPage", self.LINK_TYPE.MAIN)
end 

function tbAct:GetSignUpPage(szDes)
	return string.format("[url=openGoodVoiceUrl:%s,%d][-]", szDes or "SignUpPage", self.LINK_TYPE.SIGNUP)
end


function tbAct:GetSendMsg(pPlayer)
	local szAccount = pPlayer.szAccount
	if MODULE_GAMECLIENT then
		szAccount = Sdk:GetUid()
	end
	local szMsg = string.format("<选手：%s>快用你们手中的「桃花笺」支持一下我吧！#118#118", pPlayer.szName)
	local tbLinkData = {
	nLinkType = ChatMgr.LinkType.HyperText,
	linkParam = {
		szHyperText = string.format(self:GetPlayerPage(pPlayer.dwID,szAccount));
		}
	}
	return szMsg, tbLinkData
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

function tbAct:GetVotedCount(pPlayer)
	self:CheckPlayerData(pPlayer);

	return pPlayer.GetUserValue(self.SAVE_GROUP, self.VOTE_COUNT)
end