local tbUi = Ui:CreateClass("DreamlandStrengthenPanel");

function tbUi:OnOpen()
	self:Update()
end

function tbUi:Update()
	--目前界面顺序和配置顺序是一致的
	local tbStrengthen = me.GetStrengthen();
	local tbDefine = InDifferBattle.tbDefine
	local tbEnhanceScroll = tbDefine.tbEnhanceScroll
	local nItemCount = me.GetItemCountInBags(tbDefine.nEnhanceItemId)
	for i,v in ipairs(tbEnhanceScroll) do
		local nEquipPos = v.tbEquipPos[1]
		local nStrengthLevel = tbStrengthen[nEquipPos + 1]
		self.pPanel:Label_SetText(string.format("Value%d_1", i) , nStrengthLevel)
		local nNextStrength = tbDefine.nStrengthStep + nStrengthLevel
		local nCost = v.tbEnhanceCost[nNextStrength]
		if nCost then
			self.pPanel:Label_SetText(string.format("Label%d_2", i), nNextStrength)
			
			self["Item" .. i]:SetItemByTemplate(tbDefine.nEnhanceItemId, 1 )
			self["Item" .. i].fnClick = self["Item" .. i].DefaultClick
			-- 身上的 / 消耗的
			self.pPanel:Label_SetText("Consume" .. i, string.format("%d/%d", nItemCount, nCost))
			self.pPanel:Label_SetColorByName("Consume" .. i, nCost <= nItemCount and "Green" or "Red");
			--显示右边
			self.pPanel:SetActive("Arrow" ..i, true)
			self.pPanel:SetActive("Item" .. i, true)
			self.pPanel:SetActive("Consume" .. i, true)
			self.pPanel:SetActive("BtnStrengthen" .. i, true)
			self.pPanel:SetActive("Lomite" .. i, false)

		else
			self.pPanel:Label_SetText(string.format("Label%d_2", i), "")
			self.pPanel:SetActive("Lomite" .. i, true)

			self.pPanel:SetActive("Arrow" ..i, false)
			self.pPanel:SetActive("Item" .. i, false)
			self.pPanel:SetActive("Consume" .. i, false)
			self.pPanel:SetActive("BtnStrengthen" .. i, false)
		end
	end
end

function tbUi:Enhance(nIndex)
	local bRet, szMsg = InDifferBattle:CanEnhance(me, nIndex)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.InDifferBattleRequestInst("EnhanceEquip", nIndex)
end

function tbUi:OnSyncUiData(szType)
	if szType ~= "DreamlandLevelUpPanel" then
		return
	end
	self:Update()
end

tbUi.tbOnClick = {}

for i=1,4 do
	tbUi.tbOnClick["BtnStrengthen" .. i] = function (self)
		self:Enhance(i)
	end
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,		self.OnSyncUiData },

	};

	return tbRegEvent;
end