----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_mercenary_auto_find_target = i3k_class("i3k_ai_mercenary_auto_find_target", BASE);
function i3k_ai_mercenary_auto_find_target:ctor(entity)
	self._type		= eAType_AUTOFIGHT_CAST_FIND_TARGET;
	self._target	= nil;
end

function i3k_ai_mercenary_auto_find_target:IsValid()
	--i3k_log("i3k_ai_mercenary_auto_find_target")
	local entity = self._entity;
	local hoster = entity._hoster
	if not entity._behavior:Test(eEBDisAttack) then
		return false
	end
	local target = entity._enmities[1]
	if target and not target:IsDead() then
		self._target = target
	end
	
	target = hoster._enmities[1]
	if target and not target:IsDead() then
		self._target = target
	end

	if self._target then
		local disRange = entity._useSkill._range + 50
		local dist = i3k_vec3_dist(entity._curPos, self._target._curPos);
		if dist <= disRange then
			self._target = nil;
		end
	end

	return self._target ~= nil;
end

function i3k_ai_mercenary_auto_find_target:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		if self._target then
			--i3k_log("pos.x = "..self._target._curPosE.x)
			--local path = {self._target._curPosE}
			--entity:MovePaths(path,true);
			entity:SetTarget(self._target)
		end

		return true;
	end

	return false;
end

function i3k_ai_mercenary_auto_find_target:OnLeave()
	if BASE.OnLeave(self) then
		self._target = nil;

		return true;
	end

	return false;
end

function i3k_ai_mercenary_auto_find_target:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_mercenary_auto_find_target:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_mercenary_auto_find_target.new(entity, priority);
end
