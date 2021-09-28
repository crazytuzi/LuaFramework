-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/monster_pop");

-------------------------------------------------------
wnd_monster_pop3 = i3k_class("wnd_monster_pop3", ui.wnd_monster_pop)

function wnd_monster_pop3:ctor()
	self._uiid = eUIID_MonsterPop3
end


function wnd_create(layout, ...)
	local wnd = wnd_monster_pop3.new()
	wnd:create(layout, ...)
	return wnd;
end
