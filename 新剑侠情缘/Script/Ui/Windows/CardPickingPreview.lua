local tbUi = Ui:CreateClass("CardPreview");

tbUi.bFirstOpenPreview = true
tbUi.tbCardInfo = tbUi.tbCardInfo or {};
tbUi.tbCurPartnerList = tbUi.tbCurPartnerList or {};

local COUNT_PRE_ROW = 6;
local tbGoldCardShow = {[1] = true,[2] = true,[3] = true,[4] = true};
local tbCoinCardShow = {[4] = true,[5] = true,};

function tbUi:OnOpen(pickerType)
	self.tbAllPartnerBaseInfo = Partner:GetAllPartnerBaseInfo() or {};
	self:InitCardInfo(pickerType);
	self:InitCardBaseUI(pickerType);
	self:Update(pickerType);
end

function tbUi:InitCardBaseUI(pickerType)
	local sztitle = "";
	if pickerType == "Gold" then
		sztitle = "元宝招募预览";
	elseif pickerType == "Coin" then
		sztitle = "银两招募预览";
	end
	self.pPanel:Label_SetText("Title", sztitle);
end

function tbUi:InitCardInfo(pickerType)
	local function fnCheckShow(tbItem)
		if pickerType == "Gold" then
			return tbGoldCardShow[tbItem.nQualityLevel];
		elseif pickerType == "Coin" then
			return tbCoinCardShow[tbItem.nQualityLevel];
		end
	end

	local tbItems = CardPicker:GetCardPickItems(me, pickerType, fnCheckShow);
	table.sort(tbItems, function (a, b)
		return a.nQualityLevel < b.nQualityLevel;
	end)

	-- 特殊处理，插入当前特殊卡
	if pickerType == "Gold" then
		local bHasSPSPartner = false;
		for nIdx, tbItem in ipairs(tbItems) do
			if tbItem.szItemType == CardPicker.Def.tbSpecialTenGoldSPartner.szItemType 
				and tbItem.nItemId == CardPicker.Def.tbSpecialTenGoldSPartner.nItemId
				then
				table.remove(tbItems, nIdx);
				break;
			end
		end

		table.insert(tbItems, 1, CardPicker:GetCurSpecialPartner());
	end

	self.tbCardInfo = tbItems;
	self.tbCurPartnerList = self:UpdateCurPartnerList();
end

function tbUi:UpdateCurPartnerList()
	local partnerList = {};
	for i,tbInfo in ipairs(self.tbCardInfo) do
		partnerList[i] = tbInfo.nItemId;
	end
	return partnerList;
end

function tbUi:Update()
	local fnSetItem = function(itemObj, nIdx)
		local nCur = (nIdx - 1) * COUNT_PRE_ROW + 1;
		local nStep = nCur + COUNT_PRE_ROW - 1;
		local tbRowList = self:UpdateRowInfo(nCur,nStep);
		self:SetItem(itemObj, nIdx, tbRowList);
	end

	local nRow = math.ceil(#self.tbCardInfo / COUNT_PRE_ROW);
	if tbUi.bFirstOpenPreview then 				-- 第一次打开的时候用ScrollViewGoTop
		tbUi.bFirstOpenPreview = nil				-- 会有一个自动跑到底部bug,暂时这样解决
	else
		self.Companionpreviewlist.pPanel:ScrollViewGoTop();
	end
	self.Companionpreviewlist:Update(nRow, fnSetItem);
end

function tbUi:UpdateRowInfo(nCur,nStep)
	local tbRowList = {};
	for i = nCur,nStep do
		if self.tbCardInfo[i] then
			table.insert(tbRowList,self.tbCardInfo[i]);
		end
	end
	return tbRowList;
end

function tbUi:SetItem(itemObj, index, tbRowList)
	local function fnSetCurPartner(itemObj)
		Ui:OpenWindow("PartnerDetail", nil, nil, nil, itemObj.nPartnerId, self.tbCurPartnerList);
	end
	for i,tbInfo in ipairs(tbRowList) do
		if tbInfo then
			local nPartnerId = tbInfo.nItemId;
			itemObj["PartnerHead" .. i]:SetPartnerById(nPartnerId);
			itemObj["PartnerHead" .. i].pPanel:SetActive("GrowthLevel",false);
			itemObj.pPanel:SetActive("P" .. i, true);
			local tbBaseInfo = self.tbAllPartnerBaseInfo[nPartnerId] or {};
			itemObj.pPanel:Label_SetText("Name" .. i, tbBaseInfo.szName or "");
			local nHasPartner = me.GetUserValue(Partner.PARTNER_HAS_GROUP, nPartnerId);
			itemObj.pPanel:SetActive("HasPartner" .. i, nHasPartner == 1);
			itemObj["BtnClick" .. i].nPartnerId = nPartnerId;
			itemObj["BtnClick" .. i].pPanel.OnTouchEvent = fnSetCurPartner;
		end
	end
	self:CheckObj(itemObj,tbRowList);
end

function tbUi:CheckObj(itemObj,tbRowList)
	local rowNum = #tbRowList;
	if rowNum < COUNT_PRE_ROW then
		rowNum = rowNum + 1;
		for i = rowNum,COUNT_PRE_ROW do
			itemObj.pPanel:SetActive("P" .. i, false);
		end
	end
end

tbUi.tbOnClick =
{
	BtnClose = function (self)
		Ui:CloseWindow("CardPreview");
	end
}

function tbUi:Refresh()
	self.tbCurPartnerList = self:UpdateCurPartnerList();
	self:Update()
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_PARTNER_ADD,		self.Refresh},
    };

    return tbRegEvent;
end
