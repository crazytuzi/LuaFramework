
MarketStall.nOpenLevel = 39					-- 摆摊功能开启等级
MarketStall.nManualRefreshCost = 20;		-- 手动刷新价格（元宝）
MarketStall.nManualRefreshVipMin = 9;		-- 手动刷新最低vip等级
MarketStall.nTimeout = 24 * 3600;			-- 摆摊时间
MarketStall.nPriceChangePrecent = 50;		-- 价格允许每次调整的百分比
MarketStall.nShowCountOneType = 200;			-- 每个类别显示的数量

MarketStall.nUpdateStallItemListTime = 30 * 60; -- 更新物品列表CD
MarketStall.nMyStoreMaxItems = 20;			-- 我的摊位最多上架物品个数

MarketStall.nMaxRandomRefreshTime = 60 * 60 * 2 -- 上架全服摊位，最大随机时间==>2个小时间隔
MarketStall.nJoinGlobalStallSpace = 20 * 60	-- 从0点开始，每隔多久上架一次全服摊位，这个随便多久没都没关系
MarketStall.nStartServerJoinGlobalStallTime = 5 * 3600;	--重启服务器后，多久前上架的物品会自动上架

MarketStall.tbForbiddenTime = {2, 10}		-- 每天 2点到 10点期间上架的物品不会上架全服摊位

MarketStall.nMaxTimeFramCount = 20;			-- 当前支持多少个时间轴配置
MarketStall.nMaxPriceLimitTimeFrameCount = 20; -- 当前支持多少个价格上下限时间轴配置
MarketStall.bOpenMaxPriceLimitDynamic = false;  --摆摊基准价最高倍数随时间轴变动，开关

MarketStall.nAvaragePriceCount = 10;		-- 推荐价格是最近几次的价格平均值

MarketStall.nSellLimitTime = 1*3600;	-- 卖出CD

MarketStall.nSellLimitDataVersion = 1;		-- 卖出CD功能版本号，不要动

MarketStall.nMaxAttentionCount = 20;		-- 最大同时关注物品数量


MarketStall.bSellLimitOpen = false;			-- 卖出CD功能开关


MarketStall.szCreateRoleTimeLimitTimeFrame = "OpenDay3C";  -- 开了这个时间轴后，摆摊功能会要求创建角色时间达到 MarketStall.nCreateRoleTimeLimit 的角色才允许摆摊
MarketStall.nCreateRoleTimeLimit = 1 * 3600;	-- 创建角色多久后才允许摆摊交易


MarketStall.tbForbiddenTime[1] = MarketStall.tbForbiddenTime[1] * 3600; -- 这里别改
MarketStall.tbForbiddenTime[2] = MarketStall.tbForbiddenTime[2] * 3600;


MarketStall.nMyFavTypeId = 888888	--我的关注

-- 允许的上架数量
MarketStall.tbAllowCount = {
	[1] = true,
	[5] = true,
	[10] = true,
	[50] = true,
	[100] = true,
};

MarketStall.tbItemStates = {
	TimeOut = 2,
	Normal = 3,
}

--每月非法交易警告
MarketStall.tbWarningSettings = {
	nMailMonthDay = 1,	--每月第几天发邮件
	nMailLevelMin = 24,	--邮件最小等级
}

MarketStall.emEvent_OnItemSelled = 1;
MarketStall.emEvent_OnItemTimeout = 2;
MarketStall.emEvent_OnNewSellItem = 3;
MarketStall.emEvent_OnUpdateMyItemPrice = 4;
MarketStall.emEvent_OnCancelSellItem = 5;
MarketStall.emEvent_OnGetCacheMoney = 6;
MarketStall.emEvent_OnGetMySellItemInfo = 7;
MarketStall.emEvent_OnGetItemList = 8;
MarketStall.emEvent_OnUpdateAllStall = 9;
MarketStall.emEvent_OnBuyItem = 10;
MarketStall.emEvent_OnGetAvaragePrice = 11;
MarketStall.emEvent_OnHasLowerPrice = 12;
MarketStall.emEvent_OnSyncAttentionList = 13;	-- 同步关注列表信息
MarketStall.emEvent_OnSyncAttentionListItem = 14;	-- 同步关注列表的物品
MarketStall.emEvent_OnAttentionChange = 15;	--关注列表变动

