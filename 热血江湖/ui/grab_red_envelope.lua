-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--抢红包ui
-------------------------------------------------------

wnd_grab_red_envelope = i3k_class("wnd_grab_red_envelope",ui.wnd_base)

function wnd_grab_red_envelope:ctor()
	self._scheduler = nil
end

function wnd_grab_red_envelope:configure()
	local widgets = self._layout.vars
	self.grabBtn = widgets.grabBtn --抢红包按钮
	self.grabBtn:onClick(self, self.onGrabBtn)
	
	self.desc = widgets.desc --描述
	
	
end

function wnd_grab_red_envelope:refresh(startTime,id,payLevel)
	--startTime --开始时间
	--id		--id
	--payLevel --红包开启等级
	self:countDown()
	self.startTime = startTime
	self.id = id
	self.payLevel = payLevel
	self.desc:setText(i3k_get_string(748))
end

function wnd_grab_red_envelope:countDown()
	local time = 0
	function update(dTime)
		time = time +dTime
		if time>=8 then
			self:closeButton()
		end	
	end
	if not self._scheduler then 
		self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
	end
end

function wnd_grab_red_envelope:onGrabBtn(sender)
	--点击抢红包按钮
	i3k_sbean.grab_red_envelope(self.startTime,self.id)
end

function wnd_grab_red_envelope:closeButton()
	g_i3k_ui_mgr:CloseUI(eUIID_Grab_Red_Envelope)
end

function wnd_grab_red_envelope:releaseSchedule()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
end

function wnd_grab_red_envelope:onHide()
	self:releaseSchedule()
end

function wnd_create(layout)
	local wnd = wnd_grab_red_envelope.new()
		wnd:create(layout)
	return wnd
end
