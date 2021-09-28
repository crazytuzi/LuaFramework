----------------------------------------------------------------
local require = require;


require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_battle_prepare = i3k_class("i3k_logic_state_battle_prepare", i3k_logic_state);
function i3k_logic_state_battle_prepare:ctor()
end

function i3k_logic_state_battle_prepare:Do(fsm, evt)
	return true;
end

function i3k_logic_state_battle_prepare:Leave(fsm, evt)
	return true;
end

function i3k_logic_state_battle_prepare:OnUpdate(dTime)
	return true;
end

