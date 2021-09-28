----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

local l_playerIdleTime = 0
local r_idleTime = 0
local r_actionTime = 0
local idleAction = false;

------------------------------------------------------
i3k_ai_idle = i3k_class("i3k_ai_idle", BASE);
function i3k_ai_idle:ctor(entity)
	self._type = eAType_IDLE;
end

function i3k_ai_idle:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		if entity._playActState == 1 then
			return
		end
		if entity._socialactionID == 0 and not entity._behavior:Test(eEBFloating) then
			if entity:GetEntityType() == eET_Player and g_i3k_game_context:IsOnHugMode() and not g_i3k_game_context:IsInSuperMode() and not g_i3k_game_context:IsInMissionMode() then
				if entity:IsHugLeader() then
					entity:Play(i3k_db_common.hugMode.pickUpStand, -1);
				else
					entity:Play(i3k_db_common.hugMode.pickedUpStand, -1);
				end
			else
				entity:ChageWeaponSoulAction(i3k_db_common.engine.defaultStandAction)
				entity:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
			end
		end
		entity._socialactionID = 0

		local mgr = self._entity._triMgr;
		if mgr then
			mgr:PostEvent(self, eTEventIdle, true);
		end

		if entity:IsPlayer() then
			l_playerIdleTime = 0
		end
		if entity:GetEntityType() == eET_Player then
			r_idleTime = 0
			r_actionTime = 0
			idleAction = false;
		end

		if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId and not entity:IsOnRide() then
			if entity:IsInWater() then
				entity:Play(i3k_db_spring.common.waterIdle, -1);
			else
				entity:Play(i3k_db_spring.common.landIdle, -1);
			end
		end
		return true;
	end

	return false;
end

function i3k_ai_idle:OnLeave()
	if BASE.OnLeave(self) then
		local mgr = self._entity._triMgr;
		if mgr then
			mgr:PostEvent(self, eTEventIdle, false);
		end
		local entity = self._entity;
		if entity:IsPlayer() then
			l_playerIdleTime = 0
		end
		return true;
	end

	return false;
end

function i3k_ai_idle:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		local entity = self._entity;
		if entity:IsPlayer() then
			l_playerIdleTime = l_playerIdleTime + dTime
			if l_playerIdleTime > 0.3 then
				i3k_do_gc()
			end
		end
		if entity:GetEntityType() == eET_Player then
			if entity:IsOnRide() and not idleAction then
				r_idleTime = r_idleTime + dTime
				if entity._ride.curShowID then
					local rcfg = i3k_db_steed_huanhua[entity._ride.curShowID];
					if rcfg then
						if r_idleTime > rcfg.Idleodds/1000 then
							if not self._entity:IsMulMemberState() and not self._entity:IsHugMemberMode() and not self._entity:IsLeaderMemberState() then
								self._entity:Play("stand01", -1);
							end
							r_idleTime = 0;
							idleAction = true;
						end
					end
				end
			end
			if idleAction then
				r_actionTime = r_actionTime + dTime
				if entity._ride.curShowID then
					local rcfg = i3k_db_steed_huanhua[entity._ride.curShowID];
					if rcfg then
						if r_actionTime > rcfg.IdleActionTime/1000 then
							local condition = not self._entity:IsMulMemberState() and not self._entity:IsHugMemberMode() and not self._entity:IsLeaderMemberState() and not g_i3k_game_context:GetIsSpringWorld()
							if condition and not self._entity:isDaZuo() then
								self._entity:Play(i3k_db_common.engine.defaultAttackIdleAction, -1);
							end
							r_actionTime = 0;
							idleAction = false;
						end
					end
				end
			end
		end
		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_idle.new(entity, priority);
end
