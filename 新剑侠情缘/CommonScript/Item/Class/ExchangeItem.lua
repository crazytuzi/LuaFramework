local tbItem = Item:GetClass("ExchangeItem")
function tbItem:OnUse(pItem)
    local bRet, szMsg = self:CheckConsume(pItem)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nChangeTemplateId = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
    me.SendAward({{"item", nChangeTemplateId, 1}}, nil,nil, Env.LogWay_ExchangeItem)
    me.CenterMsg("兑换成功")
end

function tbItem:CheckConsume(pItem)
    local nNeedNum = KItem.GetItemExtParam(pItem.dwTemplateId, 2)
    if not nNeedNum or nNeedNum <= 0 then
        return false, "该道具不能兑换"
    end

    local nConsumeNum = me.ConsumeItemInAllPos(pItem.dwTemplateId, nNeedNum, Env.LogWay_ExchangeItem)
    if nConsumeNum < nNeedNum then
        return false, "数量不足"
    end

    return true
end