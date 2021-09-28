------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_xinjuekq = i3k_class("wnd_xinjuekq",ui.wnd_base)

function wnd_xinjuekq:configure()
	self._layout.vars.ok:onClick(self,function()
		self:onCloseUI()
		i3k_sbean.soulspell_unlock()
	end)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_xinjuekq.new()
	wnd:create(layout,...)
	return wnd
end
