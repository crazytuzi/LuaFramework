local tbNpc = Npc:GetClass("FairylandPeach");

function tbNpc:OnDialog()
	me.CallClientScript("Ui:OpenWindow", "PeachPanel");
end