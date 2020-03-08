if not MODULE_GAMESERVER then
    Activity.WomanAct = Activity.WomanAct or {}
    Activity.WomanAct.tbLabelInfo = Activity.WomanAct.tbLabelInfo or {}
    Activity.WomanAct.tbPlayerRequestCD = {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WomanAct") or Activity.WomanAct
tbAct.bTSMode = false 		-- 是否是师徒关系模式（否则是女神模式）
tbAct.szActDes = tbAct.bTSMode and "祝福" or "印象"
-- 赠送需达到的亲密度等级
tbAct.nImityLevel = 5
-- 付费标签价格
tbAct.nPayLabelCost = 199
-- 保存多少个付费的赠送来源
tbAct.nSavePayCount = 5
-- 参与等级
tbAct.nLevelLimit = 20

tbAct.FreeLabel = 1
tbAct.PayLabel = 2

-- 标签长度配置
tbAct.nLabelMin = 1;		-- 最小标签长度
tbAct.nLabelMax = 7;		-- 最大标签长度
tbAct.nVNLabelMin = 4;		-- 越南版最小标签长度
tbAct.nVNLabelMax = 14;		-- 越南版最大标签长度

if tbAct.bTSMode then
	tbAct.tbFree = {"名师风范", "美腻的师父", "严厉的师傅", "厉害的师父", "幽默的大大", "三人行必有我师", "一日为师终身父", "有师如此复何求", "师父今天去哪玩", "师父稀有武器呢"}
else
	tbAct.tbFree = {"可爱", "善良", "婀娜", "风雅", "率直", "活泼", "性感", "美丽", "妩媚", "温柔"}
end


-- 赠送之后可获得的礼盒个数
tbAct.nBoxLimit = 5
-- 礼盒刷新点
tbAct.nBoxRefreshTime = 4 * 60 * 60
-- 可用标签位置
tbAct.nMaxLabel = 15
-- 增加亲密度
tbAct.nAddImitity = 100

-- 赠送印象册邮件内容
tbAct.szMailTitle =  "留下你的印象";
tbAct.szMailText =  "    三月八日佳节将至，侠士经历了如此之久的江湖生活，想必已认识不少挚友，不知其中是否有印象深刻的侠士，尤其是女侠，若是有的话，就快打开印象册，为那些与你一同闯荡江湖的同行者写上你对他们的印象吧！";
tbAct.szMailFrom =  "";

-- 赠送印象标签之后发给对方的邮件内容%s （1：赠送方 2：标签）
tbAct.szAcceptMailTitle = "新的印象";
tbAct.szAcceptMailFrom = "系统";
tbAct.szAcceptMailText = "    侠士[FFFE0D]%s[-]对你留下了新的印象——[FFFE0D]%s[-]，赶快去[64db00] [url=openwnd:查看印象, FriendImpressionPanel] [-]吧！"


-- 赠送之后自身获得的奖励
tbAct.tbSendAward = 
{
	[tbAct.FreeLabel] = {{"item", 3932, 1}};
	[tbAct.PayLabel] = {{"item", 3932, 1}};
}

-- 赠送之后对方获得的奖励
tbAct.tbAcceptAward = 
{
	[tbAct.FreeLabel] = {{"item", 3932, 1}};
	[tbAct.PayLabel] = {{"item", 3932, 1}};
}

-- 女生标签到达几个可以获得奖励
tbAct.nGirlAwardLabelCount = 10
tbAct.tbGirlAward = {{"item", 10469, 1}}

-- 领取哪个活跃度可获得奖励
tbAct.tbActiveIndex = 
{
	[Gift.Sex.Boy] = {[2] = {{"item", 3910, 1}},[3] = {{"item", 3910, 1}},[4] = {{"item", 3910, 1}},[5] = {{"item", 3910, 1}}};
	[Gift.Sex.Girl] = {[2] = {{"item", 3909, 1}},[3] = {{"item", 3909, 1}},[4] = {{"item", 3909, 1}},[5] = {{"item", 3909, 1}}};
}

tbAct.tbFree2Label = tbAct.tbFree2Label or {}
if not next(tbAct.tbFree2Label) then
	for k,v in pairs(tbAct.tbFree) do
		tbAct.tbFree2Label[v] = k
	end
end

-- 印象签
tbAct.nImpressionLabelItemID = 3910
-- 免费标签需要消耗的道具数量
tbAct.nNeedConsumeImpressionLabel = 1
-- 可赠送的截止时间
tbAct.szSendLabelEndTime = "2019-3-11-3-59-59"
--[[
师徒关系模式:
	去掉旧活动领取活跃度奖励时给的奖励
	去掉升到一定等级邮件发送印象签的设定
	去掉最新消息

	印象签/印象册通过师徒种树活动获得
]]

function tbAct:InitData()
	local tbEndDateTime = Lib:SplitStr(self.szSendLabelEndTime, "-")
	local year, month, day, hour, minute, second = unpack(tbEndDateTime)
	local nEndTime = os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = tonumber(hour), min = tonumber(minute), sec = tonumber(second)})
	self.nSendLabelEndTime = nEndTime
end

tbAct:InitData()

