
local tbUi = Ui:CreateClass("CloakNumberRandomPanel");

function tbUi:OnOpen( nItemId )
	self.nItemId = nItemId;
	self.nSelAttriIndex =  0;
end

function tbUi:OnOpenEnd(  )
	self:Update()
end

function tbUi:Update( )
	local pItem = me.GetItemInBag(self.nItemId)
	if not pItem then
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	local nEquipLevel = pItem.nLevel

	self.itemframe:SetItem(self.nItemId)
	local szItemName, _, _, nQuality = Item:GetItemTemplateShowInfo(pItem.dwTemplateId, me.nFaction, me.nSex)
	local szNameColor = Item:GetQualityColor(nQuality) or "White";
	self.pPanel:Label_SetColorByName("TxtTitle", szNameColor);
	self.pPanel:Label_SetText("TxtTitle", szItemName)
	self.pPanel:Label_SetText("ClassTxt", string.format("%d阶披风", nEquipLevel) )

	local tbAttribs = Item.tbPiFeng:GetRandomAttrib(pItem)
	
	local nTempAttribIndex = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribIndex")
	local nNewAttribLevel = Item.tbPiFeng:GetItemIntValue(pItem,"TempAttirbTypeLevel")
	if nTempAttribIndex == 0 then
		self.pPanel:Button_SetText("BtnRandom", "重随")
	else
		local nOldRand = Item.tbPiFeng:GetItemIntValue(pItem, "AttirbRand" .. nTempAttribIndex)
		local nOldSaveId = Item.tbPiFeng:GetItemIntValue(pItem, "AttirbTypeLevel" .. nTempAttribIndex)
		local nAttribId, nOldAttribLevel 	= Item.tbRefinement:SaveDataToAttrib(nOldSaveId)
		local nNewRand = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribRand")

		if nNewAttribLevel > nOldAttribLevel or (nNewAttribLevel == nOldAttribLevel and nNewRand > nOldRand) then
			self.pPanel:Button_SetText("BtnRandom", "替换")	
		else
			self.pPanel:Button_SetText("BtnRandom", "保留")
		end
	end

	for i=1, Item.tbPiFeng.MAX_ATTRI_COUNT do
		local tbAttrib = tbAttribs[i]
		if tbAttrib then
			self.pPanel:SetActive("AttributeGroup" .. i, true)	
			local tbMA = tbAttrib.tbValues
			local nQuality = Item.tbRefinement:GetAttribColor(nEquipLevel, tbAttrib.nAttribLevel);
			local szDesc = FightSkill:GetMagicDesc(tbAttrib.szAttrib, tbMA);
			self.pPanel:Label_SetText("Attribute" .. i, szDesc)
			local szColor = Item:GetQualityColor(nQuality)
			self.pPanel:Label_SetGradientColor("Attribute" .. i, szColor);
			
			if nTempAttribIndex == 0 then
				self.pPanel:Button_SetEnabled("AttributeGroup" .. i, true)
				self.pPanel:Label_SetText("Label" .. i,"")
			else
				self.pPanel:Button_SetEnabled("AttributeGroup" .. i, i == nTempAttribIndex)
				if i == nTempAttribIndex then
					local nNewRand = Item.tbPiFeng:GetItemIntValue(pItem, "TempAttribRand")
					local tbNewValues  = Item.tbPiFeng:GetAttribValue(tbAttrib.nAttribId, nNewAttribLevel, nNewRand);
					local szDesc2 = FightSkill:GetMagicDesc(tbAttrib.szAttrib, tbNewValues);
					local _,_,Val1,szPercent1 = string.find(szDesc, "[^%d]*(%d+)(%%?)")
			        local _,_,Val2,szPercent2 = string.find(szDesc2, "[^%d]*(%d+)(%%?)")
			        local nVal1 = tonumber(Val1)
			        local nVal2 = tonumber(Val2)
			        local szShowMinusDesc;
			        if nVal2 >= nVal1 then
			        	szShowMinusDesc = string.format("(+%d%s)", nVal2 - nVal1, szPercent1)
			        	self.pPanel:Label_SetColorByName("Label" ..i, "Green")
			        else
			        	szShowMinusDesc = string.format("(-%d%s)", nVal1 - nVal2, szPercent1)
			        	self.pPanel:Label_SetColorByName("Label" ..i, "Red")
			        end
					self.pPanel:Label_SetText("Label" .. i, szShowMinusDesc);
				else
					self.pPanel:Label_SetText("Label" .. i,"")
				end
			end
			self.pPanel:Toggle_SetChecked("AttributeGroup" .. i, self.nSelAttriIndex == i)	
		else
			self.pPanel:SetActive("AttributeGroup" .. i, false)	
		end
	end
	local tbSelAttr = tbAttribs[self.nSelAttriIndex];
	if tbSelAttr then
		local tbMaxValue = Item.tbPiFeng:GetMaxRandomAttribValue(tbSelAttr.nAttribId, nEquipLevel)
		local szMaxDesc = FightSkill:GetMagicDesc(tbSelAttr.szAttrib, tbMaxValue);
		local _,_,Val1,szPercent1 = string.find(szMaxDesc, "[^%d]*(%d+)(%%?)")
		self.pPanel:Label_SetText("MaximumTxt", string.format("该条属性最大值 %d%s", Val1,szPercent1 ))
	else
		self.pPanel:Label_SetText("MaximumTxt", "")
	end

	local nCostItemId = Item.tbPiFeng.tbRAND_ATTRI_VAL_ITEM_ID[nEquipLevel]
	local nHaveCostItemCount = me.GetItemCountInBags(nCostItemId)
	self.PropItem:SetItemByTemplate(nCostItemId, string.format("%d/%d", Item.tbPiFeng.RAND_ATTRI_VAL_ITEM_NUM , nHaveCostItemCount)  )
	if Item.tbPiFeng.RAND_ATTRI_VAL_ITEM_NUM <= nHaveCostItemCount then
		self.PropItem.pPanel:Label_SetColorByName("LabelSuffix", "White")
	else
		self.PropItem.pPanel:Label_SetColorByName("LabelSuffix", "Red")	
	end
	
	self.PropItem.fnClick = self.PropItem.DefaultClick
	local szItemName, _, _, nQuality = Item:GetItemTemplateShowInfo(nCostItemId, me.nFaction, me.nSex)
	local szNameColor = Item:GetQualityColor(nQuality) or "White";	
	self.pPanel:Label_SetText("PropTxt", szItemName)
	self.pPanel:Label_SetColorByName("PropTxt", szNameColor);
end

function tbUi:OnSyncData( szData, nItemId )
	if szData == "ReRandomAttriNum" then
		if self.nItemId == nItemId then
			self:Update()
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

tbUi.tbOnClick.BtnClose = function (self)                                     
	Ui:CloseWindow(self.UI_NAME)
end

for i=1,Item.tbPiFeng.MAX_ATTRI_COUNT do
	tbUi.tbOnClick["AttributeGroup" .. i] = function (self)                                     
		self.nSelAttriIndex = i;
		self:Update();
	end	
end

tbUi.tbOnClick.BtnRandom = function ( self )
	if self.nSelAttriIndex == 0 then
		me.CenterMsg("请先选中一条属性")
		return
	end
	Item.tbPiFeng:ClientRefineAttriNumPF(self.nItemId, self.nSelAttriIndex)
end