local tbUi = Ui:CreateClass("ZhenFaPanelNode")
function tbUi:OnOpen()
    self:Update()
end

function tbUi:OnStrengthResult(bLvChanged)
    if not bLvChanged then
        return
    end

    self:Update()
end

function tbUi:Update()
    for nType, tbInfo in ipairs(ZhenFa.tbJueYao) do
        local nItemTID = me.GetUserValue(ZhenFa.GROUP, tbInfo.nCurItemTID)
        self.pPanel:SetActive("Equip" .. nType, nItemTID > 0)
        self.pPanel:SetActive("TricksName" .. nType, nItemTID > 0)
        if nItemTID > 0 then
            local tbIF = self["Equip" .. nType]
            tbIF:SetGenericItem({"Item", nItemTID, 1})
            local szName, _2, _3, nQuality = Item:GetItemTemplateShowInfo(nItemTID)
            local szColor = Item:GetQualityColor(nQuality)
            self.pPanel:Label_SetText("TricksName" .. nType, szName)
            self.pPanel:Label_SetColorByName("TricksName" .. nType, szColor)
            tbIF.nJueYaoPos = nType
            tbIF.fnClick = tbIF.DefaultClick
            local nStrengthLv = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nType].nStrengthLv)
            tbIF.pPanel:SetActive("LabelSuffix", true)
            tbIF.pPanel:Label_SetText("LabelSuffix", "+" .. nStrengthLv)
        end
    end
    self.nTab = self.nTab or 0
    self:UpdataTab()
end

function tbUi:UpdataTab()
    local tbMyJY = {}
    local tbItemInBag = me.GetItemListInBag()
    for _, pItem in ipairs(tbItemInBag) do
        if pItem.szClass == "JueYao" and pItem.GetIntValue(ZhenFa.JUEYAO_EQUIP_FLAG) == 0 and (self.nTab == 0 or self.nTab == pItem.nDetailType) then
            table.insert(tbMyJY, {pItem.dwId, pItem.dwTemplateId, pItem.nQuality, pItem.nDetailType, pItem.nLevel})
        end
    end
    table.sort(tbMyJY, function (a, b)
        if a[3] < b[3] then
            return
        end
        if a[3] == b[3] then
            if a[4] > b[4] then
                return
            end
            if a[4] == b[4] then
                return a[5] > b[5]
            end
            return true
        end
        return true
    end)
    local fnSetItem = function (itemObj, nIdx)
        local nBeginIdx = (nIdx-1)*4
        for i = 1, 4 do
            local tbItem = tbMyJY[nBeginIdx + i]
            itemObj.pPanel:SetActive("Item" .. i, tbItem or false)
            itemObj.pPanel:SetActive("Name" .. i, tbItem or false)
            if tbItem then
                local tbIF = itemObj["Item" .. i]
                tbIF:SetItem(tbItem[1])
                tbIF.fnClick = tbIF.DefaultClick
                local szName  = Item:GetItemTemplateShowInfo(tbItem[2])
                local szColor = Item:GetQualityColor(tbItem[3])
                itemObj.pPanel:Label_SetText("Name" .. i, szName)
                itemObj.pPanel:Label_SetColorByName("Name" .. i, szColor)
            end
        end
    end
    local nLen = math.ceil(#tbMyJY/4)
    self.ScrollView3:Update(nLen, fnSetItem)

    local nCurCount = ZhenFa:GetJueYaoCount(me)
    self.pPanel:Label_SetText("NumberTxt", string.format("%d/%d", nCurCount, GameSetting.MAX_COUNT_JUEYAO))
end

function tbUi:ChangeTab(nTab)
    if nTab == self.nTab then
        return
    end
    self.nTab = nTab
    self:UpdataTab()
end

tbUi.tbOnClick = {}
local tbBtn2Tab = {Btn1 = 0, Btn2 = 1, Btn3 = 2, Btn4 = 3, Btn5 = 4, Btn6 = 5, Btn7 = 6}
for szBtn, nTab in pairs(tbBtn2Tab) do
    tbUi.tbOnClick[szBtn] = function (self)
        self:ChangeTab(nTab)
    end
end