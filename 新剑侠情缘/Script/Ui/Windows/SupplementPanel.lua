local tbUi = Ui:CreateClass("SupplementPanel")
function tbUi:OnOpen()
    self.bCoin = false
    self:Update()
    Ui:ClearRedPointNotify("Activity_SupplementPanel")
end

function tbUi:Update()
    local nPlayerExp = me.GetExp();
    local nPlayerNextLevelExp = me.GetNextLevelExp();
    local nPlayerLevel = me.nLevel;
    local nMaxPlayerLevel = Player:GetPlayerMaxLeve();
    local bShowLimitTip = false;
    if nPlayerLevel >= nMaxPlayerLevel and nPlayerExp >= nPlayerNextLevelExp then
        bShowLimitTip = true;
    end

    self.pPanel:SetActive("UpperLimitTip", bShowLimitTip);
    local nItemNum = me.GetItemCountInAllPos(SupplementAward.ITEM_TYPE_TID)
    self.pPanel:SetActive("SpecialTips", nItemNum > 0)
    if nItemNum > 0 then
        local szName = Item:GetItemTemplateShowInfo(SupplementAward.ITEM_TYPE_TID, me.nFaction, me.nSex)
        self.pPanel:Label_SetText("SpecialTips", string.format("当前可免费完美找回，剩余%s%d个", szName, nItemNum))
    end
    local tbSuppleList = SupplementAward:GetSupplementList()
    table.sort(tbSuppleList, function (a1, a2)
        local nCanSup1 = SupplementAward:GetCanSupplementNum(me, a1.szKey)
        local nCanSup2 = SupplementAward:GetCanSupplementNum(me, a2.szKey)
        return nCanSup1 > 0 and nCanSup2 == 0
    end)

    local fnSetItem = function (tbItem, nIdx)
        tbItem:Update(tbSuppleList[nIdx], self.bCoin)
    end
    self.ScrollView:Update(#tbSuppleList, fnSetItem)
    self.pPanel:Toggle_SetChecked("BtnPerfect", not self.bCoin)
    self.pPanel:Toggle_SetChecked("BtnCommon", self.bCoin)
end

function tbUi:OnClose()
    if Ui:WindowVisible("SupplementBox") then
        Ui:CloseWindow("SupplementBox")
    end
end

tbUi.tbOnClick = {
    BtnCommon = function (self)
        if self.bCoin then
            return
        end

        self.bCoin = true
        self:Update()
    end,
    BtnPerfect = function (self)
        if not self.bCoin then
            return
        end

        self.bCoin = nil
        self:Update()
    end
}

local tbItem = Ui:CreateClass("SupplementItem")
function tbItem:Update(tbInfo, bCoin)
    self.tbSupplement = tbInfo
    self.bCoin = bCoin

    local nCanSup = SupplementAward:GetCanSupplementNum(me, tbInfo.szKey)
    self.pPanel:SetActive("GetTran", nCanSup > 0)
    self.pPanel:SetActive("HaveBack", nCanSup <= 0)
    local nItemNum = me.GetItemCountInAllPos(SupplementAward.ITEM_TYPE_TID)
    self.pPanel:SetActive("GoldTxt", self.bCoin or nItemNum <= 0)
    if (nItemNum <= 0 or self.bCoin) and nCanSup > 0 then
        local nPrice = bCoin and tbInfo.nPrice_Coin_NotDis or tbInfo.nPrice_NotDis
        self.pPanel:Label_SetText("GoldTxt", nPrice)
        self.pPanel:Sprite_SetSprite("Gold", bCoin and "CoinSmall" or "GoldSmall")
    end
    local szCanSup = nCanSup <= 1 and "" or string.format("（可找回[FFFE0D]%d[-]次）", nCanSup)
    self.pPanel:Label_SetText("Title", tbInfo.szName .. szCanSup)

    local tbAward = Lib:GetAwardFromString(bCoin and tbInfo.szAward_Coin or tbInfo.szAward)
    local nExp = me.GetBaseAwardExp() * tbAward[1][2]
    self.pPanel:Label_SetText("Exp", nExp)

    for i = 1, 3 do
        local szItemframe = "itemframe" .. i
        local tbShowAward = tbAward[i + 1]
        self.pPanel:SetActive(szItemframe, tbShowAward and true or false)
        if tbShowAward then
            self[szItemframe]:SetGenericItem(tbShowAward)
            self[szItemframe].fnClick = self[szItemframe].DefaultClick
        end
    end

    local bDiscount = SupplementAward:GetDiscount() < 1
    self.pPanel:SetActive("GoldTxt2", bDiscount)
    if bDiscount then
        self.pPanel:Label_SetText("GoldTxt2", bCoin and tbInfo.nPrice_Coin or tbInfo.nPrice)
        self.pPanel:Sprite_SetSprite("Gold2", bCoin and "CoinSmall" or "GoldSmall")
    end
    self.pPanel:SetActive("Mark", bDiscount)
    self.pPanel:SetActive("OriginalPriceDis", bDiscount)
    self.pPanel:ChangePosition("GoldTxt", bDiscount and 128 or 270, bDiscount and 13 or 23)
end

tbItem.tbOnClick = {
    BtnGet = function (self)
        local nCanSup = SupplementAward:GetCanSupplementNum(me, self.tbSupplement.szKey)
        if nCanSup <= 0 then
            return
        end

        local nItemNum = me.GetItemCountInAllPos(SupplementAward.ITEM_TYPE_TID)
        if not self.bCoin and nItemNum > 0 then
            RemoteServer.TryGetSupplementAward(self.tbSupplement.szKey, 1, self.bCoin)
            return
        end
        Ui:OpenWindow("SupplementBox", self.tbSupplement, self.bCoin)
    end
}

local tbMsgBox = Ui:CreateClass("SupplementBox")
function tbMsgBox:OnOpenEnd(tbInfo, bCoin)
    self.szKey    = tbInfo.szKey
    self.nPrice   = bCoin and tbInfo.nPrice_Coin or tbInfo.nPrice
    self.szName   = tbInfo.szName
    self.nNum     = SupplementAward:GetCanSupplementNum(me, self.szKey)
    self.nDefault = self.nNum
    self.bCoin    = bCoin
    self:Update()
end

function tbMsgBox:Update()
    self.pPanel:Label_SetText("Desc", string.format("%s可找回次数%d次", self.szName, self.nNum))
    self.pPanel:Label_SetText("Cost", self.nPrice * self.nDefault)
    self.pPanel:Label_SetText("Number", self.nDefault)
    self.pPanel:Sprite_SetSprite("MoneySprite", self.bCoin and "CoinSmall" or "GoldSmall")
end

function tbMsgBox:TryGetAward()
    RemoteServer.TryGetSupplementAward(self.szKey, self.nDefault, self.bCoin)
    Ui:CloseWindow(self.UI_NAME)
end

tbMsgBox.tbOnClick = {
    BtnSure = function (self)
        local szMoneyType = self.bCoin and "Coin" or "Gold"
        local nItemNum = me.GetItemCountInAllPos(SupplementAward.ITEM_TYPE_TID)
        if not self.bCoin and nItemNum >= self.nDefault then
            self:TryGetAward()
            return
        end
        if me.GetMoney(szMoneyType) < self.nPrice * self.nDefault then
            local szMoneyName = Shop:GetMoneyName(szMoneyType)
            local szMsg = szMoneyName .. "不足"
            szMsg = self.bCoin and szMsg or szMsg .. "，请先充值"
            me.CenterMsg(szMsg)
            if not self.bCoin then
                Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
            end
            return
        end

        self:TryGetAward()
    end,
    BtnCancel = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnA = function (self)
        self.nDefault = math.min(self.nNum, self.nDefault + 1)
        self:Update()
    end,
    BtnP = function (self)
        self.nDefault = math.max(1, self.nDefault - 1)
        self:Update()
    end,
}