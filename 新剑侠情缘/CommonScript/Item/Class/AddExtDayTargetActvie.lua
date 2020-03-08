local tbItem = Item:GetClass("AddExtDayTargetActvie")
function tbItem:OnUse(it)
    local nCurValue = EverydayTarget:GetTotalActiveValue(me)
    if nCurValue >= 100 then
        me.CenterMsg("活跃已满，无法使用")
        return
    end

    local nExtValue = KItem.GetItemExtParam(it.dwTemplateId, 1)
    EverydayTarget:AddActExtActiveValue(me, nExtValue, "Item_" .. it.dwTemplateId)
    me.CenterMsg(string.format("使用成功，增加了%d点活跃", nExtValue))
    return 1
end