function tbAct:IsEndSendLabel()
	if GetTime() >= self.nSendLabelEndTime then
		return true, string.format("活动已结束，无法添加%s", self.szActDes)
	end
	return false
end

-- bNotCheckGold 扣完元宝回调中不再检查元宝
function tbAct:CheckCommon(pPlayer, nAcceptId, nType, szLabel, bNotCheckGold)
	local bRet, szMsg = self:IsEndSendLabel()
	if bRet then
		return false, szMsg
	end

	if nType ~= self.FreeLabel and nType ~= self.PayLabel then
		return false, "未知类型"
	end

	if szLabel == "" then
		return false, "未知标签"
	end

	if pPlayer.nLevel < self.nLevelLimit then
		return false, string.format("参与等级不足%s", self.nLevelLimit)
	end

	if MODULE_GAMESERVER then
		if self.bTSMode and not TeacherStudent:IsMyTeacher(pPlayer, nAcceptId) then
			return false, string.format("只能为师父添加%s", self.szActDes)
		end
	end
	
	if not self.bTSMode and not FriendShip:IsFriend(pPlayer.dwID, nAcceptId) then
		return false, "对方不是你的好友";
	end

	local nImityLevel = FriendShip:GetFriendImityLevel(pPlayer.dwID, nAcceptId) or 0
	if nImityLevel < self.nImityLevel then
		return false, string.format("双方亲密度不足%s级", self.nImityLevel)
	end

	if nType == self.FreeLabel then
		if pPlayer.GetItemCountInAllPos(self.nImpressionLabelItemID) < self.nNeedConsumeImpressionLabel then
			return false, string.format("您拥有的%s不足", Item:GetItemTemplateShowInfo(self.nImpressionLabelItemID, pPlayer.nFaction, pPlayer.nSex) or "印象签")
		end
		if not self.tbFree2Label[szLabel] then
			return false, "未知的标签描述"
		end
	elseif nType == self.PayLabel then
		if not bNotCheckGold and pPlayer.GetMoney("Gold") < self.nPayLabelCost then
			return false, "元宝不足"
		end
		if version_vn then
			local nVNLen = string.len(szLabel);
			if nVNLen > self.nVNLabelMax or nVNLen < self.nVNLabelMin then
				return false, string.format("自定义标签需在%d~%d字之间", self.nVNLabelMin, self.nVNLabelMax);
			end
		else
			local nNameLen = Lib:Utf8Len(szLabel);
			if nNameLen > self.nLabelMax or nNameLen < self.nLabelMin then
				return false, string.format("自定义标签需在%d~%d字之间", self.nLabelMin, self.nLabelMax);
			end
		end
		if not CheckNameAvailable(szLabel) then
			return false, "含有非法字符，请修改后重试"
		end
	end

	return true
end

--------------------------- Client ------------------------------

function tbAct:OnSendLabelSuccess()
	UiNotify.OnNotify(UiNotify.emNOTIFY_WOMAN_SYNDATA)
end

function tbAct:OnAcceptLabelSuccess()
end

function tbAct:OnSynData(tbData, nStartTime, nEndTime)
	self.nStartTime = nStartTime
	self.nEndTime = nEndTime
	self:FormatData(tbData)
	UiNotify.OnNotify(UiNotify.emNOTIFY_WOMAN_SYNDATA)
end

function tbAct:FormatData(tbData)
	for dwID, tbInfo in pairs(tbData or {}) do
		self.tbLabelInfo[dwID] = self.tbLabelInfo[dwID] or {}
		self.tbLabelInfo[dwID].nPlayerId = dwID
		self.tbLabelInfo[dwID].tbFreeLabel = tbInfo.tbFreeLabel or self.tbLabelInfo[dwID].tbFreeLabel or {}
		self.tbLabelInfo[dwID].tbPayLabel = tbInfo.tbPayLabel or self.tbLabelInfo[dwID].tbPayLabel or {}
		self.tbLabelInfo[dwID].tbLabelTime = tbInfo.tbLabelTime or self.tbLabelInfo[dwID].tbLabelTime or {}
		self.tbLabelInfo[dwID].tbPayLabelPlayer = tbInfo.tbPayLabelPlayer or self.tbLabelInfo[dwID].tbPayLabelPlayer or {}
		self.tbLabelInfo[dwID].nHadLabelCount = tbInfo.nHadLabelCount or self.tbLabelInfo[dwID].nHadLabelCount or 0
	end
end

function tbAct:OnSynLabelPlayer(tbData)
	self.tbPriorData = tbData
	Ui:OpenWindow("FriendImpressionPanel")
end

function tbAct:GetLabelInfo()
	return self.tbLabelInfo
end

function tbAct:GetPriorData()
	return self.tbPriorData
end

function tbAct:ClearPriorData()
	self.tbPriorData = nil
end

function tbAct:OpenLabelWindow(nTargetId)
	if FriendShip:IsFriend(me.dwID, nTargetId) then
		Ui:OpenWindow("FriendImpressionPanel", nTargetId)
	else
		RemoteServer.TrySynLabelPlayer(nTargetId)
	end
end

function tbAct:GetTimeInfo()
	return self.nStartTime, self.nEndTime
end