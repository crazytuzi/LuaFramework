
Kin.tbAuctionData = Kin.tbAuctionData or {};
local tbClientAuctionData = Kin.tbAuctionData;

function Kin:OnAuctionSyncData(tbAuction, bFreshUi, bAllUpdate)
	if tbAuction then
		tbClientAuctionData[tbAuction.szType] = tbAuction;
	end

	if bFreshUi then
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_AUCTION_DATA, "Auction", bAllUpdate);
	end
end

function Kin:GetAuctionsData()
	if not tbClientAuctionData.Global then
		tbClientAuctionData.Global = {szType = "Global", nEndTime = GetTime() * 2};
	end
	return tbClientAuctionData;
end

function Kin:OnAuctionSyncBidingInfo(tbBidingInfo)
	self.tbAuctionBidingInfo = tbBidingInfo;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_AUCTION_DATA, "Auction", true)
end

function Kin:GetAuctionBidingInfo()
	return self.tbAuctionBidingInfo or {};
end

function Kin:GetAuction(szType)
	return szType and tbClientAuctionData[szType];
end

function Kin:Ask4AutionData(szType)
	local tbAuction = tbClientAuctionData[szType];
	if not tbAuction then
		return;
	end

	RemoteServer.OnActionRequest("OnSyncAuctions", szType, tbAuction.nVersion);
end

function Kin:Ask4AllAuctionData()
	local tbVersions = {};
	for szType, tbData in pairs(tbClientAuctionData) do
		tbVersions[szType] = tbData.nVersion;
	end

	RemoteServer.OnActionRequest("OnSyncAllAuctions", tbVersions);
end

function Kin:ClearAuctionCache()
	Kin.tbAuctionData = {};
	tbClientAuctionData = Kin.tbAuctionData;
	self.nAuctionPersonalWaitingVersion = nil;
	self.tbAuctionPersonalWaitingItem = nil;
	self.tbAuctionBidingInfo = nil;
end

function Kin:AskMyAuctionData()
	RemoteServer.OnActionRequest("OnSyncPersonalAuction", self.nAuctionPersonalWaitingVersion);
end

function Kin:DeletePersonalAuctionItem(nFrame, nItemId, nCount)
	RemoteServer.OnActionRequest("DeletePersonalAuctionItem", nFrame, nItemId, nCount);
end

function Kin:OnSyncPersonalAuctionData(tbPersonAuctionData, nVersion)
	self.tbAuctionPersonalWaitingItem = tbPersonAuctionData;
	self.nAuctionPersonalWaitingVersion = nVersion;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_AUCTION_DATA, "MyAuction");
	Kin:UpdatePersonalAuctionRedPoint();
end

function Kin:UpdatePersonalAuctionRedPoint()
	local tbPersonAuctionData = self.tbAuctionPersonalWaitingItem;
	if tbPersonAuctionData and next(tbPersonAuctionData) then
		Ui:SetRedPointNotify("MyAuction");
	else
		Ui:ClearRedPointNotify("MyAuction");
	end
end

function Kin:GetPersonalAuctionData()
	local tbResult = {};
	local tbPersonAuctionData = self.tbAuctionPersonalWaitingItem or {};
	for nOpenTime, tbItems in pairs(tbPersonAuctionData) do
		for _, tbItem in ipairs(tbItems) do
			local nItemId = tbItem.nItemId;
			local nCount = tbItem.nCount;
			local nPrice = Kin:GetAuctionItemPrice(nItemId) * nCount;
			table.insert(tbResult, {
				nItemId = nItemId;
				nCount = nCount;
				nOrgPrice = nPrice;
				nOpenTime = nOpenTime;
				});
		end
	end

	local tbGlobalAuctionData = Kin:GetAuction("Global");
	for _, tbItem in pairs(tbGlobalAuctionData.tbItems or {}) do
		if tbItem.nOwnerId == me.dwID then
			table.insert(tbResult, tbItem);
		end
	end

	return tbResult;
end

function Kin:PersonalAuctionAddedNotify(tbItems)
	local szInfo = "";
	local nTotalPrice = 0;
	for nIdx, tbItem in ipairs(tbItems) do
		local szItemName = Item:GetItemTemplateShowInfo(tbItem.nItemId, me.nFaction, me.nSex);
		szInfo = string.format("[FFFE0D]%s%s%s[-]", szInfo, szItemName, nIdx == #tbItems and "" or "、");
		nTotalPrice = nTotalPrice + Kin:GetAuctionItemPrice(tbItem.nItemId) * tbItem.nCount;
	end
	szInfo = string.format("恭喜获得%s，将以起拍价[FFFE0D]%d元宝[-]进行全服拍卖，成交后你将获得所有收益。\n[FFFE0D]（可在%d分钟之内前往拍卖取回物品）[-]",
							szInfo, nTotalPrice, Kin.AuctionDef.nPersonalAuctionWaitingTime/60);

	local fnGo = function ()
		Ui:OpenWindow("AuctionPanel", nil, true)
	end

	me.MsgBox(szInfo, {{"前往拍卖", fnGo}});
end

function Kin:AskAuctionDealListInfo(szType)
	RemoteServer.OnActionRequest("AskDealListInfo", szType);
end

function Kin:OnAuctionSyncDealList(szType, tbDealList)
	self.tbAuctionDealList = self.tbAuctionDealList or {};
	self.tbAuctionDealList[szType] = tbDealList;

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_AUCTION_DATA, "AuctionDealList", szType);
end

function Kin:GetAuctionDealList(szType)
	local tbDealList = self.tbAuctionDealList and self.tbAuctionDealList[szType];
	return tbDealList;
end

function Kin:AuctionPriceChanged(szType, nId, nPrice)
	local tbAuctionData = Kin:GetAuction(szType);
	local tbItemData = tbAuctionData.tbItems[nId];

	local fnBid = function ()
		RemoteServer.OnActionRequest("Bid", szType, tbItemData.nId, nPrice);
		Ui:CloseWindow("MessageBox");
	end

	local fnClose = function ()
		Ui:CloseWindow("MessageBox");
	end

	local tbPriceInfo = Kin.Auction:GetPriceInfo(tbItemData);
	local szItemName = Item:GetItemTemplateShowInfo(tbItemData.nItemId, me.nFaction, me.nSex);
	local szMoneyName = Shop:GetMoneyName(tbPriceInfo.szMoneyType);

	Ui:OpenWindow("MessageBox",
		string.format("当前竞价已变动，你确定要花费 [FFFE0D]%d%s[-] 参与竞拍[FFFE0D]【%s】[-]吗？", nPrice, szMoneyName, szItemName),
		{{fnBid}, {fnClose}}, {"确定", "取消"});
end

function Kin:AucitonOpenNew(szAuctionType)
	Ui:SetRedPointNotify("KinAuctionRedPoint");
	self.szAuctionNewOpenType = szAuctionType;
end

function Kin:AuctionGetNewOpenType()
	local szAuctionType = self.szAuctionNewOpenType;
	self.szAuctionNewOpenType = nil;
	return szAuctionType;
end
