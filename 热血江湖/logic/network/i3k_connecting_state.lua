----------------------------------------------------------------

local require = require

require("i3k_global");

local StateNotAuthed = 1
local StateNormalAuthed = 2
local StateReconnecting = 3
local StateWaitRestart = 4
local StateForceClosed = 5

local Event_TimerTick = 0
local Event_AuthSuccess = 1
local Event_ConnectOpenFailed = 2
local Event_ConnectClosed = 3
local Event_WaitResponse = 4
local Event_ReceiveResponse = 5
local Event_ForceClose = 6

local time_tick = 0
----------------------------------------------------------------
i3k_connecting_wait_animator = i3k_class("i3k_connecting_wait_animator");
function i3k_connecting_wait_animator:ctor()
	self._showtime = 0
end

function i3k_connecting_wait_animator:show(delay)
	--i3k_log("i3k_connecting_wait_animator show " .. delay .. " old=" .. self._showtime .. ", new=" .. time_tick + delay)
	if self._showtime == 0 then
		self._showtime = time_tick + delay
	end
end

function i3k_connecting_wait_animator:hide()
	--i3k_log("i3k_connecting_wait_animator hide showtime=" .. self._showtime)
	g_i3k_ui_mgr:CloseUI(eUIID_Wait)
	self._showtime = 0
end

function i3k_connecting_wait_animator:onTimer()
	if self._showtime > 0 and time_tick > self._showtime then
		--i3k_log("i3k_connecting_wait_animator pop showtime=" .. self._showtime)
		self._showtime = 0
		g_i3k_ui_mgr:PopupWait()
	end 
end

local connecting_wait_animator = i3k_connecting_wait_animator:new()
-------------------------------------------------------------------------------------------------

--管理网络LAG和重连状态
i3k_connecting_state = i3k_class("i3k_connecting_state");
function i3k_connecting_state:ctor()
	self._state = StateNotAuthed
	self._events = {}
	self._connecting_state_switcher = 
	{
		[StateNotAuthed] = i3k_connecting_state_not_authed.new(),
		[StateNormalAuthed] = i3k_connecting_state_normal_authed.new(),
		[StateReconnecting] = i3k_connecting_state_reconnecting.new(),
		[StateWaitRestart] = i3k_connecting_state_wait_restart.new(),
		[StateForceClosed] = i3k_connecting_state_force_closed.new(),
	}
end

function i3k_connecting_state:pushEvent(event)
	table.insert(self._events, event)
	--i3k_log("i3k_connecting_state pushEvent " .. event)
end


function i3k_connecting_state:trySwitchState(newState)
	if self._state ~= newState then
		--i3k_log("i3k_connecting_state trySwitchState " .. self._state .. "--->" .. newState)
		local oldstate = self._connecting_state_switcher[self._state]
		local newstate = self._connecting_state_switcher[newState]
		oldstate.onLeave(oldstate)
		self._state = newState
		newstate.onEnter(newstate)
	end
end

--每帧调用，处理重连
function i3k_connecting_state:onTick(dtTime)
	time_tick = time_tick + dtTime
	--i3k_log("i3k_connecting_state time=" .. self._time_tick .. ", self._waitStartTime=" .. self._waitStartTime)
	table.insert(self._events, Event_TimerTick)
	for i, e in ipairs(self._events) do
		local state = self._connecting_state_switcher[self._state]
		local newState = state:handleEvent(e)
		if newState ~= nil then
			--i3k_log("i3k_connecting_state state " .. self._state .. " " .. state:getEventHandlerName(e) .. "==>" .. newState)
			self:trySwitchState(newState)
		end
	end
	self._events = {}
	connecting_wait_animator:onTimer()
end



function i3k_connecting_state:trySetWait()
	self:pushEvent(Event_WaitResponse)
end

function i3k_connecting_state:clearWait()
	self:pushEvent(Event_ReceiveResponse)
end

function i3k_connecting_state:notifyAuthSuccess()
	self:pushEvent(Event_AuthSuccess)
end

function i3k_connecting_state:notifyConnectOpenFailed()
	self:pushEvent(Event_ConnectOpenFailed)
end

