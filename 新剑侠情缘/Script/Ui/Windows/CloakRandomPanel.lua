
local tbUi = Ui:CreateClass("CloakRandomPanel");

function tbUi:OnOpen( nItemId , bReturnToUi)
	self.nItemId = nItemId;
	self.bReturnToUi = bReturnToUi;
	self.nCurPutItemCount = 0;
	self:Update()
end

function tbUi:Update( )
	local pItem = me.GetItemInBag(self.nItemId)
	if not pItem then
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	local nEquipLevel = pItem.nLevel
	local tbProb = Item.tbPiFeng:GetShowAttriCountRate( nEquipLevel, self.nCurPutItemCount )
	local tbAttribs = Item.tbPiFeng:GetRandomAttrib(pItem)
	local nCurCount = #tbAttribs;

	local nTotal = 0;
	local tbShowProb = {};
	local nShowSumRate = 0;--小于等于当前次数的会显示到对应次数的概率里
	for i,v in ipairs(tbProb) do
		if v > 0 then
			nTotal = nTotal + v;
			if i <= nCurCount then
				nShowSumRate = nShowSumRate + v;
			else
				tbShowProb[i] = v;
			end		
		end
	end
	if nShowSumRate > 0 then
		tbShowProb[nCurCount] = nShowSumRate	
	end
	
	local tbShowLines = {};
	for k,v in pairs(tbShowProb) do
		table.insert(tbShowLines, {k,v})
	end
	table.sort( tbShowLines, function ( a,b )
		return a[1] < b[1]
	end )

	for i,v in ipairs(tbShowLines) do
		local nCount,nRateVal = unpack(v);
		local nRate = math.floor(nRateVal / nTotal * 100)
		self.pPanel:Label_SetText("ProbabilityTxt" .. i, string.format("%s条属性%d%%", Lib:Transfer4LenDigit2CnNum(nCount), nRate))
		local szColor = Item:GetQualityColor(nCount)
		self.pPanel:Label_SetColorByName("ProbabilityTxt" .. i,szColor)
	end
	for i=#tbShowLines + 1,5 do
		self.pPanel:Label_SetText("ProbabilityTxt" .. i, "")
	end
	self.pPanel:Label_SetText("TxtConsume2", tostring(self.nCurPutItemCount))
	local tbMaxProbSetting = Item.tbPiFeng:GetAttriCountMaxRate(nEquipLevel)
	local tbMaxProb = tbMaxProbSetting.tbCountRand
	local nTotal = 0;
	local nMaxRate = 0;
	local nMaxAttriCount = 0
	for i,v in ipairs(tbMaxProb) do
		nTotal = nTotal + v;
		if v > 0 then
			nMaxRate = v;
			nMaxAttriCount = i;
		end
	end
	local tbItemBase2 = KItem.GetItemBaseProp(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID)
	self.pPanel:Label_SetText("ItemName2 (2)", string.format("放入%d个%s可%d%%获得%s条属性", tbMaxProbSetting.nCostItemCount, tbItemBase2.szName, math.floor(nMaxRate / nTotal * 100), nMaxAttriCount))
end

function tbUi:UpdateNumberInput(nNum)
	local nHaveCount = me.GetItemCountInBags(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID)
	local pItem = me.GetItemInBag(self.nItemId)
	local tbMaxProbSetting = Item.tbPiFeng:GetAttriCountMaxRate(pItem.nLevel)
	local nAddMax = math.min(nHaveCount, tbMaxProbSetting.nCostItemCount)
	if nNum > nAddMax then
		nNum = nAddMax
	end
	self.nCurPutItemCount = nNum;
	self:Update()
    return nNum;
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)                                     
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnMinus = function ( self )
	if self.nCurPutItemCount == 0 then
		return
	end
	self.nCurPutItemCount = self.nCurPutItemCount - 5
	self:Update()
end

tbUi.tbOnClick.BtnAdd = function ( self )
	local pItem = me.GetItemInBag(self.nItemId)
	local tbMaxProbSetting = Item.tbPiFeng:GetAttriCountMaxRate(pItem.nLevel)
	local tbItemBase = KItem.GetItemBaseProp(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID)
	if self.nCurPutItemCount >= tbMaxProbSetting.nCostItemCount then
		me.CenterMsg(string.format("您已放入足够多的%s", tbItemBase.szName) )
		return
	end

	local nCurPutItemCount = self.nCurPutItemCount + 5
	local nHaveCount = me.GetItemCountInBags(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID)
	if nCurPutItemCount > nHaveCount then
		me.CenterMsg(string.format("您已没有那么多的%s", tbItemBase.szName))
		return
	end

	self.nCurPutItemCount = nCurPutItemCount
	self:Update()
end

tbUi.tbOnClick.BtnOK = function ( self )
	if not self.bReturnToUi then
		Item.tbPiFeng:ClientReRandomAttriTypes(self.nItemId, true, self.nCurPutItemCount)
	else
		UiNotify.OnNotify(UiNotify.emNOTIFY_PI_FENG_SYNC_DATA, "UpdateAddAttNumCostNum", self.nItemId, self.nCurPutItemCount)
	end
	Ui:CloseWindow(self.UI_NAME)
end
