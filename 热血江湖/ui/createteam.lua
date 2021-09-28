-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_createTeam = i3k_class("wnd_createTeam", ui.wnd_base)

function wnd_createTeam:ctor()
	
end

function wnd_createTeam:configure(...)
	local close = self._layout.vars.close
	local sure = self._layout.vars.sure
	local isAutoBtn = self._layout.vars.isAutoBtn
	if close then close:onTouchEvent(self, self.closeUI) end
	if sure then sure:onTouchEvent(self, self.createTeam) end
	if isAutoBtn then isAutoBtn:onTouchEvent(self, self.isAutoCB) end
end

function wnd_createTeam:onShow()
	local isAutoImg = self._layout.vars.isAutoImg
end

function wnd_createTeam:onHide()
	
end

function wnd_createTeam:createTeam(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		
	end
end

function wnd_createTeam:isAutoCB(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		
	end
end

function wnd_createTeam:closeUI(sender, eventType)
	if eventType==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_CreateTeam)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_createTeam.new();
		wnd:create(layout, ...);

	return wnd;
end