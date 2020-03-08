local tbUi = Ui:CreateClass("AuctionPanel");

function tbUi:OnOpenEnd(szAuctionType, bOpenMyAuction)
	Ui:ClearRedPointNotify("KinAuctionRedPoint");
	Kin:Ask4AllAuctionData();
	-- Kin:AskMyAuctionData(); 个人拍卖已取消
	-- Kin:UpdatePersonalAuctionRedPoint();

	self.tbCurItems = nil;
	self.szCurAuctionType = szAuctionType or self.szCurAuctionType;
	self.pPanel:SetActive("GainNode", false);
	self:UpdateAuctionScrollView({}, true); -- 滑到最上最下滚动条所需支持
	self:InitSidebar();

	self.pPanel:SetActive("BtnMyAuction", false);
	-- if bOpenMyAuction then
	-- 	Ui:OpenWindow("MyAuctionPanel");
	-- end
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_SYNC_AUCTION_DATA, self.Update, self},
	}
	return tbRegEvent
end

function tbUi:Update(szType, bAllUpdate)
	if szType ~= "Auction" then
		return;
	end

	if bAllUpdate then
		self.tbCurItems = nil;
	end

	self.szCurAuctionType = Kin:AuctionGetNewOpenType() or self.szCurAuctionType;
	self:InitSidebar();
end

function tbUi:InitSidebar()
	local fnOnSelect = function (buttonObj, tbItem)
		self.szCurAuctionType = buttonObj and buttonObj.tbItem.szType or tbItem.szType;
		-- self.szCurOrgType = tbItem and tbItem.szOrgType;
		self:UpdateAuctionScrollView(tbItem or buttonObj.tbItem, buttonObj and true or false);

		if buttonObj then
			Kin:Ask4AutionData(self.szCurAuctionType);
		end
	end

	local bFirstInit = true;
	local fnSetItem = function (itemObj, tbNodeData, nIdx)
		local tbItem = tbNodeData.tbData or tbNodeData;
		local szAuctionName = tbItem.szName or Kin.AuctionName[tbItem.szType] or tbItem.szType;
		local bMainBtn = tbNodeData.tbLeaves and true or false;
		local bDealer = tbItem.szType == "Dealer";
		local szBaseClass = bDealer and "BtnXiyu" or "BaseClass";
		itemObj.pPanel:SetActive("BaseClass", bMainBtn and not bDealer);
		itemObj.pPanel:SetActive("BtnXiyu", bMainBtn and bDealer);
		itemObj.pPanel:SetActive("SubClass", not bMainBtn);
		itemObj.pPanel:Label_SetText("LabelDark", szAuctionName);

		if bMainBtn then
			itemObj.BaseClass.tbItem = tbItem;
			itemObj.BaseClass.pPanel.OnTouchEvent = fnOnSelect;

			if bDealer then
				itemObj.BtnXiyu.tbItem = tbItem;
				itemObj.BtnXiyu.pPanel.OnTouchEvent = function (...)
					itemObj.BaseClass.pPanel.OnTouchEvent(...);
				end
			end

			itemObj[szBaseClass].pPanel:SetActive("Triangle", true);
			itemObj[szBaseClass].pPanel:Label_SetText("LabelLight", Kin.AuctionName[tbNodeData.szType] or tbNodeData.szType);
			if tbNodeData == self.SidebarScrollView:GetCurBaseNode() then
				Timer:Register(1, function ()
					itemObj[szBaseClass].pPanel:Toggle_SetChecked("Main", true);
				end);
			else
				itemObj[szBaseClass].pPanel:Toggle_SetChecked("Main", false);
			end
		else
			itemObj.SubClass.tbItem = tbItem;
			itemObj.SubClass.pPanel.OnTouchEvent = fnOnSelect;
			itemObj.SubClass.pPanel:Label_SetText("LabelLight", szAuctionName);
			itemObj.SubClass.pPanel:Toggle_SetChecked("Main", self.szCurAuctionType == tbItem.szType);
		end

		if bFirstInit and self.szCurAuctionType == tbItem.szType then
			bFirstInit = false;
			itemObj.SubClass.pPanel:Toggle_SetChecked("Main", true);
			itemObj[szBaseClass].pPanel:Toggle_SetChecked("Main", true);
			fnOnSelect(nil, tbItem);
		end
	end

	local tbTree = self:GetSideBarTreeData();
	self.SidebarScrollView:SetTreeMenu(tbTree, fnSetItem, function (tbNodeData)
		self.szCurAuctionType = tbNodeData.szType;
		self:UpdateAuctionScrollView(tbNodeData.tbData, true);
	end);

	if bFirstInit then
		self:UpdateAuctionScrollView({}, true);
	end
