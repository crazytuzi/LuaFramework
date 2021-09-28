-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_bind_effect = i3k_class("wnd_bind_effect", ui.wnd_base)

function wnd_bind_effect:ctor()

end

function wnd_bind_effect:configure()

end

function wnd_bind_effect:refresh()

end

function wnd_create(layout)
	local wnd = wnd_bind_effect.new()
	wnd:create(layout)
	return wnd
end
