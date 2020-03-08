local tbUi = Ui:CreateClass("QuickBuyOrUse")

tbUi.tbType = {
    RankBattle = {
        tbItemTemplateID = {1258},
        GetCanBuyTimes = function ()
            local tbBuyInfo  = DegreeCtrl:GetBuyCountInfo("RankBattle")
            local nBuyDegree = DegreeCtrl:GetDegree(me, tbBuyInfo[1])
            return nBuyDegree
        end,
        GetConsumeMoney = function ()
            local tbBuyInfo  = DegreeCtrl:GetBuyCountInfo("RankBattle")
            local nBuyDegree = DegreeCtrl:GetDegree(me, tbBuyInfo[1])
            local nBuyTimes = math.min(nBuyDegree, 5)
            local _, szMoneyType, nMoney = DegreeCtrl:BuyCountCostPrice(me, "RankBattle", nBuyTimes)
            return nMoney
        end,
        GetContent = function ()
            local tbBuyInfo  = DegreeCtrl:GetBuyCountInfo("RankBattle")
            local nBuyDegree = DegreeCtrl:GetDegree(me, tbBuyInfo[1])
            local nBuyTimes = math.min(nBuyDegree, 5)
            return string.format("增加%d次挑战次数", nBuyTimes)
        end
    },
}

tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnChoose1 = function (self)
        local tbInfo  = self.tbType[self.szType]
        local nItemID = self:GetUseItemID(tbInfo.tbItemTemplateID)
        if nItemID then
            RemoteServer.UseItem(nItemID)
        end
        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnChoose2 = function (self)
        me.BuyTimes(self.szType, 5)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUi:OnOpen(szType)
    if not szType or not self.tbType[szType] then
        return 0
    end

    if szType == "RankBattle" then
        local tbInfo    = self.tbType[szType]
        local nItemNum  = self:GetItemNum(tbInfo.tbItemTemplateID)
        local nBuyTimes = tbInfo.GetCanBuyTimes()
        if nItemNum == 0 or nBuyTimes == 0 then
            if nItemNum > 0 then
                local nItemID = self:GetUseItemID(tbInfo.tbItemTemplateID)
                local fnConfirm = function ()
                    RemoteServer.UseItem(nItemID)
                end
                local szMsg = "当天挑战次数不足，是否使用武神令增加挑战次数"
                me.MsgBox(szMsg, {{"确定", fnConfirm}, {"取消"}})
                return 0
            end

            me.BuyTimes(szType, 5)
            return 0
        end
    end

    self.szType = szType
    self:Update()
end

function tbUi:GetItemNum(tbItemTemplateID)
    local nNum = 0
    for _, nTemplateID in ipairs(tbItemTemplateID or {}) do
        local nItemNum = me.GetItemCountInAllPos(nTemplateID)
        nNum = nNum + nItemNum
    end
    return nNum
end

function tbUi:GetUseItemID(tbItemTemplateID)
    for _, nTemplateID in ipairs(tbItemTemplateID or {}) do
        local _, tbItem = me.GetItemCountInAllPos(nTemplateID)
        if tbItem and tbItem[1] then
            local pItem = tbItem[1]
            return pItem.dwId, nTemplateID
        end
    end
end

function tbUi:Update()
    local tbInfo               = self.tbType[self.szType]
    local nItemID, nTemplateID = self:GetUseItemID(tbInfo.tbItemTemplateID)
    local nItemNum             = me.GetItemCountInAllPos(nTemplateID) or 0
    self.itemframe1:SetItemByTemplate(nTemplateID, tostring(nItemNum)) --道具规则有修改，数量大于1才显示，所以改成字符串

    local pItem   = KItem.GetItemObj(nItemID)
    local szName  = Item:GetDBItemShowInfo(pItem)
    self.pPanel:Label_SetText("ItemName1", szName)

    local nBuyTimes = tbInfo.GetCanBuyTimes()
    self.itemframe2:SetDigitalItem("Gold", nBuyTimes)

    local nConsume = tbInfo.GetConsumeMoney()
    self.pPanel:Label_SetText("DegreeNum", nConsume)

    self.pPanel:Label_SetText("ItemName2", tbInfo.GetContent())
end