
local tbUi = Ui:CreateClass("JuanZhouPanel");

function tbUi:OnOpen(nTemplateId, nItemId)
	self.tbJuanZhouItem = self.tbJuanZhouItem or Item:GetClass("JuanZhou");
	self.tbSetting = self.tbJuanZhouItem:GetSetting(nTemplateId);
	if not self.tbSetting then
		me.CenterMsg("异常道具！");
		return 0;
	end

	self.nTemplateId = nTemplateId;
	self.nItemId = nItemId;

	self:Update();
end

function tbUi:Update()
	local tbBaseInfo = KItem.GetItemBaseProp(self.nTemplateId);
	local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(self.nTemplateId, me.nFaction, me.nSex);
	local szNameColor = Item:GetQualityColor(nQuality) or "White";

	self.pPanel:Label_SetText("TxtTitle", tbBaseInfo.szName);
	self.pPanel:Label_SetColorByName("TxtTitle", szNameColor);

	self.pPanel:Label_SetText("TxtIntro", tbBaseInfo.szIntro);

	local nItemCount = nil;
	if not self.nItemId or self.nItemId > 0 then
		nItemCount = me.GetItemCountInBags(self.nTemplateId)
	end
	self.itemframe:SetItemByTemplate(self.nTemplateId, nItemCount);

	for i = 1, 6 do
		local itemGrid = self["itemframe" .. i];
		if itemGrid then
			local tbAward = self.tbSetting.tbAward[i];
			if tbAward then
				itemGrid:SetGenericItem(tbAward);
				itemGrid.fnClick = itemGrid.DefaultClick;
			end

			itemGrid.pPanel:SetActive("Main", tbAward and true or false);
		end
	end

	local tbFinishList = {};
	local tbUnFinishList = {};

	for idx, tbMoney in ipairs(self.tbSetting.tbNeedMoney) do
		if me.GetMoney(tbMoney[1]) < tbMoney[2] then
			table.insert(tbUnFinishList, tbMoney);
		else
			table.insert(tbFinishList, tbMoney);
		end
	end

	for idx, tbInfo in ipairs(self.tbSetting.tbNeedItem) do
		local nCount, tbItem = me.GetItemCountInBags(tbInfo[1]);
		for _, pItem in ipairs(tbItem) do
			if pItem.szClass == "SkillBook" and not Item:GetClass("SkillBook"):CheckCanSell(pItem) then
				nCount = nCount - pItem.nCount;
			end
		end

		if nCount < tbInfo[2] then
			table.insert(tbUnFinishList, {"item", tbInfo[1], tbInfo[2]});
		else
			table.insert(tbFinishList, {"item", tbInfo[1], tbInfo[2]});
		end
	end

	local function fnSetItem(ItemObj, index)
		local tbInfo;
		if self.tbSetting.nNeedCount <= 0 then
			tbInfo = tbUnFinishList[index];
			if not tbInfo then
				tbInfo = tbFinishList[index - #tbUnFinishList];
			end
		else
			tbInfo = tbFinishList[index];
		end

		if tbInfo[1] == "item" then
			ItemObj.itemframe:SetItemByTemplate(tbInfo[2]);
		else
			ItemObj.itemframe:SetDigitalItem(tbInfo[1]);
		end

		ItemObj.itemframe.fnClick = ItemObj.itemframe.DefaultClick;

		local szName, nIcon, nView, nQuality, szNameColor, szTip;
		local nTotalNeedCount, nHaveCount, nNeedItemId;
		if tbInfo[1] == "item" then
			szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(tbInfo[2], me.nFaction, me.nSex);

			local nCount, tbItem = me.GetItemCountInBags(tbInfo[2]);
			for _, pItem in ipairs(tbItem) do
				if pItem.szClass == "SkillBook" and not Item:GetClass("SkillBook"):CheckCanSell(pItem) then
					nCount = nCount - pItem.nCount;
				end
			end
			szTip = nCount >= tbInfo[3] and "[64db00]%s/%s[-]" or "%s/%s";
			szTip = string.format(szTip, nCount, tbInfo[3]);

			if nCount < tbInfo[3] and nItemCount and nItemCount > 0 then
				nTotalNeedCount, nHaveCount, nNeedItemId = StoneMgr:GetCombineShowInfo(me, tbInfo[2]);
			end
		else
			szName = Shop:GetMoneyName(tbInfo[1]);
			nQuality = 0; --Item:GetDigitalItemQuality(tbInfo[1], tbInfo[2]) or 0;  --策划说不要颜色

			local nCount = me.GetMoney(tbInfo[1]);
			szTip = nCount >= tbInfo[2] and "[64db00]%s/%s[-]" or "%s/%s";
			szTip = string.format(szTip, nCount, tbInfo[2]);
		end

		szNameColor = Item:GetQualityColor(nQuality) or "White";
		ItemObj.pPanel:Label_SetColorByName("ItemName", szNameColor);

		ItemObj.pPanel:Label_SetText("ItemName", szName);
		ItemObj.pPanel:Label_SetText("Number", szTip);

		ItemObj.pPanel:ChangePosition("ItemName", -130, nTotalNeedCount and 25 or 11, 0);
		ItemObj.pPanel:ChangePosition("Number", 177, nTotalNeedCount and 25 or 11, 0);

		ItemObj.pPanel:SetActive("ComposeTxt", nTotalNeedCount and true or false);
		ItemObj.pPanel:SetActive("BtnCompose", nTotalNeedCount and true or false);

		if nTotalNeedCount then
			local szNeedName = Item:GetItemTemplateShowInfo(nNeedItemId);
			local szColor = nHaveCount >= nTotalNeedCount and "[00FF00]" or "[FFFFFF]";
			ItemObj.pPanel:Label_SetText("ComposeTxt", string.format("%s%s/%s个%s[-]", szColor, nHaveCount, nTotalNeedCount, szNeedName));
			ItemObj.BtnCompose.pPanel.OnTouchEvent = function ()
				local szDstName = Item:GetItemTemplateShowInfo(tbInfo[2]);
				local tbTotalNeedStone, nTotalCost = StoneMgr:GetCombineStoneNeed(tbInfo[2], 1, me);
				if tbTotalNeedStone then
					me.MsgBox(string.format("确定合成[FFFE0D]%s[-]吗？花费[FFFE0D]%s银两[-]。", szDstName, nTotalCost),
					{
						{"确定", function () RemoteServer.DoQuickCombineStone(tbInfo[2]); end},
						{"取消"},
					});
				else
					me.CenterMsg("魂石数量不足，无法合成");
				end
			end
		end
	end

	self.ScrollView.pPanel:SetActive("Main", self.tbSetting.nNeedCount <= 0);
	self.pPanel:SetActive("Tips", self.tbSetting.nNeedCount > 0);

	if self.tbSetting.nNeedCount > 0 then
		local szTip = #tbFinishList >= self.tbSetting.nNeedCount and "[64db00]%s/%s[-]" or "%s/%s";

		self.pPanel:Label_SetText("Info", string.format(szTip, #tbFinishList, self.tbSetting.nNeedCount));
		self.pPanel:Label_SetText("ShowTip", self.tbSetting.szTips or "nil");
		--self.pPanel:Label_SetColorByName("ShowTip", szNameColor);

		self.pPanel:Button_SetText("BtnComplete", "选择物品");
	else
		self.ScrollView:Update(#tbFinishList + #tbUnFinishList, fnSetItem);
		self.pPanel:Button_SetText("BtnComplete", "完成任务");
	end
	self.pPanel:SetActive("BtnComplete", (self.nItemId and self.nItemId > 0) and true or false);
	self.pPanel:SetActive("BtnSell", (self.nItemId and self.nItemId > 0) and true or false);
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.Update },
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.Update },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnComplete = function (self)
	local pItem = me.GetItemInBag(self.nItemId);
	if not pItem then
		me.CenterMsg("异常道具");
		return;
	end

	if self.tbSetting.nNeedCount <= 0 then
		local bRet, szMsg = self.tbJuanZhouItem:CheckCanCommit(pItem);
		if not bRet then
			me.CenterMsg(szMsg);
			return;
		end
		RemoteServer.UseJuanZhouItem(self.nItemId);
	else
		local function fnGetItemList()
			local tbItemList = {};
			for nItemId in pairs(self.tbSetting.tbAllowInfo) do
				local nCount, tbItem = me.GetItemCountInBags(nItemId);
				if tbItem[1] and tbItem[1].szClass == "SkillBook" then
					for i = #tbItem, 1, -1 do
						local pSkillBook = tbItem[i];
						if not Item:GetClass("SkillBook"):CheckCanSell(pSkillBook) then
							nCount = nCount - pSkillBook.nCount;
							table.remove(tbItem, i);
						end
					end
				end

				if nCount > 0 then
					tbItemList[nItemId] = tbItem;
				end
			end
			return tbItemList;
		end

		local function fnCheckCanAdd(tbSelect, tbItem)
			local nCount = 0;
			local nTotalCount = 0;
			for _, tbInfo in pairs(tbSelect) do
				if tbInfo.dwTemplateId == tbItem.dwTemplateId then
					nCount = nCount + tbInfo.nCount;
				end
				nTotalCount = nTotalCount + tbInfo.nCount;
			end

			if self.tbSetting.nNeedCount > 0 then
				if nTotalCount >= self.tbSetting.nNeedCount then
					return false;
				end
			end

			local nAllow = self.tbSetting.tbAllowInfo[tbItem.dwTemplateId] or 0;
			return nCount < nAllow and true or false;
		end

		local function fnConfirm(tbSelect)
			local bRet, szMsg = self.tbJuanZhouItem:CheckCanCommit(pItem, tbSelect);
			if not bRet then
				me.CenterMsg(szMsg);
				return;
			end
			RemoteServer.UseJuanZhouItem(self.nItemId, tbSelect);
			return true;
		end

		local tbParam = {
			szTitle = pItem.szName;
			szTipsLeft = "已放入的物品";
			szTipsRight = "选择" .. (self.tbSetting.szTips or "需求物品");
			szBtn = "完成任务";
			fnGetItemList = fnGetItemList;
			fnCheckCanAdd = fnCheckCanAdd;
			fnConfirm = fnConfirm;
		}
		Ui:OpenWindow("ExchangePanel", "", tbParam);
	end
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnSell = function (self)
	Ui:CloseWindow(self.UI_NAME);
	Shop:ConfirmSell(self.nItemId);
end