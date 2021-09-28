-- 挂载entity
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity;


------------------------------------------------------
i3k_entity_mount = i3k_class("i3k_entity_mount", BASE);
function i3k_entity_mount:ctor(guid)
	self._cfg = {}
	self._cfg.speed 	= 10
	self._entityType	= eET_Mount;
	self._birthPos		= Engine.SVector3(0, 0, 0);
	self._groupType		= eGroupType_N -- 中立
	self:CreateActor()
end

function i3k_entity_mount:createMount(modelId)
	self._id = modelId
	self:CreateRes(modelId)
end

function i3k_entity_mount:CreateResSync(modelID)
	local mcfg = i3k_db_models[modelID];
	if mcfg and self._entity then
		self._rescfg = mcfg;

		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._resCreated	= self._resCreated - 1;
			
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);

			self._entity:EnterWorld(false);
		end
	end
end

function i3k_entity_mount:IsAttackable(attacker)
	return false;
end

function i3k_entity_mount:CanRelease()
	return true;
end

function i3k_entity_mount:ValidInWorld()
	return true;
end