function i3k_connecting_state:notifyConnectClosed()
	self:pushEvent(Event_ConnectClosed)
end

function i3k_connecting_state:notifyForceClose()
	self:pushEvent(Event_ForceClose)
end

i3k_connecting_state_base = i3k_class("i3k_connecting_state_base");
function i3k_connecting_state_base:ctor()
	self._eventHandler =
	{
		[Event_TimerTick] = "onTimerTick",
		[Event_AuthSuccess] = "onAuthSuccess",
		[Event_ConnectOpenFailed] = "onConnectOpenFailed",
		[Event_ConnectClosed] = "onConnectClosed",
		[Event_WaitResponse] = "onWaitResponse",
		[Event_ReceiveResponse] = "onReceiveResponse",
		[Event_ForceClose] = "onForceClose",
	}
end

function i3k_connecting_state_base:handleEvent(event)
	local handler = self[self:getEventHandlerName(event)]
	return handler and handler(self)
end

function i3k_connecting_state_base:getEventHandlerName(event)
	return self._eventHandler[event]
end

function i3k_connecting_state_base:onEnter(event)
end

function i3k_connecting_state_base:onLeave(event)
end

----------------------------------------------------------------------------------------------------------------------
i3k_connecting_state_not_authed = i3k_class("i3k_connecting_state_not_authed", i3k_connecting_state_base);
function i3k_connecting_state_not_authed:ctor()
end

function i3k_connecting_state_not_authed:onEnter()
end

function i3k_connecting_state_not_authed:onLeave()
	connecting_wait_animator:hide()
end

function i3k_connecting_state_not_authed:onTimerTick()
end

function i3k_connecting_state_not_authed:onAuthSuccess()
	return StateNormalAuthed
end

function i3k_connecting_state_not_authed:onConnectOpenFailed()
	connecting_wait_animator:hide()
	g_i3k_ui_mgr:PopupTipMessage("无法连接服务器，请稍候再试")
end

function i3k_connecting_state_not_authed:onConnectClosed()
	connecting_wait_animator:hide()
	g_i3k_ui_mgr:PopupTipMessage("服务器繁忙，请稍候再试")
end

function i3k_connecting_state_not_authed:onWaitResponse()
	connecting_wait_animator:show(500)
end

function i3k_connecting_state_not_authed:onReceiveResponse()
	connecting_wait_animator:hide()
end

function i3k_connecting_state_not_authed:onForceClose()
	return StateForceClosed
end
----------------------------------------------------------------------------------------------------------------------			
i3k_connecting_state_normal_authed = i3k_class("i3k_connecting_state_normal_authed", i3k_connecting_state_base);
function i3k_connecting_state_normal_authed:ctor()
	self._waittime = 0
end

function i3k_connecting_state_normal_authed:onEnter()
	g_i3k_ui_mgr:CloseUI(eUIID_Tips)
end

function i3k_connecting_state_normal_authed:onLeave()
	connecting_wait_animator:hide()
	self._waittime = 0
end

function i3k_connecting_state_normal_authed:onTimerTick()
	if self._waittime > 0 and time_tick > self._waittime + 10000 then
		return StateWaitRestart
	end
end

function i3k_connecting_state_normal_authed:onConnectClosed()
	return StateReconnecting
end

function i3k_connecting_state_normal_authed:onWaitResponse()
	connecting_wait_animator:show(2000)
	self._waittime = time_tick
end

function i3k_connecting_state_normal_authed:onReceiveResponse()
	connecting_wait_animator:hide()
	self._waittime = 0
end

function i3k_connecting_state_normal_authed:onForceClose()
	return StateForceClosed
end

----------------------------------------------------------------------------------------------------------------------
i3k_connecting_state_reconnecting = i3k_class("i3k_connecting_state_reconnecting", i3k_connecting_state_base);
function i3k_connecting_state_reconnecting:ctor()
	self._times = 0
	self._acctime = 0
	self._lasttime = 0
end

function i3k_connecting_state_reconnecting:onEnter()
	self._times = 0
	self._acctime = 0
	self._lasttime = time_tick
	i3k_game_network_reset()
end

