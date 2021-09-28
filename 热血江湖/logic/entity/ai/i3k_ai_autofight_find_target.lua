----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_find_target = i3k_class("i3k_ai_autofight_find_target", BASE);
function i3k_ai_autofight_find_target:ctor(entity)
	self._type		= eAType_AUTOFIGHT_FIND_TARGET;
	self._target	= nil;
end

function i3k_ai_autofight_find_target:IsValid()
	local entity = self._entity;
	if not entity._AutoFight then
		return false;
	end
	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end
	
	local filterdist = entity:GetPropertyValue(ePropID_alertRange)
	local world = i3k_game_get_world();
	if world._cfg.autofightradius then
		filterdist = world._cfg.autofightradius
	end
	local r1 = entity:GetRadius();
	if entity._PreCommand == ePreTypeClickMove or entity._PreCommand == ePreTypeJoystickMove then
		return false;
	end	

	if entity._curSkill then
		local target = nil;
		local ignoreDist = false;
		local stype = entity._curSkill._cfg.type;
		if stype == eSE_Damage or stype == eSE_DBuff then -- 伤害、诅咒
			if entity._forceAttackTarget and not entity._forceAttackTarget:IsDead() then
				ignoreDist = true;
				target = entity._forceAttackTarget;
			else
				local enmities = entity:GetEnmities();
				if enmities then
					local enmity = enmities[1];
					if enmity then
						ignoreDist = true;
						target = enmity;
					end
				end
					
				if not target or target._groupType == eGroupType_N then
					
					local tentity = nil
					local mapType = i3k_game_get_map_type();
					for i,v in ipairs(entity._alives[2]) do
						local r2 =  entity._alives[2][i].entity:GetRadius();
						local radius = r1 + r2;	
						if radius then
							if mapType then
								if mapType == g_ARENA_SOLO or mapType == g_TAOIST then
									break;
								end
							end
							
							if entity._alives[2][i].dist < entity._curSkill._range + radius then
								tentity = entity._alives[2][i];
								if entity._alives[2][i+1] and entity._alives[2][i+1].dist then
									if tentity.dist <  entity._alives[2][i+1].dist then
										tentity = entity._alives[2][i+1];
									else
										tentity = entity._alives[2][i];
									end
								else
									tentity = entity._alives[2][i];
									break;
								end
							else
								if v.entity:GetEntityType() == eET_Player and v.dist > filterdist then
									if entity._alives[2][i+1] and entity._alives[2][i+1].dist < filterdist then
										tentity = entity._alives[2][i+1];
										break;	
									end
								else
									tentity = entity._alives[2][i-1];
									break;	
								end
							end		
						end
					end
					
					if entity._groupType == eGroupType_O then
						
						local nentity = tentity or entity._alives[2][1] or entity._alives[3][1]
						if target and nentity and nentity.entity and nentity.entity._groupType ~= eGroupType_N  then
							target = nentity.entity;
						elseif not ignoreDist then
							target = tentity or entity._alives[2][1];
							if entity._alives[3][1] then
								local trap =  entity._alives[3][1];
								if trap.entity and trap.entity._traptype == eSTrapActive then
									target = entity._alives[3][1];			
								end
							end
						
							if nentity and nentity.entity._groupType == eGroupType_N and nentity.dist > i3k_db_common.droppick.AutoFightMapbuffAutoRange then
								target = nil;
								return false;
							end
						end
					else
						target = tentity or entity._alives[2][1] -- 敌方
					end
				end
			end
		elseif stype == eSE_Buff then -- 祝福
			if entity._target and entity._target._guid == entity._guid then
				return false;
			end 
			self._target = entity;
			
			return true;
		end

		if target then
			if ignoreDist then
				if not (target:GetEntityType() == eET_Pet and (not entity._enmities or #entity._enmities <= 0)) then
					self._target = target;
				end

				if not entity._target or entity._target:IsDead() then
					return true;
				end
	
				return target._guid ~= entity._target._guid;
			else
				local r2 = target.entity:GetRadius();
				local radius = r1 + r2;
				if target.dist < filterdist + radius then
					
					if not (target.entity:GetEntityType() == eET_Pet and (not entity._enmities or #entity._enmities <= 0)) then
						self._target = target.entity;
					end
					if not entity._target or entity._target:IsDead() then
						return true;
					end
					if target.dist < entity._curSkill._range + radius then
						return false;
					end
					return target.entity._guid ~= entity._target._guid;
				end
			end
		end
	end

	return false;
end

function i3k_ai_autofight_find_target:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		--i3k_log("i3k_ai_autofight_find_target")
		entity._behavior:Clear(eEBGuard);

		if self._target then
			if entity._curSkill then
				entity:SetTarget(self._target);
			else
				entity:MoveTo(self._target._curPos);
			end
		end

		return true;
	end

	return false;
end

function i3k_ai_autofight_find_target:OnLeave()
	if BASE.OnLeave(self) then
		self._target = nil;

		return true;
	end

	return false;
end

function i3k_ai_autofight_find_target:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_find_target:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_autofight_find_target.new(entity, priority);
end

