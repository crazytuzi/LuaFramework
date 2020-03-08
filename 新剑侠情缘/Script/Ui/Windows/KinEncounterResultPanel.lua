local tbUi = Ui:CreateClass("KinEncounterResultPanel")

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnBack = function(self)
		self.ScrollView:GoTop()
	end,
}

function tbUi:OnOpen(tbData)
	self.pPanel:SetActive("BtnBack", false)
	self.pPanel:SetActive("Victory", tbData.nResult > 0)
	self.pPanel:SetActive("Fail", tbData.nResult < 0)
	self.pPanel:SetActive("Draw", tbData.nResult == 0)

	self.nShowScrollMax = 0
	self.ScrollView:Update(#tbData.tbPlayers, function(pGrid, nIdx)
		if self.nShowScrollMax - nIdx >= 10 then
  			self.nShowScrollMax = nIdx
	  	end
	  	self.nShowScrollMax = math.max(self.nShowScrollMax, nIdx)
  		self.pPanel:SetActive("BtnBack", self.nShowScrollMax > 10)

		pGrid.pPanel:SetActive("Rank", nIdx > 3)
		for i=1, 3 do
			pGrid.pPanel:SetActive("NO"..i, nIdx == i)
		end
		pGrid.pPanel:Label_SetText("Rank", tostring(nIdx))
		
		local szName, nKill = unpack(tbData.tbPlayers[nIdx])
		pGrid.pPanel:Label_SetText("TxtName", szName)
		pGrid.pPanel:Label_SetText("TxtBattlefieldHonor", tostring(nKill))
	end)
end

function tbUi:RegisterEvent()
    return {
        {UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterMap},
    }
end

function tbUi:OnEnterMap(nTemplateMapId)
    if nTemplateMapId ~= KinEncounter.Def.nFightMapId then
        --Ui:CloseWindow(self.UI_NAME)
    end
end