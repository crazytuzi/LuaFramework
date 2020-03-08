
local tbUi = Ui:CreateClass("CloakAttributeRandomPanel");

function tbUi:OnOpen( nItemId , nAddAttNumCostNum)
	self.pPanel:SetActive("BtnClose", false)
	self.nItemId = nItemId;
	--	有传用传的，没传用原来的或0
	if nAddAttNumCostNum  then
		self.nAddAttNumCostNum = nAddAttNumCostNum
	else
		if not self.nAddAttNumCostNum then
			self.nAddAttNumCostNum = 0
		end
	end
	self.pPanel:SetActive("effect", false)
	
	self:Update()
end

function tbUi:Update( )
	local pItem = me.GetItemInBag(self.nItemId)
	if not pItem then
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	local nEquipLevel = pItem.nLevel
	local nCostItemNum = Item.tbPiFeng.tbRAND_ATTRI_TYPE_ITEM_NUM[nEquipLevel]
	local nHaveCostItemCount = me.GetItemCountInBags(Item.tbPiFeng.RAND_ATTRI_TYPE_COST_ID)
	
	self.PropItem:SetItemByTemplate(Item.tbPiFeng.RAND_ATTRI_TYPE_COST_ID, string.format("%d/%d", nCostItemNum , nHaveCostItemCount)  )
	if nCostItemNum <= nHaveCostItemCount then
		self.PropItem.pPanel:Label_SetColorByName("LabelSuffix", "White")
	else
		self.PropItem.pPanel:Label_SetColorByName("LabelSuffix", "Red")
	end

	self.PropItem.fnClick = self.PropItem.DefaultClick
	local szItemName, _, _, nQuality = Item:GetItemTemplateShowInfo(Item.tbPiFeng.RAND_ATTRI_TYPE_COST_ID, me.nFaction, me.nSex)
	local szNameColor = Item:GetQualityColor(nQuality) or "White";
	self.pPanel:Label_SetColorByName("PropTxt", szNameColor);
	self.pPanel:Label_SetText("PropTxt", szItemName)

	self.Itemframe1:SetItem(self.nItemId)
	self.Itemframe2:SetItem(self.nItemId)
	local szItemName, _, _, nQuality = Item:GetItemTemplateShowInfo(pItem.dwTemplateId, me.nFaction, me.nSex)
	self.pPanel:Label_SetText("TxtTitle1", szItemName)
	self.pPanel:Label_SetText("TxtTitle2", szItemName)
	local szNameColor = Item:GetQualityColor(nQuality) or "White";
	self.pPanel:Label_SetColorByName("TxtTitle1", szNameColor);
	self.pPanel:Label_SetColorByName("TxtTitle2", szNameColor);

	
	self.pPanel:Label_SetText("ClassTxt1", string.format("%d阶披风",nEquipLevel) )
	self.pPanel:Label_SetText("ClassTxt2", string.format("%d阶披风",nEquipLevel))

	local tbAttribs = Item.tbPiFeng:GetRandomAttrib(pItem)
	local tbNewAttribs = Item.tbPiFeng:GetRandomAttribTempIds(pItem)

	self.pPanel:SetActive("PiFengDiBan", #tbNewAttribs == 0);
	self.Itemframe2.pPanel:SetActive("Main",#tbNewAttribs ~= 0)
	self.pPanel:SetActive("BtnAfter", #tbNewAttribs ~= 0)

	local nMaxAttriCount = Item.tbPiFeng:GetMaxAtrriCountByLevel(nEquipLevel)
	if #tbAttribs >= nMaxAttriCount then
		self.nAddAttNumCostNum = 0;
		self.pPanel:SetActive("RuweijingGroup", false)
	else
		local nHaveCostItemCount2 = me.GetItemCountInBags(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID);
		self.pPanel:SetActive("RuweijingGroup", true)
		self.PropItem2:SetItemByTemplate(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID, string.format("%d/%d", self.nAddAttNumCostNum , nHaveCostItemCount2)  )
		if self.nAddAttNumCostNum <= nHaveCostItemCount2 then
			self.PropItem2.pPanel:Label_SetColorByName("LabelSuffix", "White")
		else
			self.PropItem2.pPanel:Label_SetColorByName("LabelSuffix", "Red")
		end
		
		self.PropItem2.fnClick = self.PropItem2.DefaultClick

		local szItemName2, _, _, nQuality2 = Item:GetItemTemplateShowInfo(Item.tbPiFeng.ADD_ATTRI_COUNT_ITEM_ID, me.nFaction, me.nSex)
		self.pPanel:Label_SetText("PropTxt2", szItemName2)
		local szNameColor2 = Item:GetQualityColor(nQuality2) or "White";
		self.pPanel:Label_SetColorByName("PropTxt2", szNameColor2);
	end

	for i=1, Item.tbPiFeng.MAX_ATTRI_COUNT do
		local tbVals = {tbAttribs[i], tbNewAttribs[i]};
		for j=1,2 do
			local tbAttrib = tbVals[j]
			if tbAttrib then
				self.pPanel:SetActive("Attribute" .. j .. i, true)		
				local tbMA = tbAttrib.tbValues
				local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel);
				local szDesc = FightSkill:GetMagicDesc(tbAttrib.szAttrib, tbMA);
				self.pPanel:Label_SetText("Attribute" .. j .. i, szDesc);
				local szColor = Item:GetQualityColor(nQuality)
				self.pPanel:Label_SetGradientColor("Attribute" .. j .. i, szColor);
			else
				self.pPanel:SetActive("Attribute" .. j .. i, false)		
			end
		end
	end
	
end

function tbUi:OnSyncData( szData, nItemId , nAddAttNumCostNum)
	if self.nItemId ~= nItemId then
		return
	end
	if szData == "ReRandomAttriTypes" or szData == "UpdateAddAttNumCostNum" then
		if nAddAttNumCostNum then
			self.nAddAttNumCostNum = nAddAttNumCostNum
		end
		self:Update()
		if szData == "ReRandomAttriTypes" then
			self.pPanel:SetActive("effect", false)
			self.pPanel:SetActive("effect", true)
		end
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_PI_FENG_SYNC_DATA,   self.OnSyncData},
	};
	return tbRegEvent;
end
tbUi.tbOnClick = {}

-- tbUi.tbOnClick.BtnClose = function (self)                                     
-- 	Ui:CloseWindow(self.UI_NAME)
-- end

tbUi.tbOnClick.BtnRandom = function ( self )
	Item.tbPiFeng:ClientReRandomAttriTypes(self.nItemId, true, self.nAddAttNumCostNum)
end

tbUi.tbOnClick.BtnFront = function ( self )
	Item.tbPiFeng:ClientReRandomATChooseOld(self.nItemId)
end

tbUi.tbOnClick.BtnAdjustment = function ( self )
	Ui:OpenWindow("CloakRandomPanel", self.nItemId, true)
end

tbUi.tbOnClick.BtnAfter = function ( self )
	Item.tbPiFeng:ClientReRandomATChooseNew(self.nItemId)
end

