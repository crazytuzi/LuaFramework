
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_single_buff_tips = i3k_class("wnd_single_buff_tips",ui.wnd_base)

function wnd_single_buff_tips:ctor()
	self._sc = nil
	self._timeTick = 0
end

function wnd_single_buff_tips:configure()

end

function wnd_single_buff_tips:refresh(text, pos)
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
		self._timeTick = 0
	end

	local posX = pos.x - 20
	local posY = pos.y + 20

	self._layout.vars.text:setText(text)
	self._layout.vars.root:setPosition(posX, posY)
	self._sc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dTime)
		self._timeTick = self._timeTick + dTime
		if self._timeTick >=1.5 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
			g_i3k_ui_mgr:CloseUI(eUIID_SingleBuffTips)
		end
	end, 0.1, false)
end

function wnd_single_buff_tips:onHide()
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_single_buff_tips.new()
	wnd:create(layout, ...)
	return wnd;
end

