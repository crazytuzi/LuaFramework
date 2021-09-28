------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_star_shape_tips = i3k_class("wnd_star_shape_tips",ui.wnd_base)

local RIGHT = 4688
local WRONG = 4689

function wnd_star_shape_tips:configure()
	self._layout.vars.close:onClick(self,self.onCloseUI)
end

function wnd_star_shape_tips:refresh(isPureColor, isSameColor, isSameShape)
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(1734))
	widgets.desc2:setText(i3k_get_string(1735))
	widgets.icon1:setImage(g_i3k_db.i3k_db_get_icon_path(isPureColor and RIGHT or WRONG))
	widgets.icon2:setImage(g_i3k_db.i3k_db_get_icon_path((isSameColor and not isSameShape) and RIGHT or WRONG))	
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_star_shape_tips.new()
	wnd:create(layout,...)
	return wnd
end