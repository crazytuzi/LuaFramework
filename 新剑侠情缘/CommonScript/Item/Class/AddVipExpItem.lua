
local tbItem = Item:GetClass("AddVipExpItem");

function tbItem:OnUse(it)
    local nCount = KItem.GetItemExtParam(it.dwTemplateId, 1);
    --me.SendAward({{"VipExp", nCount*100} }, nil, nil, Env.LogWay_IdIpAddVipExp);
    return 1;
end

