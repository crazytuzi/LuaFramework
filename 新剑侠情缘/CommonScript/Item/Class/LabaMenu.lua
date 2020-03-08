local tbItem = Item:GetClass("LabaMenu");
function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("LabaAct") then
		me.CenterMsg("活动已经结束", true)
		return
	end
	me.CallClientScript("Activity.LabaAct:OnUseLabaMenu")
end
