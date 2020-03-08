local tbUi = Ui:CreateClass("GrowInvestPanel");

function tbUi:OnOpen(nGroupIndex)
	if not Recharge:IsShowProGroupInPanel("GrowInvest", "GrowInvestPanel") then
		return 0
	end
	self.pPanel:Label_SetText("Level", me.nLevel)
	local tbGrowInvestSetting = Recharge.tbGrowInvestGroup[nGroupIndex]
	local nCanGet = 0
	local nTotal = 0
	local nLevel = me.nLevel
	for i,v in ipairs(tbGrowInvestSetting) do
		nTotal = nTotal + v.nAwardGold
		if nLevel >= v.nLevel then
			nCanGet = nCanGet + v.nAwardGold
		end
	end
	local tbProdInfo = Recharge.tbSettingGroup.GrowInvest[nGroupIndex]

	self.pPanel:Label_SetText("Content", string.format("    购买%s超值[FFFE0D]8倍[-]返还[FFFE0D]%d元宝[-]，现在购买马上领取[FFFE0D]%d元宝[-]。", tbProdInfo.szNoromalDesc, nTotal, nCanGet))
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnBuy = function (self)
	Ui:OpenWindow("WelfareActivity", "GrowInvest")
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

