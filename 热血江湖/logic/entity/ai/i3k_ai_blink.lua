----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

------------------------------------------------------
i3k_ai_blink = i3k_class("i3k_ai_blink", BASE);
function i3k_ai_blink:ctor(entity)
	self._type = eAType_Blink;
end

function i3k_ai_blink:IsValid()
	local entity = self._entity;

	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end
	if entity:GetEntityType() == eET_Player and entity._DigStatus == 2 then
		return false;
	end

	if not g_i3k_game_context:GetMapEnter() then
		return false;
	end
	
	if not entity._isBlinkSkill then
		return false;
	end
	
	if entity._curSkill then
		local target = entity._target;
		if target and target._guid ~= entity._guid then
			if entity:GetEntityType() == eET_Player and entity._curSkill._specialArgs.blink then
				local blink =  entity._curSkill._specialArgs.blink
				self._radius = entity:GetRadius() + target:GetRadius();
				local dist = i3k_vec3_dist(entity._curPos, target._curPos) - self._radius; 
				if dist < entity._curSkill._range then
					return false;
				end
				if dist <= blink.distance then
					local dist = blink.distance - entity._curSkill._range + blink.amendDistance;
					local dir = i3k_vec3_normalize1(i3k_vec3_sub1(target._curPos, entity._curPos));
					local moveInfo = i3k_engine_trace_line(entity._curPosE, dir, dist, 1);	
					if moveInfo.valid then
						self._targetPos = moveInfo.path;
						local dist1 = i3k_vec3_dist(entity._curPos, moveInfo.path) - self._radius; 
						if dist1 < entity._curSkill._range then
							return false;
						end
						if dist1 > blink.distance + self._radius then
							return false
						end
						return true;
					end
				end
			end	
		end
	end

	return false;
end

function i3k_ai_blink:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_blink:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_blink:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return true;
	end

	return false;
end

function i3k_ai_blink:OnEnter()
	if BASE.OnEnter(self) and self._entity._isBlinkSkill then
		self._entity:SetPos(self._targetPos, true);
		self._entity:BlinkEndPos(self._targetPos)
		self._entity._isBlinkSkill = false;
		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_blink.new(entity, priority);
end
