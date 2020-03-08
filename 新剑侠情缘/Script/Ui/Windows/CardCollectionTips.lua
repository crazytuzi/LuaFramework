local tbUi = Ui:CreateClass("CardCollection")

function tbUi:OnOpen(nItemTemplateId, nItemId, tbIntValueInfo)
    if not nItemId and not tbIntValueInfo then
        return 0
    end
end

function tbUi:OnOpenEnd(nItemTemplateId, nItemId, tbIntValueInfo)
    local nCollectionId = CollectionSystem:GetCollectionByItem(nItemTemplateId)
    local nLen = CollectionSystem:GetCollectionLength(nCollectionId)

    local nCompletion = 0
    local nRare = 0
    local tbShowCard = {}
    for i = 1, nLen do
        local szTimeFrame = CollectionSystem:GetTimeFrame(nCollectionId, i)
        if szTimeFrame == "" or GetTimeFrameState(szTimeFrame) == 1 then
            table.insert(tbShowCard, i)
        end
    end
    local nShowLen = #tbShowCard

    local tbComplete = {}
    local tbPosData = {}
    tbIntValueInfo = tbIntValueInfo or {}
    if nItemId then
        nCompletion = CollectionSystem:GetCompletion(nCollectionId)
        for i = 1, nLen do
            tbComplete[i] = CollectionSystem:IsPosActivate(nCollectionId, i)
        end
        local nSaveGroup = CollectionSystem:GetSaveInfo(nCollectionId)
        for i = 1, CollectionSystem.SAVE_LEN do
            local nFlag = me.GetUserValue(nSaveGroup, i + CollectionSystem.DATA_SESSION)
            table.insert(tbPosData, nFlag)
        end
    else
        for i = 1, nLen do
            local _, nSaveKey, nSavePos = CollectionSystem:GetSaveInfo(nCollectionId, i)
            local nFlag = tbIntValueInfo[nSaveKey] or 0
            local bActivate = CollectionSystem:GetDecimalBits(nFlag, nSavePos) > 0
            nCompletion = bActivate and nCompletion + 1 or nCompletion
            tbComplete[i] = bActivate
        end
        for i = 1, CollectionSystem.SAVE_LEN do
            table.insert(tbPosData, tbIntValueInfo[i + CollectionSystem.DATA_SESSION] or 0)
        end
    end
    nRare = CollectionSystem:GetAllRare(nCollectionId, tbPosData)

    self.pPanel:Label_SetText("Have", "[92d2ff]拥有[-] 1 [92d2ff]件[-]")
    self.Details_Item:SetGenericItem({"Item", nItemTemplateId})

    local fnSetItem = function(itemObj, nIdx)
        for i = 1, 3 do
            local nPos = (nIdx - 1)*3 + i
            itemObj.pPanel:SetActive("Item" .. i, nPos <= nShowLen)
            if nPos <= nShowLen then
                local nPosInCollection = tbShowCard[nPos]
                local bActivate = tbComplete[nPosInCollection]
                local szName = bActivate and "[c8ff00]" or "[969696]"
                szName = szName .. CollectionSystem:GetCardName(nCollectionId, nPosInCollection)
                itemObj["Item" .. i].pPanel:Label_SetText("Name" .. i, szName)
                itemObj["Item" .. i].pPanel:Sprite_SetSprite("Main", bActivate and "ListBgLight" or "ListBgDark")

                local nCardId = CollectionSystem:GetCardId(nCollectionId, nPosInCollection)
                itemObj["Item" .. i].pPanel.OnTouchEvent = function ()
                    self:OpenCardTips(nCardId)
                end
            end
        end
        itemObj.pParent = self
    end
    self.ScrollView:Update(math.ceil(nShowLen/3), fnSetItem)

    local bRankBoard = CollectionSystem:IsHaveRankBoard(nCollectionId)
    self.pPanel:SetActive("Btn1", bRankBoard or false)

    self.nCollectionId = nCollectionId
    self.szCollectionInfo = nCollectionId == CollectionSystem.RANDOMFUBEN_ID 
                                and string.format("珍稀度：%d\n完成度：%d/%d", nRare, nCompletion, nShowLen) 
                                or string.format("完成度：%d/%d", nCompletion, nShowLen)
    if bRankBoard then
        if nItemId then
            self:UpdateRankInfo()
            RankBoard:CheckUpdateData("CardCollection_" .. nCollectionId, 1)
        else
            local szPos = (tbIntValueInfo[CollectionSystem.ITEM_RANK] or 0) > 0 and tbIntValueInfo[CollectionSystem.ITEM_RANK] or "未上榜"
            local szInfo = string.format("排名：%s\n%s", szPos, self.szCollectionInfo)
            self.pPanel:Label_SetText("Label1", szInfo)
        end
    else
        self.pPanel:Label_SetText("Label1", self.szCollectionInfo)
    end

    local tbInfo = KItem.GetItemBaseProp(nItemTemplateId)
    self.pPanel:Label_SetText("Label2", tbInfo.szIntro)
    self.pPanel:Label_SetText("Name", tbInfo.szName)

    self.pPanel:SetActive("Btn1", nItemId or false)
    self.pPanel:SetActive("Btn2", nItemId or false)
end

function tbUi:OpenCardTips(nCardId)
    Ui:OpenWindow("ItemTips", "Item", nil, nCardId)
end

function tbUi:UpdateRankInfo(nRank)
    local bRankBoard = CollectionSystem:IsHaveRankBoard(self.nCollectionId)
    if not bRankBoard then
        return
    end
    local szRank = "CardCollection_" .. self.nCollectionId
    local tbMyInfo = RankBoard.tbMyRankInfo[szRank] or {}
    local szPosition = (tbMyInfo.nPosition and tbMyInfo.nPosition > 0) and tbMyInfo.nPosition or "未上榜"
    local szInfo = string.format("排名：%s\n%s", szPosition, self.szCollectionInfo)
    self.pPanel:Label_SetText("Label1", szInfo)
end

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OpenRankBoard()
    Ui:OpenWindow("RankBoardPanel", "CardCollection_" .. self.nCollectionId)
end

function tbUi:CheckCardList()
    if not self.nCollectionId then
        return
    end
    Ui:CloseWindow(self.UI_NAME)
    Ui:OpenWindow("CollectionCardList", self.nCollectionId)
end

function tbUi:CheckShowDown()
    self.pPanel:SetActive("down", not self.ScrollView.pPanel:ScrollViewIsBottom())
end

tbUi.tbOnClick = {
    Btn1 = function (self)
        self:OpenRankBoard()
    end,
    Btn2 = function (self)
        self:CheckCardList(self.nCollectionId)
    end,
}

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_SYNC_RANKBOARD_DATA, self.UpdateRankInfo, self},
    }
end

local tbItem = Ui:CreateClass("CardCollectionListItem")

tbItem.tbOnDrag =
{
    Item1 = function ()
    end,
    Item2 = function ()
    end,
    Item3 = function ()
    end,
}

tbItem.tbOnDragEnd =
{
    Item1 = function (self)
        self.pParent:CheckShowDown()
    end,
    Item2 = function (self)
        self.pParent:CheckShowDown()
    end,
    Item3 = function (self)
        self.pParent:CheckShowDown()
    end,
}