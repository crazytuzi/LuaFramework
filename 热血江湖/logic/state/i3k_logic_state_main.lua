----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_main = i3k_class("i3k_logic_state_main", i3k_logic_state);
function i3k_logic_state_main:ctor()
end

function i3k_logic_state_main:Entry(fsm, from, evt, to)
	local logic = i3k_game_get_logic();
	if not logic then
		return false;
	end

	if not g_i3k_game_context then
		return false;
	end

	--[[
	local roleInfo = g_i3k_game_context:GetRoleInfo();

	local village = require("logic/battle/i3k_village");
	self._village = village.i3k_village.new();
	if not self._village:Create(roleInfo.curLocation.mapID) then
		self._village = nil;
	end

	if self._village then
		logic:EnterNewWorld(self._village);
	end

	return self._village ~= nil;
	]]
	return true;
end

function i3k_logic_state_main:Do(fsm, evt)
	return true;
end

function i3k_logic_state_main:Leave(fsm, evt)
	return true;
end

