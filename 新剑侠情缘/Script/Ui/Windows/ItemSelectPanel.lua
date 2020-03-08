local tbUi = Ui:CreateClass("ItemSelectPanel")

tbUi.tbOnClick = {
    Btn = function (self)
        if not self.nItemId then
            return
        end

        if self.nSelected ~= self.nCanChooseNum then
            me.CenterMsg(string.format("请选择%d种奖励", self.nCanChooseNum))
            return
        end

        local tbSelItem = {}
        if self.nCanChooseNum > 1 then
            for nItemTID, nCount in pairs(self.tbMultiSel) do
                if nCount > 0 then
                    tbSelItem[nItemTID] = nCount
                end
            end
        else
            for nItemTID, _ in pairs(self.tbSelected) do
                tbSelItem[nItemTID] = 1
            end
        end

        RemoteServer.UseChooseItem(self.nItemId, tbSelItem)

        Ui:CloseWindow(self.UI_NAME)
    end,

    BtnBack = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUi:OnOpen(nItemTemplateId, nItemId, tb4ChooseList)
    if not nItemTemplateId then
        return 0
    end

    local tbItemInst = Item:GetClass("NeedChooseItem")
    local tb4Choose  = tb4ChooseList or tbItemInst:Get4ChooseList(nItemTemplateId)
    if not tb4Choose then
        return 0
    end

    local nNeedCount = KItem.GetItemExtParam(nItemTemplateId, 2)
    for _, tbItemChoose in pairs(tb4Choose) do
        if tbItemChoose.nThisNeedCount > 0 and tbItemChoose.nThisNeedCount < nNeedCount then
            nNeedCount = tbItemChoose.nThisNeedCount;
        end    
    end    

    if  nNeedCount > 0 and me.GetItemCountInAllPos(nItemTemplateId) < nNeedCount then
        local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId);
        me.CenterMsg(string.format(XT("不足%d个%s，不能兑换"), nNeedCount, (tbBaseInfo and tbBaseInfo.szName) or ""))
        return 0
    end

    self.tb4Choose = {}
    self.tbChooseMax = {}
    self.tbMultiSel = {}
    for nItemTemplateId, tbItemChoose in pairs(tb4Choose) do
        local nTimeFrame = 0;
        if not Lib:IsEmptyStr(tbItemChoose.szTimeFrame) then
            nTimeFrame = CalcTimeFrameOpenTime(tbItemChoose.szTimeFrame);
        end

        local nSortValue = Lib:GetLocalDay(nTimeFrame) * 10000 + (10000 - tbItemChoose.nIndex);
        table.insert(self.tb4Choose, {nItemTemplateId, tbItemChoose.nNum, nSortValue})
        self.tbChooseMax[nItemTemplateId] = tbItemChoose.nNum;
        self.tbMultiSel[nItemTemplateId] = 0
    end

    table.sort(self.tb4Choose, function (a, b)
        return a[3] > b[3];
    end);

    self.nItemId         = nItemId
    self.nItemTemplateId = nItemTemplateId
    self.nCanChooseNum   = tonumber(KItem.GetItemExtParam(nItemTemplateId, 1))
end

function tbUi:OnOpenEnd()
    self.tbSelected = {}
    self.nSelected  = 0
    self.bCanChoose = self.nItemId and true or false

    self:UpdateList()
    self:UpdateTitle()
    self.pPanel:SetActive("Btn", self.bCanChoose)

    local szName = Item:GetItemTemplateShowInfo(self.nItemTemplateId, me.nFaction, me.nSex)
    self.pPanel:Label_SetText("ItemName", szName)
end

