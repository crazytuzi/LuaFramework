----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

------------------------------------------------------
i3k_ai_fear = i3k_class("i3k_ai_fear", BASE);
function i3k_ai_fear:ctor(entity)
	self._type = eAType_FEAR;
end

function i3k_ai_fear:IsValid()
	if self._entity:IsDead() then
		return false;
	end

	if self._entity._behavior:Test(eEBFear) then
		if self._entity._fearPos then
			return false;
		end

		return true;
	end

	return false;
end

function i3k_ai_fear:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		local rnd_x = i3k_integer(i3k_engine_get_rnd_f(-1, 1) * 500);
		local rnd_z = i3k_integer(i3k_engine_get_rnd_f(-1, 1) * 500);

		local _pos = { };
			_pos.x = entity._curPos.x + rnd_x;
			_pos.y = entity._curPos.y;
			_pos.z = entity._curPos.z + rnd_z;
		_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(_pos)));		

		entity:FearTo(_pos, false);

		return true;
	end

	return false;
end

function i3k_ai_fear:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_fear:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_fear:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_fear.new(entity, priority);
end

