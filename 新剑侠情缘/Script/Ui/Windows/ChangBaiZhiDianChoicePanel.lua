local tbUi = Ui:CreateClass("ChangBaiZhiDianChoicePanel")

function tbUi:OnOpen(tbFaction)
	if not ChangBaiZhiDian:IsChoosingFaction() then
		return
	end
	self.tbFaction = tbFaction
	self:UpdateMain()

	self.nTimer = Timer:Register(Env.GAME_FPS, self.TimerUpdate, self)
end

function tbUi:OnOpenEnd()
	Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
end

function tbUi:TimerUpdate()
	self.pPanel:Label_SetText("TitleTxt", (ChangBaiZhiDian.tbChoosedFactions[me.dwID] ~= 0 and "等待活动开启：" or "请选择你在活动中的门派：")..ChangBaiZhiDian.nLeftTime)
	if not ChangBaiZhiDian:IsChoosingFaction() then
		Ui:CloseWindow(self.UI_NAME)
		Ui:CloseWindow("ChatLargePanel")
	end
	return true
end

function tbUi:UpdateMain()
	local tbChoosedFaction = ChangBaiZhiDian.tbChoosedFactions
	local tbChoosedFactionRevert = {}
	local tbMembers = TeamMgr:GetTeamMember()
	local tbRoleIdKeyVal = {}
	for i, v in ipairs(tbMembers) do
		tbRoleIdKeyVal[v.nPlayerID] = v
	end
	tbRoleIdKeyVal[me.dwID] = {szName = me.szName}

	for dwRoleId, nFaction in pairs(tbChoosedFaction) do
		if nFaction ~= 0 then
			tbChoosedFactionRevert[nFaction] = dwRoleId
		end
	end

	for i, nFaction in ipairs(self.tbFaction) do
		local szBigIcon,szAtlas = Faction:GetBigIcon(nFaction)
		local dwChoosedRoleId = tbChoosedFactionRevert[nFaction]
		local szButton = "Faction"..i
		self.pPanel:Button_SetSprite(szButton, szBigIcon)
		if dwChoosedRoleId then
			self.pPanel:Sprite_SetSprite(szButton, szBigIcon,szAtlas)
			local tbMemberInfo = tbRoleIdKeyVal[dwChoosedRoleId]
			self.pPanel:Label_SetText("Name"..i, string.format("[%s]%s[-]", dwChoosedRoleId == me.dwID and "c8ff00" or "92d2ff", tbMemberInfo.szName))
		else
			self.pPanel:Sprite_SetSpriteGray(szButton, szBigIcon,szAtlas)
			self.pPanel:Label_SetText("Name"..i, "")
		end
	end
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

function tbUi:ChooseFaction(nIndex)
	local nFaction = self.tbFaction[nIndex]
	if not ChangBaiZhiDian:IsChoosingFaction() then
		me.CenterMsg("当前阶段已不可选择")
		return
	end
	if ChangBaiZhiDian.tbChoosedFactions[me.dwID] == nFaction then
		return
	end
	for k, v in pairs(ChangBaiZhiDian.tbChoosedFactions) do
		if v == nFaction then
			me.CenterMsg("该门派已被其他队员选择")
			return
		end
	end
	RemoteServer.ChangBaiC2ZCall("ChooseFaction", nFaction)
end

tbUi.tbOnClick = {}

for i = 1, 6 do
	tbUi.tbOnClick["Faction"..i] = function(self)
		self:ChooseFaction(i)
	end
end

tbUi.tbOnClick.Bg = function (self)
	if Ui:WindowVisible("ChatLargePanel") then
		return
	end

	Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
end

function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_CHANGBAI_FACTION, self.UpdateMain}
	};
	return tbRegEvent
end