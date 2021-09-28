----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_trigger_skill = i3k_class("i3k_ai_autofight_trigger_skill", BASE);
function i3k_ai_autofight_trigger_skill:ctor(entity)
	self._type	= eAType_AUTOFIGHT_TRIGGER_SKILL;
	self._UseSkill = -1
	self._SkillCheck = false
end

function i3k_ai_autofight_trigger_skill:IsValid()
	local entity = self._entity;
	if entity._AutoFight == false then
		return false
	end
	if entity._PreCommand ~= -1 then
		return false
	end
	if entity._superMode.valid then
		return false
	end
	self._UseSkill = self:AiSkillCheck()
	if self._UseSkill == 0 then
		return false
	end
	return entity:CanUseSkill() and not entity._curSkill or entity._maunalSkill;
end

function i3k_ai_autofight_trigger_skill:OnEnter()
	if BASE.OnEnter(self) then
		self:SetSkill();
		return true;
	end

	return false;
end

function i3k_ai_autofight_trigger_skill:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_trigger_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_trigger_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function i3k_ai_autofight_trigger_skill:SetSkill()
	local entity = self._entity;
	local skill = nil;
	skill = entity._skills[self._UseSkill];

	if skill then
		entity:UseSkill(skill);
	end
	
end


function i3k_ai_autofight_trigger_skill:AiSkillCheck()
	local entity = self._entity;
	local cfg = entity._cfg.AutoaiNode
	local heroAllSkills, heroUseSkills = g_i3k_game_context:GetRoleSkills()
	for k,v in pairs(cfg) do
		local tricfg = i3k_db_ai_trigger[v]
		if tricfg then
			local eventcfg = i3k_db_trigger_event[tricfg.tid]
			local behcfg = i3k_db_trigger_behavior[tricfg.bid]
			if behcfg then
				for k, v in pairs(heroUseSkills) do
					if v == behcfg.args[1] then
						if eventcfg.tid == 8 then
							if entity._hp < entity:GetPropertyValue(ePropID_maxHP) * eventcfg.args[2]/100 then
								local skill = entity._skills[v];
								if skill and skill:CanUse() then
									return v
								end
							end
						end
					end
				end
			end
		end
	end
	

	return 0;
end

function create_component(entity, priority)
	return i3k_ai_autofight_trigger_skill.new(entity, priority);
end

