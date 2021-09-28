-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_above_buff_tips = i3k_class("wnd_above_buff_tips",ui.wnd_base)

function wnd_above_buff_tips:ctor()

end

function wnd_above_buff_tips:configure()
	self._sc = nil
	self._timeTick = 0
	local widgets = self._layout.vars
	
	self._name = widgets.name
	self._desc = widgets.desc
end

function wnd_above_buff_tips:refresh(cfg)
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
		self._timeTick = 0
	end
	self._name:setText(cfg.note)
	self._desc:setText(i3k_get_string(cfg.buffDescID))
	self._sc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dTime)
		self._timeTick = self._timeTick + dTime
		if self._timeTick >=1.5 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
			g_i3k_ui_mgr:CloseUI(eUIID_AboveBuffTips)
		end
	end, 0.1, false)
end

function wnd_above_buff_tips:onHide()
	if self._sc then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sc)
		self._sc = nil
	end
end

function wnd_create(layout)
	local wnd = wnd_above_buff_tips.new()
	wnd:create(layout)
	return wnd
end
