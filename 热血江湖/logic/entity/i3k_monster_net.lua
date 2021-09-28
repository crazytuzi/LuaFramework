------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_monster").i3k_monster;



------------------------------------------------------
i3k_monster_net = i3k_class("i3k_monster_net", BASE);
function i3k_monster_net:ctor(guid)
	self._entityType	= eET_Monster;
	self._isBoss		= false;
	self._enmities		= { };
	self._birthPos		= Engine.SVector3(0, 0, 0);
end

function i3k_monster_net:Create(id, agent)
	local cfg = i3k_db_monsters[id];
	if not cfg then
		return false;
	end
	self._isBoss = cfg.boss ~= 0;
	for k,v in pairs(cfg.statusList) do
		self._behavior:Set(tonumber(v))
	end
	local skills = { };
	if cfg.skills then
		for k, v in ipairs(cfg.skills) do
			skills[v] = { id = v, lvl = cfg.slevel[k] or 0 };
		end
	end
	return self:CreateFromCfg(id, cfg.name, cfg, cfg.level, skills, agent);
end

function i3k_monster_net:CanAttack()
	return true
end