function MarketStall:Load()
	local szType = "sddddddddssdddds";
	local tbParam = {"szMainType", "nSubType", "nSellLimitType", "nSellLimitSubType", "nSellLimitLevel", 
		"nType", "nIndex", "nMinPrecent", "nMaxPrecent", "szOpenTimeFrame", "szCloseTimeFrame", "nPrice", 
		"nShowLimitPrecent", "nCantSellAgain", "nSubTypeSold", "szTimeOutFunc"};
	for i = 1, self.nMaxTimeFramCount do
		szType = szType .. "sd";
		table.insert(tbParam, "szTimeFrame" .. i);
		table.insert(tbParam, "nPrice" .. i);
	end

	for i = 1, self.nMaxPriceLimitTimeFrameCount do
		szType = szType .. "ss";
		table.insert(tbParam, "szPriceLimitTimeFrame" .. i);
		table.insert(tbParam, "szLimitPrice" .. i);
	end

	local tbAllStallInfo = LoadTabFile("Setting/MarketStall/MarketStallItem.tab", szType, nil, tbParam);
	self.tbAllType = LoadTabFile("Setting/MarketStall/MarketTypeDef.tab", "ddsdd", "nTypeId", {"nTypeId", "nShowCount", "szTypeName", "nIndex", "nSort"});

	self.tbSellLimitInfo = {};
	self.tbAllStallInfo = {};
	for _, tbInfo in pairs(tbAllStallInfo) do
		local nType = tbInfo.nType
		assert(self.tbAllType[nType], string.format("Setting/MarketStall/MarketStallItem.tab type error !!! nType = %d", nType));

		self.tbSellLimitInfo[tbInfo.szMainType] = self.tbSellLimitInfo[tbInfo.szMainType] or {};
		self.tbSellLimitInfo[tbInfo.szMainType][tbInfo.nSubType] = {nType = tbInfo.nSellLimitType, nSubType = tbInfo.nSellLimitSubType, nLevel = tbInfo.nSellLimitLevel};
		tbInfo.nSellLimitType = nil
		tbInfo.nSellLimitSubType = nil
		tbInfo.nSellLimitLevel = nil

		tbInfo.nDefaultPrice = tbInfo.nPrice;
		tbInfo.tbPriceInfo = {};
		for i = 1, self.nMaxTimeFramCount do
			local szTimeFrame = tbInfo["szTimeFrame" .. i];
			local nPrice = tbInfo["nPrice" .. i];
			if szTimeFrame and szTimeFrame ~= "" then
				assert(nPrice > 0, string.format("Setting/MarketStall/MarketStallItem.tab price error !!! nPrice = %d", nPrice));

				table.insert(tbInfo.tbPriceInfo, {szTimeFrame = szTimeFrame, nPrice = nPrice});
			end
			tbInfo["szTimeFrame" .. i] = nil
			tbInfo["nPrice" .. i] = nil
		end

		tbInfo.tbPriceLimit = {};
		for i = 1, self.nMaxPriceLimitTimeFrameCount do
			local szTimeFrame = tbInfo["szPriceLimitTimeFrame" .. i];
			local szLimit = tbInfo["szLimitPrice" .. i];
			if szTimeFrame and szTimeFrame ~= "" and szLimit and szLimit ~= "" then
				local nMin, nMax = string.match(szLimit, "^(%d+)|(%d+)$");
				nMin = tonumber(nMin);
				nMax = tonumber(nMax);
				assert(nMin and nMax, "Setting/MarketStall/MarketStallItem.tab szLimitPrice error !!!");

				table.insert(tbInfo.tbPriceLimit, {szTimeFrame = szTimeFrame, nMin = nMin, nMax = nMax});
			end
			tbInfo["szPriceLimitTimeFrame" .. i] = nil
			tbInfo["szLimitPrice" .. i] = nil
		end

		if tbInfo.nShowLimitPrecent < 100 then
			tbInfo.nShowLimitPrecent = 120;
		end
		tbInfo.nMinPrecent = 100
		tbInfo.nMaxPrecent = tbInfo.nMaxPrecent * 10
		tbInfo.nShowLimitPrecent = tbInfo.nShowLimitPrecent / 100;

		--self:UpdatePrice(tbInfo);
		self.tbAllStallInfo[tbInfo.szMainType] = self.tbAllStallInfo[tbInfo.szMainType] or {};
		assert(not self.tbAllStallInfo[tbInfo.szMainType][tbInfo.nSubType], "Setting/MarketStall/MarketStallItem.tab item repeat !!! ", tbInfo.szMainType, tbInfo.nSubType);

		self.tbAllStallInfo[tbInfo.szMainType][tbInfo.nSubType] = Lib:CopyTB(tbInfo);
	end
