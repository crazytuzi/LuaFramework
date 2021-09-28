------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity


------------------------------------------------------
i3k_furniture = i3k_class("i3k_furniture", BASE);

function i3k_furniture:ctor(guid)
	self._entityType = eET_Furniture
	self._isPlace = false
	self._furnitureInfo = {}
	self._curMountFurniture = nil
	self:CreateActor()
end

function i3k_furniture:create(modelId, furnitureInfo, isPlace)
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

	local additionID = self._furnitureInfo.additionId
	
	if additionID and additionID ~= 0 then
		self:AttachMountFurniture(additionID)
	end
end

function i3k_furniture:OnSelected(val)
	if val then
		if g_i3k_game_context:getIsInPlaceState() then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurniture, "setChooseFurniture", self._guid, self._furnitureInfo, g_HOUSE_FLOOR_FURNITURE)
		end
	end
end

function i3k_furniture:AttachMountFurniture(furnitureID)
	local furnitureCfg = i3k_db_home_land_hang_furniture[furnitureID]  --取朝向模型
	assert(furnitureCfg, string.format("挂饰id：%d取不到配置", furnitureID))
	local modelID = i3k_engine_check_is_use_stock_model(furnitureCfg.models[self._furnitureInfo.direction])
	if modelID and self._entity then
		local cfg = i3k_db_models[modelID]
		
		if cfg then
			if cfg.path then
				self._curMountFurniture = self._entity:LinkHosterChild(cfg.path, string.format("home_land_%s_MountFurniture_%d", self._guid, modelID), i3k_db_home_land_base.houseFurniture.linkPoint, "", 0.0, cfg.scale);
			end
			self._entity:LinkChildShow(self._curMountFurniture, true)
		end
	end
	
	self._furnitureInfo.additionId = furnitureID
end

function i3k_furniture:DetachMountFurniture()
	if self._entity and self._curMountFurniture then
		self._entity:RmvHosterChild(self._curMountFurniture);
	end
end

function i3k_furniture:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
	return true;
end

function i3k_furniture:CanRelease()
	return true;
end

function i3k_furniture:ValidInWorld()
	return true;
end
