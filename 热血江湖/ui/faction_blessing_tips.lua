-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_blessing_tips = i3k_class("wnd_faction_blessing_tips", ui.wnd_base)

function wnd_faction_blessing_tips:ctor()

end

function wnd_faction_blessing_tips:configure()

end

function wnd_faction_blessing_tips:refresh(msgText)
	self._layout.vars.des:setText(msgText)
end

function wnd_create(layout,...)
	local wnd = wnd_faction_blessing_tips.new()
	wnd:create(layout,...)
	return wnd
end