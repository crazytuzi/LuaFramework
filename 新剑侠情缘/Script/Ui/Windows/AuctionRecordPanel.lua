local tbUi = Ui:CreateClass("AuctionRecordPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_AUCTION_DATA, self.OnUpdate, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen(szType)
	Kin:AskAuctionDealListInfo(szType)
end

function tbUi:OnOpenEnd(szType)
	self.szType = szType;
	self.nCurPage = 1;
	self.nMaxPage = 0;
	self:Update();
end

function tbUi:OnUpdate(szNotifyType, szDataType)
	if szNotifyType == "AuctionDealList" and szDataType == self.szType then
		self:Update();
	end
end

local nCountPerPage = 10;
tbUi.tbAuctionHistoryName = {
	Global = "全服拍卖记录";
	Dealer = "西域行商拍卖记录";
};

function tbUi:Update()
	local tbRecordList = Kin:GetAuctionDealList(self.szType) or {};
	self.nMaxPage = math.ceil(#tbRecordList / nCountPerPage);

	local szTitle = self.tbAuctionHistoryName[self.szType] or "家族拍卖记录";
	self.pPanel:Label_SetText("Title", szTitle);
	local szPage = string.format("%d/%d", self.nCurPage, math.max(self.nMaxPage, 1));
	self.pPanel:Label_SetText("Pages", szPage);
	self.pPanel:SetActive("NoAuction", #tbRecordList == 0);

	local nBeginIdx = (self.nCurPage - 1) * 10;
	for i = 1, nCountPerPage do
		local tbItem = tbRecordList[nBeginIdx + i];
		if tbItem then
			self.pPanel:SetActive("AuctionRecordItem" .. i, true);
			local szEvent = tbItem.szType == "Global" and "" or Kin.AuctionName[tbItem.szType];
			local szTime = os.date("%m月%d日%H:%M", tbItem.nTime);
			local tbItemInfo = KItem.GetItemBaseProp(tbItem.nItemId);
			local szPriceInfo = "流拍至全服拍卖";
			if tbItem.nPrice then
				local szAuctionKind = tbItem.bBidOver and "一口价成交" or "竞拍价成交";
				local szMoneyName, szMoneyEmotion = Shop:GetMoneyName(tbItem.szMoneyType);
				szPriceInfo = string.format("%d%s%s", tbItem.nPrice, szMoneyEmotion or szMoneyName, szAuctionKind);
			end

			self.pPanel:Label_SetText("Event" .. i, szEvent);
			self.pPanel:Label_SetText("Time" .. i, szTime);
			self.pPanel:Label_SetText("Price" .. i, szPriceInfo);
			
			if tbItem.nCount == 1 then
				self.pPanel:Label_SetText("Name" .. i, tbItemInfo.szName);
			else
				self.pPanel:Label_SetText("Name" .. i, string.format("%s× %d", tbItemInfo.szName, tbItem.nCount));
			end
		else
			self.pPanel:SetActive("AuctionRecordItem" .. i, false);
		end
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnLeft()
	if self.nCurPage > 1 then
		self.nCurPage = self.nCurPage - 1;
		self:Update();
	end
end

function tbUi.tbOnClick:BtnRight()
	if self.nCurPage < self.nMaxPage then
		self.nCurPage = self.nCurPage + 1;
		self:Update();
	end
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end
