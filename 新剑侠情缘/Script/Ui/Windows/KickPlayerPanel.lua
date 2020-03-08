local tbUi = Ui:CreateClass("KickPlayerPanel")
tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen(tbPlayers, szType)
	if Lib:IsEmptyStr(szType) then
		return 0
	end
	self.szType = szType
	self.pPanel:Label_SetText("Title", "成员列表")
	self.tbPlayers = tbPlayers
	self:Refresh()
end

function tbUi:Refresh()
	self.ScrollView:Update(#self.tbPlayers, function(pGrid, nIdx)
		local tbItemData = self.tbPlayers[nIdx]

		local szIcon, szAtlas = PlayerPortrait:GetPortraitIcon(tbItemData.nPortrait)
		pGrid.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szAtlas)
		pGrid.pPanel:Label_SetText("Name", tbItemData.szName)
		pGrid.pPanel:Label_SetText("lbLevel", tbItemData.nLvl)
		local szFactionIcon = Faction:GetIcon(tbItemData.nFaction)
		pGrid.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
		pGrid.pPanel:SetActive("PlayerTitle", tbItemData.nHonorLevel > 0)
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbItemData.nHonorLevel)
		pGrid.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)

		pGrid.pPanel.OnTouchEvent = function ()
	        Ui:OpenWindowAtPos("RightPopup", 160, -180, "KickPlayer", {
	        	dwRoleId = tbItemData.nId,
	        	szOpenType = self.szType,
	        })
	    end
	end)
end

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_KICK_PLAYER, self.OnKickPlayer, self},
	}
end

function tbUi:OnKickPlayer(nTargetId)
	for i, tbPlayer in ipairs(self.tbPlayers) do
		if nTargetId == tbPlayer.nId then
			table.remove(self.tbPlayers, i)
			break
		end
	end
	self:Refresh()
end
