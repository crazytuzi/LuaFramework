----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_exit = i3k_class("i3k_logic_state_exit", i3k_logic_state);
function i3k_logic_state_exit:ctor()
end

function i3k_logic_state_exit:Entry(fsm, from, evt, to)
	return true;
end

function i3k_logic_state_exit:Do(fsm, evt)
	return true;
end

function i3k_logic_state_exit:Leave(fsm, evt)
	return true;
end

function i3k_logic_state_exit:OnUpdate(dTime)
end

