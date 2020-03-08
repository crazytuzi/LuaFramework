
local tbUi = Ui:CreateClass("CloakAppraisalPanel");

function tbUi:OnOpen( nItemId )
	self.nItemId = nItemId;
	self.nTemplateId = nTemplateId
	self.nCurPutItemCount = 0;
	self.pPanel:SetActive("BtnShop", false)
	self:Update()
end

function tbUi:Update( )
	local pItem = me.GetItemInBag(self.nItemId)
	if not pItem then
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	self.nTemplateId = pItem.dwTemplateId
	self.Details_Item:SetItem(self.nItemId, {}, me.nFaction, me.nSex)
	local szName, _, _, nQuality = Item:GetItemTemplateShowInfo(self.nTemplateId, me.nFaction, me.nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";
    
	self.pPanel:Label_SetText("TxtTitle", szName)
	self.pPanel:Label_SetColorByName("TxtTitle", szNameColor);

	local nIdentiyCost = Item.tbPiFeng:GetIdentifyCost(self.nTemplateId)
	local szMoneyName = Shop:GetMoneyName(Item.tbPiFeng.szIndentiyfyMoneyType)
	local szMoneyDesc;
	if me.GetMoney(Item.tbPiFeng.szIndentiyfyMoneyType) < nIdentiyCost then
		szMoneyDesc = string.format("%s[ff0000]%d[-]", szMoneyName, nIdentiyCost )
	else
		szMoneyDesc = string.format("%s%d", szMoneyName, nIdentiyCost )
	end
	self.pPanel:Label_SetText("ConsumeTxt1", szMoneyDesc)
	self.pPanel:SetActive("ConsumeTxt2", false)

	local tbItemBase = KItem.GetItemBaseProp(self.nTemplateId)
	self.pPanel:Label_SetText("ClassTxt", string.format("%d阶", tbItemBase.nLevel))

	local tbProb = Item.tbPiFeng:GetShowAttriCountRate( tbItemBase.nLevel, self.nCurPutItemCount )
	
	local nTotal = 0;
	for i,v in ipairs(tbProb) do
		nTotal = nTotal + v;
	end
	local nShowCount = 0
	for i,v in ipairs(tbProb) do
		if v > 0 then
			local nRate = math.floor(v / nTotal * 100)
			nShowCount = nShowCount + 1;
			self.pPanel:Label_SetText("ProbabilityTxt" .. nShowCount, string.format("%s条属性%d%%", Lib:Transfer4LenDigit2CnNum(i), nRate))
			local szColor = Item:GetQualityColor(i)
			self.pPanel:Label_SetColorByName("ProbabilityTxt" .. nShowCount,szColor)
		end
	end
	
	for i=nShowCount + 1,5 do
		self.pPanel:Label_SetText("ProbabilityTxt" .. i, "")
	end
	self.pPanel:Label_SetText("TxtConsume2", tostring(self.nCurPutItemCount))
	local tbMaxProbSetting = Item.tbPiFeng:GetAttriCountMaxRate(tbItemBase.nLevel)
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
	self.pPanel:Label_SetText("ItemName2 (2)", string.format("[FFFE0D]放入%d个入微镜可%d%%获得%s条属性[-]", tbMaxProbSetting.nCostItemCount, math.floor(nMaxRate / nTotal * 100), nMaxAttriCount))
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_ITEM,   self.Update},
		{ UiNotify.emNOTIFY_DEL_ITEM,    self.Update},
	};
	return tbRegEvent;
end
tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)                                     
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnMinus = function ( self )
	if self.nCurPutItemCount == 0 then
		me.CenterMsg("不能再减少了")
		return
	end
	self.nCurPutItemCount = self.nCurPutItemCount - 5
	self:Update()
end

tbUi.tbOnClick.BtnAdd = function ( self )
	local tbItemBase = KItem.GetItemBaseProp(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID)
	local pItem = me.GetItemInBag(self.nItemId)
	local tbMaxProbSetting = Item.tbPiFeng:GetAttriCountMaxRate(pItem.nLevel)
	if self.nCurPutItemCount >= tbMaxProbSetting.nCostItemCount then
		me.CenterMsg(string.format("您已放入足够多的%s", tbItemBase.szName) )
		return
	end
	local nCurPutItemCount = self.nCurPutItemCount + 5
	local nHaveCount = me.GetItemCountInBags(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID)
	if nCurPutItemCount > nHaveCount then
		me.CenterMsg(string.format("您已没有那么多的%s", tbItemBase.szName) )
		return
	end
	
	self.nCurPutItemCount = nCurPutItemCount
	self:Update()
end

tbUi.tbOnClick.BtnAppraisal = function ( self )
	RemoteServer.PiFengReq("Unidentify", self.nItemId, self.nCurPutItemCount)
end