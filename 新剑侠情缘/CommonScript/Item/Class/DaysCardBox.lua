local tbItem = Item:GetClass("DaysCardBox")

function tbItem:CheckUse(it)
    local nLeftDay = Recharge:GetDaysCardLeftDay(me, 1)
    if nLeftDay <= 0 then
        return false, "无法开启礼包，少侠当前不处于7日礼包时效内"
    end

    return true
end

function tbItem:OnUse(it)
    local bRet, szMsg = self:CheckUse(it)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end

    local nItemTID = KItem.GetItemExtParam(it.dwTemplateId, 1)
    if nItemTID <= 0 then
        return
    end

    me.SendAward({{"Item", nItemTID, 1}}, nil, nil, Env.LogWay_FirstRechargeAward)
    return 1
end

function tbItem:OnClientUse(it)
    local bRet, szMsg = self:CheckUse(it)
    if not bRet then
        local fnGo = function ()
            Ui:OpenWindow("WelfareActivity","RechargeGift")
        end
    
        me.MsgBox("无法开启礼包，少侠当前不处于[FFFE0D]7日礼包[-]时效期内。", {{"前往购买", fnGo}, {"暂不购买"}})
        return 1
    end
end