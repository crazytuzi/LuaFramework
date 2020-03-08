
local tbNpc = Npc:GetClass("HideHeadNpc");

function tbNpc:OnNpcLoadFinish(pNpc)
	Ui.Effect.SetAvatarHeadVisable(pNpc.nId, false);
end
