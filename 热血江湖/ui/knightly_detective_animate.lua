-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_knightly_detective_animate = i3k_class("wnd_knightly_detective_animate", ui.wnd_base)

function wnd_knightly_detective_animate:ctor()
	self._countTime = 1.3
	self._isSuccess = false
end

function wnd_knightly_detective_animate:configure()
	
end

function wnd_knightly_detective_animate:refresh(isSuccess)
	self._isSuccess = isSuccess
	if self._isSuccess then
		self._layout.anis.c_chenggong.play()
	else
		self._layout.anis.c_shibai.play()
	end
end

function wnd_knightly_detective_animate:onUpdate(dTime)
	self._countTime = self._countTime - dTime
	if self._countTime <= 0 then
		if self._isSuccess then
			self._layout.anis.c_chenggong.stop()
		else
			self._layout.anis.c_shibai.stop()
		end
		g_i3k_ui_mgr:AddTask(self, {}, function()
			g_i3k_ui_mgr:CloseUI(eUIID_KnightlyDetectiveAnimate)
		end, 1)
	end
end

function wnd_knightly_detective_animate:onHide()
	g_i3k_ui_mgr:CloseUI(eUIID_KnightlyDetectiveLeader)
	if self._isSuccess then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_KnightlyDetectiveMember, "onLeaderSurvey")
	end
end

function wnd_create(layout)
	local wnd = wnd_knightly_detective_animate.new()
	wnd:create(layout)
	return wnd
end