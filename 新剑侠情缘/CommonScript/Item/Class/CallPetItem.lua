local tbItem = Item:GetClass("CallPetItem")
tbItem.nExtSurviveDays = 1
tbItem.nExtPetTemplateId = 2

function tbItem:CheckCanUse(nPetTemplateId)
    local tbHouse = House:GetHouse(me.dwID)
    if not tbHouse then
        return false, "没有家园"
    end

    return true
end

function tbItem:OnUse(it)
    local nPetTemplateId = KItem.GetItemExtParam(it.dwTemplateId, self.nExtPetTemplateId)
    local bOk, szErr = self:CheckCanUse(nPetTemplateId)
    if not bOk then
        me.CenterMsg(szErr)
        return
    end

    local nPlayerId = me.dwID
    local nSurviveDays = KItem.GetItemExtParam(it.dwTemplateId, self.nExtSurviveDays)
    local tbInfo = Pet:GetPetInfo(nPlayerId)
    if tbInfo and tbInfo[nPetTemplateId] then
        local tbHouse = House:GetHouse(nPlayerId)
        tbHouse.tbPets[nPetTemplateId].nDeadline = nSurviveDays<=0 and -1 or (tbInfo[nPetTemplateId].nDeadline+24*3600*nSurviveDays)
        House:Save(nPlayerId)
    else
        local nDeadline = nSurviveDays<=0 and -1 or (GetTime()+24*3600*nSurviveDays)
        Pet:SetPetInfo(nPlayerId, nPetTemplateId, nDeadline)
    end
    if Pet:Spawn(me, me.dwID) and House:IsIndoor(me) then
        Pet:CallAround(me, me.dwID, true)
    end

    me.CenterMsg(string.format("使用%s成功", it.szName))
    Log("CallPetItem:OnUse", nPlayerId, it.dwTemplateId, nPetTemplateId, nSurviveDays, nDeadline)
    return 1
end
