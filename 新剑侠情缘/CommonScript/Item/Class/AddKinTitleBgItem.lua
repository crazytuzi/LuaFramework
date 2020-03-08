local tbItem = Item:GetClass("AddKinTitleBgItem")

tbItem.nExtBgId = 1

function tbItem:OnUse(it)
    local nKinId = me.dwKinId
    local tbKinData = Kin:GetKinById(nKinId or 0)
    if not tbKinData then
        me.CenterMsg("你没有家族，无法使用")
        return
    end

    if tbKinData:GetLeaderId() ~= me.dwID then
        me.CenterMsg("你不是家族领袖，无法使用")
        return
    end

    local nItemTempId = it.dwTemplateId
    local nBgId = KItem.GetItemExtParam(nItemTempId, self.nExtBgId) or 0

    Kin:SetKinTitleBg(nKinId, nBgId)
    me.CenterMsg(string.format("使用%s成功", it.szName))
    me.CallClientScript("Ui:CloseWindow", "ItemBox")
    me.CallClientScript("Ui:CloseWindow", "ItemTips")
    Log("Use AddKinTitleBgItem", nKinId, me.dwID, it.dwTemplateId, nBgId)
    return 1
end