-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fly_mount_preview = i3k_class("wnd_fly_mount_preview", ui.wnd_base)

function wnd_fly_mount_preview:ctor()
	
end

function wnd_fly_mount_preview:configure()
	self._layout.vars.globel_bt:onClick(self, function()
		g_i3k_ui_mgr:CloseUI(eUIID_Fly_Mount_Preview)
	end)
end

function wnd_fly_mount_preview:refresh(id)
	self._layout.vars.ImageName:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_steed_skill[id].iconID))
	self._layout.vars.lableName:setText(i3k_db_steed_skill_cfg[id][1].skillName)
	self._layout.vars.desa:setText(i3k_db_steed_skill_cfg[id][1].skillDesc)
end

function wnd_create(layout, ...)
	local wnd = wnd_fly_mount_preview.new()
	wnd:create(layout, ...)
	return wnd;
end