------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_wujuekq = i3k_class("wnd_wujuekq",ui.wnd_base)

function wnd_wujuekq:configure()
	self._layout.vars.ok:onClick(self,function()
		self:onCloseUI()
		i3k_sbean.unlock_wujue()
	end)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_wujuekq.new()
	wnd:create(layout,...)
	return wnd
end