function i3k_connecting_state_reconnecting:onLeave()
	self._times = 0
	self._acctime = 0
	self._lasttime = 0
	connecting_wait_animator:hide()
end

function i3k_connecting_state_reconnecting:onTimerTick()
	if self._times >= 5 or self._acctime >= 14000 then
		return StateWaitRestart
	end
	if self._times >= 4 or self._acctime >= 9000 then
		i3k_game_network_reset()
		self:reconnect()
	elseif self._times == 0 or time_tick >= self._lasttime + 3000 then
		self:reconnect()
	end
end

function i3k_connecting_state_reconnecting:onAuthSuccess()
	return StateNormalAuthed
end

function i3k_connecting_state_reconnecting:onConnectOpenFailed()
	g_i3k_ui_mgr:PopupTipMessage("无法连接服务器，正在重试...")
end

function i3k_connecting_state_reconnecting:onConnectClosed()
	g_i3k_ui_mgr:PopupTipMessage("服务器断开连接，正在重试...")
end

function i3k_connecting_state_reconnecting:reconnect()
	--i3k_log("i3k_connecting_state_reconnecting time=" .. time_tick .. ", times=" .. self._times .. ", acctime=" .. self._acctime)
	i3k_reconnect_to_server()
	self._times = self._times + 1
	self._acctime = self._acctime + (time_tick - self._lasttime)
	self._lasttime = time_tick
	--connecting_wait_animator:hide()
	connecting_wait_animator:show(0)
end

function i3k_connecting_state_reconnecting:onForceClose()
	return StateForceClosed
end
----------------------------------------------------------------------------------------------------------------------
i3k_connecting_state_wait_restart = i3k_class("i3k_connecting_state_wait_restart", i3k_connecting_state_base);
function i3k_connecting_state_wait_restart:ctor()
	self._userChooseState = nil
end

function i3k_connecting_state_wait_restart:onEnter()
	self._userChooseState = nil
	g_i3k_ui_mgr:ShowTopCustomMessageBox2("重试", "退出", "网路状态异常，请确认网路通畅后重试",
	 	function (retry)
			if retry then
				self._userChooseState = StateReconnecting
			else
				self._userChooseState = StateNotAuthed
				g_i3k_ui_mgr:PopupTipMessage("需要重启用户端")
				g_i3k_game_handler:ReturnInitView(false)
			end
		end)
end

function i3k_connecting_state_wait_restart:onLeave()
	self._userChooseState = nil
end

function i3k_connecting_state_wait_restart:onTimerTick()
	return self._userChooseState
end

function i3k_connecting_state_wait_restart:onAuthSuccess()
	g_i3k_ui_mgr:CloseUI(eUIID_TopMessageBox2)
	return StateNormalAuthed
end

----------------------------------------------------------------------------------------------------------------------
i3k_connecting_state_force_closed = i3k_class("i3k_connecting_state_force_closed", i3k_connecting_state_base);
function i3k_connecting_state_force_closed:ctor()
	self._lastShowTime = 0
	self._errStr = "连接中断，请重新登入"
end

function i3k_connecting_state_force_closed:onEnter()
	i3k_game_network_disconnect()
	local errCode = i3k_get_last_force_close_error_code()
	if errCode == -1 then
		self._errStr = "连接中断，请重新登入";
	elseif errCode == -2 then
		self._errStr = "连接中断，相同帐号在其他设备上线了";
	elseif errCode == -3 then
		self._errStr = "检测到版本有更新，请重新下载安装";
	elseif errCode == -4 then
		self._errStr = "检测到版本有更新，请重启游戏重新进入";
	end
end

function i3k_connecting_state_force_closed:onLeave()
end

function i3k_connecting_state_force_closed:onTimerTick()
	if self._lastShowTime >= 0 and self._lastShowTime + 5000 < time_tick then
		g_i3k_ui_mgr:ShowTopMessageBox1(self._errStr, 
		function ()
			self._lastShowTime = -1
			g_i3k_ui_mgr:PopupTipMessage("需要重启用户端")
			g_i3k_game_handler:ReturnInitView(false)
		end)
		self.lastShowTime = time_tick
	end
end

