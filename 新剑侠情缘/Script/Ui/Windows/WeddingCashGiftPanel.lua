local tbUi = Ui:CreateClass("WeddingCashGiftPanel")
tbUi.tbOnClick = 
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnCashGift = function(self)
		if self.pPanel:IsActive("CashGift") then
			self:ShowGiftSelectionPanel(false)
		else
			self:UpdateSendPanel()
		end
	end,

	BtnGive = function(self)
		local nHost1, nHost2 = unpack(self.tbHosts)
		local bOk, szErr, szErrType = Wedding:GiveCashGiftReq(nHost1, nHost2, self.nCheckedGold)
		if not bOk then
			me.CenterMsg(szErr)
			if szErrType=="not_enough_gold" then
				Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
				Ui:CloseWindow(self.UI_NAME)
			end
			return
		end
		self:ShowGiftSelectionPanel(false)
	end,
}

function tbUi:RegisterEvent()
	return {
		{UiNotify.emNOTIFY_WEDDING_CASHGIFT_CHANGE, self.Refresh},
	}
end

function tbUi:OnOpen(nHost1, nHost2)
	self.nCheckedGold = nil
	self.tbHosts = {nHost1, nHost2}
	self.pPanel:SetActive("CashGift", false)

	Wedding:UpdateCashGiftData(nHost1, nHost2)
	self:Refresh()
end

function tbUi:ShowGiftSelectionPanel(bShow)
	self.pPanel:SetActive("CashGift", bShow)
end

function tbUi:UpdateSendPanel()
	self:ShowGiftSelectionPanel(false)

	local tbList = Wedding:GetCashGiftValidList(me.GetVipLevel())
	if not next(tbList) then
		me.CenterMsg("剑侠尊享等级不足")
		return
	end

	local tbData = Wedding:GetCashGiftData(self.tbHosts[1], self.tbHosts[2])
	local nRemain = tbData.nRemain
	local tbRemainList = {}
	for _, nGold in ipairs(tbList) do
		if nGold>nRemain then
			break
		end
		table.insert(tbRemainList, nGold)
	end
	if not next(tbRemainList) then
		me.CenterMsg("你在本场婚礼赠送的礼金已经达到上限")
		return
	end

	self.tbToggles = {}
	self.ScrollViewCashGift:Update(#tbRemainList, function(pGrid, nIdx)
		table.insert(self.tbToggles, pGrid.Toggle.pPanel)

		local nGold = tbRemainList[nIdx]
		pGrid.pPanel:Label_SetText("Number", nGold)
		pGrid.Toggle.pPanel:Toggle_SetChecked("Main", self.nCheckedGold==nGold)

		pGrid.Toggle.pPanel.OnTouchEvent = function()
			self.nCheckedGold = tbRemainList[nIdx]
			
			for _,pToggle in ipairs(self.tbToggles) do
				pToggle:Toggle_SetChecked("Main", false)
			end
			pGrid.Toggle.pPanel:Toggle_SetChecked("Main", true)
		end
	end)

	self:ShowGiftSelectionPanel(true)
end

function tbUi:Refresh()
	local tbData = Wedding:GetCashGiftData(self.tbHosts[1], self.tbHosts[2])
	local tbList = tbData.tbList or {}

	self.pPanel:SetActive("BtnCashGift", not Lib:IsInArray(self.tbHosts, me.dwID) and tbData.bCanGive)

	self.ScrollView:Update(#tbList, function(pGrid, nIdx)
		local szName, nGold = unpack(tbList[nIdx])
		pGrid.pPanel:Label_SetText("Money", string.format("%d元宝", nGold))
		pGrid.pPanel:Label_SetText("Name", szName)
	end)
end