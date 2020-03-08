Require("CommonScript/EnvDef.lua");
local tbRandomItem = Item:GetClass("RandomItem");

tbRandomItem.tbItemLogType =
{
	[968] = Env.LogWay_FindDungeonAward;
	[2178] = Env.LogWay_RankBattleAward_Rank;
	[2179] = Env.LogWay_RankBattleAward_Rank;
};

tbRandomItem.nExtParam_1 = 1
tbRandomItem.nExtParam_2 = 2
tbRandomItem.nExtParam_2_AutoUse = 1
tbRandomItem.nExtParam_2_NotShowTip = -1
-- 这里好像只用服务端加载就行了
function tbRandomItem:LoadItemList()
	local szType = "dssddssddddddddsssss";
	local tbTitle = {"ClassParamID", "Probability", "Name", "Item", "DebtReplaceItem", "OtherType", "SubType", "Amount","Add2Auction", "TimeLimit",
						"WorldMsg", "FriendMsg", "KinMsg", "TeamMsg", "ForbidStall", "CloseWorldMsg", "CloseFriendMsg", "CloseKinMsg", "CloseTeamMsg",
						"DateLimit"};
	local tbFile = LoadTabFile("Setting/Item/RandomItem.tab", szType, nil, tbTitle);
	if not tbFile then
		Log("[RandomItem] LoadItemList ERR !! Setting/Item/RandomItem.tab can not find !!");
		return;
	end

	local fnCheckFunc;
	if MODULE_GAMESERVER then
		fnCheckFunc = function (tbRow)
			return true
		end
	else
		fnCheckFunc = function (tbRow)
			return tbRow.Probability < 0
		end
	end
	self.tbItemList = {};
	local tbTotalPro = {};
	for _, tbRow in pairs(tbFile) do
		if tbRow.ClassParamID and tbRow.ClassParamID > 0 then
			tbRow.Probability = tonumber(tbRow.Probability);
			assert(tbRow.Probability, "[RandomItem] Probability is nil !! ClassParamID = " .. tbRow.ClassParamID);
			if fnCheckFunc(tbRow) then
				self.tbItemList[tbRow.ClassParamID] = self.tbItemList[tbRow.ClassParamID] or {tbFixedItem = {}, tbRandomItem = {}};
				local tbAward = {};
				tbAward.nProbability 	= tbRow.Probability;
				tbAward.szName 			= tbRow.Name;
				tbAward.nAmount 		= tbRow.Amount;
				tbAward.nTimeLimit 		= tbRow.TimeLimit;
				tbAward.nWorldMsg 		= tbRow.WorldMsg;
				tbAward.szCloseWorldMsg = tbRow.CloseWorldMsg;
				tbAward.nFriendMsg 		= tbRow.FriendMsg;
				tbAward.szCloseFriendMsg = tbRow.CloseFriendMsg;
				tbAward.nKinMsg 		= tbRow.KinMsg;
				tbAward.szCloseKinMsg	= tbRow.CloseKinMsg;
				tbAward.nTeamMsg		= tbRow.TeamMsg;
				tbAward.szCloseTeamMsg	= tbRow.CloseTeamMsg;
				tbAward.szOtherType		= tbRow.OtherType;
				tbAward.nAdd2Auction	= tbRow.Add2Auction;
				tbAward.nDebtReplaceItem = tbRow.DebtReplaceItem;
				tbAward.bForbidStall    = tbRow.ForbidStall > 0;
				if tbRow.DateLimit and tbRow.DateLimit ~= "" then
					tbAward.nDateLimit	= Lib:ParseDateTime(tbRow.DateLimit)
				end
				if tbRow.Item > 0 then
					tbAward.nItem = tbRow.Item;
					tbAward.nAmount = math.max(tbAward.nAmount, 1)
				else
					if tbRow.SubType and tbRow.SubType ~= "" then
						tbAward.SubType = tonumber(tbRow.SubType) or tbRow.SubType;
					end
				end

				if tbRow.Probability > 0 then
					tbTotalPro[tbRow.ClassParamID] = tbTotalPro[tbRow.ClassParamID] or 0;
					tbTotalPro[tbRow.ClassParamID] = tbTotalPro[tbRow.ClassParamID] + tbRow.Probability;
					assert(tbTotalPro[tbRow.ClassParamID] <= 1000000, "[RandomItem] TotalRate > 100W ClassParamID = " .. tbRow.ClassParamID);
					table.insert(self.tbItemList[tbRow.ClassParamID].tbRandomItem, tbAward);
				elseif tbRow.Probability < 0 then
					table.insert(self.tbItemList[tbRow.ClassParamID].tbFixedItem, tbAward);
				end
			end
		end
	end
end

tbRandomItem.tbAwardType =
{
}

