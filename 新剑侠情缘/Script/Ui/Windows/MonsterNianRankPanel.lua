local tbUi = Ui:CreateClass("MonsterNianRankPanel")

tbUi.tbOnClick = {
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_REFRESH_MN_RANK, self.Refresh, self},
	}
end

function tbUi:OnOpen()
	Activity.MonsterNianAct:UpdateRankData()
	self:Refresh()
end

function tbUi:Refresh()
	local tbData = Activity.MonsterNianAct:GetRankData()
	local nTotal = 0
	for _, tb in ipairs(tbData) do
		nTotal = nTotal+tb[3]
	end
	self.pPanel:Label_SetText("FamilyIntegral", "家族总积分："..nTotal)
	self.pPanel:Label_SetText("IntegralDate", string.format("%s年兽积分榜", Lib:TimeDesc14(tbData.nTime or GetTime())))

	self.ScrollView:Update(#tbData, function(pGrid, nIdx)
		local _, szName, nScore = unpack(tbData[nIdx])
		pGrid.pPanel:Label_SetText("BlessingValue", nIdx)
		pGrid.pPanel:Label_SetText("lbRoleName", szName)
		pGrid.pPanel:Label_SetText("Get", nScore)
	end)
end