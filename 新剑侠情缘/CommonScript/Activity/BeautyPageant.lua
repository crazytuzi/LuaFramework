if not MODULE_GAMESERVER then
    Activity.BeautyPageant = Activity.BeautyPageant or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("BeautyPageant") or Activity.BeautyPageant

tbAct.LEVEL_LIMIT = 40
tbAct.SIGNUP_ITEM = 4691  --海选赛宣传单道具
tbAct.SIGNUP_ITEM_FINAL = 4741  --决赛宣传单道具
tbAct.SIGNUP_ITEM_SEMIFINAL = 7939  --VN全服评选（第二轮）宣传单道具
tbAct.VOTE_ITEM = 4692
tbAct.IMITITY_PER_VOTE = 10 --每投一票增加多少亲密度

tbAct.szScriptDataKey = "BeautyPageantAct"
--41-80可用
tbAct.SAVE_GROUP = 68
tbAct.VERSION = 41
tbAct.VOTE_COUNT = 42
tbAct.VOTE_AWARD_1 = 43
tbAct.VOTE_AWARD_2 = 44
tbAct.VOTE_AWARD_3 = 45
tbAct.VOTE_AWARD_4 = 46
tbAct.VOTE_AWARD_5 = 47
tbAct.VOTE_AWARD_6 = 48
tbAct.VOTE_AWARD_7 = 49
tbAct.VOTE_AWARD_8 = 50
tbAct.VOTE_AWARD_9 = 51
tbAct.VOTE_AWARD_10 = 52

-- 主页面
tbAct.szMainEntryUrl = "http://www.jxqy.org?platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$"
-- 报名页面
tbAct.szSignUpUrl = "http://www.jxqy.org?platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$"
-- 玩家页面
tbAct.szPlayerUrl = "http://www.jxqy.org?platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$&rroleid=%s&rpartition=%s"

tbAct.szMainEntryUrl_VN = "http://www.jxqy.org?type=ranking&platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$&openid=$openid$&job=$job$"
tbAct.szSignUpUrl_VN = "http://www.jxqy.org?type=regis&platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$&openid=$openid$&job=$job$"
tbAct.szPlayerUrl_VN = "http://www.jxqy.org?type=vote&platid=$PlatId$&area=$Area$&partition=$ServerId$&roleid=$RoleId$&rolename=$RoleName$&family=$KinName$&itemnum=$VoteItem$&rroleid=%s&rpartition=%s&openid=$openid$&job=$job$"
tbAct.STATE_TYPE = 
{
	END = 0,	--结束/未开始
	SIGN_UP = 1,	--报名
	LOCAL = 2,	--本服比赛
	LOCAL_REST = 3,	--本服比赛间歇期
	FINAL = 4,	--全服决赛
	FINAL_REST = 5,	--全服决赛间歇期
}

tbAct.SignUpType = 
{
	LOCAL = 1, 				-- 本服比赛报名
	FINAL = 2, 				-- 晋级决赛
}

tbAct.STATE_TIME = 
{
	[tbAct.STATE_TYPE.SIGN_UP] = {Lib:ParseDateTime("2017-06-16 12:00:00"), Lib:ParseDateTime("2017-06-16 12:00:00")},
	[tbAct.STATE_TYPE.LOCAL] = {Lib:ParseDateTime("2017-06-16 12:00:00"), Lib:ParseDateTime("2017-06-22 23:59:59")},
	[tbAct.STATE_TYPE.LOCAL_REST] = {Lib:ParseDateTime("2017-06-23 00:00:00"), Lib:ParseDateTime("2017-06-26 11:59:59")},
	[tbAct.STATE_TYPE.FINAL] = {Lib:ParseDateTime("2017-06-26 12:00:00"), Lib:ParseDateTime("2017-07-02 23:59:59")},
	[tbAct.STATE_TYPE.FINAL_REST] = {Lib:ParseDateTime("2017-07-03 00:00:00"), Lib:ParseDateTime("2017-07-07 23:59:59")},
}

