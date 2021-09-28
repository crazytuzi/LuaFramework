----------------------------------------------------------------
local require = require;

require("logic/state/i3k_logic_state");


------------------------------------------------------
i3k_logic_state_lead = i3k_class("i3k_logic_state_lead", i3k_logic_state);
function i3k_logic_state_lead:ctor()
end

function i3k_logic_state_lead:Do(fsm, evt)
	g_i3k_game_context:enterPlayerLeadMap()
	return true;
end

function i3k_logic_state_lead:Leave(fsm, evt)
	g_i3k_game_context:leavePlayerLead()
end

function i3k_logic_state_lead:OnUpdate(dTime)
	return true;
end

function i3k_logic_state_lead:OnLogic(dTick)
	return true;
end
