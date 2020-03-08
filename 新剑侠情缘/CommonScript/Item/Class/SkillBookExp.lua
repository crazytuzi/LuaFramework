
local tbItem = Item:GetClass("SkillBookExp");
tbItem.nBookExpValue = 1;

function tbItem:OnUse(it)
    local nExpValue = KItem.GetItemExtParam(it.dwTemplateId, tbItem.nBookExpValue);
    if nExpValue <= 0 then
        return;
    end

    local tbBook = Item:GetClass("SkillBook");
    tbBook:UpdateGrowXiuLianExp(me);
    local tbAllAward = {{tbBook.szSkillBookExpName, nExpValue}};
    me.SendAward(tbAllAward, true, false, Env.LogWay_MiJi);
    me.CallClientScript("Player:ServerSyncData", "AddSkillBookExp");
    return 1;
end    