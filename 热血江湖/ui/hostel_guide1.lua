-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_hostel_guide1 = i3k_class("wnd_hostel_guide1", ui.wnd_base)

function wnd_hostel_guide1:ctor()
	
end

function wnd_hostel_guide1:configure()
	
end

function wnd_hostel_guide1:onShow()
	
end

function wnd_hostel_guide1:refresh(index)
	self._layout.vars.btn:setTag(index)
	self._layout.vars.btn:onClick(self, self.onContinue)
	
	local desc = index==1 and i3k_get_string(15155) or i3k_get_string(15156)
	self._layout.vars.descLabel:setText(desc)
end

function wnd_hostel_guide1:onContinue(sender)
	local index = sender:getTag()
	if index==1 then
		self:refresh(index+1)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_HostelGuide2)
		g_i3k_ui_mgr:CloseUI(eUIID_HostelGuide1)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_hostel_guide1.new()
	wnd:create(layout, ...)
	return wnd;
end