-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_bind_effect_marry = i3k_class("wnd_bind_effect_marry", ui.wnd_base)

function wnd_bind_effect_marry:ctor()

end

function wnd_bind_effect_marry:configure()

end

function wnd_bind_effect_marry:refresh()

end

function wnd_create(layout)
	local wnd = wnd_bind_effect_marry.new()
	wnd:create(layout)
	return wnd
end
