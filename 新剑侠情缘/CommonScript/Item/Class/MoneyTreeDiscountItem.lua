local tbItem = Item:GetClass("MoneyTreeDiscountItem")
function tbItem:OnUse(it)
	MoneyTree:OnUseDiscountItem(me)
	me.CenterMsg("使用成功")
    return 1
end