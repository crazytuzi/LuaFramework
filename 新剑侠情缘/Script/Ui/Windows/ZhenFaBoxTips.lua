
local tbUi = Ui:CreateClass("ZhenFaBoxTips");
tbUi.tbBtnInfo = {"直接使用", "精致修复", "传世修复"};
function tbUi:OnOpen(nItemId, nItemTemplateId)
	local pItem = KItem.GetItemObj(nItemId or 0);
	if not pItem then
		Ui:OpenWindow("ItemTips", "Item", nil, nItemTemplateId);
		return 0;
	end

	self.nItemId = nItemId;
	self.nItemTemplateId = nItemTemplateId;

	self:Update();
end

function tbUi:Update()
	local pItem = KItem.GetItemObj(self.nItemId or 0);
	if not pItem then
		Ui:CloseWindow("ZhenFaBoxTips");
		return;
	end
	self.tbBaseInfo = KItem.GetItemBaseProp(self.nItemTemplateId);
	local szNameColor = Item:GetQualityColor(self.tbBaseInfo.nQuality) or "White";
	self.pPanel:Label_SetColorByName("ItemName", szNameColor);
	self.pPanel:Label_SetText("ItemName", self.tbBaseInfo.szName);
	self.pPanel:Label_SetText("CountInfo", string.format("拥有%s件", pItem and pItem.nCount or 0));
	self.ItemShowGird:SetItemByTemplate(self.nItemTemplateId);
	self.ItemShowGird.fnClick = nil;

	local szTips = Item:GetClass("RandomItemByTimeFrame"):GetIntrol(self.nItemTemplateId);
	szTips = string.gsub(szTips, "\\n", "\n");
	self.pPanel:Label_SetText("Tips", szTips);
	local tbItemInfo = {{self.nItemTemplateId}};
	for i = 1, 2 do
		local nKeyItemId = KItem.GetItemExtParam(self.nItemTemplateId, i + 1);
		local nDstItemId = KItem.GetItemExtParam(nKeyItemId, 2);
		table.insert(tbItemInfo, {nDstItemId, nKeyItemId});
	end

	local fnSetItem = function (itemObj, index)
		local nDstItemId, nKeyItemId = unpack(tbItemInfo[index]);
		itemObj.Item:SetItemByTemplate(nDstItemId);
		itemObj.Item.fnClick = function ()
			Ui:OpenWindowAtPos("ItemTips", -392, -10, "Item", nil, nDstItemId);
		end

		local szItemName = nKeyItemId and "Name2" or "Name1";
		local tbBaseInfo = KItem.GetItemBaseProp(nDstItemId);
		local szNameColor = Item:GetQualityColor(tbBaseInfo.nQuality) or "White";
		itemObj.pPanel:Label_SetColorByName(szItemName, szNameColor);
		itemObj.pPanel:Label_SetText(szItemName, tbBaseInfo.szName);

		itemObj.pPanel:SetActive("Name1", szItemName == "Name1");
		itemObj.pPanel:SetActive("Name2", szItemName == "Name2");

		itemObj.pPanel:SetActive("Consume", nKeyItemId and true or false);
		if nKeyItemId then
			local tbBaseInfo = KItem.GetItemBaseProp(nKeyItemId);
			local _, _, _, _, szItemNameColor = Item:GetQualityColor(tbBaseInfo.nQuality);
			local szItemName = Item:GetItemTemplateShowInfo(nKeyItemId);
			local nKeyCount = me.GetItemCountInBags(nKeyItemId);
			local szColor = (nKeyCount == 0 and "[FF0000]" or "[FFFFFF]");

			itemObj.Consume:SetLinkText(string.format('消耗[%s][url=openwndatpos:%s, ItemTips, -392, -10, "Item", nil, %s][-](%s%s[-]/1)', szItemNameColor, szItemName, nKeyItemId, szColor, nKeyCount));
		end

		itemObj.Btn.pPanel:Label_SetText("BtnTxt", tbUi.tbBtnInfo[index]);
		itemObj.Btn.pPanel.OnTouchEvent = function ()
			self:OnClick(nDstItemId, nKeyItemId);
		end
	end

	self.ScrollView:Update(tbItemInfo, fnSetItem);
end

function tbUi:OnClick(nDstItemId, nKeyItemId)
	if not nKeyItemId then
		me.MsgBox("少侠是否确认直接使用[11adf6]古旧阵法残卷[-]？（[11adf6]古旧阵法残卷[-]可修复为更高级的[aa62fc]精致阵法古籍[-]或[ff8f06]传世阵法古籍[-]，从而获得更稀有的奖励）", 
			{
				{"确认", function () RemoteServer.UseItem(self.nItemId); end},
				{"取消"},
			}, "UseZhenFaBoxTips");
		return;
	end

	local nCount, tbItem = me.GetItemCountInBags(nKeyItemId);
	if nCount <= 0 then
		local szItemName = Item:GetItemTemplateShowInfo(nKeyItemId);
		me.CenterMsg(string.format("%s数量不足！", szItemName));
		local bRet = Shop:AutoChooseItem(nKeyItemId);
		if bRet then
			Ui:CloseWindow(self.UI_NAME);
		end
		return;
	end

	RemoteServer.UseItem(tbItem[1].dwId);
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnSyncItem(nItemId, bUpdateAll)
	self:Update();
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_ITEM,				self.OnSyncItem},
		{ UiNotify.emNOTIFY_DEL_ITEM,				self.OnSyncItem},
	};

	return tbRegEvent;
end