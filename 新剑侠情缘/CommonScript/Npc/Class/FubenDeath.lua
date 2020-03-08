local tbNpc = Npc:GetClass("FubenDeath")

function tbNpc:OnCreate(szParam)
	if not Fuben.KinDefendMgr:IsDefendMap(him.nMapTemplateId) then
		return
	end
	local tbFubenInst = Fuben.tbFubenInstance[him.nMapId]
    if not tbFubenInst then
    	return
    end
    if not tbFubenInst:CanRebornNpc(him.nTemplateId) then
    	Log("FubenDeath:OnCreate delete", him.nTemplateId, him.nMapTemplateId)
		him.Delete()
	end
end

function tbNpc:OnDeath(pKiller)
	if not MODULE_GAMESERVER then
		return;
	end

	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);
	SeriesFuben:OnKillNpc(him, pKiller)
end

function tbNpc:OnEarlyDeath(pKiller)
	if MODULE_GAMESERVER then
		return;
	end

	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);
end