end

function tbUi:GetSideBarTreeData()
	local tbTree = {};
	local tbKinAuction = {szType = "家族拍卖", tbLeaves = {}};
	local tbGlobalAuction = {szType = "Global", tbLeaves = {}};
	local tbDealerAuction = {szType = "Dealer", tbLeaves = {}};
	local tbBidingAuction = {szType = "MyBiding", tbLeaves = {}, tbData = {szType = "MyBiding", tbItems = {}}};
	table.insert(tbTree, tbKinAuction);
	table.insert(tbTree, tbGlobalAuction);

	local tbAuctions = Kin:GetAuctionsData();
	local tbBidingInfo = Kin:GetAuctionBidingInfo();

	for _, tbAuction in pairs(tbAuctions) do
		if tbAuction.szType == "Global" then
			tbGlobalAuction.tbData = tbAuction;
		elseif tbAuction.szType == "Dealer" then
			tbDealerAuction.tbData = tbAuction;
			table.insert(tbTree, tbDealerAuction);
		elseif tbAuction.bOpen and next(tbAuction.tbItems) then
			table.insert(tbKinAuction.tbLeaves, tbAuction);
			if not self.szCurAuctionType then
				self.szCurAuctionType = tbAuction.szType;
			end

			if Kin.Auction:IsKinAuction(self.szCurAuctionType) then
				tbKinAuction.bDown = true;
			end
		end

		-- 处理我的拍卖
		local szAuctionKey = tbAuction.szSaleOrderId or tbAuction.szType;
		local tbBiding = tbBidingInfo[szAuctionKey] or {};
		for nItemIdx, tbInfo in pairs(tbBiding.tbBidList or {}) do
			local tbItem = tbAuction.tbItems and tbAuction.tbItems[nItemIdx];
			if tbItem and not tbItem.bSold then
				tbItem = Lib:CopyTB1(tbItem);
				tbItem.szType = tbAuction.szType;
				tbItem.nSortValue = tbInfo.nAddTime;
				tbItem.nToppingTime = tbInfo.nToppingTime
				tbBidingAuction.tbData.tbItems[tbAuction.szType .. nItemIdx] = tbItem;
			end
		end
	end

	if next(tbBidingAuction.tbData.tbItems) then
		tbBidingAuction.tbData.nStartTime = 0;
		table.insert(tbTree, tbBidingAuction);
	end

	self.tbGlobalAuctionTypeMap = {};
	for _, tbNode in ipairs(tbTree) do
		for nIdx, tbItem in pairs(tbNode.tbData and (tbNode.tbData.tbItems or tbNode.tbData.tbShowItems) or {}) do
			local szItemTypeName = Kin:AuctionGetItemType(tbItem.nItemId);
			local szItemType = szItemTypeName .. tbNode.szType;
			if not self.tbGlobalAuctionTypeMap[szItemType] then
				self.tbGlobalAuctionTypeMap[szItemType] = {
					szType = szItemType;
					szName = szItemTypeName;
					szOrgType = tbNode.szType;
					tbItems = {};
					tbShowItems = tbNode.tbData.tbShowItems;
					nStartTime = tbNode.tbData.nStartTime;
				};
				table.insert(tbNode.tbLeaves, self.tbGlobalAuctionTypeMap[szItemType]);

				if szItemType == self.szCurAuctionType then
					tbNode.bDown = true;
				end
			end

			self.tbGlobalAuctionTypeMap[szItemType].tbItems[nIdx] = tbItem;

			if not self.szCurAuctionType then
				self.szCurAuctionType = tbNode.szType;
			end
		end
	end

	return tbTree;
