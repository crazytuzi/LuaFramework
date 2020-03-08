if not MODULE_GAMESERVER then
    Activity.YinXingJiQingAct = Activity.YinXingJiQingAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("YinXingJiQingAct") or Activity.YinXingJiQingAct
--YXJQ:银杏寄情
--QS:情书
tbAct.QS_CONTENT_MAX_LEN = 12  --情书内容字数
tbAct.MAX_MODIFY         = 2   --每封情书修改次数
tbAct.LIKE_COUNT_PER     = 1   --每封情书点赞次数
tbAct.DAY_LIKE_COUNT_PER = 3   --每天给某个玩家总共点赞次数
tbAct.DAY_LIKE_COUNT     = 10 --每天点赞次数
tbAct.MODITY_COST        = 200 --修改情书花费的元宝
tbAct.PLAYER_LEVEL       = 20  --玩家等級
tbAct.IMITYLEVEL         = 15 --点赞亲密度等级

tbAct.MAINUI_QS_COUNT    = 12  --主UI情书数量
tbAct.QS_COUNT           = 3   --情书数量

function tbAct:CheckData(tbData)
	if tbData.nDataDay and tbData.nDataDay >= Lib:GetLocalDay() then
		return
	end
	tbData.nDataDay   = Lib:GetLocalDay()
	tbData.nLikeCount = 0
	tbData.tbLikeList = {}
	for i = 1, self.QS_COUNT do
		if tbData.tbQS and tbData.tbQS[i] then
			tbData.tbQS[i].nModifyTimes = 0
		end
	end
end

function tbAct:CheckCommit(tbData, tbQS, nPlayer, nKinId)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	if tbQS.nIdx <= 0 or tbQS.nIdx > self.QS_COUNT then
		return false, "每人只能寄三封情书！"
	end
	if tbData.tbQS and tbData.tbQS[tbQS.nIdx] then
		return false, "不可以重复寄情"
	end
	local nProfessionPlayer = tbQS.nProfessionPlayer
	if not nProfessionPlayer then
		return false, "请先选择寄情对象！"
	end
	if nProfessionPlayer == nPlayer then
		return false, "不能选自己寄情对象"
	end
	for i = 1, self.QS_COUNT do
		if tbData.tbQS and tbData.tbQS[i] and tbData.tbQS[i].nPlayer == nProfessionPlayer then
			return false, "不可以寄情同一个玩家"
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
	for i = 1, self.QS_COUNT do
		if Lib:IsEmptyStr(tbQS.tbContent[i]) then
			return false, "情书还未编辑完毕"
		end
		if ReplaceLimitWords(tbQS.tbContent[i]) then
			return false, "情书内容含有敏感字符"
		end
		local nContentLen = Lib:Utf8Len(tbQS.tbContent[i])
		if nContentLen > self.QS_CONTENT_MAX_LEN then
			return false, "情书内容每行最多12个字"
		end
	end
	return true
end

function tbAct:CheckModify(tbData, tbQS)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	tbData.tbQS  = tbData.tbQS or {}
	if not tbData.tbQS[tbQS.nIdx] then
		return false, "还没写情书"
	end
	self:CheckData(tbData)
	if tbData.tbQS[tbQS.nIdx].nModifyTimes and tbData.tbQS[tbQS.nIdx].nModifyTimes >= self.MAX_MODIFY then
		return false, "每封情书每天只能修改两次"
	end
	local bHaveChange = false
	for i = 1, self.QS_COUNT do
		if Lib:IsEmptyStr(tbQS.tbContent[i]) then
			return false, "情书还未编辑完毕"
		end
		if ReplaceLimitWords(tbQS.tbContent[i]) then
			return false, "情书内容含有敏感字符"
		end
		local nContentLen = Lib:Utf8Len(tbQS.tbContent[i])
		if nContentLen > self.QS_CONTENT_MAX_LEN then
			return false, "情书内容每行最多12个字"
		end
		bHaveChange = bHaveChange or tbData.tbQS[tbQS.nIdx].tbContent[i] ~= tbQS.tbContent[i]
	end
	if not bHaveChange then
		return false, "情书尚未做出任何修改"
	end
	return true
end

function tbAct:CheckLike(tbData, nLikePlayer, nBelonger, nIdx)
	if MODULE_GAMESERVER then
		if GetTime() > self.nOperationEndTime then
			return false, "活动已结束"
		end
	end
	if nLikePlayer == nBelonger then
		return false, "不能给自己点赞"
	end
	if not nBelonger or nIdx <= 0 or nIdx > self.QS_COUNT then
		return false, "数据异常，请重试"
	end
	local nImityLevel = FriendShip:GetFriendImityLevel(nLikePlayer, nBelonger) or 0
	if nImityLevel < self.IMITYLEVEL then
		return false, string.format("只能给亲密度%d级以上的好友点赞", self.IMITYLEVEL)
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
		return false, "每天只能给同一封情书点赞[FFFE0D]1次[-]"
	end
	return true
end

if MODULE_GAMESERVER then return end

function tbAct:OnSyncMyData(tbData)
	self.tbMyData       = tbData or {}
	self.tbPlayerQS     = {}
	self.tbFriendQSList = {}
	self.nRequestTime   = 0
end

