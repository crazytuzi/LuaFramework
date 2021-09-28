----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_dead_mercenary = i3k_class("i3k_ai_dead_revive_mercenary", BASE);
function i3k_ai_dead_mercenary:ctor(entity)
	self._type = eAType_DEAD_MERCENARY;
end

function i3k_ai_dead_mercenary:IsValid()
	if not BASE.IsValid(self) then return false; end

	return self._entity:IsDead();
end

function i3k_ai_dead_mercenary:OnEnter()
	if BASE.OnEnter(self) then
        local alist = {}
        table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadAction, actloopTimes = 1})
        table.insert(alist, {actionName = i3k_db_common.engine.defaultDeadLoopAction, actloopTimes = -1})
		self._entity:PlayActionList(alist, 1);
		self._entity._deadTimeLine = g_i3k_get_GMTtime(i3k_game_get_time())
		self._entity:LockAni(true);

		self._entity:ShowTitleNode(false);
		local world = i3k_game_get_world();
		if world then
			if self._entity._hoster and not self._entity._hoster:IsDead() then 
				if world._mapType == g_BASE_DUNGEON and world._openType == g_FIELD then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(80,self._entity._name,i3k_db_common.posUnlock.autoRevive))
				elseif world._fightmap or world._mapType == g_FACTION_DUNGEON then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(117,self._entity._name))
				else	
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(80,self._entity._name,i3k_db_common.posUnlock.autoRevive))
				end
			end
		end

		return true;
	end

	return false;
end

function i3k_ai_dead_mercenary:OnLeave()
	if BASE.OnLeave(self) then
		self._entity:LockAni(false);

		return true;
	end

	return false;
end

function i3k_ai_dead_mercenary:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		if dTick > 0 then
			local activeonce = false
			local world = i3k_game_get_world();
			if world then
				if world._fightmap then
					activeonce = true
				end
			end

			-- if world and not world._syncRpc then
			-- 	if self._timeTick > 15000 and not activeonce then
			-- 		return false;
			-- 	end
			-- end
		end

		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_dead_mercenary.new(entity, priority);
end

