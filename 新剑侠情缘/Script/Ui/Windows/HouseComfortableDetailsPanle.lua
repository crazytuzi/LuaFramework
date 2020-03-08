
local tbUi = Ui:CreateClass("HouseComfortableDetailsPanle");

function tbUi:OnOpen(szType, tbShowInfo, nValidCount, fnOnClose)
	self:Update(szType, tbShowInfo, nValidCount);
	self.fnOnClose = fnOnClose;
end

function tbUi:Update(szType, tbShowInfo, nValidCount)
	self.pPanel:Label_SetText("Title", string.format("[FFFE0D]%s[-][9BFFE9FF]当前增加舒适度数量[-]", szType));

	local tbTypeInfo = {};
	for _, tbInfo in pairs(tbShowInfo or {}) do
		local tbFurniture = House:GetFurnitureInfo(tbInfo[1]);
		local nLevel = tbFurniture.nLevel
		tbTypeInfo[nLevel] = tbTypeInfo[nLevel] or {nCount = 0, nTotalComfortValue = 0};
		tbTypeInfo[nLevel].nCount = tbTypeInfo[nLevel].nCount + 1;
		tbTypeInfo[nLevel].nTotalComfortValue = tbTypeInfo[nLevel].nTotalComfortValue + tbFurniture.nComfortValue;
	end

	local tbShow = {};
	for nLevel, tbInfo in pairs(tbTypeInfo) do
		table.insert(tbShow, {nLevel = nLevel, nCount = tbInfo.nCount, nTotalComfortValue = tbInfo.nTotalComfortValue});
	end

	table.sort(tbShow, function (a, b)
		return a.nLevel > b.nLevel;
	end)

	local nTotal = 0
	local nOverflowIndex = 0
	local nOverflowCount = 0
	for i, tb in ipairs(tbShow) do
		if nOverflowIndex > 0 then
			tb.nTotalComfortValue = 0
		else
			if nTotal + tb.nCount > nValidCount then
				nOverflowIndex = i
				local nValid = nValidCount - nTotal
				if nValid > 0 then
					nOverflowCount = tb.nCount - nValid
					tb.nTotalComfortValue = math.floor(tb.nTotalComfortValue / tb.nCount) * nValid
					tb.nCount = nValid
				else
					tb.nTotalComfortValue = 0
				end
			else
				nTotal = nTotal + tb.nCount
			end
		end
	end
	if nOverflowIndex > 0 and nOverflowCount > 0 then
		local tbOverflow = Lib:CopyTB(tbShow[nOverflowIndex])
		tbOverflow.nCount = nOverflowCount
		tbOverflow.nTotalComfortValue = 0
		table.insert(tbShow, nOverflowIndex + 1, tbOverflow)
	end

	local function fnSetItem(itemObj, index)
		local tbInfo = tbShow[index];
		itemObj.pPanel:Label_SetText("LabelInfo", string.format("[92D2FF]%s级家具：[-]%s个           [%s]舒适度+%s[-]",
			tbInfo.nLevel, tbInfo.nCount, tbInfo.nTotalComfortValue > 0 and "C8FF00" or "FF0000", tbInfo.nTotalComfortValue));
	end

	self.ScrollView:Update(tbShow or {}, fnSetItem);
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	if self.fnOnClose then
		self.fnOnClose();
		self.fnOnClose = nil;
	end
end