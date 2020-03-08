local tbItem = Item:GetClass("MaterialCollectBox");

function tbItem:OnUse(it)
	me.CallClientScript("Ui:OpenWindow", "MaterialBoxPanel")
end