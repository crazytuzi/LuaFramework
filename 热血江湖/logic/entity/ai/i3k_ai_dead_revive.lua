----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_dead_revive = i3k_class("i3k_ai_dead_revive", BASE);
function i3k_ai_dead_revive:ctor(entity)
	self._type = eAType_DEAD_REVIVE;
end

function i3k_ai_dead_revive:IsValid()
	if not BASE.IsValid(self) then return false; end

	return self._entity._behavior:Test(eEBRevive);
end

function i3k_ai_dead_revive:OnEnter()
	if BASE.OnEnter(self) then
        local alist = {}
            table.insert(alist, {actionName = i3k_db_common.rolerevive.action, actloopTimes = 1})
            table.insert(alist, {actionName = i3k_db_common.engine.defaultStandAction, actloopTimes = -1})
		self._entity:PlayActionList(alist, 1);
		if self._entity:GetEntityType() == eET_Mercenary or self._entity._inPetLife then
			self._entity:PlayReviveEffect(i3k_db_common.rolerevive.effID);
		end
		if self._entity:IsPlayer() then
			local logic = i3k_game_get_logic()
			self._entity:AttachCamera(logic:GetMainCamera())
			self._entity._cameraentity = nil;
		end

		return true;
	end

	return false;
end

function i3k_ai_dead_revive:OnLeave()
	if BASE.OnLeave(self) then
		self._entity:LockAni(false);
		self._entity:StopReviveEffect();

		return true;
	end

	return false;
end

function i3k_ai_dead_revive:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
	--[[	if self._timeTick > i3k_db_common.rolerevive.duration then
			return false;
		end--]]

		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_dead_revive.new(entity, priority);
end