end

function MarketStall:GetVipShowCount(nCurCount, nVipLevel)
	if nVipLevel >= 17 then
		return nCurCount * 2;
	elseif nVipLevel >= 10 then
		return nCurCount * 1.5;
	else
		return nCurCount;
	end
end

function MarketStall:GetShowCount(nType)
	local tbTypeInfo = self.tbAllType[nType];
	if not tbTypeInfo or not tbTypeInfo.nShowCount or tbTypeInfo.nShowCount < 1 then
		return self.nShowCountOneType;
	end

	return tbTypeInfo.nShowCount;
end

function MarketStall:UpdatePrice(tbInfo)
	if MODULE_GAMECLIENT then
		tbInfo.dwClientPlayerId = me.dwID;
	end

	tbInfo.nPrice = tbInfo.nDefaultPrice;
	for _, tbPriceInfo in ipairs(tbInfo.tbPriceInfo) do
		local nPrice = tbPriceInfo.nPrice;
		local szTimeFrame = tbPriceInfo.szTimeFrame;
		if GetTimeFrameState(szTimeFrame) == 1 then
			tbInfo.nPrice = nPrice;
		else
			tbInfo.szNextTimeFrame = szTimeFrame;
			break;
		end
	end

	local nMaxPrecent, nMinPrecent = tbInfo.nMaxPrecent, tbInfo.nMinPrecent;
	for _, tbLimit in ipairs(tbInfo.tbPriceLimit) do
		local szTimeFrame = tbLimit.szTimeFrame;
		if GetTimeFrameState(szTimeFrame) == 1 then
			nMaxPrecent, nMinPrecent = tbLimit.nMax, tbLimit.nMin;
		else
			tbInfo.szNextPriceLimitTimeFrame = szTimeFrame;
			break;
		end
	end

	if not self.bOpenMaxPriceLimitDynamic then
		nMaxPrecent, nMinPrecent = tbInfo.nMaxPrecent, tbInfo.nMinPrecent;
	end

	tbInfo.tbAllowPrice = {};
	for nCurPrecent = math.max(100, nMaxPrecent), nMinPrecent, -self.nPriceChangePrecent do
		if nCurPrecent <= nMaxPrecent and nCurPrecent >= nMinPrecent then
			local nCurPrice = math.floor(tbInfo.nPrice * nCurPrecent / 100);
			tbInfo.tbAllowPrice[nCurPrice] = 1;
		end
	end
end

MarketStall:Load();

function MarketStall:GetPriceInfo(szMainType, nSubType)
	local tbInfo = (self.tbAllStallInfo[szMainType] or {})[nSubType or 0];
	if not tbInfo then
		return;
	end

	if MODULE_GAMECLIENT and me.dwID ~= tbInfo.dwClientPlayerId then
		self:UpdatePrice(tbInfo);
	end

	if tbInfo.szOpenTimeFrame and tbInfo.szOpenTimeFrame ~= "" and GetTimeFrameState(tbInfo.szOpenTimeFrame) ~= 1 then
		return;
	end

	if tbInfo.szCloseTimeFrame and tbInfo.szCloseTimeFrame ~= "" and GetTimeFrameState(tbInfo.szCloseTimeFrame) == 1 then
		return;
	end

	if not tbInfo.tbAllowPrice or
		(tbInfo.szNextTimeFrame and GetTimeFrameState(tbInfo.szNextTimeFrame) == 1) or
		(tbInfo.szNextPriceLimitTimeFrame and GetTimeFrameState(tbInfo.szNextPriceLimitTimeFrame) == 1) then
		self:UpdatePrice(tbInfo);
	end

	return tbInfo.nPrice, tbInfo.tbAllowPrice;
end

function MarketStall:GetItemType(szMainType, nSubType)
	local tbInfo = (self.tbAllStallInfo[szMainType] or {})[nSubType or 0];
	if not tbInfo then
		return;
	end

	return tbInfo.nType, tbInfo.nShowLimitPrecent;
