local tbUi = Ui:CreateClass("WorldCupGuessPanel")
local tbAct = Activity.WorldCupGuessAct

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

for i=1, 5 do
	tbUi.tbOnClick["BtnGuess"..i] = function(self)
		Ui:OpenWindow("WorldCupGuessSelPanel", i, self.tbData)
	end
	tbUi.tbOnClick["Box"..i] = function(self)
		local nShowId = i == 1 and tbAct.nShowRewardItemId1 or tbAct.nShowRewardItemId4
		Ui:OpenWindow("ItemTips", "Item", nil, nShowId)
	end
end

function tbUi:OnOpen()
	self.pPanel:Label_SetText("HeaderTxt", "")

	self:Refresh()
	tbAct:UpdateData()
end

function tbUi:Refresh()
	self.tbData = tbAct.tbData or {{}, {}, {}}

	for i=1, 5 do
		local nItemTemplateId = self.tbData[1][i] or 0
		local bRight = self.tbData[3][i]
		local tbTeam = tbAct.tbTeamCfg[nItemTemplateId]

		self.pPanel:Texture_SetTexture("NationalFlag"..i, string.format("UI/Textures/WordCup/%s.png", tbTeam[2]))
		self.pPanel:SetActive("Success"..i, bRight ~= nil and bRight)
		self.pPanel:SetActive("Fail"..i, bRight ~= nil and not bRight)
		if nItemTemplateId > 0 then
			self.pPanel:SetActive("CountryTxtBg"..i, true)
			self.pPanel:Label_SetText("CountryTxt"..i, tbTeam[1])
		else
			self.pPanel:SetActive("CountryTxtBg"..i, false)
		end
		self.pPanel:SetActive("BtnGuess"..i, nItemTemplateId <= 0 and bRight == nil)

		local bShowMult = nItemTemplateId > 0 and (bRight or bRight == nil)
		self.pPanel:SetActive("BoxTxt"..i, bShowMult)
		if bShowMult then
			local nGuessTimeIdx = self.tbData[2][i]
			local tbTimeCfg = i==1 and tbAct.tbTop1Cfg or tbAct.tbTop4Cfg
			local tbCfg = tbTimeCfg[nGuessTimeIdx]
			local nTimes = tbCfg[3]
			self.pPanel:Label_SetText("BoxTxt"..i, string.format("%dx", nTimes))
		end
	end
end
