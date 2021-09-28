----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


----------------------------------------------------------------



------------------------------------------------------
i3k_logic_state_battle = i3k_class("i3k_logic_state_battle", i3k_logic_state);
function i3k_logic_state_battle:ctor()
	self._Traps
		= { };
	self.Trap
		= nil;
	self._dungeon
		= nil;
end

function i3k_logic_state_battle:Entry(fsm, from, evt, to)
	local logic = i3k_game_get_logic();
	if not logic then
		return false;
	end
	
	-- local data = i3k_sbean.normalmap_start_req.new()
	-- data.mapId = logic:GetDungeonID()
	-- i3k_game_send_str_cmd(data, "normalmap_start_res")
	return true;
end

function i3k_logic_state_battle:Do(fsm, evt)
	return true;
end

function i3k_logic_state_battle:Leave(fsm, evt)
	if self._dungeon then
		self._dungeon:Release();
		self._dungeon = nil;
	end

	return true;
end