end

function MarketStall:CheckOpen()
	if MarketStall.bClose then
		return false;
	end

	return true;
end

function MarketStall:GetSoldStallAward(szMainType, nSubType, nCount)
	if not nSubType or nSubType <= 0 then
		return {szMainType, nCount}
	end

	local tbRet = {szMainType, nSubType, nCount, 0}
	local tbInfo = self.tbAllStallInfo[szMainType][nSubType]
	if not tbInfo then
		Log("[x] MarketStall:GetSoldStallAward", szMainType, nSubType, nCount)
		return tbRet
	end

	local nSubTypeSold = tbInfo.nSubTypeSold
	if nSubTypeSold and nSubTypeSold>0 and nSubType~=nSubTypeSold then
		tbRet[2] = nSubTypeSold
	end

	local nTimeout = self:GetSoldItemTimeout(tbInfo.szTimeOutFunc)
	if nTimeout>0 then
		tbRet[4] = nTimeout
	end

	if tbInfo.nCantSellAgain and tbInfo.nCantSellAgain>0 then
		tbRet[5] = true
	end

	return tbRet
end

function MarketStall:GetStallAward(szMainType, nSubType, nCount)
	if not nSubType or nSubType <= 0 then
		return {szMainType, nCount};
	end
	return {szMainType, nSubType, nCount}
end

function MarketStall:GetStallAwardName(szMainType, nSubType, nFaction, nSex)
	local nType = Player.AwardType[szMainType];
	local szName = "道具名"
	if nType == Player.award_type_item then
		szName = Item:GetItemTemplateShowInfo(nSubType, nFaction, nSex)
	elseif nType == Player.award_type_money then
		szName = Shop:GetMoneyName(szAwardType)
	end

	return szName;
end

function MarketStall:RegisterCheckOpen(szType, fnCheck)
	self.tbCheckOpen = self.tbCheckOpen or {}
	self.tbCheckOpen[szType] = fnCheck
end

function MarketStall:IsMarketOpen(pPlayer)
	if GetTimeFrameState(self.szCreateRoleTimeLimitTimeFrame) == 1 and
		pPlayer.dwCreateTime > TimeFrame:CalcTimeFrameOpenTime(MarketStall.szCreateRoleTimeLimitTimeFrame) and
		GetTime() - pPlayer.dwCreateTime < self.nCreateRoleTimeLimit then

		return false, "新建角色1小时后开启摆摊";
	end

	if pPlayer.nLevel < self.nOpenLevel then
		return false, string.format("%d级后开放摆摊", self.nOpenLevel)
	end

	for szType, fnCheck in pairs(self.tbCheckOpen or {}) do
		local bRet, szMsg = fnCheck(pPlayer)
		if not bRet then
			return bRet, szMsg
		end
	end
	return true
end

function MarketStall:IsMyStoreFull(pPlayer)
	if MODULE_GAMESERVER then
		local tbPlayerInfo = self.tbStallInfoByPlayer[pPlayer.dwID] or {};
		return Lib:CountTB(tbPlayerInfo) >= self.nMyStoreMaxItems;
	else
		return #self.tbData.tbMyItems >= self.nMyStoreMaxItems;
	end
end

function MarketStall:GetSellCost(nTotalPrice)
	return math.max(math.ceil(nTotalPrice * 0.01), 1)
end

