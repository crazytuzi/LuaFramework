------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity


------------------------------------------------------
i3k_house_skin = i3k_class("i3k_house_skin", BASE);

function i3k_house_skin:ctor(guid)
	self._entityType = eET_HouseSkin
	self:CreateActor()
end

function i3k_house_skin:create(modelId)
	local mcfg = i3k_db_models[modelId];
	if mcfg then
		self._resCreated = 0
		self._name		= mcfg.desc;
		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
			self._entity:EnterWorld(false);
		end
	end
end

function i3k_house_skin:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
	return true;
end

function i3k_house_skin:CanRelease()
	return true;
end

function i3k_house_skin:ValidInWorld()
	return true;
end