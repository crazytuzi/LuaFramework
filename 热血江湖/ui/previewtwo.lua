-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_previewtwo = i3k_class("wnd_previewtwo",ui.wnd_base)
function wnd_previewtwo:ctor()
	
end

function wnd_previewtwo:configure()
	self._layout.vars.globel_btn:onClick(self,self.onClose)
end

function wnd_previewtwo:refresh(info)
	if info then
		local widgets = self._layout.vars
		widgets.mainTitle:setText(info.UITitle)
		widgets.descText:setText(info.UISlogan)
		widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(info.miniIconId))
	end
end

function wnd_previewtwo:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_PreviewDetailtwo)
end

function wnd_create(layout, ...)
	local wnd = wnd_previewtwo.new()
	wnd:create(layout, ...)
	return wnd
end
