------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE =
	require("logic/entity/i3k_mercenary").i3k_mercenary;


------------------------------------------------------
i3k_ghost = i3k_class("i3k_ghost", BASE);
function i3k_ghost:ctor(guid)
	self._isBoss		= false;
end

function i3k_ghost:CreateGhost(id, modelID)
	if id == -1 then
		self._entityType = eET_Ghost;
	end

	if modelID then
		self:CreateRes(modelID);
	end
end

function i3k_ghost:CreateGhostRes(entityType, cfg) --ºÃ≥–÷ÿ–¥
	self._entityType	= entityType
	self._cfg			= cfg;
	self._lvl			= 1;
	self._name			= "";
	
	self:EnableOccluder(true);

	return self:CreateFromCfg(-1, cfg.name, cfg, self._lvl);
end

function i3k_ghost:GetAliveTick()
	return self._aliveTick;
end

function i3k_ghost:OnLogic(dTick)
	BASE.OnLogic(self, dTick);

	return true;
end

function i3k_ghost:CanRelease()
	return true;
end

