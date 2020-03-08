local tbUi = Ui:CreateClass("ExchangePanel");

local ITEM_PER_LINE = 4;
local MIN_LINE = 5;


function tbUi:OnOpen(szType, tbParam)
	local szTitle = "兑换"
	local szBtnText = "确定"
	local szTipsLeft = "已放入物品";
	local szTipsRight = "点击你要放入的物品";

	if not tbParam then
		local tbSetting = Exchange.tbExchangeSetting[szType];
		if not tbSetting then
			return 0;
		end

		if not Lib:IsEmptyStr(tbSetting.Title) then
			szTitle = tbSetting.Title
		end
	else
		if tbParam.szTitle and tbParam.szTitle ~= "" then
			szTitle = tbParam.szTitle;
		end

		if tbParam.szBtn and tbParam.szBtn ~= "" then
			szBtnText = tbParam.szBtn;
		end

		if tbParam.szTipsLeft and tbParam.szTipsLeft ~= "" then
			szTipsLeft = tbParam.szTipsLeft;
		end

		if tbParam.szTipsRight and tbParam.szTipsRight ~= "" then
			szTipsRight = tbParam.szTipsRight;
		end

	end

	self.tbParam = tbParam;
	self.szType = szType;
	self.pPanel:Label_SetText("Title", szTitle)
	self.pPanel:Label_SetText("TextClick", szTipsRight);
	self.pPanel:Label_SetText("TextPutIn", szTipsLeft);
	self.pPanel:Button_SetText("BtnConfirm", szBtnText);
	self:Reset()
end

function tbUi:Reset()
	local tbItem;
	if not self.tbParam then
		tbItem = Exchange:GetCanExchageItems(me, self.szType);
	else
		tbItem = self.tbParam.fnGetItemList();
	end

	local tbRightItemList = {}
	for dwTemplateId, v in pairs(tbItem) do
		for i, pItem in ipairs(v) do
			table.insert(tbRightItemList, { dwTemplateId = pItem.dwTemplateId, nItemId = pItem.dwId, nCount = pItem.nCount })
		end
	end
	self.tbRightItemList = tbRightItemList;

	self.tbLeftItemList = {};

	self:UpdateLeftAndRight()
end

function tbUi:UpdateLeftAndRight()
	self:UpdateRigtItemList()
	self:UpdateLeftItemList()
end

function tbUi:OnSelItem(tbScrItems, tbTarItems, nItemIndex)
	local tbItem = tbScrItems[nItemIndex]
	if not tbItem then
		return
	end

	local tbTemp = Lib:CopyTB(tbItem)
	tbItem.nCount = tbItem.nCount - 1
	tbTemp.nCount = 1
	local bMerged = false;
	for i,v in ipairs(tbTarItems) do
		if v.nItemId == tbTemp.nItemId then
			v.nCount = v.nCount + tbTemp.nCount;
			bMerged = true;
			break;
		end
	end
	if not bMerged then
		table.insert(tbTarItems, tbTemp)
	end
	if tbItem.nCount == 0 then
		table.remove(tbScrItems, nItemIndex)
	end

	self:UpdateLeftAndRight();
end

function tbUi:UpdateRigtItemList()
	local fnClick = function (itemObj)
		if itemObj.bCanAdd then
			self:OnSelItem(self.tbRightItemList, self.tbLeftItemList, itemObj.nItemIndex)
		end
	end

	local fnSetItem = function(tbItemGrid, index)
		local nStart = (index - 1) * ITEM_PER_LINE
		for i = 1, ITEM_PER_LINE do
			local tbItem = self.tbRightItemList[nStart + i];
			local tbGrid = tbItemGrid:GetGrid(i)
			if tbItem then
				tbGrid.bCanAdd = true; --MathRandom(10) > 5;
				if self.tbParam and self.tbParam.fnCheckCanAdd then
					tbGrid.bCanAdd = self.tbParam.fnCheckCanAdd(self.tbLeftItemList, tbItem);
				end

				tbGrid:SetItemByTemplate(tbItem.dwTemplateId, tbItem.nCount );
				tbGrid.nItemIndex = nStart + i;
				tbGrid.fnClick = fnClick;
				tbGrid.fnLongPress = tbGrid.DefaultClick;
				tbGrid.pPanel:SetActive("Main", true)

				tbGrid.pPanel:SetActive("CDLayer", not tbGrid.bCanAdd);
			else
				tbGrid.nItemIndex = nil;
				tbGrid:Clear();
				tbGrid.pPanel:SetActive("Main", false)
			end
		end
	end

	self.ScrollViewRight:Update( math.max(math.ceil(#self.tbRightItemList / ITEM_PER_LINE), MIN_LINE), fnSetItem);    -- 至少显示5行
end

function tbUi:UpdateLeftItemList()
	local fnClick = function (itemObj)
		self:OnSelItem(self.tbLeftItemList, self.tbRightItemList, itemObj.nItemIndex)
	end

    local fnSetItem = function(tbItemGrid, index)
	    local nStart = (index - 1) * ITEM_PER_LINE
	    for i = 1, ITEM_PER_LINE do
	        local tbItem = self.tbLeftItemList[nStart + i];
        	local tbGrid = tbItemGrid:GetGrid(i)
	        if tbItem then
	        	tbGrid:SetItemByTemplate(tbItem.dwTemplateId, tbItem.nCount );
	        	tbGrid.nItemIndex = nStart + i;
	        	tbGrid.fnClick = fnClick;
	        	tbGrid.fnLongPress = tbGrid.DefaultClick;
			else
				tbGrid.nItemIndex = nil;
				tbGrid:Clear();
	        end
	    end
	end

    self.ScrollViewLeft:Update( math.max(math.ceil(#self.tbLeftItemList / ITEM_PER_LINE), MIN_LINE), fnSetItem);    -- 至少显示5行
end

function tbUi:OnSyncItem()
	self:Reset();
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnConfirm()
	local tbSelItems = {}
	if not self.tbParam then
		for i,v in ipairs(self.tbLeftItemList) do
			tbSelItems[v.dwTemplateId] = (tbSelItems[v.dwTemplateId] or 0) + v.nCount
		end
		Exchange:ExchangeItems(self.szType, tbSelItems)
	else
		for i, v in ipairs(self.tbLeftItemList) do
			tbSelItems[v.nItemId] = tbSelItems[v.nItemId] or 0;
			tbSelItems[v.nItemId] = tbSelItems[v.nItemId] + v.nCount;
		end

		if self.tbParam.fnConfirm(tbSelItems) then
			Ui:CloseWindow(self.UI_NAME);
		end
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnSyncItem },

    };

    return tbRegEvent;
end