end

function tbUi:UpdateAuctionScrollView(tbAuctionData, bManualSwitch)
	local nNow = GetTime();
	self.tbCurItems = self.tbCurItems or {};
	if bManualSwitch then
		self.tbCurItems = {};
	end
	local tbItems = self.tbCurItems;

	tbAuctionData = tbAuctionData or Kin:GetAuction(self.szCurAuctionType) or {};
	self.tbCurAuctionData = tbAuctionData;

	local tbAuctionItems = tbAuctionData.tbItems or tbAuctionData.tbShowItems or {};
	-- 当前列表为空, 或手动切换过来时, 进行刷新列表
	if not next(tbItems) or bManualSwitch then
		for _, tbItem in pairs(tbAuctionItems) do
			if not tbItem.bSold and (tbItem.nTimeOut or math.huge) > nNow then
				table.insert(tbItems, tbItem);
			end
		end
	else
		for nIdx, tbItem in pairs(tbItems) do
			if tbAuctionItems[tbItem.nId] then
				tbItems[nIdx] = tbAuctionItems[tbItem.nId];
			elseif tbItem.szType and tbAuctionItems[tbItem.szType .. tbItem.nId] then
				tbItems[nIdx] = tbAuctionItems[tbItem.szType .. tbItem.nId];
			else
				tbItem.bSold = true;
			end
		end
	end

	if not next(tbItems) then
		tbAuctionData.bOpen = false;
		tbAuctionData.nVersion = -1 	--客户端判断当前拍卖结束，版本号置为-1，向服务器请求数据时再强制同步一次，避免客户端数据出错误判
	end
	local bMyBiding = string.find(self.szCurAuctionType or "", "MyBiding")
	table.sort(tbItems, function (a, b)
		if bMyBiding then 		--"我的拍卖"主页面优先按置顶顺序排序
			if a.nToppingTime then
				if not b.nToppingTime then
					return true
				else
					if a.nToppingTime > b.nToppingTime then
						return true
					elseif a.nToppingTime < b.nToppingTime then
						return false
					end
				end
			else
				if b.nToppingTime then
					return false
				end
			end
		end

		if a.nSortValue and b.nSortValue then
			return a.nSortValue < b.nSortValue;
		end

		if a.nOrgPrice == b.nOrgPrice then
			return a.nId < b.nId;
		end
		return a.nOrgPrice > b.nOrgPrice;
	end);
	self.tbAuctionItemObjMaps = {};
	local pScrollView = self.ItemsScrollView
	local fnSetItem = function (itemObj, nIdx)
		pScrollView:CheckShowGridMax(itemObj, nIdx)
		local tbItem = tbItems[nIdx];
		self.tbAuctionItemObjMaps[itemObj] = true;
		itemObj:Init(tbItem, tbAuctionData, self);
		itemObj:UpdateTime(tbAuctionData);
	end

	pScrollView:Update(#tbItems, fnSetItem, 9, self.BackTop, self.BackBottom );
	self:UpdateOtherInfo(tbItems);

	local fnCountdown = function ()
		for itemObj, _ in pairs(self.tbAuctionItemObjMaps) do
			itemObj:UpdateTime(tbAuctionData);
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

function tbUi:UpdateOtherInfo(tbItems)
	local bShowNoKin = not Kin:HasKin() and self.szCurAuctionType == "家族拍卖";
	self.pPanel:SetActive("NoFamily", bShowNoKin);
	self.pPanel:SetActive("NoAuction", #tbItems == 0 and not bShowNoKin);
	self.pPanel:SetActive("BtnAuctionRecord", not string.find(self.szCurAuctionType or "", "MyBiding"));

	local tbAuctionData = self.tbCurAuctionData;
	local tbPlayerIds = tbAuctionData.tbPlayerIds or {};
	local bJoin = tbPlayerIds[me.dwID];
	local bOpen = tbAuctionData.nStartTime and GetTime() >= tbAuctionData.nStartTime;

	if bJoin and bOpen then
		self.pPanel:SetActive("GainNode", true);

		local nTotalGold   = tbAuctionData.nBonusGold or 0;
		local nTotalSilver = tbAuctionData.nBonusSilver or 0;
		local nJoinMember  = tbAuctionData.nBonusCount or Lib:CountTB(tbAuctionData.tbPlayerIds);
		local nGoldEach    = math.floor(nTotalGold / nJoinMember);
		self.pPanel:Label_SetText("TxtGold", nGoldEach);
		
		self.pPanel:SetActive("MoneyIcon2", true);
		self.pPanel:Label_SetText("TxtGold2", math.floor(nTotalSilver / nJoinMember));

		local nMinGold = Kin:AuctionGetMinBonusPrice(tbAuctionData.szType);
		local szMinTip = "";
		if nGoldEach < nMinGold then
			local _, szMoneyEmotion = Shop:GetMoneyName("Gold");
			szMinTip = string.format("(本次保底分红:%s%d)", szMoneyEmotion, nMinGold);
		end
		self.pPanel:ChangePosition("TxtMinGoldInfo", 195, 34);
		self.pPanel:Label_SetText("TxtMinGoldInfo", szMinTip);
		self.pPanel:Label_SetText("TxtJoinInfo", "预计本场拍卖结束后您可以获得分红：");

	elseif (tbAuctionData.szType == "Dealer" and tbAuctionData.bOpen) or tbAuctionData.szOrgType == "Dealer" then
		self.pPanel:SetActive("GainNode", true);
		local nTotalGold = 0;
		local tbBidders = {};
		local tbAuctionData = Kin:GetAuction("Dealer");
		for nId, tbItem in pairs(tbAuctionData.tbItems or {}) do
			if tbItem.nBidderId then
				tbBidders[tbItem.nBidderId] = tbBidders[tbItem.nBidderId] or 0;
				tbBidders[tbItem.nBidderId] = tbBidders[tbItem.nBidderId] + tbItem.nCurPrice;
			end
		end

		for nPlayerId, nCost in pairs(tbBidders) do
			local nRedBagId = Kin.Auction:GetDealerLuckybagIdByCost(nCost);
			if nRedBagId then
				nTotalGold = nTotalGold + (Kin:RedBagGetBaseGold(nRedBagId) or 0);
			end
		end
		self.pPanel:Label_SetText("TxtGold", nTotalGold);
		self.pPanel:ChangePosition("TxtMinGoldInfo", 70, 34);
		self.pPanel:Label_SetText("TxtMinGoldInfo", "[FFFE0D]*从西域行商处拍下的物品均不可上架摆摊[-]");
		self.pPanel:Label_SetText("TxtJoinInfo", "预计本场拍卖结束后世界红包总金额：");
		self.pPanel:SetActive("MoneyIcon2", false);
		self.pPanel:Label_SetText("TxtGold2", "");
	else
		self.pPanel:SetActive("GainNode", false);
	end
end

function tbUi:OnClose()
	if self.nAuctionItemsTimer then
		Timer:Close(self.nAuctionItemsTimer);
		self.nAuctionItemsTimer = nil;
	end
	self.tbAuctionItemObjMaps = nil;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnAuctionRecord()
	local szAuctionType = self.szCurAuctionType;
	if self.tbGlobalAuctionTypeMap[self.szCurAuctionType] then
		szAuctionType = self.tbGlobalAuctionTypeMap[self.szCurAuctionType].szOrgType;
	end

	if not Kin:HasKin() and szAuctionType ~= "Global" and szAuctionType ~= "Dealer" then
		me.CenterMsg("少侠你还未加入家族，无法查看家族拍卖记录");
		return;
	end

	Ui:OpenWindow("AuctionRecordPanel", szAuctionType);
end

function tbUi.tbOnClick:BtnMyAuction()
	Ui:OpenWindow("MyAuctionPanel");
end

function tbUi.tbOnClick:BtnJoinFamily()
	if not Kin:HasKin() then
		Ui:OpenWindow("KinJoinPanel");
		Ui:CloseWindow(self.UI_NAME)
	end
end

--------------------------------------------------------
local tbSidebarItemUi = Ui:CreateClass("AuctionSidebarItem");
local tbItemUi = Ui:CreateClass("AuctionItem");
tbItemUi.tbOnDrag =
{
	Main = function (self, szWnd, nX, nY)
		self.pScrollView:OnDragList(nY)
	end	;
}

tbItemUi.tbOnDragEnd =
{
	Main = function (self)
		self.pScrollView:OnDragEndList()
	end	;
}

tbItemUi.fnClickGrid = function (tbGrid)
	Item:ShowItemCompareTips(tbGrid)
end

function tbItemUi:Init(tbItemData, tbAuctionData, rootPanel)
	self.rootPanel = rootPanel;
	self.tbItemData = tbItemData;
	self.szType = tbItemData.szType or tbAuctionData.szOrgType or tbAuctionData.szType;

	local tbPriceInfo = Kin.Auction:GetPriceInfo(tbItemData);
	self.pPanel:Label_SetText("TxtCurPrice", tbPriceInfo.nCurPrice);
	self.pPanel:Label_SetText("TxtMaxPrice", tbPriceInfo.nMaxPrice);
	self.Item:SetItemByTemplate(tbItemData.nItemId, tbItemData.nCount, me.nFaction);
	self.Item.fnClick = tbItemUi.fnClickGrid;

	local szItemName = Item:GetItemTemplateShowInfo(tbItemData.nItemId, me.nFaction, me.nSex);
	self.pPanel:Label_SetText("TxtName", szItemName);

	local szBidAdd = (tbItemData.nBidderId == me.dwID) and "加价" or "竞价";
	self.pPanel:Label_SetText("TxtBidAdd", szBidAdd);

	if me.dwID == tbItemData.nBidderId then
		self.pPanel:SetActive("TxtMyState2", false);
		self.pPanel:SetActive("TxtMyState", true);
		self.pPanel:Label_SetText("TxtMyState", "您的出价最高");
	elseif me.dwID == tbItemData.nOwnerId then
		self.pPanel:SetActive("TxtMyState2", false);
		self.pPanel:SetActive("TxtMyState", true);
		self.pPanel:Label_SetText("TxtMyState", "您的拍卖品");
	else
		self.pPanel:SetActive("TxtMyState2", tbItemData.nBidderId and true or false);
		self.pPanel:SetActive("TxtMyState", false);
	end

	self.pPanel:Sprite_SetSprite("Main", tbItemData.nBidderId == me.dwID and "BtnListThirdPress" or "BtnListThirdNormal");

	local szIcon, szIconAtlas = Shop:GetMoneyIcon(tbPriceInfo.szMoneyType);
	self.pPanel:Sprite_SetSprite("MoneyIcon1", szIcon, szIconAtlas);
	self.pPanel:Sprite_SetSprite("MoneyIcon2", szIcon, szIconAtlas);


	local bShowBidOver = tbPriceInfo.nMaxPrice < Env.INT_MAX;
	self.pPanel:SetActive("MoneyIcon1", bShowBidOver);
	self.pPanel:SetActive("TxtMaxPrice", bShowBidOver);
	self.pPanel:SetActive("BtnBidOver", bShowBidOver);

	self.pPanel:SetActive("SpriteForbidStall", tbItemData.bForbidStall and true or false);

	if tbAuctionData.szType == "MyBiding" then 		--在"我的拍卖"主页面显示置顶按钮
		self.pPanel:SetActive("BtnTopping", true)
	else
		self.pPanel:SetActive("BtnTopping", false)
	end
end

function tbItemUi:UpdateTime(tbAuctionData)
	local nNow = GetTime();
	local szTimeInfo = "";
	local tbItemData = self.tbItemData;
	local nTimeOut = tbItemData.nTimeOut or math.huge;
	local nLeftTime = tbItemData.nStartTime and (tbItemData.nStartTime - nNow);
	nLeftTime = nLeftTime or (tbAuctionData.nStartTime and tbAuctionData.nStartTime - nNow);
	if tbAuctionData.tbShowItems then
		if (tbAuctionData.szOrgType or tbAuctionData.szType) == "Dealer" then
			szTimeInfo = "19:05开启";
		end
	elseif nLeftTime and nLeftTime > 0 then
		local szLeftTime = Lib:TimeDesc3(nLeftTime);
		szTimeInfo = string.format("%s开始", szLeftTime);
	else
		nLeftTime = nTimeOut - nNow;
		if nLeftTime < 0 or tbItemData.bSold then
			szTimeInfo = "已结束";
		else
			szTimeInfo = Lib:TimeDesc3(nLeftTime);
		end
	end
	self.pPanel:Label_SetText("TxtLeftTime", szTimeInfo);
	self.pPanel:SetActive("MarkSellOut", tbItemData.bSold or (nTimeOut < nNow and tbItemData.nBidderId));
	self.pPanel:SetActive("MarkLiupai", nTimeOut < nNow and not tbItemData.bSold and not tbItemData.nBidderId);
end

tbItemUi.tbOnClick = tbItemUi.tbOnClick or {};

function tbUi:CheckBid(tbItemData, szAuctionType)
	-- 全服拍卖未开启时
	if not tbItemData.nTimeOut then
		me.CenterMsg(self.szBidTips or "未开启");
		return false;
	end

	local nNow = GetTime();
	local tbAuctionData = Kin:GetAuction(szAuctionType);
	if tbAuctionData.nStartTime and nNow < tbAuctionData.nStartTime then
		local szLeftTime = Lib:TimeDesc3(tbAuctionData.nStartTime - nNow);
		me.CenterMsg(string.format("%s后开始拍卖", szLeftTime));
		return false;
	end

	if tbItemData.nStartTime and nNow < tbItemData.nStartTime then
		local szLeftTime = Lib:TimeDesc3(tbItemData.nStartTime - nNow);
		me.CenterMsg(string.format("%s后开始拍卖", szLeftTime));
		return false;
	end

	if tbItemData.bSold or tbItemData.nTimeOut == 0 then
		me.CenterMsg("已经被拍走了");
		return false;
	end

	if me.dwID == tbItemData.nOwnerId then
		me.CenterMsg("不能竞拍自己的拍卖品");
		return false;
	end

	local nVipLimit = Kin.Auction:GetBidBidVipLimitByType(szAuctionType);
	if me.GetVipLevel() < nVipLimit then
		me.CenterMsg(string.format("达到剑侠尊享%d后可竞拍", nVipLimit));
		return false;
	end

	return true;
end

function tbItemUi.tbOnClick:BtnBidAdd()
	local tbItemData = self.tbItemData;
	if not self.rootPanel.CheckBid(self.rootPanel, tbItemData, self.szType) then
		return;
	end

	local tbPriceInfo = Kin.Auction:GetPriceInfo(tbItemData);
	local nCurMoney = me.GetMoney(tbPriceInfo.szMoneyType);
	local nRealCost = tbPriceInfo.nNextPrice;
	if me.dwID == tbItemData.nBidderId then
		nRealCost = tbPriceInfo.nNextPrice - tbPriceInfo.nCurPrice;
	end

	if nCurMoney < nRealCost then
		Ui:OpenWindow("CommonShop", tbItemData.bSilver and "Dress" or "Recharge", "Recharge");
		return;
	end

	local szItemName = Item:GetItemTemplateShowInfo(tbItemData.nItemId, me.nFaction, me.nSex);
	local szMoneyName = Shop:GetMoneyName(tbPriceInfo.szMoneyType);
	if tbPriceInfo.nNextPrice >= tbPriceInfo.nMaxPrice then
		local szMsg = string.format("你的出价已经达到了一口价（[FFFE0D]%d%s[-]），是否一口价买下[FFFE0D]【%s】[-]？", tbPriceInfo.nMaxPrice, szMoneyName, szItemName);
		local fnConfirm = function ()
			RemoteServer.OnActionRequest("BidOver", self.szType, tbItemData.nId, tbPriceInfo.nMaxPrice);
		end

		me.MsgBox(szMsg, {{"确认", fnConfirm}, {"取消"}});
		return;
	else
		local szMsg = string.format("确定要花费 [FFFE0D]%d%s[-] 参与\n[FFFE0D]【%s】[-]的竞拍吗？", tbPriceInfo.nNextPrice, szMoneyName, szItemName);
		if tbItemData.nBidderId == me.dwID then
			szMsg = string.format("你当前出价最高，确定要花费 [FFFE0D]%d%s[-] 加价竞拍[FFFE0D]【%s】[-]吗？", nRealCost, szMoneyName, szItemName);
		end

		local fnConfirm = function ()
			RemoteServer.OnActionRequest("Bid", self.szType, tbItemData.nId, tbPriceInfo.nNextPrice);
		end
		me.MsgBox(szMsg, {{"确认", fnConfirm}, {"取消"}});
	end
end

function tbItemUi.tbOnClick:BtnBidOver()
	local tbItemData = self.tbItemData;
	if not self.rootPanel.CheckBid(self.rootPanel, tbItemData, self.szType) then
		return;
	end

	local tbPriceInfo = Kin.Auction:GetPriceInfo(tbItemData);
	local nCurMoney = me.GetMoney(tbPriceInfo.szMoneyType);
	local nRealCost = tbPriceInfo.nMaxPrice;
	if me.dwID == tbItemData.nBidderId then
		nRealCost = tbPriceInfo.nMaxPrice - tbPriceInfo.nCurPrice;
	end

	if nCurMoney < nRealCost then
		Ui:OpenWindow("CommonShop", tbItemData.bSilver and "Dress" or "Recharge", "Recharge");
		return;
	end

	local szItemName = Item:GetItemTemplateShowInfo(tbItemData.nItemId, me.nFaction, me.nSex);
	local szMoneyName = Shop:GetMoneyName(tbPriceInfo.szMoneyType);
	local szMsg = string.format("确定要花费 [FFFE0D]%d%s[-] 一口价购买\n[FFFE0D]【%s】[-]吗？", tbPriceInfo.nMaxPrice, szMoneyName, szItemName);
	if me.dwID == tbItemData.nBidderId then
		szMsg = string.format("你当前出价最高[FFFE0D]（%d%s）[-]，确定要再增加 [FFFE0D]%d%s[-] 一口价购买\n[FFFE0D]【%s】[-]吗？",
						tbPriceInfo.nCurPrice, szMoneyName, nRealCost, szMoneyName, szItemName);
	end
	local fnConfirm = function ()
		RemoteServer.OnActionRequest("BidOver", self.szType, tbItemData.nId, tbPriceInfo.nMaxPrice);
	end
	me.MsgBox(szMsg, {{"确认", fnConfirm}, {"取消"}});
end

function tbItemUi.tbOnClick:BtnTopping()
	self.rootPanel.nLastToppingTime = self.rootPanel.nLastToppingTime or 0
	if GetTime() - self.rootPanel.nLastToppingTime < Kin.AuctionDef.TOPPING_INTERVAL then
		me.CenterMsg(string.format("操作太频繁，请%d秒后重试", Kin.AuctionDef.TOPPING_INTERVAL + self.rootPanel.nLastToppingTime - GetTime()))
		return
	end
	self.rootPanel.nLastToppingTime = GetTime()
	local tbItemData = self.tbItemData
	RemoteServer.OnActionRequest("ToppingPlayerBidingList", tbItemData.szType, tbItemData.nId)
end