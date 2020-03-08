local tbItem = Item:GetClass("JingMaiItem")

function tbItem:OnUse(it)
	if not JingMai:CheckOpen(me) then 
		me.CenterMsg("此经脉尚不可打通，请少侠迟些时日再试试", true)
		return
	end
	local nJingMaiId = KItem.GetItemExtParam(it.dwTemplateId, 1);
	me.CallClientScript("Ui:OpenWindow", "JingMaiPanel", nJingMaiId)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
end