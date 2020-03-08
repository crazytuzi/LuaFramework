local tbItem = Item:GetClass("XingYiDouZhuanItem")

function tbItem:OnClientUse()
	Ui:CloseWindow("ItemTips");
	Ui:CloseWindow("ItemBox");
	if me.nMapTemplateId == ChangeFaction.tbDef.nMapTID then
		me.CenterMsg("请返回安全区或者主城转门派");
		return;
	end
	local bIsForbit = Item:CheckIsForbid("XingYiDouZhuanItem");
	if bIsForbit then return end;
	Ui:OpenWindow("ChangeFactionPanel");
end