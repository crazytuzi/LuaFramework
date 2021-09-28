----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_find_target = i3k_class("i3k_ai_find_target", BASE);
function i3k_ai_find_target:ctor(entity)
	self._type		= eAType_FIND_TARGET;
	self._target	= nil;
end

function i3k_ai_find_target:IsValid()
	local entity = self._entity;
	local logic = i3k_game_get_logic();
	local world = nil
	if entity._AutoFight then
		return false;
	end
	
	if entity:GetEntityType() == eET_Mercenary and logic then
		world = logic:GetWorld();
		if world then
			local syncRpc = world._openType == g_BASE_DUNGEON;
			if world._fightmap then
				syncRpc = false;
			end
			local enmities = entity:GetEnmities();
			if syncRpc and #enmities == 0 then
				return false;
			end
		end
	end
	
	if entity:IsDead() or not entity:CanAttack() then
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
					if enmity and not enmity:IsDead() then
						ignoreDist = true;
						target = enmity;
					end
				end
				if not target then
					if entity:GetEntityType() == eET_Mercenary and world._fightmap then
						if entity._hoster then
							local tid = i3k_engine_get_rnd_u(1, #entity._alives[2]);
							target = entity._alives[2][tid]
							if target then
								entity:AddEnmity(target.entity)
							end
						end
					else
						local tentity = nil
						for i,v in ipairs(entity._alives[2]) do
							local r1 = entity:GetRadius();
							local r2 =  entity._alives[2][i].entity:GetRadius();
							local radius = r1 + r2;
							if radius then
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
									tentity = entity._alives[2][i-1];
									break;
								end
							end
						end
						target = tentity or entity._alives[2][1] or entity._alives[3][1]--entity._alives[2][1] -- 敌方
					end
				end
			end
		elseif stype == eSE_Buff then -- 祝福
			if entity._curSkill._scope.type == eSScopT_Owner then
				if entity._target and entity._target._guid == entity._guid then
					return false;
				end
				self._target = entity;
				
				return true;
			else
				target = entity._alives[1][1] -- 己方
			end
		end
		
		if target then
			local world = i3k_game_get_world()
			if entity:GetEntityType() == eET_Monster and not world._syncRpc then
				if target.entity and target.entity._entityType == eET_Trap then
					return false
				end
			end
			if ignoreDist then
				if not (target:GetEntityType() == eET_Pet and (not entity._enmities or #entity._enmities <= 0)) then
					self._target = target;
				end
				
				if not entity._target then
					return true;
				end
				
				return target._guid ~= entity._target._guid;
			else
				local r1 = entity:GetRadius();
				local r2 = target.entity:GetRadius();
				local radius = r1 + r2;
				local filterdist = entity:GetPropertyValue(ePropID_alertRange)
				if entity:IsPlayer() and entity._PVPStatus ~= g_PeaceMode then
					filterdist = i3k_db_common.engine.fightunselectTargetDist
				end
				
				if target.dist < (filterdist + radius) then
					if not (target.entity:GetEntityType() == eET_Pet and (not entity._enmities or #entity._enmities <= 0)) then
						self._target = target.entity;
					end
					
					if not entity._target then
						return true;
					end
					
					if target.dist < (entity._curSkill._range + radius) then
						return false;
					end
					
					return target.entity._guid ~= entity._target._guid;
				end
			end
		end
	end
	
	return false;
end

function i3k_ai_find_target:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		entity._behavior:Clear(eEBGuard);
		
		if self._target then
			entity:SetTarget(self._target);			
		end
		
		return true;
	end
	
	return false;
end

function i3k_ai_find_target:OnLeave()
	if BASE.OnLeave(self) then
		self._target = nil;
		
		return true;
	end
	
	return false;
end

function i3k_ai_find_target:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end
	
	return false;
end

function i3k_ai_find_target:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end
	
	return false;
end

function create_component(entity, priority)
	return i3k_ai_find_target.new(entity, priority);
end

