local tbNpc = Npc:GetClass("FubenAddNpc");

function tbNpc:OnDeath(pKiller)
	Fuben:OnKillNpc(him, pKiller);
	Fuben:NpcUnLock(him);

	local nNpcId = tonumber(him.szScriptParam);
	if not nNpcId then
		return;
	end

	local nMapId, nX, nY = him.GetWorldPos();
	local pNpc = KNpc.Add(nNpcId, 10, -1, nMapId, nX, nY);
end
