----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;
------------------------------------------------------
--PreCommand
--ePreTypeCommonattack	= 0	--普通攻击
--ePreTypeBindSkill1	= 1	--绑定技能1
--ePreTypeBindSkill2	= 2	--绑定技能2
--ePreTypeBindSkill3	= 3	--绑定技能3
--ePreTypeBindSkill4	= 4	--绑定技能4
--ePreTypeDodgeSkill	= 5	--轻功
--ePreTypeDIYSkill	= 6	--自定义技能
--ePreTypeClickMove	= 7	--点击移动
--ePreTypeJoystickMove	= 8	--摇杆移动
--ePreTypeResetMove	= 9	--强制复位
------------------------------------------------------
i3k_ai_precommond = i3k_class("i3k_ai_precommond", BASE);
function i3k_ai_precommond:ctor(entity)
	self._type	= eAType_AUTOFIGHT_SKILL;
end

function i3k_ai_precommond:IsValid()
	local entity = self._entity;
	if entity._PreCommand ~= -1 then
		if self._entity._PreCommand == ePreTypeCommonattack then
			if self._entity._superMode.valid or self._entity._superMode.cache.valid then
				local skill = self._entity._weapon.skills[self._entity._superMode.attacks];
				if skill then
					if self._entity:CanUseSkill(skill) then
						return true;
					end
				end
			elseif self._entity._missionMode.valid or self._entity._missionMode.cache.valid then
				local skill = self._entity._missionMode.attacks[self._entity._missionMode.attacksIdx];
				if skill then
					if self._entity:CanUseSkill(skill) then
						return true
					end
				end
			else
				local skill = self._entity:GetAttackSkill();
				if skill then
					if self._entity:CanUseSkill(skill) then
						return true
					end
				end
			end
		elseif self._entity._PreCommand >= ePreTypeBindSkill1 and self._entity._PreCommand <= ePreTypeBindSkill4 then
			if self._entity._missionMode.valid then
				local skill = self._entity._missionMode.skills[self._entity._PreCommand];
				if skill then
					if self._entity:CanUseSkill(skill) then
						return true
					end
				end
			else
				local sid = self._entity._bindSkills[self._entity._PreCommand]
				local skill = nil;
				skill = self._entity._skills[sid];
				if skill then
					if self._entity:CanUseSkill(skill) then
						return true
					else
						if not skill:CanUse() then
							self._entity._PreCommand = -1
						end
						return false
					end
				end
			end
		elseif self._entity._PreCommand == ePreTypeDodgeSkill then
			local skill = self._entity._dodgeSkill
			if skill then
				if self._entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
						self._entity._PreCommand = -1
					end
					return false
				end
			end
		elseif self._entity._PreCommand == ePreTypeUniqueSkill then
			local skill = self._entity._uniqueSkill
			if skill then
				if self._entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
					self._entity._PreCommand = -1
				end
					return false
				end
		    end
		elseif self._entity._PreCommand == ePreGameTypeInstanceSkill then
			local skill = entity._gameInstanceSkills[entity._gameInstanceSkillId]
			if skill then
				if self._entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
					self._entity._PreCommand = -1
				end
					return false
				end
		    end
		elseif self._entity._PreCommand == ePreTypeDIYSkill then
			local skill = self._entity._DIYSkill
			if skill then
				if self._entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
						self._entity._PreCommand = -1
					end
					return false
				end
			end
		elseif self._entity._PreCommand == ePreTypeSpiritSkill then
			local skill = self._entity._spiritSkill
			if skill then
				if self._entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
						self._entity._PreCommand = -1
					end
					return false
				end
			end
		elseif self._entity._PreCommand == ePreTypeClickMove then
				self._entity._preautonormalattack = false;
				self._entity._autonormalattack = false
				--self._entity._PreCommand = -1
				if g_i3k_game_context:GetFindWayStatus() and self._entity:CanMove() then
					return true;
				end
				return false
		elseif self._entity._PreCommand == ePreTypeJoystickMove then
				self._entity._preautonormalattack = false;
				self._entity._autonormalattack = false
				--self._entity._PreCommand = -1
				return false
		elseif self._entity._PreCommand == ePreTypeItemSkill then
			local skill = entity._itemSkills[entity._preSkillItemId]
			if skill then
				if entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
						entity._PreCommand = -1
					end
					return false
				end
			end
		elseif self._entity._PreCommand == ePreTypeTournamentSkill then
			local skill = entity._tournamentSkills[entity._tournamentSkillID]
			if skill then
				if entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
						entity._PreCommand = -1
					end
					return false
				end
			end		
		elseif self._entity._PreCommand == ePreTypeAnqiSkill then
			local skill = entity._anqiSkill
			
			if skill then
				if entity:CanUseSkill(skill) then
					return true
				else
					if not skill:CanUse() then
						entity._PreCommand = -1
					end
					return false
				end
			end
		end	
	end

	return false;
