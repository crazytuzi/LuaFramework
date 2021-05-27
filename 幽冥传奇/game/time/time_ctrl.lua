
TimeCtrl = TimeCtrl or BaseClass(BaseController)
TimeCtrl.HeartBeatTime = 10		-- 心跳时间

function TimeCtrl:__init()
	if TimeCtrl.Instance ~= nil then
		ErrorLog("[TimeCtrl] attempt to create singleton twice!")
		return
	end
	TimeCtrl.Instance = self

	self.server_time = 0
	self.server_start_time = 0
	self.last_req_time = 0
	self.timer_quest = nil

	self.cur_day = -1

	self.send_time = 0 			-- 记录发送获取服务器时间协议的当前时间
	self.send_count = 0			-- 已发送获取服务器时间未返回次数
	self.cheak_delay_time = 0

	self:registerAllProtocols()
	self:RegisterAllEvents()
end

function TimeCtrl:__delete()
	self:CancelTimer()

	self.send_count = 0
	self.cheak_delay_time = 0
	TimeCtrl.Instance = nil
end

function TimeCtrl:registerAllProtocols()
	self:RegisterProtocol(SCServerTime, "OnServerTime")
	self:RegisterProtocol(SCHeartBeatAck, "OnHeartBeatAck")
	self:RegisterProtocol(SCWaiguaCheckAck, "OnWaiguaCheckAck")
end

function TimeCtrl:RegisterAllEvents()
	self:Bind(LoginEventType.ENTER_GAME_SERVER_SUCC, BindTool.Bind(self.OnEnterGameServerSucc, self))
	self:Bind(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnGameServerDisConnect, self))
end

function TimeCtrl:OnEnterGameServerSucc()
	if nil == self.timer_quest then
		self:SendTimeReq()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:SendTimeReq() end, TimeCtrl.HeartBeatTime)
	end
	TimeCtrl.SendWaiguaCheckReq()
end

function TimeCtrl:OnGameServerDisConnect()
	self:CancelTimer()
end

function TimeCtrl:SendTimeReq()
	self.send_time = Status.NowTime
	self.send_count = self.send_count + 1
	self.cheak_delay_time = self.cheak_delay_time + TimeCtrl.HeartBeatTime

	local protocol = ProtocolPool.Instance:GetProtocol(CSHeartBeatReq)
	protocol:EncodeAndSend()
end

function TimeCtrl:OnHeartBeatAck(protocol)
	self.send_count = math.max(self.send_count - 1, 0)
	self:SetDelayTime()
	self:SetServerTime(protocol.server_time)
end

function TimeCtrl:OnServerTime(protocol)
	self:SetServerTime(protocol.server_time)
	self.server_start_time = protocol.open_server_time
	self.combined_day = protocol.combined_day
end

function TimeCtrl:GetServerTime()
	return self.server_time + (Status.NowTime - self.last_req_time)
end

function TimeCtrl:SetServerTime(server_time)
	local old_server_time = self:GetServerTime()
	self.server_time = server_time
	self.last_req_time = Status.NowTime

	if math.floor(old_server_time / 86400) ~= math.floor(self:GetServerTime() / 86400) then
		OtherData.Instance:PassDay()
		GlobalEventSystem:Fire(OtherEventType.PASS_DAY)
	end
end

-- 服务器开服时间
function TimeCtrl:GetServerStartTime()
	return self.server_start_time
end

-- 服务器合服时间
function TimeCtrl:GetServerCombineTime()
	return self.server_combine_time
end

function TimeCtrl:GetCurOpenServerDay()
	return self.cur_day
end

function TimeCtrl:GetServerTimeFormat()
	local second = self:GetServerTime()
	return os.date("*t", second)
end

-- 设置网络延迟
function TimeCtrl:SetDelayTime()
	if 0 == self.send_count then
		GameNet.Instance:SetDelayTime(Status.NowTime - self.send_time)
	elseif self.send_count > 0 and self.cheak_delay_time >= 100 then
		self.send_count = 0 
		self.cheak_delay_time = 0
	end
end

function TimeCtrl:CancelTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TimeCtrl:GetDayIndex(begin_time, now_time)
	local tmp_time = 0
	local is_past = now_time < begin_time
	if is_past then
		tmp_time = begin_time
		begin_time = now_time
		now_time = tmp_time
	end

	local format_time = os.date("*t", begin_time)
	local begin_zero_time = os.time{year=format_time.year, month=format_time.month, day=format_time.day, hour=0, min = 0, sec=0}

	local day_index = (now_time - begin_zero_time) / (24 * 3600);

	if is_past then
		return -day_index
	else
		return day_index
	end
end

-- 请求校验
function TimeCtrl.SendWaiguaCheckReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSWaiguaCheckReq)
	protocol:EncodeAndSend()
end

-- 请求校验
function TimeCtrl:OnWaiguaCheckAck(protocol)
	GlobalTimerQuest:AddDelayTimer(TimeCtrl.SendWaiguaCheckReq, protocol.Interval_time / 1000)
end

-- 跨天时间段
function TimeCtrl:IsPassDayTimeNow()
	local format_time = os.date("*t", self:GetServerTime())
	if (format_time.hour == 23 and format_time.min >= 58)
		or (format_time.hour == 0 and format_time.min <= 5) then
		return true
	end
	return false
end
