local tbItem = Item:GetClass("BWZQReplaceItem");

function tbItem:OnUse(it)
	if not Activity:__IsActInProcessByType("NpcBiWuZhaoQin") then
		me.CenterMsg("当前并无比武招亲活动！")
		return 
	end
	Activity:OnPlayerEvent(me, "Act_NpcBiWuZhaoQinClientCall", "UseReplaceItem");
end