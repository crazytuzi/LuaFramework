----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_damage_car = i3k_class("i3k_ai_damage_car", BASE);
function i3k_ai_damage_car:ctor(entity)
	self._type	= eAType_DAMAGE_CAR;
end

function i3k_ai_damage_car:IsValid()
	local entity = self._entity;
	if entity._carState ~= 0 and entity._isReplaceCar then
		return true
	end
	return false;
end

function i3k_ai_damage_car:OnEnter()
	if BASE.OnEnter(self) then
		--设置模型
		--self._entity._cfg.modelID = self._entity._cfg.damage_model
		--self._entity._cfg.rescfg	= i3k_db_models[self._entity._cfg.modelID]
		self._entity:ChangeModelFacade(self._entity._cfg.damage_model)
		self._entity._isReplaceCar = false
		return true;
	end

	return false;
end

function i3k_ai_damage_car:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_damage_car:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_damage_car:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_damage_car.new(entity, priority);
end
