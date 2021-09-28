------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_xinjuetpcg = i3k_class("wnd_xinjuetpcg",ui.wnd_base)

function wnd_xinjuetpcg:configure()
	self._layout.vars.closeBtn:onClick(self,self.onCloseUI)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_xinjuetpcg.new()
	wnd:create(layout,...)
	return wnd
end
