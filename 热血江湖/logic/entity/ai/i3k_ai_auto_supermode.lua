----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_auto_supermode = i3k_class("i3k_ai_auto_supermode", BASE);
function i3k_ai_auto_supermode:ctor(entity)
	self._type	= eAType_AUTO_SUPERMODE;
end

local autoSuperModeMapType = i3k_db_common.autoFight.autoSuperModeMapType
function i3k_ai_auto_supermode:IsValid()
	local entity = self._entity;
	local mapType = i3k_game_get_map_type()
	if not entity._AutoFight or not autoSuperModeMapType[mapType] then
		return false
	end
	
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local autoSuperLvl = g_i3k_db.i3k_db_get_auto_super_vip_lvl()
	local cfg = g_i3k_game_context:GetUserCfg()
	if vipLvl >= autoSuperLvl and cfg:GetIsAutoSuperMode() then
		if entity:IsPlayer() and not g_i3k_game_context:IsInSuperMode() and entity._sp >= i3k_db_common.general.maxEnergy then
			local func = function()
				i3k_sbean.motivate_weapon()
			end
			g_i3k_game_context:UnRide(func, true)
		end
	end

	return false;
end

function i3k_ai_auto_supermode:OnEnter()
	if BASE.OnEnter(self) then
		return true;
	end

	return false;
end

function i3k_ai_auto_supermode:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_auto_supermode:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_auto_supermode:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end
	return false;
end

function create_component(entity, priority)
	return i3k_ai_auto_supermode.new(entity, priority);
end