function MarketStall:CheckCanSellItem(pPlayer, szMainType, nSubType)
	local nAwardType = Player.AwardType[szMainType];
	if not nAwardType then
		return false, "上架物品未知";
	end

	local nCurCount = 0;
	local pItem;
	if nAwardType == Player.award_type_item then
		pItem = pPlayer.GetItemInBag(nSubType);
		if not pItem then
			return false, "无效道具，不可出售";
		end

		if MODULE_GAMESERVER then
			if self.bAllForbidden or (self.tbForbidden and self.tbForbidden[pItem.dwTemplateId]) then
				return false, "此物品暂时无法出售";
			end
		end

		local tbInfo = (self.tbAllStallInfo[szMainType] or {})[pItem.dwTemplateId];
		if not tbInfo then
			return false, "此物品不可上架";
		end

		if tbInfo.szCloseTimeFrame and tbInfo.szCloseTimeFrame ~= "" and GetTimeFrameState(tbInfo.szCloseTimeFrame) == 1 then
			return false, "陈旧物品，不能上架";
		end

		if pItem.nPos ~= Item.emITEMPOS_BAG then
			return false, "只有背包内的道具才可以摆摊";
		end

		local bCanSell = Item:CheckCanSell(pItem);
		if not bCanSell then
			return false, "此物品不可出售";
		end

		if Item:IsForbidStall(pItem) then
			return false, "此物品不可上架"
		end

		nCurCount = pItem.nCount;
	elseif nAwardType == Player.award_type_money then
		nCurCount = pPlayer.GetMoney(szMainType);
	else
		return false, "上架物品类型未知！";
	end

	local _, tbPriceInfo = self:GetPriceInfo(szMainType, pItem and pItem.dwTemplateId or nSubType);
	if not tbPriceInfo then
		return false, "不可上架物品";
	end

	return true, "", nCurCount, pItem, tbPriceInfo;
end

function MarketStall:CheckCanNewSellItem(pPlayer, szMainType, nSubType, nCount, nPrice, bIgnorCheckCost)
	if self:IsMyStoreFull(pPlayer) then
		return false, "不能上架更多物品"
	end

	if not self.tbAllowCount[nCount] then
		return false, "上架物品数量有误"
	end

	local bRet, szMsg, nCurCount, pItem, tbPriceInfo = self:CheckCanSellItem(pPlayer, szMainType, nSubType);
	if not bRet then
		return false, szMsg;
	end

	local bCanSell, nLastTime = self:CheckSellLimit(pPlayer, szMainType, pItem and pItem.dwTemplateId or nSubType);
	if not bCanSell then
		return false, string.format("%s后才可以上架此物品", Lib:TimeDesc6(nLastTime));
	end

	if not bIgnorCheckCost and nCurCount < nCount then
		return false, "大侠没有这么多物品呀！";
	end

	if not tbPriceInfo or not tbPriceInfo[nPrice] then
		return false, "这东西不能使用这个价格上架哟！";
	end

	local nCost = self:GetSellCost(nCount * nPrice)
	local nHasGold = pPlayer.GetMoney("Gold");
	if not bIgnorCheckCost and nHasGold < nCost then
		return false, "手续费不足，无法上架";
	end

	return true, "", nCost, pItem;
end

function MarketStall:CheckCanUpdateItemPrice(pPlayer, szMainType, nSubType, nCount, nPrice, bIgnorCheckCost)
	if nCount <= 0 then
		return false, "此物品已经售完，无需重新上架！";
	end

	local _, tbPriceInfo = self:GetPriceInfo(szMainType, nSubType);
	if not tbPriceInfo or not tbPriceInfo[nPrice] then
		return false, "这东西不能使用这个价格上架哟！";
	end

	local bCanSell, nLastTime = self:CheckSellLimit(pPlayer, szMainType, nSubType);
	if not bCanSell then
		return false, string.format("%s后才可以重新上架此物品", Lib:TimeDesc6(nLastTime));
	end

	local nCost = math.max(math.ceil(nCount * nPrice * 0.01), 1);
	local nHasGold = pPlayer.GetMoney("Gold");
	if not bIgnorCheckCost and nHasGold < nCost then
		return false, "手续费不足，无法上架";
	end

	return true, "", nCost;
end

function MarketStall:OnSyncSelllLimitData(tbData)
	if MODULE_GAMESERVER then
		return;
	end

	local tbPlayerInfo = me.GetScriptTable("MarketStall");
	tbPlayerInfo.tbSellLimitInfo = tbData;
end

function MarketStall:GetSellLimitInfo(pPlayer)
	local tbPlayerInfo = pPlayer.GetScriptTable("MarketStall");
	tbPlayerInfo.tbSellLimitInfo = tbPlayerInfo.tbSellLimitInfo or {};

	if not tbPlayerInfo.tbSellLimitInfo.nVersion or tbPlayerInfo.tbSellLimitInfo.nVersion ~= self.nSellLimitDataVersion then
		tbPlayerInfo.tbSellLimitInfo = {nVersion = self.nSellLimitDataVersion};
	end
	return tbPlayerInfo.tbSellLimitInfo;
end

