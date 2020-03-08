local tbUi = Ui:CreateClass("DiscountCouponPanel")

function tbUi:OnOpenEnd(pItem, nItem, nPrice, nDisPrice)
    self.itemframe:SetGenericItem({"Item", nItem, 1})
    self.itemframe.fnClick = self.itemframe.DefaultClick

    local szName = Item:GetItemTemplateShowInfo(nItem)
    self.pPanel:Label_SetText("ItemName", szName)
    self.pPanel:Label_SetText("TxtPriceMoney", nPrice)
    self.pPanel:Label_SetText("TxtOnsaleMoney", nDisPrice)
    self.nCurCount = 1
    self.nMaxCount = pItem.nCount
    self.nItemId = pItem.dwId
    self.nOnePrice = nDisPrice
    self:ChangeCount(self.nCurCount)
end

function tbUi:ChangeCount(nChangeCount)
    self.nCurCount = math.min(math.max(1, nChangeCount), self.nMaxCount)
    local nMyGold = me.GetMoney("Gold")
    self.pPanel:Label_SetText("TxtHaveMoney", nMyGold)
    self.pPanel:Label_SetText("TxtCostMoney", self.nCurCount*self.nOnePrice)
    self.pPanel:Label_SetText("Label_Number", self.nCurCount)
end

function tbUi:UpdateNumberInput(nInput)
    if nInput > self.nMaxCount then
        me.CenterMsg("超过最大数量")
        nInput = self.nMaxCount
    end
    self:ChangeCount(nInput)
    return self.nCurCount
end

function tbUi:Buy()
    if self.nCurCount == 0 then
        return
    end

    if self.nCurCount > self.nMaxCount then
        me.CenterMsg("超过最大数量")
        return
    end

    local nPrice = self.nOnePrice * self.nCurCount
    local nMyGold = me.GetMoney("Gold")
    if nMyGold < nPrice then
        Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
        local szName = Shop:GetMoneyName("Gold")
        me.CenterMsg(string.format("%s不足，请先充值", szName))
        return
    end

    RemoteServer.UseDiscountCoupon(self.nItemId, self.nCurCount)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnPlus = function (self)
        self:ChangeCount(self.nCurCount + 1)
    end,
    BtnMinus = function (self)
        self:ChangeCount(self.nCurCount - 1)
    end,
    Label_Number = function (self)
        local function fnUpdate(nInput)
            local nResult = self:UpdateNumberInput(nInput)
            return nResult
        end 
        Ui:OpenWindow("NumberKeyboard", fnUpdate)
    end,
    BtnBuy = function (self)
        self:Buy()
    end,
}