tbAct.STATE_DESC = 
{
	[tbAct.STATE_TYPE.END] = "评选结束",
	[tbAct.STATE_TYPE.SIGN_UP] = "火热报名",
	[tbAct.STATE_TYPE.LOCAL] = "海选赛阶段",
	[tbAct.STATE_TYPE.LOCAL_REST] = "本服第一美女",
	[tbAct.STATE_TYPE.FINAL] = "决赛阶段",
	[tbAct.STATE_TYPE.FINAL_REST] = "武林第一美女",

}

tbAct.MSG_CHANNEL_TYPE = 
{
	NORMAL = 1,
	FACTION = 2,
	PRIVATE = 3,
}

tbAct.tbFurnitureSelectAward = 
{
	["OpenDay1"] = 4825,
	["OpenDay224"] = 4826,	--开放4级家具
	["OpenDay339"] = 4827,	--开放5级家具
}

tbAct.tbVotedAward = 
{
	{tbAward={"Coin",100000}, 	nNeedCount = 10, nSaveKey = tbAct.VOTE_AWARD_1, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Contrib",10000}, nNeedCount = 30, nSaveKey = tbAct.VOTE_AWARD_2, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Gold",1000}, 	nNeedCount = 60, nSaveKey = tbAct.VOTE_AWARD_3, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Item", 2699, 1}, nNeedCount = 100, nSaveKey = tbAct.VOTE_AWARD_4, bIsDirectShow = true, nMaxCount = 1},
	{tbAward={"Energy", 15000}, nNeedCount = 200, nSaveKey = tbAct.VOTE_AWARD_5, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 3693, 1}, nNeedCount = 500, nSaveKey = tbAct.VOTE_AWARD_6, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Item", 224, 20}, nNeedCount = 1000, nSaveKey = tbAct.VOTE_AWARD_7, bIsDirectShow = false, nMaxCount = 1},
	--家具材料任选箱需要特殊处理
	{tbAward={"Furniture", 1}, 	nNeedCount = 3000, nSaveKey = tbAct.VOTE_AWARD_8, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Energy", 500000}, nNeedCount = 10000, nSaveKey = tbAct.VOTE_AWARD_9, bIsDirectShow = false, nMaxCount = 1},
	{tbAward={"Energy", 50}, 	nNeedCount = 10000, nSaveKey = tbAct.VOTE_AWARD_10, bIsDirectShow = false, nMaxCount = -1},
}

if version_vn then
	tbAct.STATE_TYPE = 
	{
		END = 0,	--结束/未开始
		SIGN_UP = 1,	--报名
		LOCAL = 2,	--本服比赛
		LOCAL_REST = 3,	--本服比赛间歇期
		SEMIFINAL = 4, -- 全服评选
		SEMIFINAL_REST = 5,  -- 全服评选间歇期
		FINAL = 6,	--全服决赛
		FINAL_REST = 7,	--全服决赛间歇期
	}
	tbAct.STATE_TIME = 
	{
		[tbAct.STATE_TYPE.SIGN_UP] = {Lib:ParseDateTime("2018-06-13 12:00:00"), Lib:ParseDateTime("2018-06-26 23:59:59")},
		[tbAct.STATE_TYPE.LOCAL] = {Lib:ParseDateTime("2018-06-13 12:00:00"), Lib:ParseDateTime("2018-06-26 23:59:59")},
		[tbAct.STATE_TYPE.LOCAL_REST] = {Lib:ParseDateTime("2018-06-27 00:00:00"), Lib:ParseDateTime("2018-07-04 11:59:59")},
		[tbAct.STATE_TYPE.SEMIFINAL] = {Lib:ParseDateTime("2018-07-04 12:00:00"), Lib:ParseDateTime("2018-07-17 23:59:59")},
		[tbAct.STATE_TYPE.SEMIFINAL_REST] = {Lib:ParseDateTime("2018-07-18 00:00:00"), Lib:ParseDateTime("2018-07-25 11:59:59")},
		[tbAct.STATE_TYPE.FINAL] = {Lib:ParseDateTime("2018-07-25 12:00:00"), Lib:ParseDateTime("2018-08-24 23:59:59")},
		[tbAct.STATE_TYPE.FINAL_REST] = {Lib:ParseDateTime("2018-08-25 00:00:00"), Lib:ParseDateTime("2018-08-30 23:59:59")},
	}
	tbAct.STATE_DESC = 
	{
		[tbAct.STATE_TYPE.END] = "评选结束",
		[tbAct.STATE_TYPE.SIGN_UP] = "火热报名",
		[tbAct.STATE_TYPE.LOCAL] = "本服海选",
		[tbAct.STATE_TYPE.LOCAL_REST] = "本服第一美女",
		[tbAct.STATE_TYPE.SEMIFINAL] = "全服评选阶段",
		[tbAct.STATE_TYPE.SEMIFINAL_REST] = "全服评选阶段",
		[tbAct.STATE_TYPE.FINAL] = "决赛阶段",
		[tbAct.STATE_TYPE.FINAL_REST] = "武林第一美女",
	}
	tbAct.tbVotedAward = 
	{
		{tbAward={"Coin",100000}, 	nNeedCount = 10, nSaveKey = tbAct.VOTE_AWARD_1, bIsDirectShow = true, nMaxCount = 1},
		{tbAward={"Contrib",10000}, nNeedCount = 30, nSaveKey = tbAct.VOTE_AWARD_2, bIsDirectShow = true, nMaxCount = 1},
		{tbAward={"Gold",1000}, 	nNeedCount = 60, nSaveKey = tbAct.VOTE_AWARD_3, bIsDirectShow = true, nMaxCount = 1},
		{tbAward={"Item", 2699, 1}, nNeedCount = 100, nSaveKey = tbAct.VOTE_AWARD_4, bIsDirectShow = true, nMaxCount = 1},
		{tbAward={"Energy", 15000}, nNeedCount = 200, nSaveKey = tbAct.VOTE_AWARD_5, bIsDirectShow = false, nMaxCount = 1},
		{tbAward={"Item", 3693, 1}, nNeedCount = 500, nSaveKey = tbAct.VOTE_AWARD_6, bIsDirectShow = false, nMaxCount = 1},
		{tbAward={"Item", 224, 20}, nNeedCount = 1000, nSaveKey = tbAct.VOTE_AWARD_7, bIsDirectShow = false, nMaxCount = 1},
		--家具材料任选箱需要特殊处理
		{tbAward={"Furniture", 1}, 	nNeedCount = 3000, nSaveKey = tbAct.VOTE_AWARD_8, bIsDirectShow = false, nMaxCount = 1},
		{tbAward={"Energy", 500000}, nNeedCount = 10000, nSaveKey = tbAct.VOTE_AWARD_9, bIsDirectShow = false, nMaxCount = 1},
		{tbAward={"Energy", 50}, 	nNeedCount = 10000, nSaveKey = tbAct.VOTE_AWARD_10, bIsDirectShow = false, nMaxCount = -1},
	}
end

-- 报名类型对应的阶段
tbAct.tbSugnUp2State = 
{
	[tbAct.SignUpType.LOCAL] = tbAct.STATE_TYPE.LOCAL,
	[tbAct.SignUpType.FINAL] = tbAct.STATE_TYPE.FINAL,
}

function tbAct:GetUrl()
	if version_vn then
		return self.szMainEntryUrl_VN, self.szSignUpUrl_VN, self.szPlayerUrl_VN
	else
		return self.szMainEntryUrl, self.szSignUpUrl, self.szPlayerUrl
	end
end

function tbAct:GetMainEntryUrl()
	local szMainEntryUrl = self:GetUrl()
	return szMainEntryUrl
end

function tbAct:GetSignUpUrl()
	local _, szSignUpUrl = self:GetUrl()
	return szSignUpUrl
end

function tbAct:GetPlayerUrl()
	local _, _, szPlayerUrl = self:GetUrl()
	return szPlayerUrl
end

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
	return Activity:__IsActInProcessByType("BeautyPageant")
end

function tbAct:GetSendMsg(pPlayer)
	local szMsg = string.format("<佳人：%s>快用你们手中的「红粉佳人」支持一下我吧！#118#118", pPlayer.szName)
	local tbLinkData = {nLinkType = ChatMgr.LinkType.HyperText, linkParam={szHyperText = string.format("[url=openBeautyUrl:PlayerPage, %s][-]", string.format(self:GetPlayerUrl(), pPlayer.dwID, Sdk:GetServerId()))}}

	return szMsg, tbLinkData
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
