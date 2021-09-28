-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_broadcast = i3k_class("wnd_broadcast", ui.wnd_base)

function wnd_broadcast:ctor()
end

function wnd_broadcast:configure(...)
	self.isBroadcasting = false
	self.isShowingFrontView = false
	self.isPause = false
	self.isMicOn = false
	self:onFrontView()
	self:onMic()
	self._layout.vars.btnStop:onClick(self, self.onStop)
	self._layout.vars.btnPause:onClick(self, self.onPause)
	self._layout.vars.btnCamera:onClick(self, self.onFrontView)
	self._layout.vars.btnMic:onClick(self, self.onMic)
	self._layout.vars.btnDrag:onTouchEvent(self, self.onDrag)
end

function wnd_broadcast:onShow()
end

function wnd_broadcast:onHide()
end

function wnd_broadcast:dragpos()
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	self._layout.vars.chatView:setPosition(self._chatViewBeganPos.x + touchPos.x - self._touchBeganPos.x, 
											self._chatViewBeganPos.y + touchPos.y - self._touchBeganPos.y)
end

function wnd_broadcast:onDrag(sender, eventType)
	if eventType==ccui.TouchEventType.moved then
		if self.lastTick ~= i3k_get_update_tick() then
			self.lastTick = i3k_get_update_tick()
			self:dragpos()
		end
	elseif eventType==ccui.TouchEventType.began then
		self._chatViewBeganPos = self._layout.vars.chatView:getPosition()
		self._touchBeganPos = g_i3k_ui_mgr:GetMousePos()
	else
		self:dragpos()
		self._chatViewBeganPos = nil
		self._touchBeganPos = nil
	end
end

function wnd_broadcast:onUpdate(dTime)
	if self.isBroadcasting then
		local deltaTime = i3k_game_get_time() - self.startTime

		local h = i3k_integer(deltaTime / (60 * 60))
		deltaTime = deltaTime - h * 60 * 60

		local m = i3k_integer(deltaTime / 60)
		deltaTime = deltaTime - m * 60

		local s = deltaTime

		self._layout.vars.labelTime:setText(string.format("%02d:%02d:%02d", h, m, s))
	end
end

function wnd_broadcast:startBroadcast()
	if self.isBroadcasting == false then
		self.isBroadcasting = true
		self.startTime = i3k_game_get_time()
	end
end

function wnd_broadcast:onStop()
	g_i3k_game_handler:RKStopBroadcast()
end

function wnd_broadcast:onPause()
	if self.isPause then
		g_i3k_game_handler:RKResumeBroadcast()
		self._layout.vars.btnPause:stateToNormal()
		self._layout.vars.btnStop:enable()
		self.isPause = false
	else
		g_i3k_game_handler:RKPauseBroadcast()
		self._layout.vars.btnPause:stateToPressed()
		self._layout.vars.btnStop:disable()
		self.isPause = true
	end
end

function wnd_broadcast:onFrontView()
	if self.isShowingFrontView then
		g_i3k_game_handler:RKHiddenFrontView()
		self.isShowingFrontView = false
		self._layout.vars.btnCamera:stateToNormal()
	else
		g_i3k_game_handler:RKShowFrontView()
		self.isShowingFrontView = true
		self._layout.vars.btnCamera:stateToPressed()
	end
end

function wnd_broadcast:onMic()
	self.isMicOn = not self.isMicOn
	g_i3k_game_handler:RKSetMicEnable(self.isMicOn)
	if self.isMicOn then
		self._layout.vars.btnMic:stateToPressed()
	else
		self._layout.vars.btnMic:stateToNormal()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_broadcast.new();
		wnd:create(layout, ...);

	return wnd;
end
