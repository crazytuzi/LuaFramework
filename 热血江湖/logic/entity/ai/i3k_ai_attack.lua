----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

------------------------------------------------------
i3k_ai_attack = i3k_class("i3k_ai_attack", BASE);
function i3k_ai_attack:ctor(entity)
	self._type = eAType_ATTACK;
end

function i3k_ai_attack:IsValid()
	local entity = self._entity;

	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end
	if entity:GetEntityType() == eET_Player and entity._DigStatus == 2 then
		return false;
	end

	if entity:GetEntityType() == eET_Trap then
		if entity._ntype ~= eEntityTrapType_AOE then
			return false;
		else
			if entity._curSkill and entity._curSkill:CanUse() then
				return true
			end
		end
	end

	if not g_i3k_game_context:GetMapEnter() then
		return false;
	end

	if entity._behavior:Test(eEBAttack) then
		return true;
	end

	if entity._curSkill and entity._curSkill:CanUse() then
		local target = entity._target;
		if target then
			if not target:IsPlayer() then
				if target._behavior:Test(eEBInvisible) then
					return false;
				end
			end
			local dist = i3k_vec3_sub1(entity._curPos, target._curPos);
			if (entity._curSkill._range + (entity:GetRadius() + target:GetRadius())) > i3k_vec3_len(dist) then
				return true;
			end

			return false;
		else
			if entity:GetEntityType() == eET_Player then 
				if entity._AutoFight then
					return false
				end
			elseif entity:GetEntityType() == eET_Mercenary then
				if entity._cfg.ultraSkill == entity._curSkill._id then
					return true
				end

				if entity._curSkill._specialArgs.rushInfo and not entity._hoster:IsPlayer() then
					return true
				end
			end
		end

		return self:CanAttackNoneTarget();
	end

	return false;
end

function i3k_ai_attack:CanAttackNoneTarget()
	return false;
end

function i3k_ai_attack:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		local target = entity._target;

		local speed = entity:GetPropertyValue(ePropID_speed);
		if speed > 0 and entity._target and entity._target._guid ~= entity._guid then
			local p1 = target._curPos;
			local p2 = entity._curPos;

			local rot_y = i3k_vec3_angle1(p1, p2, { x = 1, y = 0, z = 0 });
			entity:SetFaceDir(0, rot_y, 0);
		end

		self._startTick	= i3k_game_get_logic_time();
		self._skill		= entity._curSkill;
		self._canBreak	= self._skill._canBreak;
		self._duration	= self._skill._duration;
		self._attacker	= entity:StartAttack();
		self._movable = entity._movable;
		if not self._attacker then
			return false;
		end

		self._entity._movable = false;

		return true;
	end

	return false;
end

function i3k_ai_attack:OnLeave()
	if BASE.OnLeave(self) then
		if self._canBreak and self._attacker then
			self._attacker:StopAttack(false);
		end

		self._entity:FinishAttack();

		self._entity._movable = self._movable;

		return true;
	end

	return false;
end

function i3k_ai_attack:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then return false; end

	return true;
end

function i3k_ai_attack:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	local seq_skill = self._entity._seq_skill;
	if seq_skill and seq_skill.valid and seq_skill.parent == self._skill then
		seq_skill.valid = false;

		if self._attacker then
			if self._attacker:NextSequence(seq_skill.skill) then
				self._duration	= seq_skill.skill._duration;
				self._startTick	= i3k_game_get_logic_time();
			end
		end
	end

	if self._skill then
		if (i3k_game_get_logic_time() - self._startTick) * 1000 >= self._duration then
			return false;
		end
	end

	return true;
end

function create_component(entity, priority)
	return i3k_ai_attack.new(entity, priority);
end
