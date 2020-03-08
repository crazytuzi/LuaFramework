local tbUi = Ui:CreateClass("PortraitItemPreviewPanel")

function tbUi:OnOpenEnd(nItemTID, nItemID)
    local tbPortrait = {}
    for i = 1, 99 do
        local nPortrait = KItem.GetItemExtParam(nItemTID, i)
        if not nPortrait or nPortrait <= 0 then
            break
        end
        table.insert(tbPortrait, nPortrait)
    end
    self:Update(tbPortrait)

    self.nItemID = nItemID
    self.pPanel:SetActive("BtnGet", nItemID or false)
    local tbInfo = KItem.GetItemBaseProp(nItemTID) or {}
    self.pPanel:Label_SetText("Tip", tbInfo.szIntro or "")
end

function tbUi:Update(tbPortrait)
    local nSCLen = math.ceil(#tbPortrait/2)
    local fnSetItem = function (itemObj, nIdx)
        for i = 1, 2 do
            local nPortrait = tbPortrait[(nIdx-1)*2 + i]
            itemObj.pPanel:SetActive("skillitem" .. i, nPortrait or false)
            if nPortrait then
                local szHead, szAtlas = PlayerPortrait:GetSmallIcon(nPortrait)
                itemObj["skillitem" .. i].pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
                local _1, _2, _3, szName = PlayerPortrait:GetDesc(nPortrait)
                itemObj["skillitem" .. i].pPanel:Label_SetText("Name", szName)
            end
        end
    end
    self.ScrollView:Update(nSCLen, fnSetItem)
end

tbUi.tbOnClick = {
    BtnGet = function (self)
        if not self.nItemID then
            return
        end

        Item:ClientUseItem(self.nItemID)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}