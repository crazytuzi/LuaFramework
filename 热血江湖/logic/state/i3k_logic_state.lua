----------------------------------------------------------------
local require = require;

require("i3k_state_base");


------------------------------------------------------
i3k_logic_state = i3k_class("i3k_logic_state", i3k_state_base);
function i3k_logic_state:ctor()
end

function i3k_logic_state:OnSceneAniStop(name)
end

function i3k_logic_state:OnKeyDown(handled, key)
	return 0;
end

function i3k_logic_state:OnKeyUp(handled, key)
	return 0;
end

function i3k_logic_state:OnTouchDown(handled, x, y)
	return 0;
end

function i3k_logic_state:OnTouchUp(handled, x, y)
	return 0;
end

function i3k_logic_state:OnDrag(handled, touchDown, x, y)
	return 0;
end

function i3k_logic_state:OnZoom(handled, delta)
	return 0;
end

