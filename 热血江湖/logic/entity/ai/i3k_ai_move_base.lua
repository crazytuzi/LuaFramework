----------------------------------------------------------------
module(..., package.seeall)

local require = require

local MODULE = require("logic/entity/ai/i3k_ai_base");
local BASE = MODULE.i3k_ai_base;

------------------------------------------------------
i3k_ai_move_base = i3k_class("i3k_ai_move_base", BASE);
function i3k_ai_move_base:ctor(entity)
	self._syncRpc = false;
end

function i3k_ai_move_base:OnAttach()
	self._entity._movable = true;
end

function i3k_ai_move_base:OnDetach()
	self._entity._movable = false;
end

function i3k_ai_move_base:IsValid()
	if not BASE.IsValid() then return false; end

	local entity = self._entity;

	if not entity:CanMove() then
		return false;
	end

	-- first check if skill can attack target
	if entity._curSkill and entity._target then
		local dist = i3k_vec3_sub1(entity._curPos, entity._target._curPos);
		if entity._curSkill._range > i3k_vec3_len(dist) then
			return false;
		end
	end

	return true;
end

function i3k_ai_move_base:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		local curSkill = self._entity._curSkill
		if entity:IsPlayer() then
			if g_i3k_game_context:GetIsInHomeLandZone() then --家园中移动关闭钓鱼ui
				g_i3k_ui_mgr:CloseUI(eUIID_HomeLandFish)
			end
			entity:ResetAttackIdx()
			if curSkill and entity:IsAttacksSkill(curSkill) then
				entity._curSkill = entity._attacks[1]
			end
		end
		self._syncRpc = entity:IsNeedSyncRpc();
		local speed	= entity:GetPropertyValue(ePropID_speed);
		if entity:GetEntityType() == eET_Player and (entity._iscarOwner == 1 and speed <= g_i3k_game_context:GetEscortCarSpeed() or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId) then
			if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
				if entity:IsInWater() then
					entity:Play(i3k_db_spring.common.waterWalk, -1);
				else
					entity:Play(i3k_db_spring.common.landWalk, -1);
				end
			elseif entity:IsHugLeader() then
				entity:Play(i3k_db_common.hugMode.pickUpWalk, -1);
			else
				entity:Play(i3k_db_common.engine.roleWalkAction, -1);
			end
		else
			entity:ChageWeaponSoulAction(i3k_db_common.engine.defaultRunAction);
			entity:Play(i3k_db_common.engine.defaultRunAction, -1);
		end

		return true;
	end

	return false;
end
