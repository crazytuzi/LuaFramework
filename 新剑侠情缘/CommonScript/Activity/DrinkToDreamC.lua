if not MODULE_GAMESERVER then
    Activity.DrinkToDreamAct = Activity.DrinkToDreamAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("DrinkToDreamAct") or Activity.DrinkToDreamAct;

tbAct.SINCEREWORDS_CONTENT_MAX_LEN = 12  --衷言内容最大字数
tbAct.MAX_MODIFY_TIMES = 2   --每个衷言可以修改的次数
tbAct.LIKE_COUNT_PER     = 1   --每个衷言点赞次数
tbAct.DAY_LIKE_COUNT_PER = 3   --每天给某个玩家总共点赞次数
tbAct.DAY_LIKE_COUNT     = 10 --每天点赞次数
tbAct.MODITY_COST        = 200 --修改衷言花费的元宝
tbAct.PLAYER_LEVEL       = 20  --玩家等級
tbAct.IMITYLEVEL         = 15 --点赞亲密度等级

tbAct.MAINUI_SINCEREWORDS_COUNT = 12  --主UI显示衷言数量
tbAct.SINCEREWORDS_COUNT = 3   --衷言数量


tbAct.nLikeItem = 10616 --点赞道具id
--活跃度对应的宝箱(这里应该配随机宝箱)
tbAct.tbEverydayTargetAward = {
	[1] = 10616,    --20活跃度
	[2] = 10616,	--40活跃度
	[3] = 10616,	--60活跃度
	[4] = 10616,	--80活跃度
	[5] = 10616,	--100活跃度
}
tbAct.nConsumeLikeItemNum = 1; --每次点赞消耗道具的数量
tbAct.LIKEITEM_AWARD_RATE = 0.95; --普通账号活跃度获得点赞道具共鸣的概率
tbAct.LIKEITEM_AWARD_RATE_SMALL = 0.05; --小号活跃度获得点赞道具共鸣的概率

function tbAct:CheckData(tbData)
	if tbData.nDataDay and tbData.nDataDay >= Lib:GetLocalDay() then
		return
	end
	tbData.nDataDay   = Lib:GetLocalDay()
	tbData.nLikeCount = 0
	tbData.tbLikeList = {}
	for i = 1, self.SINCEREWORDS_COUNT do
		if tbData.tbSincereWords and tbData.tbSincereWords[i] then
			tbData.tbSincereWords[i].nModifyTimes = 0
		end
	end
end

function tbAct:CheckCommit(tbData, tbSincereWords, nPlayer, nKinId)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	if tbSincereWords.nIdx <= 0 or tbSincereWords.nIdx > self.SINCEREWORDS_COUNT then
		return false, "每人只能寄三封衷言！"
	end
	if tbData.tbSincereWords and tbData.tbSincereWords[tbSincereWords.nIdx] then
		return false, "不可以重复写衷言"
	end
	local nProfessionPlayer = tbSincereWords.nProfessionPlayer
	if not nProfessionPlayer then
		return false, "请先选择写衷言对象！"
	end
	if nProfessionPlayer == nPlayer then
		return false, "不能给自己写衷言"
	end
	for i = 1, self.SINCEREWORDS_COUNT do
		if tbData.tbSincereWords and tbData.tbSincereWords[i] and tbData.tbSincereWords[i].nPlayer == nProfessionPlayer then
			return false, "不可以给同一个玩家写衷言"
		end
	end
	if MODULE_GAMESERVER then
		local tbRoleStayInfo = KPlayer.GetRoleStayInfo(nProfessionPlayer)
		if not tbRoleStayInfo then
			return false, "该玩家不存在"
		end
		if not FriendShip:IsFriend(nPlayer, nProfessionPlayer) and
			(nKinId == 0 or tbRoleStayInfo.dwKinId ~= nKinId) then
			return false, "该玩家与您关系太疏远了"
		end
	end
	for i = 1, self.SINCEREWORDS_COUNT do
		if Lib:IsEmptyStr(tbSincereWords.tbContent[i]) then
			return false, "衷言还未编辑完毕"
		end
		if ReplaceLimitWords(tbSincereWords.tbContent[i]) then
			return false, "衷言内容含有敏感字符"
		end
		local nContentLen = Lib:Utf8Len(tbSincereWords.tbContent[i])
		if nContentLen > self.SINCEREWORDS_CONTENT_MAX_LEN then
			return false, "衷言内容每行最多12个字"
		end
	end
	return true
