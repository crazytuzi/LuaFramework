----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_mercenary_skill = i3k_class("i3k_ai_autofight_mercenary_skill", BASE);
function i3k_ai_autofight_mercenary_skill:ctor(entity)
	self._type	= eAType_AUTOFIGHT_MERCENARY_SKILL;
end

function i3k_ai_autofight_mercenary_skill:IsValid()
	local entity = self._entity;
	if entity._AutoFight == false then
		return false
	end
	local logic = i3k_game_get_logic();
	if logic then
		local player = logic:GetPlayer()
		if player then
			for k = 1, player:GetMercenaryCount() do
				local mercenary = player:GetMercenary(k);
				if mercenary then
					local nurseSP = mercenary._sp
					local fullSP = 1000
					if i3k_db_common then
						if i3k_db_common.general then
							if i3k_db_common.general.maxEnergy then
								fullSP = i3k_db_common.general.maxEnergy
							end
						end
					end
					if nurseSP>=fullSP then 
						mercenary:UltraSkill()
					end
				end
			end
		end
	end

	return false;
end

function i3k_ai_autofight_mercenary_skill:OnEnter()
	if BASE.OnEnter(self) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_mercenary_skill:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_mercenary_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_mercenary_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_autofight_mercenary_skill.new(entity, priority);
end
