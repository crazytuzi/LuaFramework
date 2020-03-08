function CollectionSystem:GetCardName(nCollectionId, nPos)
    local tbCollection = self.tbCollection[nCollectionId]
    if not tbCollection then
        return ""
    end

    return tbCollection.tbCard[nPos].szName
end

function CollectionSystem:GetCardId(nCollectionId, nPos)
    local tbCollection = self.tbCollection[nCollectionId]
    if not tbCollection then
        return ""
    end

    return tbCollection.tbCard[nPos].nCard
end

function CollectionSystem:GetTimeFrame(nCollectionId, nPos)
    local tbCollection = self.tbCollection[nCollectionId]
    if not tbCollection then
        return
    end

    for nIdx, tbInfo in ipairs(tbCollection.tbCard) do
        if nPos == nIdx then
            return self.tbCard[tbInfo.nCard].szTimeFrame
        end
    end
end

function CollectionSystem:GetCollectionByItem(nItemTemplateId)
    for nCollectionId, tbInfo in pairs(self.tbCollection) do
        if tbInfo.nItemTemplateId == nItemTemplateId then
            return nCollectionId
        end
    end
end

function CollectionSystem:GetRandomCompletion()
    local nCompletion = self:GetCompletion(1)
    local nLen = self:GetCollectionLength(1)
    return string.format("完成度: %d/%d", nCompletion, nLen)
end

function CollectionSystem:OnSyncActivityState(tbState)
    self.tbState = tbState
end

function CollectionSystem:GetActivityState(nCollectionId)
    self.tbState = self.tbState or {}
    for _, nOpenedId in pairs(self.tbState) do
        if nOpenedId == nCollectionId then
            return true
        end
    end
end