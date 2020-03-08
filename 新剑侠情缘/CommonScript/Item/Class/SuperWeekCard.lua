
local tbItem = Item:GetClass("SuperWeekCard");
local nIndex = 3
function tbItem:OnUse(it)
    local bRet, szMsg = Recharge:IsCanBuySuperDaysCard(me, nIndex)
    if bRet then
        return
    end
    Recharge:AddBuySuperDaysCardCount(me, nIndex)
    me.CenterMsg("您获得了至尊周卡的购买资格!")
    return 1
end

function tbItem:OnClientUse(it)
    local bRet, szMsg = Recharge:IsCanBuySuperDaysCard(me, nIndex)
    if bRet then
        me.CenterMsg("您当前已具备至尊周卡购买资格")
        return
    end
end