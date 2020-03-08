local tbItem = Item:GetClass("JueYao")
function tbItem:OnCreate(pEquip)
    ZhenFa:OnGenerate(pEquip)
end

function tbItem:OnUse(pItem)
    return ZhenFa:TryEquipJueYao(me, pItem)
end

local tbMaterial = Item:GetClass("JueYaoMaterial")
function tbMaterial:OnClientUse(pItem)
    Ui:OpenWindow("ZhenFaStrengthPanel")
    Ui:CloseWindow("ItemTips")
    return 1
end