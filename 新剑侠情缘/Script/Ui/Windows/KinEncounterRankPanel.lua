local tbUi = Ui:CreateClass("KinEncounterRankPanel")

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen()
	RemoteServer.KinEncounterReq("UpdateRank")
	self:Refresh()
end

function tbUi:Refresh()
	local tbData = KinEncounter.tbKillRank or {}
	for i=1, 11 do
		local tbRow = tbData[i]
		if tbRow then
			self.pPanel:Label_SetText("RoleName"..i, tbRow[1])
			self.pPanel:Label_SetText("KillNumber"..i, tbRow[2])
			if i == 11 then
				self.pPanel:Label_SetText("Number11", tbRow[3])
			end
		end
		self.pPanel:SetActive("RankItem"..i, not not tbRow)
	end
end