end

function tbAct:CheckModify(tbData, tbSincereWords)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	tbData.tbSincereWords  = tbData.tbSincereWords or {}
	if not tbData.tbSincereWords[tbSincereWords.nIdx] then
		return false, "还没写衷言"
	end
	self:CheckData(tbData)
	if tbData.tbSincereWords[tbSincereWords.nIdx].nModifyTimes and tbData.tbSincereWords[tbSincereWords.nIdx].nModifyTimes >= self.MAX_MODIFY_TIMES then
		return false, "每封衷言每天只能修改两次"
	end
	local bHaveChange = false
	for i = 1, self.SINCEREWORDS_COUNT do
		if Lib:IsEmptyStr(tbSincereWords.tbContent[i]) then
			return false, "衷言还未编辑完毕"
		end
		if ReplaceLimitWords(tbSincereWords.tbContent[i]) then
			return false, "衷言内容含有敏感字符"
		end
		local nContentLen = Lib:Utf8Len(tbSincereWords.tbContent[i])
		if nContentLen > self.SINCEREWORDS_CONTENT_MAX_LEN then
			return false, "衷言内容每行最多12个字"
		end
		bHaveChange = bHaveChange or tbData.tbSincereWords[tbSincereWords.nIdx].tbContent[i] ~= tbSincereWords.tbContent[i]
	end
	if not bHaveChange then
		return false, "衷言尚未做出任何修改"
	end
	return true
end

function tbAct:CheckLike(tbData, pPlayer, nBelonger, nIdx)
	if GetTime() > self.nOperationEndTime then
		return false, "活动已结束"
	end
	local nLikePlayer = pPlayer.dwID;
	if nLikePlayer == nBelonger then
		return false, "不能给自己点赞"
	end
	if not nBelonger or nIdx <= 0 or nIdx > self.SINCEREWORDS_COUNT then
		return false, "数据异常，请重试"
	end

	local nHave = pPlayer.GetItemCountInAllPos(self.nLikeItem);
	if nHave < self.nConsumeLikeItemNum then
		return false, "共鸣不足，无法给该玩家点赞"
	end
	local bIsFriend = FriendShip:IsFriend(nLikePlayer, nBelonger)
	if bIsFriend == true then
		local nImityLevel = FriendShip:GetFriendImityLevel(nLikePlayer, nBelonger) or 0
		if nImityLevel < self.IMITYLEVEL then
			return false, string.format("只能给亲密度%d级以上的好友点赞", self.IMITYLEVEL)
		end
	else
		return false, "对方不是您的好友"
	end

	self:CheckData(tbData)
	tbData.nLikeCount = tbData.nLikeCount or 0
	if tbData.nLikeCount >= self.DAY_LIKE_COUNT then
		return false, "每人每天只能给别人点赞[FFFE0D]10次[-]"
	end
	tbData.tbLikeList = tbData.tbLikeList or {}
	tbData.tbLikeList[nBelonger] = tbData.tbLikeList[nBelonger] or {nCount = 0, tbIdxCount = {}}
	if tbData.tbLikeList[nBelonger].nCount >= self.DAY_LIKE_COUNT_PER then
		return false, "每天只能给同一个玩家点赞[FFFE0D]3次[-]"
	end
	tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] = tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] or 0
	if tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] >= self.LIKE_COUNT_PER then
		return false, "每天只能给同一封衷言点赞[FFFE0D]1次[-]"
	end
	return true
end
