----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

------------------------------------------------------
i3k_ai_network_attack = i3k_class("i3k_ai_network_attack", BASE);
function i3k_ai_network_attack:ctor(entity)
	self._type = eAType_ATTACK;
end

function i3k_ai_network_attack:IsValid()
	local entity = self._entity;
	
	if entity._isAttacking then
		return true;
	end

	return false;
end

function i3k_ai_network_attack:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		local target = entity._target;

		if entity._target and entity._target._guid ~= entity._guid then
			local p1 = target._curPos;
			local p2 = entity._curPos;

			local rot_y = i3k_vec3_angle1(p1, p2, { x = 1, y = 0, z = 0 });
			entity:SetFaceDir(0, rot_y, 0);
			
		end
       
		--[[if not entity._curSkill then
			return false;
		end--]]
		--[[self._skill		= entity._curSkill;
		self._canBreak	= self._skill._canBreak;
		self._duration	= self._skill._duration;
		self._attacker	= entity:StartAttack();--]]
		self._startTick	= i3k_game_get_logic_time();
		self._seq_skillidx = 1
		self.rushinit = false;
		self._moveTime	= 0;
		return true;
	end

	return false;
end

function i3k_ai_network_attack:OnLeave()
	if BASE.OnLeave(self) then
	
		return true;
	end

	return false;
end

function i3k_ai_network_attack:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then return false; end
	
	return true;
end

function i3k_ai_network_attack:OnLogic(dTick)
	--i3k_log("i3k_ai_network_attack:"..dTick)
	if not BASE.OnLogic(self, dTick) then return false; end
	
	--i3k_log("self._timeTick:"..self._timeTick.."|"..self._skill._duration)
	if self._attacker and self._skill then
		--i3k_log("self._skill._seq_skill.skills[self._skill._seq_skill.idx]._id:"..self._skill._seq_skill.skills[self._skill._seq_skill.idx]._id)
		if self._skill._seq_skill and self._skill._seq_skill.skills and self._skill._seq_skill.skills[self._seq_skillidx] and self._skill._seq_skill.skills[self._seq_skillidx]._id == self._attacker._skill._id then
			self._seq_skillidx = self._seq_skillidx + 1
			self._duration	= self._attacker._skill._duration;
			self._startTick	= i3k_game_get_logic_time()
			
		end
	end
	if self._skill then
		--i3k_log("skilltime:"..(i3k_game_get_logic_time() - self._startTick) * 1000)
		if (i3k_game_get_logic_time() - self._startTick) * 1000 >= self._duration then
			return false;
		end
	end
	return true;
end

function create_component(entity, priority)
	return i3k_ai_network_attack.new(entity, priority);
end
