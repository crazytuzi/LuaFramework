-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_photo_end = i3k_class("wnd_faction_photo_end", ui.wnd_base)

local ROLE_DESC = "ui/widgets/bpgzt"

function wnd_faction_photo_end:ctor()
	
end

function wnd_faction_photo_end:configure(...)
	local widgets = self._layout.vars
	widgets.allReward:onClick(self, self.onClose)
	widgets.useItemBtn:onClick(self, self.onClose)
	widgets.desc:setText(i3k_get_string(1783))
end

function wnd_faction_photo_end:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionPhotoList)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionPhotoEnd)
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_photo_end.new();
		wnd:create(layout, ...);
	return wnd;
end