function tbRandomItem:GetFirstItemParam(nClassParamID)
	if MODULE_GAMESERVER then
		return
	end
	local tbItemList = self:GetItemList()
	local tbItem = tbItemList[nClassParamID]
	if not tbItem then
		return
	end
	local tbAward = tbItem.tbFixedItem[1] or tbItem.tbRandomItem[1]
	if not tbAward then
		return
	end
	return tbAward.nItem
end

function tbRandomItem:AddOtherAward(szType, SubType, nCount, nItem)
	if szType == "EquipDebris" then
		if SubType == 0 or SubType == "" then
			SubType = nil;
		end
		return {szType, nItem, SubType}
	elseif szType == "LabaMatrial" or szType == "CookMaterial" then
		return {szType, nItem, nCount}
	else
		if SubType then
			return {szType, SubType, nCount}
		else
			return {szType, nCount}
		end
	end
end

function tbRandomItem:GetItemName(tbItem)
	if tbItem.nItem and tbItem.nItem > 0 then
		local tbBaseInfo = KItem.GetItemBaseProp(tbItem.nItem);
		if not tbBaseInfo then
			return tbItem.szName;
		end

		if tbItem.nAmount < 2 then
			return tbBaseInfo.szName;
		end

		return string.format("%s*%s", tbBaseInfo.szName, tbItem.nAmount);
	end

	local tbMoneyInfo = Shop.tbMoney[tbItem.szOtherType or "nil"];
	if tbMoneyInfo then
		return string.format("%s%s%s", tbMoneyInfo.Name, tbItem.nAmount, tbMoneyInfo.Unit or "");
	end

	return tbItem.szName;
end

function tbRandomItem:GetItemValue(nItemTemplateId)
	self.tbItemValueCache = self.tbItemValueCache or {};
	local nValue = self.tbItemValueCache[nItemTemplateId];
	if nValue then
		return nValue;
	end

	local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId);
	self.tbItemValueCache[nItemTemplateId] = tbBaseInfo and tbBaseInfo.nValue or -1;

	return self.tbItemValueCache[nItemTemplateId];
end

