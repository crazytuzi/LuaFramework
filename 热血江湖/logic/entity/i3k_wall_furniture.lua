------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity


------------------------------------------------------
i3k_wall_furniture = i3k_class("i3k_wall_furniture", BASE);

function i3k_wall_furniture:ctor(guid)
	self._entityType = eET_WallFurniture
	self._furnitureInfo = {}
	self:CreateActor()
end

function i3k_wall_furniture:create(modelId, furnitureInfo)
	self._furnitureInfo = furnitureInfo
	local mcfg = i3k_db_models[modelId];
	if mcfg then
		self._name		= mcfg.desc;
		if self._entity:CreateHosterModel(mcfg.path, string.format("entity_%s", self._guid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
			self._entity:EnterWorld(false);
		end
	end
end

function i3k_wall_furniture:OnSelected(val)
	if val then
		if g_i3k_game_context:getIsInPlaceState() then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurniture, "setChooseFurniture", self._guid, self._furnitureInfo, g_HOUSE_WALL_FURNITURE)
		end
	end
end

function i3k_wall_furniture:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
	return true;
end

function i3k_wall_furniture:CanRelease()
	return true;
end

function i3k_wall_furniture:ValidInWorld()
	return true;
end