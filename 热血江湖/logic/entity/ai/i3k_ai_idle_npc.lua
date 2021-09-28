----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_idle_npc = i3k_class("i3k_ai_idle_npc", BASE);
function i3k_ai_idle_npc:ctor(entity)
	self._type = eAType_IDLE_NPC;
end

function i3k_ai_idle_npc:OnEnter()
	if BASE.OnEnter(self) then
		self._entity:Play(i3k_db_common.engine.defaultStandAction, -1);
		
		local mgr = self._entity._triMgr;
		if mgr then
			mgr:PostEvent(self, eTEventIdle, true);
		end
		
		return true;
	end

	return false;
end

function i3k_ai_idle_npc:OnLeave()
	if BASE.OnLeave(self) then
		local mgr = self._entity._triMgr;
		if mgr then
			mgr:PostEvent(self, eTEventIdle, false);
		end

		return true;
	end

	return false;
end

function i3k_ai_idle_npc:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_idle_npc.new(entity, priority);
end

