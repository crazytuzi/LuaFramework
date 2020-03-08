local tbItem = Item:GetClass("DiscountCoupon")
tbItem.EXCHANGE_ITEM  = 1
tbItem.EXCHANGE_PRICE = 2
tbItem.EXCHANGE_DIS_PRICE = 3

function tbItem:OnUse(pItem, nCount)
    nCount = nCount or 1
    if nCount <= 0 then
        return
    end
    if pItem.nCount < nCount then
        me.CenterMsg("道具数量不足")
        return
    end

    local nPrice  = KItem.GetItemExtParam(pItem.dwTemplateId, self.EXCHANGE_DIS_PRICE)
    local nItemId = pItem.dwId
    me.CostGold(nPrice*nCount, Env.LogWay_DiscountCoupon, nil,
        function (nPlayerId, bSuccess)
            local bRet, szMsg = self:OnCostCallback(nPlayerId, bSuccess, nItemId, nCount)
            return bRet, szMsg
        end)
end

function tbItem:OnCostCallback(nPlayerId, bSuccess, nItemId, nCount)
    if not bSuccess then
        return false, "支付失败"
    end

    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return false, "掉线了，请重试"
    end

    local pItem = KItem.GetItemObj(nItemId)
    if not pItem or pItem.nCount < nCount then
        return false, "道具数量不足"
    end

    local nRet = pPlayer.ConsumeItem(pItem, nCount, Env.LogWay_DiscountCoupon)
    if nRet ~= nCount then
        Log("DiscountCoupon OnCostCallback Fail", nPlayerId, nItemId, nCount, nRet)
        return false, "道具消耗失败"
    end

    local nItem = KItem.GetItemExtParam(pItem.dwTemplateId, self.EXCHANGE_ITEM)
    pPlayer.SendAward({{"Item", nItem, nCount}}, true, false, Env.LogWay_DiscountCoupon)
    Log("DiscountCoupon OnCostCallback:", nPlayerId, nCount)
    return true
end

function tbItem:OnClientUse(pItem)
    if pItem then
        local nItem = KItem.GetItemExtParam(pItem.dwTemplateId, self.EXCHANGE_ITEM)
        local nPrice = KItem.GetItemExtParam(pItem.dwTemplateId, self.EXCHANGE_PRICE)
        local nDisPrice = KItem.GetItemExtParam(pItem.dwTemplateId, self.EXCHANGE_DIS_PRICE)
        Ui:OpenWindow("DiscountCouponPanel", pItem, nItem, nPrice, nDisPrice)
        Ui:CloseWindow("ItemTips")
    end
    return 1
end