function tbUi:UpdateList()
    local bMultiChoose = self.nCanChooseNum > 1
    local fnSet = function (item, nIdx)
        local nBeginIdx = 2*nIdx - 2
        for i = 1, 4 do
            item["skillitem" .. i].pPanel:SetActive("Main", false)
        end
        for i = 1, 2 do
            local tbItem   = self.tb4Choose[nBeginIdx + i]
            local nItemIdx = bMultiChoose and (2+i) or i
            local pItem    = item["skillitem" .. nItemIdx]
            pItem.pPanel:SetActive("Main", tbItem)
            if not tbItem then
                return
            end

            local nItemTID = tbItem[1]
            local szName = Item:GetItemTemplateShowInfo(nItemTID, me.nFaction, me.nSex)
            pItem.pPanel:Label_SetText("Name", szName)
            pItem.itemframe:SetGenericItem({"Item", nItemTID})
            pItem.itemframe.fnClick = pItem.itemframe.DefaultClick

            if bMultiChoose then
                pItem.BtnMinus.pPanel.OnTouchEvent = function ()
                    self:ChangeNum(pItem, nItemTID, -1)
                end
                pItem.BtnPlus.pPanel.OnTouchEvent = function ()
                    self:ChangeNum(pItem, nItemTID, 1)
                end
                pItem.Label_Number.pPanel:Label_SetText("Main", "0")
                pItem.Label_Number.pPanel.OnTouchEvent = function ()
                    Ui:OpenWindow("NumberKeyboard", function (nInput)
                        local nResult = self:UpdateNumberInput(pItem, nItemTID, nInput)
                        return nResult
                    end)
                end
            else
                pItem.pPanel:SetActive("Tag", self.bCanChoose and self.tbSelected[nItemTID])
                pItem.pPanel:SetActive("Toggle", self.bCanChoose)
                pItem.pPanel.OnTouchEvent = function ()
                    if self.bCanChoose then
                        self:OnSelectItem(pItem, nItemTID)
                    end
                end
            end
        end
    end

    self.ScrollView:Update(math.ceil(#self.tb4Choose/2), fnSet)
end

function tbUi:OnSelectItem(item, nItemTemplateId)
    if self.tbSelected[nItemTemplateId] then
        if self.nCanChooseNum == 1 then
            return
        end

        self.nSelected = self.nSelected - 1
        self.tbSelected[nItemTemplateId] = nil
        item.pPanel:SetActive("Tag", false)
    else
        if self.nCanChooseNum == 1 then
            for nId, tbItem in pairs(self.tbSelected) do
                self.tbSelected[nId] = nil
                tbItem.pPanel:SetActive("Tag", false)
            end

            self.nSelected = 1
            self.tbSelected[nItemTemplateId] = item
            item.pPanel:SetActive("Tag", true)
        else
            if self.nSelected >= self.nCanChooseNum then
                me.CenterMsg(string.format("只能选择%d种", self.nCanChooseNum))
                return
            end

            self.nSelected = self.nSelected + 1
            self.tbSelected[nItemTemplateId] = item
            item.pPanel:SetActive("Tag", true)
        end
    end

    self:UpdateTitle()
end

function tbUi:UpdateTitle()
    self.pPanel:Label_SetText("ItemTip", string.format("从以下奖励挑选%d件(%d/%d)", self.nCanChooseNum, self.nSelected, self.nCanChooseNum))
end

function tbUi:ChangeNum(pItem, nItemTID, nChange)
    local nInput = math.max(math.min(self.tbMultiSel[nItemTID] + nChange, self.tbChooseMax[nItemTID]), 0)
    self:UpdateNumberInput(pItem, nItemTID, nInput)
end

function tbUi:UpdateNumberInput(pItem, nItemTID, nInput)
    self.nSelected = self.nSelected - self.tbMultiSel[nItemTID]
    local szWarnMsg
    if nInput + self.nSelected > self.nCanChooseNum then
        szWarnMsg = string.format("该道具最多只能选择%d个物品", self.nCanChooseNum)
        nInput = self.nCanChooseNum - self.nSelected
    end
    if nInput > self.tbChooseMax[nItemTID] then
        szWarnMsg = string.format("该选项只能选择%d个", self.tbChooseMax[nItemTID])
        nInput = self.tbChooseMax[nItemTID]
    end
    if szWarnMsg then
        me.CenterMsg(szWarnMsg)
    end

    self.tbMultiSel[nItemTID] = math.max(math.min(nInput, self.tbChooseMax[nItemTID]), 0)
    self.nSelected = self.nSelected + self.tbMultiSel[nItemTID]
    local szNumber = self.tbMultiSel[nItemTID] > 0 and "[C8FF00]" or "[-]"
    pItem.Label_Number.pPanel:Label_SetText("Main", szNumber .. self.tbMultiSel[nItemTID])
    self:UpdateTitle()
    return self.tbMultiSel[nItemTID]
end