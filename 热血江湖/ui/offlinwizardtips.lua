-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_offlinWizardTips = i3k_class("wnd_offlinWizardTips", ui.wnd_base)

function wnd_offlinWizardTips:ctor()
	
end

function wnd_offlinWizardTips:configure()
	local widgets = self._layout.vars
	self.desc = widgets.desc
end

function wnd_offlinWizardTips:refresh(str)
	self.desc:setText(str)
end

function wnd_create(layout)
	local wnd = wnd_offlinWizardTips.new()
	wnd:create(layout)
	return wnd;
end
