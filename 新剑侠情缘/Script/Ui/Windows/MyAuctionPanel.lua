local tbUi = Ui:CreateClass("MyAuctionPanel");

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_SYNC_AUCTION_DATA, self.Update, self},
	}
	return tbRegEvent
end

function tbUi:OnOpen()
	Kin:AskMyAuctionData();
end

function tbUi:OnOpenEnd()
	self:Update();
end

function tbUi:OnClose()
	if self.nAuctionItemsTimer then
		Timer:Close(self.nAuctionItemsTimer);
		self.nAuctionItemsTimer = nil;
	end
end

function tbUi:Update()
	local tbItems = Kin:GetPersonalAuctionData();
	self.pPanel:SetActive("NoAuction", #tbItems == 0)

	self.tbAuctionItemObjMaps = {};
	local fnSetItem = function (itemObj, nIdx)
		local tbItem = tbItems[nIdx];
		itemObj:Init(tbItem);
		itemObj:UpdateTime();
		self.tbAuctionItemObjMaps[itemObj] = tbItem;
	end

	self.ScrollView:Update(#tbItems, fnSetItem);

	local fnCountdown = function ()
		local nNow = GetTime();
		for itemObj, _ in pairs(self.tbAuctionItemObjMaps) do
			itemObj:UpdateTime();
		end
		return true;
	end

	if self.nAuctionItemsTimer then
		Timer:Close(self.nAuctionItemsTimer);
		self.nAuctionItemsTimer = nil;
	end
	if fnCountdown() and next(tbItems) then
		self.nAuctionItemsTimer = Timer:Register(Env.GAME_FPS, fnCountdown);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

local tbItemUi = Ui:CreateClass("MyAuctionItem");

function tbItemUi:Init(tbItem)
	self.tbItem = tbItem;
	local szItemName = Item:GetItemTemplateShowInfo(tbItem.nItemId, me.nFaction, me.nSex);
	self.pPanel:Label_SetText("Name", szItemName);
	self.pPanel:Label_SetText("Price", tbItem.nCurPrice or tbItem.nOrgPrice);
	self.itemframe:SetItemByTemplate(tbItem.nItemId, tbItem.nCount, me.nFaction);
	self.itemframe.fnClick = self.itemframe.DefaultClick;
end

function tbItemUi:UpdateTime()
	local tbItem = self.tbItem;
	local szTimeInfo = nil;
	local nNow = GetTime();

	self.pPanel:SetActive("Time1", tbItem.nStartTime and true or false);
	self.pPanel:SetActive("Time2", not tbItem.nStartTime);

	if tbItem.nStartTime then
		local nLeftTime = tbItem.nStartTime and (tbItem.nStartTime - nNow);
		if nLeftTime and nLeftTime > 0 then
			local szLeftTime = Lib:TimeDesc3(nLeftTime);
			szTimeInfo = string.format("%s开始", szLeftTime);
		else
			nLeftTime = tbItem.nTimeOut - nNow;
			if nLeftTime < 0 then
				szTimeInfo = "已结束";
			else
				szTimeInfo = Lib:TimeDesc3(nLeftTime);
			end
		end
		self.pPanel:Label_SetText("Time1", szTimeInfo);
	elseif tbItem.nOpenTime then
		local nLeftTime = tbItem.nOpenTime - nNow;
		if nLeftTime < 0 then
			tbItem.nStartTime = tbItem.nOpenTime + Kin.AuctionDef.nAuctionPrepareTime;
			tbItem.nTimeOut = tbItem.nOpenTime + Kin.AuctionDef.nAuctionPrepareTime + Kin.AuctionDef.nGlobalAuctionLastingTime;
			self:UpdateTime();
		else
			szTimeInfo = Lib:TimeDesc3(nLeftTime);
			self.pPanel:Label_SetText("Time2", szTimeInfo .. "开始");
		end
	end
end

tbItemUi.tbOnClick = tbItemUi.tbOnClick or {};

function tbItemUi.tbOnClick:BtnAuctionRecord()
	local tbItem = self.tbItem;
	if not tbItem or tbItem.nStartTime or not tbItem.nOpenTime then
		me.CenterMsg("不存在该物品");
		return;
	end

	local fnConfirm = function ()
		Kin:DeletePersonalAuctionItem(tbItem.nOpenTime, tbItem.nItemId, tbItem.nCount);
	end

	me.MsgBox("你确定要取消拍卖吗？[FFFE0D]\n（取消拍卖后退回拍卖品）[-]", {{"确定", fnConfirm}, {"取消"}});
end
