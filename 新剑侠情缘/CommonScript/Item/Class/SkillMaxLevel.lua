
------------------取消通过该类道具提升技能等级上限功能 FT-12158 ------------------

local tbItem = Item:GetClass("SkillMaxLevel");
function tbItem:CheckSellItem(pPlayer, nItemTemplateId)
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
    if not Compose.UnCompose:CanUnCompose(nItemTemplateId) then
        return
    end
    return {szFirstName = "拆分", fnFirst = "UnCompose"};
end