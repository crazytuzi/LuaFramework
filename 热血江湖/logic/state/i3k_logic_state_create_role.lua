----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_create_role = i3k_class("i3k_logic_state_create_role", i3k_logic_state);
function i3k_logic_state_create_role:ctor()
end

function i3k_logic_state_create_role:Entry(fsm, from, evt, to)
	return true;
end

function i3k_logic_state_create_role:Do(fsm, evt)
	return true;
end

function i3k_logic_state_create_role:Leave(fsm, evt)
	return true;
end

function i3k_logic_state_create_role:OnUpdate(dTime)
end