end

function i3k_ai_precommond:OnEnter()
	if BASE.OnEnter(self) then
		if self._entity._PreCommand == ePreTypeCommonattack then
			if self._entity._superMode.valid or self._entity._superMode.cache.valid then
				local skill = self._entity._weapon.skills[self._entity._superMode.attacks];
				if skill then
					if self._entity:UseSkill(skill) then
						self._entity._PreCommand = -1
					end
				end
			elseif self._entity._missionMode.valid or self._entity._missionMode.cache.valid then
				local skill = self._entity._missionMode.attacks[self._entity._missionMode.attacksIdx];
				if skill then
					if self._entity:UseSkill(skill) then
						self._entity._PreCommand = -1
					end
				end
			else
				local skill = self._entity:GetAttackSkill();
				if skill then
					if self._entity:UseSkill(skill) then
						self._entity._PreCommand = -1
					end
				end
			end
		elseif self._entity._PreCommand >= ePreTypeBindSkill1 and self._entity._PreCommand <= ePreTypeBindSkill4 then
			if self._entity._missionMode.valid then
				local skill = self._entity._missionMode.skills[self._entity._PreCommand];
				if skill then
					if self._entity:UseSkill(skill) then
						self._entity._PreCommand = -1
					end
				end
			else
				local sid = self._entity._bindSkills[self._entity._PreCommand]
				local skill = nil;
				skill = self._entity._skills[sid];
				if skill then
					if self._entity:UseSkill(skill) then
						self._entity._PreCommand = -1
					end
				end
			end
		elseif self._entity._PreCommand == ePreTypeDodgeSkill then
			local skill = self._entity._dodgeSkill
			if skill then
				if self._entity:UseSkill(skill) then
					self._entity._PreCommand = -1
				end
			end
		elseif self._entity._PreCommand == ePreTypeUniqueSkill then
			local skill = self._entity._uniqueSkill
			if skill then
				if self._entity:UseSkill(skill) then
					self._entity._PreCommand = -1
				end
			end
		elseif self._entity._PreCommand == ePreGameTypeInstanceSkill then
			local skill = self._entity._gameInstanceSkills[self._entity._gameInstanceSkillId]
			if skill then
				if self._entity:UseSkill(skill) then
					self._entity._PreCommand = -1
					self._entity._gameInstanceSkillId = -1
				end
			end
		elseif self._entity._PreCommand == ePreTypeDIYSkill then
			local skill = self._entity._DIYSkill
			if skill then
				if self._entity:UseSkill(skill) then
					self._entity._PreCommand = -1
				end
			end
		elseif self._entity._PreCommand == ePreTypeSpiritSkill then
			local skill = self._entity._spiritSkill
			if skill then
				if self._entity:UseSkill(skill) then
					self._entity._PreCommand = -1
				end
			end			
		elseif self._entity._PreCommand == ePreTypeClickMove then
			--if self._entity._AutoFight == false then
				
				if g_i3k_game_context:GetFindWayStatus() then
					local fpd = g_i3k_game_context:GetFindPathData()
					local speed = nil
					if self._entity._iscarOwner == 1 and g_i3k_game_context:GetTmpCarState() then
						speed = g_i3k_game_context:GetCurCarSpeed()
						g_i3k_game_context:SetTmpCarState(false)
					end
					g_i3k_game_context:SeachPathWithMap(fpd.mapid,fpd.pos,fpd.task_type,fpd.petID, fpd.transferData,speed,fpd.line, fpd.callFunc)
				end
				self._entity._PreCommand = -1
				return false
			--else
			--	return true
			--end
		elseif self._entity._PreCommand == ePreTypeJoystickMove then
			--if self._entity._AutoFight == false then
				self._entity._PreCommand = -1
				return false
			--else
			--	return true
			--end
		elseif self._entity._PreCommand == ePreTypeItemSkill then
			self._entity._PreCommand = -1;
			self._entity._preSkillItemId = nil
			self._entity:UseSkillWithItem(self._entity._preSkillItemId)
		elseif self._entity._PreCommand == ePreTypeTournamentSkill then
			self._entity._PreCommand = -1;
			self._entity._tournamentSkillID = nil
			self._entity:UseSkillWithItem(self._entity._tournamentSkillID)
		elseif self._entity._PreCommand == ePreTypeAnqiSkill then
			local skill = self._entity._anqiSkill
			
			if skill then
				if self._entity:UseSkill(skill) then
					self._entity._PreCommand = -1
				end
			end
		end
		return true
	end
	return false;
end

function i3k_ai_precommond:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_precommond:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_precommond:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_precommond.new(entity, priority);
end
