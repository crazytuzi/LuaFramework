local tbItem = Item:GetClass("AnniversaryJiYuActMaterial")
local tbAct = MODULE_GAMESERVER and Activity:GetClass("AnniversaryJiYuAct") or Activity.AnniversaryJiYuAct

function tbItem:OnClientUse(pItem)
	--前往指定NPC处提交材料
	Ui:CloseWindow("ItemBox")
	tbAct:GotoSubmitMaterial()
end