function tbRandomItem:AddAward(pPlayer, tbItem, szFromItemName, nLogReazon, nLogReazon2)
	if pPlayer and tbItem.nDebtReplaceItem > 0 and tbItem.nItem > 0 then
		local nValue = Player:GetRewardValueDebt(pPlayer.dwID);
		if nValue>0 and MathRandom(100)<50 then
			local nOrgValue = self:GetItemValue(tbItem.nItem);
			local nDstValue = self:GetItemValue(tbItem.nDebtReplaceItem);
			if nOrgValue > 0 and nDstValue >= 0 and nOrgValue > nDstValue then
				tbItem = Lib:CopyTB(tbItem);

				local nCostVale = math.floor((nOrgValue - nDstValue) * tbItem.nAmount / 1000);
				Log("[RandomItem] debt ", tbItem.nItem, tbItem.nDebtReplaceItem, nValue, math.min(nValue, nCostVale), nLogReazon, nLogReazon2);

				tbItem.nKinMsg = 0;
				tbItem.nTeamMsg = 0;
				tbItem.nWorldMsg = 0;
				tbItem.nItem = tbItem.nDebtReplaceItem;
				Player:CostRewardValueDebt(pPlayer.dwID, nCostVale, nLogReazon, nLogReazon2);
			end
		end
	end

	local tbGetAward;
	local bAdd2Auction
	local szItemName = self:GetItemName(tbItem);
	local nItemId = nil;
	if (tbItem.nItem or -1) <= 0 and
		not self.tbAwardType[tbItem.szOtherType or "nil"] and
		not Shop.tbMoney[tbItem.szOtherType or "nil"] and
		not Player.AwardType[tbItem.szOtherType or "nil"] then
		if pPlayer then
			Log("[RandomItem] AddAward ERR ?? tbItem is error !!", pPlayer.szName, pPlayer.dwID, szFromItemName);
			Lib:LogTB(tbItem);
		end
		return;
	end

	if tbItem.nItem and tbItem.nItem > 0 and tbItem.szOtherType == "" then
		local szTimeOut;	--这里用字符串格式的时间而不用时间戳，是方便服务器日志直接看到物品的有效期
		if tbItem.nTimeLimit and tbItem.nTimeLimit > 0 then
			szTimeOut = os.date("%Y-%m-%d %H:%M:%S", GetTime() + tbItem.nTimeLimit)
		end
		if tbItem.nDateLimit and tbItem.nDateLimit > 0 then				--TimeLimit和DataLimit同时配置时，取两者之间的最小值作为过期时间
			if not szTimeOut or Lib:ParseDateTime(szTimeOut) > tbItem.nDateLimit then
				szTimeOut = os.date("%Y-%m-%d %H:%M:%S", tbItem.nDateLimit)
			end
		end
		if tbItem.nAdd2Auction == 1 then
			bAdd2Auction = true
		end
		tbGetAward = {"item", tbItem.nItem, tbItem.nAmount, szTimeOut, tbItem.bForbidStall}
		nItemId = tbItem.nItem;
	else
		tbGetAward = self:AddOtherAward(tbItem.szOtherType, tbItem.SubType, tbItem.nAmount, tbItem.nItem);
		if not tbGetAward  then
			Log("[RandomItem] AddOtherAward ERR ?? bRet is false !!",  (pPlayer and pPlayer.dwID or "") , szFromItemName, tbItem.szOtherType, tbItem.SubType or "nil", tbItem.nAmount);
			return;
		end
	end

	if pPlayer then

		if nItemId then
			szItemName = string.format("<%s>", szItemName);
		end

		if tbItem.nWorldMsg > 0 and (Lib:IsEmptyStr(tbItem.szCloseWorldMsg) or TimeFrame:GetTimeFrameState(tbItem.szCloseWorldMsg) ~= 1) then
			local szMsg = MsgInfoCtrl:GetMsg(tbItem.nWorldMsg, pPlayer.szName, szFromItemName or "", szItemName);
			if nItemId then
				KPlayer.SendWorldNotify(0, 999, szMsg, 0, 1);
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.System, szMsg, nil, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId, nFaction = pPlayer.nFaction, nSex = pPlayer.nSex});
			else
				KPlayer.SendWorldNotify(0, 999, szMsg, 1, 1);
			end
		end

		if tbItem.nKinMsg > 0 and pPlayer.dwKinId > 0 and (Lib:IsEmptyStr(tbItem.szCloseKinMsg) or TimeFrame:GetTimeFrameState(tbItem.szCloseKinMsg) ~= 1) then
			local szMsg = MsgInfoCtrl:GetMsg(tbItem.nKinMsg, pPlayer.szName, szFromItemName or "", szItemName);
			if nItemId then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId, nFaction = pPlayer.nFaction, nSex = pPlayer.nSex});
			else
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, szMsg, pPlayer.dwKinId);
			end
		end

		if tbItem.nTeamMsg and tbItem.nTeamMsg > 0 and pPlayer.dwTeamID > 0 and (Lib:IsEmptyStr(tbItem.szCloseTeamMsg) or TimeFrame:GetTimeFrameState(tbItem.szCloseTeamMsg) ~= 1) then
			local szMsg = MsgInfoCtrl:GetMsg(tbItem.nTeamMsg, pPlayer.szName, szFromItemName or "", szItemName);
			if nItemId then
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID, {nLinkType = ChatMgr.LinkType.Item, nTemplateId = nItemId, nFaction = pPlayer.nFaction, nSex = pPlayer.nSex})
			else
				ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Team, szMsg, pPlayer.dwTeamID)
			end
		end
	end

	bAdd2Auction = false; -- 关闭个人拍卖产出！！

	return tbGetAward,bAdd2Auction;
end

function tbRandomItem:OnUse(it)
	local bShowTip = true
	local nKind = tonumber(it.nRandomItemKindId or KItem.GetItemExtParam(it.dwTemplateId, self.nExtParam_1));
	local nShowTip = tonumber(it.nRandomItemKindId or KItem.GetItemExtParam(it.dwTemplateId, self.nExtParam_2));
	if nShowTip == self.nExtParam_2_NotShowTip then
		bShowTip = false
	end
	local nRet, szMsg, tbAllAward = self:GetRandItemAward(me, nKind,  it.szName, bShowTip, it.dwTemplateId)
	if szMsg then
		me.CenterMsg(szMsg)
	end
	Activity:OnPlayerEvent(me, "Act_OnRandomItemUse", it.dwTemplateId);
	Log("[Item] RandomItem OnUse", it.dwTemplateId, it.szName, me.szName, me.szAccount, me.dwID);
	return nRet, tbAllAward;
end

if MODULE_GAMESERVER then
	function tbRandomItem:GetItemList()
		return self.tbItemList
	end
else
	function tbRandomItem:GetItemList()
		if not self.tbItemList then
			self:LoadItemList()
		end
		return self.tbItemList
	end
end