tbAct.tbPlayerQS = tbAct.tbPlayerQS or {}
tbAct.tbReadCd = tbAct.tbReadCd or {}
function tbAct:OnReadRsp(nPlayer, tbData, nIdx)
	if not tbData then
		me.CenterMsg("没找到该玩家的情书")
		return
	end
	if not self.tbPlayerQS[nPlayer] then
		self.tbPlayerQS[nPlayer] = tbData
	else
		self.tbPlayerQS[nPlayer].szName = tbData.szName
		self.tbPlayerQS[nPlayer].tbQS = self.tbPlayerQS[nPlayer].tbQS or {}
		for i = 1, self.QS_COUNT do
			self.tbPlayerQS[nPlayer].tbQS[i] = tbData.tbQS[i] or self.tbPlayerQS[nPlayer].tbQS[i]
		end
	end
	Ui:OpenWindow("YXJQ_PlayerQS", nPlayer, nIdx)
end

function tbAct:OpenQS(nPlayer, nIdx)
	if nPlayer == me.dwID then
		Ui:OpenWindow("YXJQ_PlayerQS", nPlayer, nIdx)
		return
	end

	local tbVersion = nil
	if self.tbPlayerQS[nPlayer] then
		self.tbReadCd[nPlayer] = self.tbReadCd[nPlayer] or 0
		if GetTime() - self.tbReadCd[nPlayer] < 5 then
			Ui:OpenWindow("YXJQ_PlayerQS", nPlayer, nIdx)
			return
		end
		self.tbReadCd[nPlayer] = GetTime()
		tbVersion  = {}
		local tbQS = (self.tbPlayerQS[nPlayer] or {}).tbQS or {}
		for i = 1, self.QS_COUNT do
			tbVersion[i] = tbQS[i] and tbQS[i].nVersion or nil
		end
	end
	RemoteServer.YinXingJiQingClientCall("Read", nPlayer, tbVersion, nIdx or 1)
end

function tbAct:GetPlayerData(nPlayer)
	if nPlayer == me.dwID then
		self.tbMyData = self.tbMyData or {}
		self.tbMyData.tbQS = self.tbMyData.tbQS or {}
		return self.tbMyData
	else
		return self.tbPlayerQS[nPlayer]
	end
end

function tbAct:GetFriendQSList()
	self.tbFriendQSList = self.tbFriendQSList or {}
	local nCD = #self.tbFriendQSList < self.MAINUI_QS_COUNT and 60*3 or 60*60*2
	if not self.nRequestTime or (GetTime() - self.nRequestTime) >= nCD then
		self.nRequestTime = GetTime()
		RemoteServer.YinXingJiQingClientCall("ReqQSList")
	end
	return self.tbFriendQSList
end

function tbAct:Commit(tbQSData, bConfirm)
	local tbData      = self:GetPlayerData(me.dwID)
	local bExist      = tbData.tbQS[tbQSData.nIdx]
	local szCheckFunc = bExist and "CheckModify" or "CheckCommit"
	local szType      = bExist and "Modify" or "Commit"
	local bRet, szMsg = self[szCheckFunc](self, tbData, tbQSData, me.dwID, me.dwKinId)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	if not bConfirm then
		local szMsg = szType == "Commit" and
			string.format("每封情书首次提交免费，后续修改提交需要消耗%d元宝，确认提交吗？", self.MODITY_COST)
			or string.format("修改提交需要消耗[FFFE0D]%d元宝[-]，确认提交吗？关闭情书界面可放弃修改", self.MODITY_COST)
		me.MsgBox(szMsg,
			{{"确认", Activity.YinXingJiQingAct.Commit, Activity.YinXingJiQingAct, tbQSData, true}, {"取消"}})
		return
	end
	if szType == "Modify" and me.GetMoney("Gold") < self.MODITY_COST then
		me.CenterMsg("元宝不足！请先去充值")
		Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
		return
	end
	RemoteServer.YinXingJiQingClientCall(szType, tbQSData)
end

function tbAct:OnCommitCallBack(nIdx, tbQS)
	local tbData = self:GetPlayerData(me.dwID)
	local szMsg  = tbData.tbQS[nIdx] and "修改成功" or "提交成功"
	tbData.tbQS[nIdx] = tbQS
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_YXJQ_DATA)
	me.CenterMsg(szMsg)
end

function tbAct:Like(nPlayerId, nQSIdx)
	local tbData = self:GetPlayerData(me.dwID)
	local bRet, szMsg = self:CheckLike(tbData, me.dwID, nPlayerId, nQSIdx)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.YinXingJiQingClientCall("Like", nPlayerId, nQSIdx)
end

function tbAct:OnLikeCallBack(nBelonger, nIdx)
	local tbData = self:GetPlayerData(me.dwID)
	tbData.nLikeCount = (tbData.nLikeCount or 0) + 1
	tbData.tbLikeList = tbData.tbLikeList or {}
	tbData.tbLikeList[nBelonger] = tbData.tbLikeList[nBelonger] or {nCount = 0, tbIdxCount = {}}
	tbData.tbLikeList[nBelonger].nCount = tbData.tbLikeList[nBelonger].nCount + 1
	tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] = (tbData.tbLikeList[nBelonger].tbIdxCount[nIdx] or 0) + 1

	local tbBelong = self:GetPlayerData(nBelonger)
	if tbBelong and tbBelong.tbQS and tbBelong.tbQS[nIdx] then
		tbBelong.tbQS[nIdx].nLikeCount = (tbBelong.tbQS[nIdx].nLikeCount or 0) + 1
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_YXJQ_DATA)
	me.CenterMsg("点赞成功")
end

function tbAct:OnBeLikeCallBack(nIdx, nLikeCount)
	if not self.tbMyData or not self.tbMyData.tbQS or not self.tbMyData.tbQS[nIdx] then
		return
	end
	self.tbMyData.tbQS[nIdx].nLikeCount = nLikeCount
end

function tbAct:OnSyncQSList(tbQSList)
	self.tbFriendQSList = tbQSList or {}
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_YXJQ_DATA, 1)
end