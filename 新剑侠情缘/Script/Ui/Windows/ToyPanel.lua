local tbUi = Ui:CreateClass("ToyPanel")
tbUi.tbOnClick = 
{
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnOpen(nStudentId)
    self:UpdateData()
    self:Refresh()
end

function tbUi:UpdateData()
    local tbItems = {}
    for nId in pairs(Toy.tbSetting) do
        table.insert(tbItems, nId)
    end
    table.sort(tbItems, function(nA, nB)
        local nUnlockedA = Toy:IsUnlocked(me, nA)
        local nUnlockedB = Toy:IsUnlocked(me, nB)
        if nUnlockedA ~= nUnlockedB then
            return nUnlockedA
        end

        local nSortA = Toy:GetSetting(nA).nSort
        local nSortB = Toy:GetSetting(nB).nSort
        if nSortA ~= nSortB then
            return nSortA < nSortB
        end
        return nA < nB
    end)
    self.tbItems = tbItems
end

function tbUi:GetCountInfo(szClass)
    if szClass == "ToyStick" then
        return true, me.GetItemCountInBags(Toy.Def.nStickId)
    elseif szClass == "ToyHat" then
        return true, me.GetItemCountInBags(Toy.Def.nGreenHatId)
    end
    return false
end

local tbCantUseClasses = {
    ToyLabel = true,
    ToyBook = true,
}
function tbUi:Refresh()
    local nRowCount = 5
    local nTotal = #self.tbItems
    local fnSetItem = function(pGrid, nIdx)
        for i = 1, nRowCount do
            local nRealIdx = (nIdx - 1) * nRowCount + i
            local nId = self.tbItems[nRealIdx]
            if nId then
                local tbSetting = Toy:GetSetting(nId)
                pGrid.pPanel:Label_SetText("Label"..i, tbSetting.szName)
                pGrid.pPanel:Label_SetColorByName("Label"..i, tbSetting.szNameColor)

                local bUnlocked = Toy:IsUnlocked(me, nId)
                local pItem = pGrid["Item"..i]
                if bUnlocked then
                    pItem.pPanel:Sprite_SetSprite("ItemLayer", tbSetting.szIcon, tbSetting.szAtlas)
                else
                    pItem.pPanel:Sprite_SetSpriteGray("ItemLayer", tbSetting.szIcon, tbSetting.szAtlas)
                end
                pItem.pPanel:SetActive("ItemLayer", true)

                pItem.pPanel:Sprite_SetSprite("Color", tbSetting.szFrameColor)

                local nCD = Toy:GetCD(nId)
                pItem.pPanel:Sprite_SetCDControl("CDLayer", nCD, Toy.Def.nInterval)
                pItem.pPanel:SetActive("CDLayer", nCD > 0)

                local bNeedCount, nCount = self:GetCountInfo(tbSetting.szClass)
                pItem.pPanel:SetActive("LabelSuffix", bNeedCount)
                if bNeedCount then
                    pItem.pPanel:Label_SetText("LabelSuffix", nCount)
                end

                pGrid.pPanel:SetActive("Toy"..i, true)

                pItem.fnClick = function()
                    local szDesc = string.gsub(tbSetting.szDesc, "\\n", "\n")
                    local szOutput = string.gsub(tbSetting.szOutput, "\\n", "\n")
                    Ui:OpenWindow("SimplifyItemPanel", tbSetting.szName, string.format("%s\n产出：%s", szDesc, szOutput), function()
                        Toy:Use(nId)
                        Ui:CloseWindow("ToyPanel")
                    end, not bUnlocked or not not tbCantUseClasses[tbSetting.szClass], tbSetting.szNameColor)
                end
            else
                pGrid.pPanel:SetActive("Toy"..i, false)
            end
        end
    end
    self.ScrollView:Update(math.ceil(nTotal / nRowCount), fnSetItem)
end