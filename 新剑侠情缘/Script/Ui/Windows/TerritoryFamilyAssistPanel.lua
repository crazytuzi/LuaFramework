local tbUi = Ui:CreateClass("TerritoryFamilyAssistPanel");

function tbUi:OnOpen()
	self:UpdateAidList()
end

function tbUi:UpdateAidList(tbAidList)
	if not tbAidList then
		tbAidList = DomainBattle.tbCross:GetAidList()
	end

	if not tbAidList then
		return
	end

	local tbPlayerList = {}
	for _, tbPlayerInfo in pairs( tbAidList ) do
		table.insert(tbPlayerList, tbPlayerInfo)
	end

	local fnSetItem = function (itemObj, nIndex)
		local tbPlayerInfo = tbPlayerList[nIndex]
		itemObj.pPanel:Label_SetText("FamilyName", tbPlayerInfo.szKinName);
		itemObj.pPanel:Label_SetText("PlayerName", tbPlayerInfo.szName);
		itemObj.pPanel:Label_SetText("lbLevel", tostring(tbPlayerInfo.nLevel));
		itemObj.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbPlayerInfo.nFaction));
		local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(tbPlayerInfo.nPortrait);
		if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
			itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas);
		end

		if tbPlayerInfo.nHonorLevel > 0 then
			itemObj.pPanel:SetActive("PlayerTitle", true)
			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbPlayerInfo.nHonorLevel)
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false)
		end
	end

	self.ScrollView:Update(#tbPlayerList, fnSetItem);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_AID_LIST, self.UpdateAidList, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end
