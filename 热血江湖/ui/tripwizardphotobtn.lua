module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_tripWizardPhotoBtn = i3k_class("wnd_tripWizardPhotoBtn", ui.wnd_base)
function wnd_tripWizardPhotoBtn:ctor()

end
function wnd_tripWizardPhotoBtn:configure()
    local widgets = self._layout.vars
	widgets.transBtn:onClick(self, self.onOkBtn)
end

function wnd_tripWizardPhotoBtn:refresh(photoID)
	
end

function wnd_tripWizardPhotoBtn:onOkBtn(sender)
	if not g_i3k_ui_mgr:GetUI(eUIID_TripWizardPhotoShow) then
		g_i3k_ui_mgr:OpenUI(eUIID_TripWizardPhotoShow)
		g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardPhotoShow, g_tripGet)
	end
end

function wnd_create(layout)
	local wnd = wnd_tripWizardPhotoBtn.new();
		wnd:create(layout);
	return wnd;
end