function MarketStall:CheckSellLimit(pPlayer, szMainType, nSubType)
	if not self.bSellLimitOpen then
		return true;
	end

	local tbLimitInfo = (self.tbSellLimitInfo[szMainType] or {})[nSubType or 0];
	if not tbLimitInfo then
		Log("[MarketStall] get tbLimitInfo fail !!", szMainType, nSubType or 0);
		return true;
	end
	local nCurType = tbLimitInfo.nType;
	local nCurSubType = tbLimitInfo.nSubType;
	local nCurLevel = tbLimitInfo.nLevel;
	local tbSellLimitInfo = self:GetSellLimitInfo(pPlayer);

	local tbLimit = tbSellLimitInfo[nCurType];
	if not tbLimit then
		return true;
	end

	local nBuyTime = 0;
	for nLevel, tbInfo in pairs(tbLimit) do
		if nLevel <= nCurLevel then
			for nSubLimitType, nTime in pairs(tbInfo) do
				if nLevel < nCurLevel or nSubLimitType == nCurSubType then
					nBuyTime = math.max(nTime, nBuyTime);
				end
			end
		end
	end

	local nLastTime = self.nSellLimitTime - (GetTime() - nBuyTime);
	return nLastTime <= 0, nLastTime;
end

function MarketStall:OnBuyItem_SellLimit(nSellLimitType, nSellLimitSubType, nSellLimitLevel, nTime, pPlayer)
	if not self.bSellLimitOpen then
		return;
	end

	if MODULE_GAMESERVER then
		pPlayer.CallClientScript("MarketStall:OnBuyItem_SellLimit", nSellLimitType, nSellLimitSubType, nSellLimitLevel, nTime);
	else
		pPlayer = me;
	end

	local tbSellLimitInfo = self:GetSellLimitInfo(pPlayer);
	tbSellLimitInfo[nSellLimitType] = tbSellLimitInfo[nSellLimitType] or {};
	tbSellLimitInfo[nSellLimitType][nSellLimitLevel] = tbSellLimitInfo[nSellLimitType][nSellLimitLevel] or {};
	tbSellLimitInfo[nSellLimitType][nSellLimitLevel][nSellLimitSubType] = nTime;
end

function MarketStall:TipBuyItemFromMarket(pPlayer, nItemId, szTipsInfo)
	if MODULE_GAMESERVER then
		pPlayer.CallClientScript("MarketStall:TipBuyItemFromMarket", nil, nItemId, szTipsInfo)
		return;
	end

	pPlayer = pPlayer or me;

	if not szTipsInfo then
		local szItemName = Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
		szTipsInfo = string.format("[FFFE0D]%s[-]数量不足，是否前往摆摊购买？", szItemName);
	end
	pPlayer.MsgBox(szTipsInfo,
	{
		{"前往", function () Ui:OpenWindow("MarketStallPanel", 1, nil, "item", nItemId); end },
		{"取消"}
	});
end

function MarketStall:TipBuyItemFromShop(pPlayer, nItemId, szTipsInfo)
	if MODULE_GAMESERVER then
		pPlayer.CallClientScript("MarketStall:TipBuyItemFromShop", nil, nItemId, szTipsInfo)
		return;
	end

	pPlayer = pPlayer or me;

	if not szTipsInfo then
		local szItemName = Item:GetItemTemplateShowInfo(nItemId, pPlayer.nFaction, pPlayer.nSex)
		szTipsInfo = string.format("[FFFE0D]%s[-]数量不足，是否前往商城购买？", szItemName);
	end
	pPlayer.MsgBox(szTipsInfo,
	{
		{"前往", function () Ui:OpenWindow("CommonShop", "Treasure", "tabAllShop", nItemId) end },
		{"取消"}
	});
end

function MarketStall:GetSoldItemTimeout(szFuncType)
	if not szFuncType or szFuncType=="" then
		return 0
	end

	if szFuncType=="Next4AM" then
		local nNow = GetTime()
		local tbData = os.date("*t", nNow)
		if tbData.hour<4 then
			tbData.hour = 4
			tbData.min = 0
			tbData.sec = 0
		else
			nNow = nNow+24*3600
			tbData = os.date("*t", nNow)
			tbData.hour = 4
			tbData.min = 0
			tbData.sec = 0
		end
		return os.time(tbData)
	else
		Log("[x] MarketStall:GetSoldItemTimeout", szFuncType)
	end
	return 0
end