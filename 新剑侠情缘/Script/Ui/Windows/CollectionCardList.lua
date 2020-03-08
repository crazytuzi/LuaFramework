local tbUi = Ui:CreateClass("CollectionCardList")

function tbUi:OnOpenEnd(nCollectionId)
    local nLen = CollectionSystem:GetCollectionLength(nCollectionId)
    local tbShowCard = {}
    for i = 1, nLen do
        local szTimeFrame = CollectionSystem:GetTimeFrame(nCollectionId, i)
        if szTimeFrame == "" or GetTimeFrameState(szTimeFrame) == 1 then
            table.insert(tbShowCard, i)
        end
    end
    local nShowLen = #tbShowCard

    local fnSetItem = function(itemObj, nIdx)
        for i = 1, 5 do
            local nPos = (nIdx - 1)*5 + i
            local szItem = "itemframe" .. i
            itemObj.pPanel:SetActive(szItem, nPos <= nShowLen)
            if nPos <= nShowLen then
                local bActivate = CollectionSystem:IsPosActivate(nCollectionId, tbShowCard[nPos])
                local nCardTemplateId = CollectionSystem:GetCardId(nCollectionId, tbShowCard[nPos])
                if bActivate then
                    itemObj[szItem]:SetItemByTemplate(nCardTemplateId, 0, nil, nil, {bShowCDLayer = not bActivate})
                    itemObj[szItem].fnClick = itemObj[szItem].DefaultClick
                else
                    local _, nIcon, _, nQuality = Item:GetItemTemplateShowInfo(nCardTemplateId, me.nFaction, me.nSex)
                    local szIconAtlas, szIconSprite = Item:GetIcon(nIcon)
                    local pIFPanel = itemObj[szItem].pPanel
                    pIFPanel:SetActive("ItemLayer", true)
                    pIFPanel:Sprite_SetSpriteGray("ItemLayer", szIconSprite, szIconAtlas)
                    pIFPanel:SetActive("CDLayer", true)
                    pIFPanel:Sprite_SetGray("CDLayer", true)
                    pIFPanel:SetActive("Color", true)
                    pIFPanel:Sprite_SetGray("Color", true)

                    itemObj[szItem].nTemplate = nCardTemplateId
                    itemObj[szItem].nFaction = me.nFaction
                end
                itemObj[szItem].fnClick = itemObj[szItem].DefaultClick
            end
        end
    end
    self.ScrollView:Update(math.ceil(nShowLen/5), fnSetItem)
end

tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end
}