------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_wujueDh = i3k_class("wnd_wujueDh",ui.wnd_base)

local TAB = {
	7979,--突破成功
	7980,--升阶成功
	7981,--激活成功
}

function wnd_wujueDh:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_wujueDh:refresh(id)
	self._layout.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(TAB[id]))
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_wujueDh.new()
	wnd:create(layout,...)
	return wnd
end
