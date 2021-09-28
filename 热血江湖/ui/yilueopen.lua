------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_yilueOpen = i3k_class("wnd_yilueOpen",ui.wnd_base)

function wnd_yilueOpen:configure()
	self._layout.vars.ok:onClick(self,function()
		self:onCloseUI()
		i3k_sbean.unlock_Yilue()
	end)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_yilueOpen.new()
	wnd:create(layout,...)
	return wnd
end
