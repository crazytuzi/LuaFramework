----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_attack").i3k_ai_attack;

------------------------------------------------------
i3k_ai_manual_attack = i3k_class("i3k_ai_manual_attack", BASE);
function i3k_ai_manual_attack:ctor(entity)
	self._type = eAType_MANUAL_ATTACK;
end

function i3k_ai_manual_attack:CanAttackNoneTarget()
	local entity = self._entity
	if entity._curSkill then
		if entity._curSkill._itemSkillId~=0 or entity._curSkill._gameInstanceSkillId~=0 or entity._curSkill._tournamentSkillID~=0 or entity._curSkill._anqiSkillID ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5550))
			entity._curSkill = nil
			return false
		else
			return not (entity._curSkill._itemSkillId~=0)
		end
	end
	return false;
end

function create_component(entity, priority)
	return i3k_ai_manual_attack.new(entity, priority);
end
