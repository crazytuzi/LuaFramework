----------------------------------------------------------------
local require = require

require("i3k_global");


------------------------------------------------------
i3k_state_base = i3k_class("i3k_state_base");
function i3k_state_base:ctor()
	self._isEntry = false;
end

function i3k_state_base:DoNothing(_,_,_,_)
	return true;
end

function i3k_state_base:Entry(fsm, from, evt, to)
	return true;
end

function i3k_state_base:Do(fsm, evt)
	return true;
end

function i3k_state_base:Leave(fsm, evt)
	return true;
end

function i3k_state_base:OnUpdate(dTime)
	return true;
end

function i3k_state_base:OnLogic(dTick)
	return true;
end

function i3k_state_base:OnMapLoaded()
end

function i3k_state_base:LoadMap(path, pos, cfg, delay)
	local _cb = function()
		self:OnMapLoaded();
	end

	local logic = i3k_game_get_logic();
	if logic then
		logic:LoadMap(path, pos, cfg, _cb, delay);
	end
end

function i3k_state_base:OnHitObject(handled, entity)
	return false;
end

function i3k_state_base:OnHitGround(handled, x, y, z)
	return false;
end

