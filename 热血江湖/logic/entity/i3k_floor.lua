------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity


------------------------------------------------------
i3k_floor = i3k_class("i3k_floor", BASE);

function i3k_floor:ctor(guid)
	self._entityType	= eET_Floor;
	self:CreateActor()
end

function i3k_floor:Create(modelId, gid)
	self._gid = gid
	local mcfg = i3k_db_models[modelId];
	if mcfg then
		self._resCreated = 0
		self._name		= mcfg.desc;
		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._gid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
			self._entity:EnterWorld(false);
		end
	end
end

function i3k_floor:OnSelected(val)
	if val then
		
	end
end

function i3k_floor:CanRelease()
	return true;
end

function i3k_floor:ValidInWorld()
	return true;
end