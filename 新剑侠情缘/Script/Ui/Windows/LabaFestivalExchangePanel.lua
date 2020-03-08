local tbUi = Ui:CreateClass("LabaFestivalExchangePanel");
local tbAct = Activity.LabaAct
function tbUi:OnOpen()
	tbAct:RequestMaterialData()
	self.nChangeId = nil
	self.nMyId = nil
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local fnMarket = function (itemObj)
		self.nChangeId = itemObj.nId
	end
	for nId = 1, 8 do
		local szMarketItemName = "MarketName" ..nId
		if tbAct.tbMaterial[nId] then
			self[szMarketItemName].pPanel:SetActive("Main", true)
			local szMarketItemTxt = string.format("Txt%dName", nId)
			self[szMarketItemName].pPanel:Label_SetText(szMarketItemTxt, tbAct.tbMaterial[nId].szName)
			self[szMarketItemName].nId = nId
			self[szMarketItemName].pPanel.OnTouchEvent = fnMarket
			self[szMarketItemName].pPanel:Toggle_SetChecked("Main",  self.nChangeId and nId == self.nChangeId)
		else
			self[szMarketItemName].pPanel:SetActive("Main", false)
		end
	end
	local fnKnapsack = function (itemObj)
		self.nMyId = itemObj.nId
	end
	local bExist 
	local tbCanExchange, nExchangeCount = tbAct:GetCanExchangeMaterial()
	for i = 1, 8 do
		local szKnapsackItemName = "KnapsackName" .. i
		if tbCanExchange[i] then
			self[szKnapsackItemName].pPanel:SetActive("Main", true)
			local szItemTxt = string.format("TxtName%d", i)
			local nId = tbCanExchange[i].nId
			local szName = tbAct.tbMaterial[nId].szName
			self[szKnapsackItemName].pPanel:Label_SetText(szItemTxt, szName)
			local szNumberTxt = "TxtNumber" .. i
			local nHave = tbCanExchange[i].nHave
			self[szKnapsackItemName].pPanel:Label_SetText(szNumberTxt, nHave)
			self[szKnapsackItemName].nId = nId
			self[szKnapsackItemName].pPanel.OnTouchEvent = fnKnapsack
			if self.nMyId and nId == self.nMyId then
				bExist = true
				self[szKnapsackItemName].pPanel:Toggle_SetChecked("Main",  true)
			else
				self[szKnapsackItemName].pPanel:Toggle_SetChecked("Main",  false)
			end
			
		else
			self[szKnapsackItemName].pPanel:SetActive("Main", false)
		end
	end
	if not bExist then
		self.nMyId = nil
	end
	self.pPanel:Label_SetText("ConsumeTxt2", tbAct.nExchangeCost)
	self.pPanel:Label_SetText("SurplusTxt2", tbAct.nMaxExchangeCount - (nExchangeCount or 0))

end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_SYNC_LABA_ACT_MATERIAL_DATA, self.RefreshUi, self},

	};
	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnExchange = function (self)
		if not self.nChangeId or not self.nMyId then
			me.CenterMsg("请在左边选中自己需要的材料，右边选中多余的材料", true)
			return
		end
		local fnAgree = function (self)
			RemoteServer.LabaActClientCall("ExchangeMaterial", self.nMyId, self.nChangeId)
		end
		local szChangeName = (tbAct.tbMaterial[self.nChangeId] or {}).szName or "-"
		local szMyName = (tbAct.tbMaterial[self.nMyId] or {}).szName or "-"
		me.MsgBox(string.format("是否花费[FFFE0D]%d[-]元宝将%s换成%s？", tbAct.nExchangeCost, szMyName, szChangeName), {{"同意", fnAgree, self}, {"拒绝"}})
	end;
}
