----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_cast_find_target = i3k_class("i3k_ai_autofight_cast_find_target", BASE);
function i3k_ai_autofight_cast_find_target:ctor(entity)
	self._type		= eAType_AUTOFIGHT_CAST_FIND_TARGET;
	self._target	= nil;
end

function i3k_ai_autofight_cast_find_target:IsValid()
	local entity = self._entity;
	if not entity._AutoFight then
		return false;
	end

	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end

	if entity._PreCommand == ePreTypeClickMove or entity._PreCommand == ePreTypeJoystickMove then
		return false;
	end

	if not entity._behavior:Test(eEBAttack) and entity._behavior:Test(eEBDisAttack) then
		local radius = entity:GetPropertyValue(ePropID_alertRange);
		local world = i3k_game_get_world();
		if world._cfg.autofightradius then
			radius = world._cfg.autofightradius;
		end

		local castskill = nil;

		for k, v in pairs(entity._attacker) do
			if v._skill._specialArgs.castInfo and v._skill._cfg.forceBreak == 0 then
				castskill = v._skill;

				break;
			end
		end

		if castskill then
			local range = castskill._range;

			local target = nil;

			local stype = castskill._cfg.type;
			if stype == eSE_Damage or stype == eSE_DBuff then -- 伤害、诅咒
				if entity._forceAttackTarget and not entity._forceAttackTarget:IsDead() then
					local dist = i3k_vec3_dist(entity._forceAttackTarget._curPos, entity._curPos);
					if dist > range and dist <= radius then
						target = entity._forceAttackTarget;
					else
						return false;
					end
				else
					local enmities = entity:GetEnmities();
					if enmities then
						local enmity = enmities[1];
						if enmity then
							local dist = i3k_vec3_dist(enmity._curPos, entity._curPos);
							if dist > range and dist <= radius then
								target = enmity;
							else
								return false;
							end
						end
					end

					if not target or target._groupType == eGroupType_N then
						local tentity = entity._alives[2][1];
						if tentity then
							if tentity.dist > range and tentity.dist <= radius then
								target = tentity.entity;
							else
								return false;
							end
						end
					end
				end
			elseif stype == eSE_Buff then
				-- if entity._target and entity._target._guid == entity._guid then
				-- 	return false;
				-- end 
				-- self._target = entity;
	
				-- return true;
				return false
			end

			if target then
				self._target = target;

				return not entity._target or target._guid ~= entity._target._guid;
			end
		end
	end
	
	return false;
end

function i3k_ai_autofight_cast_find_target:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		if self._target then
			local rnd_x =  i3k_engine_get_rnd_f(-1.5, 1.5);
			local rnd_z =  i3k_engine_get_rnd_f(-1.5, 1.5);
			local pos1 = { x = rnd_x + self._target._curPosE.x, y = self._target._curPosE.y, z = rnd_z + self._target._curPosE.z};
			entity:MoveTo(pos1,true);
		end

		return true;
	end

	return false;
end

function i3k_ai_autofight_cast_find_target:OnLeave()
	if BASE.OnLeave(self) then
		self._target = nil;

		return true;
	end

	return false;
end

function i3k_ai_autofight_cast_find_target:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_cast_find_target:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_autofight_cast_find_target.new(entity, priority);
end

