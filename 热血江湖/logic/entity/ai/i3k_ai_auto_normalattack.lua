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
i3k_ai_auto_normalattack = i3k_class("i3k_ai_auto_normalattack", BASE);
function i3k_ai_auto_normalattack:ctor(entity)
	self._type	= eAType_AUTOFIGHT_SKILL;
end

function i3k_ai_auto_normalattack:IsValid()
	local entity = self._entity;

	if not entity._target or entity._target:IsDead() then
		local enmities = entity:GetEnmities();
		if enmities then
			local enmity = enmities[1];
			if not enmity then
				return false;
			end
		end
	end

	if not entity._autonormalattack then
		return false;
	end

	if entity._AutoFight then
		return false;
	end
	
	if entity._curSkill then
		return false;
	end

	if entity._PreCommand ~= -1 then
		return false	
	end

	return true;
end

function i3k_ai_auto_normalattack:OnEnter()
	if BASE.OnEnter(self) then
		self._entity._PreCommand = ePreTypeCommonattack
		return true
	end
	return false;
end

function i3k_ai_auto_normalattack:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_auto_normalattack:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_auto_normalattack:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_auto_normalattack.new(entity, priority);
end
