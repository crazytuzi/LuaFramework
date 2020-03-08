
local tbUi = Ui:CreateClass("CloakUpgradePanel");

function tbUi:OnOpen( nItemId )
	self.nItemId = nItemId;
	self.pPanel:SetActive("NewTxt", false)
	self.pPanel:SetActive("NewBg", false)
	self:Update()
end

function tbUi:Update( )
	local pItem = me.GetItemInBag(self.nItemId)
	if not pItem then
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	self.nTemplateId = pItem.dwTemplateId
	local nEquipLevel = pItem.nLevel
	self.itemframe1:SetItem(self.nItemId)
	local nTarTemplateId = Item.GoldEquip:GetCosumeItemToTarItem(self.nTemplateId)
	local tbItemBaseTar = KItem.GetItemBaseProp(nTarTemplateId)
	local nTarLevel = tbItemBaseTar.nLevel

	self.itemframe2:SetItemByTemplate(nTarTemplateId)
	local szName, _, _, nQuality = Item:GetItemTemplateShowInfo(self.nTemplateId, me.nFaction, me.nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";
	self.pPanel:Label_SetText("TxtTitle1", szName)
	self.pPanel:Label_SetColorByName("TxtTitle1", szNameColor);

	local szName, _, _, nQuality = Item:GetItemTemplateShowInfo(nTarTemplateId, me.nFaction, me.nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";
	self.pPanel:Label_SetText("TxtTitle2", szName)
	self.pPanel:Label_SetColorByName("TxtTitle2", szNameColor);
	
	self.pPanel:Label_SetText("ClassTxt1", string.format("%d阶", nEquipLevel))
	self.pPanel:Label_SetText("ClassTxt2", string.format("%d阶", nTarLevel))

	local tbAttribs = Item.tbPiFeng:GetRandomAttrib(pItem)
	local nMaxAtrriCountOrg = Item.tbPiFeng:GetMaxAtrriCountByLevel(nEquipLevel)
	local nMaxAtrriCountTar = Item.tbPiFeng:GetMaxAtrriCountByLevel(nTarLevel)
	local nAddAttriCount = nMaxAtrriCountTar - nMaxAtrriCountOrg;
	for i=1, Item.tbPiFeng.MAX_ATTRI_COUNT do
		local tbAttrib = tbAttribs[i]
		if tbAttrib then
			self.pPanel:SetActive("Attribute" .. 1 .. i, true)
			self.pPanel:SetActive("Attribute" .. 2 .. i, true)
			local tbMA = tbAttrib.tbValues
			
			local szDesc = FightSkill:GetMagicDesc(tbAttrib.szAttrib, tbMA);
			
			for j=1,2 do
				self.pPanel:Label_SetText("Attribute" .. j .. i, szDesc);	
				
			end
			local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel);
			local szColor = Item:GetQualityColor(nQuality)
			self.pPanel:Label_SetGradientColor("Attribute1" .. i, szColor);
			local nQuality = Item.tbRefinement:GetAttribColor(nTarLevel, tbAttrib.nAttribLevel);
			local szColor = Item:GetQualityColor(nQuality)
			self.pPanel:Label_SetGradientColor("Attribute2" .. i, szColor);

		else
			self.pPanel:SetActive("Attribute" .. 1 .. i, false)
			self.pPanel:SetActive("Attribute" .. 2 .. i, false)
		end
	end
	for i=#tbAttribs + 1, #tbAttribs + nAddAttriCount do
		self.pPanel:SetActive("Attribute2" .. i, true)
		self.pPanel:Label_SetText("Attribute2" ..  i, "? ? ? ? ?");	
		self.pPanel:Label_SetGradientColor("Attribute2" .. i, "White");

	end

	local tbConsumItems = Item.GoldEquip:GetEvolutionConsumeSetting(me, pItem)
	local nCostItemId,nCostItemCount = unpack(tbConsumItems[1]);
	local nCurHaveNum = me.GetItemCountInBags(nCostItemId);
	self.PropItem:SetItemByTemplate(nCostItemId, string.format("%d/%d", nCostItemCount, nCurHaveNum))
	local szName, _, _, nQuality = Item:GetItemTemplateShowInfo(nCostItemId, me.nFaction, me.nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";
    self.pPanel:Label_SetText("PropTxt", szName)
    self.pPanel:Label_SetGradientColor("PropTxt", szNameColor);
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)                                     
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnUpgrade = function (self)                                     
	Item.tbPiFeng:ClientDoEvolution(self.nItemId)
end

