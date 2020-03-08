local tbUI = Ui:CreateClass("NearbyTeamPanel")

tbUI.tbOnClick =
{
    btnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    btnInvite = function(self)
    	self:Apply()
    end,
}

function tbUI:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_SYNC_NEARBY_TEAMS, self.Refresh, self},
	}
	return tbRegEvent
end

function tbUI:OnOpen()
	self:Refresh({})
	TeamMgr:SyncNearbyTeams()
end

function tbUI:Refresh(tbTeams)
	local nRows = #tbTeams
	self.tbTeams = tbTeams
	self.tbChecked = {}
	local fnSetItem = function(tbItemGrid, nIdx)
		local tbData = tbTeams[nIdx]
		local tbCaptainInfo = tbData.tbCaptainInfo

		-- team head
		tbItemGrid.pPanel:Label_SetText("lbLevel", tbCaptainInfo.nLevel)
		local szFactionIcon = Faction:GetIcon(tbCaptainInfo.nFaction)
		local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbCaptainInfo.nPortrait)
		tbItemGrid.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
		tbItemGrid.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbCaptainInfo.nHonorLevel)
		if ImgPrefix then
			tbItemGrid.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
		end
		tbItemGrid.pPanel:SetActive("PlayerTitle", ImgPrefix or false)

		tbItemGrid.pPanel:Label_SetText("lbRoleName", string.format("%s的队伍", tbCaptainInfo.szName))
		local szActivityName = tbData.nTargetActivityId>0 and TeamMgr:GetActivityInfo(tbData.nTargetActivityId) or "无"
		tbItemGrid.pPanel:Label_SetText("TeamTarget", szActivityName)
		tbItemGrid.pPanel:Label_SetText("MemberCount", tbData.nMemberCount)

		tbItemGrid.pPanel:Toggle_SetChecked("CheckTeam", not not self.tbChecked[nIdx])

		local bShowKinIcon = Kin:HasKin() and me.dwKinId == tbCaptainInfo.nKinId;
		tbItemGrid.pPanel:SetActive("Mark", bShowKinIcon);

		tbItemGrid.CheckTeam.pPanel.OnTouchEvent = function()
			self.tbChecked[nIdx] = nil
			if tbItemGrid.pPanel:Toggle_GetChecked("CheckTeam") then
				self.tbChecked[nIdx] = true
			end
		end
	end
	self.ScrollView:Update(nRows, fnSetItem)
end

function tbUI:Apply()
	local bSend = false
	for nIdx in pairs(self.tbChecked) do
		TeamMgr:Apply(self.tbTeams[nIdx].nTeamID, self.tbTeams[nIdx].tbCaptainInfo.nPlayerID, true)
		bSend = true
	end
	me.CenterMsg(bSend and "入队申请已发送" or "请指定要申请的队伍")
	if bSend then
		Ui:CloseWindow(self.UI_NAME)
	end
end