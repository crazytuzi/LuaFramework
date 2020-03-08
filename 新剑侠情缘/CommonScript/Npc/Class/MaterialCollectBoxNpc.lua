local tbNpc = Npc:GetClass("MaterialCollectBoxNpc");
function tbNpc:OnDialog()
	me.CallClientScript("Ui:OpenWindow", "MaterialCollectPanel")
end
