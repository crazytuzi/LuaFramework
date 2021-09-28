module(..., package.seeall)

local require = require;
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_defend_count = i3k_class("wnd_defend_count",ui.wnd_base)

--波数图片1~9/0
local COUNT_ICON = {3643, 3644, 3645, 3646, 3647, 3648, 3649, 3650, 3651, 3642}

function wnd_defend_count:ctor()

end

function wnd_defend_count:configure()
	
end

function wnd_defend_count:refresh(count)
	if count < 10 then
		self._layout.vars.ten_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[10]))
		self._layout.vars.unit_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[count]))
	else
		local tag = count%10 == 0 and 10 or count%10
		self._layout.vars.ten_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[math.modf(count/10)]))
		self._layout.vars.unit_icon:setImage(g_i3k_db.i3k_db_get_icon_path(COUNT_ICON[tag]))
	end
end

function wnd_create(layout)
	local wnd = wnd_defend_count.new()
	wnd:create(layout)
	return wnd
end
