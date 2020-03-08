--战场npc 包括建筑
local tbNpc = Npc:GetClass("BattleNpc") 

function tbNpc:OnDeath(pKiller)
	Battle:OnNpcDeath(him, pKiller)
end

function tbNpc:OnEarlyDeath(pKiller)
	if Battle.OnEarlyDeath then
		Battle:OnEarlyDeath( him, pKiller )
	end
end