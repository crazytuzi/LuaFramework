-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/monster_pop");

-------------------------------------------------------
wnd_monster_pop2 = i3k_class("wnd_monster_pop2", ui.wnd_monster_pop)

function wnd_monster_pop2:ctor()
	self._uiid = eUIID_MonsterPop2
end


function wnd_create(layout, ...)
	local wnd = wnd_monster_pop2.new()
	wnd:create(layout, ...)
	return wnd;
end
