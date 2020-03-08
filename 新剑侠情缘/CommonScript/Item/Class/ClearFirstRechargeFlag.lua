local tbItem = Item:GetClass("ClearFirstRechargeFlag")

function tbItem:OnUse()
    self:Clear(me)
    return 1
end

function tbItem:Clear(pPlayer)
    Recharge:ClearBuyedFlag(pPlayer)
    Log("ClearFirstRechargeFlag Success", pPlayer.dwTID, (it or {}).dwId or 0)
end

function tbItem:OnTimeOut(dwTID, nCount)
    self:Clear(me)
    me.CenterMsg("成功重置所有充值档位", true)
end

function tbItem:OnClientUse(it)
    if self:IsHaveFirstAward() then
        local fnGo = function ()
            RemoteServer.UseItem(it.dwId)
        end
    
        me.MsgBox("当前尚有未充值的双倍档位，是否确定使用?", {{"使用", fnGo}, {"取消"}})
        return 1
    end
end

function tbItem:IsHaveFirstAward()
    local nMaxBit = 0
    for _, tbInfo in pairs(Recharge.tbProductionSettingAll) do
        if tbInfo.tbFirstAward then
            nMaxBit = math.max(nMaxBit, tbInfo.nGroupIndex)
        end
    end

    local nFlag = Recharge:GetBuyedFlag(me)
    for i = 1, nMaxBit do
        if KLib.GetBit(nFlag, i) == 0 then
            return true
        end
    end
end