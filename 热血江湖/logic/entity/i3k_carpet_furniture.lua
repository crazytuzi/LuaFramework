------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity


------------------------------------------------------
i3k_carpet_furniture = i3k_class("i3k_carpet_furniture", BASE);

function i3k_carpet_furniture:ctor(guid)
	self._entityType = eET_CarpetFurniture
	self._isPlace = false
	self._furnitureInfo = {}
	self._curMountFurniture = nil
	self:CreateActor()
end

function i3k_carpet_furniture:create(modelId, furnitureInfo, isPlace)
	self._furnitureInfo = furnitureInfo
	self._isPlace = isPlace
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

function i3k_carpet_furniture:OnSelected(val)
	if val then
		if g_i3k_game_context:getIsInPlaceState() then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurniture, "setChooseFurniture", self._guid, self._furnitureInfo, g_HOUSE_CARPET_FURNITURE)
		end
	end
end

function i3k_carpet_furniture:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
	return true;
end

function i3k_carpet_furniture:CanRelease()
	return true;
end

function i3k_carpet_furniture:ValidInWorld()
	return true;
end