function tbRandomItem:RandomItemAward(pPlayer, nKind, szFromItemName, nLogReazon, nLogReazon2)
	local tbItemList = self:GetItemList()
    if not tbItemList[nKind] then
		return 0, "箱子无法打开!";
	end

	local nMaxProbability = 1000000;
	local nRate = MathRandom(1, nMaxProbability);

	-- 添加道具
	local tbGetAllAward = {}
	local tbAdd2AuctionIndex = {} 				 -- 把随到的所有需要拍卖的奖励索引放到这里

	for _, tbItem in ipairs(tbItemList[nKind].tbFixedItem) do
		local tbAward,bAdd2Auction = self:AddAward(pPlayer, tbItem, szFromItemName, nLogReazon, nLogReazon2)
		if tbAward then
			table.insert(tbGetAllAward, tbAward)
			if bAdd2Auction then
				table.insert(tbAdd2AuctionIndex,#tbGetAllAward)
			end
		elseif pPlayer then
			Log(string.format(XT("%s随机获得物品失败 箱子：%s，物品：%s"), pPlayer.szName, szFromItemName, tbItem.szName));
		end
	end

	local nRateSum = 0;
	for i, tbItem in ipairs(tbItemList[nKind].tbRandomItem) do
		nRateSum = nRateSum + tbItem.nProbability;
		if nRate <= nRateSum then
			local tbAward,bAdd2Auction = self:AddAward(pPlayer, tbItem, szFromItemName, nLogReazon, nLogReazon2)
			if tbAward then
				table.insert(tbGetAllAward, tbAward)
				if bAdd2Auction then 				-- 保证需要拍卖的道具的索引在tbAdd2AuctionIndex中从小到大
					table.insert(tbAdd2AuctionIndex,#tbGetAllAward)
				end
			elseif pPlayer then
				Log(string.format(XT("%s随机获得物品失败 箱子：%s，物品：%s"), pPlayer.szName, szFromItemName, tbItem.szName));
			end
			break;
		end
	end

	return 1, nil, tbGetAllAward,tbAdd2AuctionIndex;
end

--数据检查用
function tbRandomItem:GetAllAward( nKind )
	local tbItemList = self:GetItemList()
	if not tbItemList[nKind] then
		return
	end

	local tbAllAward = {};
	for _, tbItem in ipairs(tbItemList[nKind].tbFixedItem) do
		table.insert(tbAllAward, tbItem)
	end
	for i, tbItem in ipairs(tbItemList[nKind].tbRandomItem) do
		table.insert(tbAllAward, tbItem)
	end
	return tbAllAward
end

function tbRandomItem:GetFixRandItemAward(nKind)
	local tbItemList = self:GetItemList()
	if not tbItemList[nKind] then
		return 0, "箱子无法打开!!";
	end
	local tbGetAllAward = {}
	for _, tbItem in ipairs(tbItemList[nKind].tbFixedItem) do
		local tbAward,bAdd2Auction = self:AddAward(nil, tbItem, "")
		if tbAward then
			table.insert(tbGetAllAward, tbAward)
		end
	end
	return 1, tbGetAllAward
end

--nOrgTemplateId 有可能不存在
function tbRandomItem:GetRandItemAward(pPlayer, nKind, szFromItemName, bShowUi, nOrgTemplateId)
	local bRet, szMsg = pPlayer.CheckNeedArrangeBag();
	if bRet then
		return 0, szMsg;
	end

	local tbItemList = self:GetItemList()
	if not tbItemList[nKind] then
		return 0, "箱子无法打开!!!";
	end

	local nRet, szMsg, tbGetAllAward,tbAdd2AuctionIndex = self:RandomItemAward(pPlayer, nKind, szFromItemName);
	if nRet == 0 then
		return 0, szMsg;
	end

	local LogWayType = Env.LogWay_RandomItem;
	if nOrgTemplateId then
		LogWayType = self.tbItemLogType[nOrgTemplateId];
	end

	if pPlayer.ItemLogWay then
		LogWayType = pPlayer.ItemLogWay;
		pPlayer.ItemLogWay = nil;
	end

	if not LogWayType then
		LogWayType = Env.LogWay_RandomItem;
	end

	local tbAuctionAward = {}

	if tbAdd2AuctionIndex and next(tbAdd2AuctionIndex) then
		tbGetAllAward,tbAuctionAward = Kin:FormatAuctionItem(tbGetAllAward,tbAdd2AuctionIndex,tbAuctionAward)
		if tbAuctionAward and next(tbAuctionAward) then
			Kin:AddPersonAuction(pPlayer.dwID, tbAuctionAward)
		end
	end

	local tbAllAward = KPlayer:FormatAward(pPlayer, tbGetAllAward, szFromItemName);
	tbAllAward = KPlayer:MgrAward(pPlayer, tbAllAward);

	Lib:CallBack({KPlayer.SendAwardUnsafe, KPlayer, pPlayer.dwID, tbAllAward, not bShowUi, (bShowUi == nil or bShowUi) and true or false, LogWayType, nKind});
	return 1, szMsg, tbGetAllAward;
end
