
TimeCtrl = TimeCtrl or BaseClass(BaseController)

function TimeCtrl:__init()
	if TimeCtrl.Instance ~= nil then
		print_error("[TimeCtrl] attempt to create singleton twice!")
		return
	end
	TimeCtrl.Instance = self

	self.server_time = os.time()
	self.server_real_start_time = 0
	self.last_req_time = 0
	self.timer_quest = nil
	self.cur_day = -1
	self.send_time_list = {}
	self.delay_time = 0

	self:RegisterAllProtocols()
	self:RegisterAllEvents()
end

function TimeCtrl:__delete()
	self:CancelTimer()

	TimeCtrl.Instance = nil
end

function TimeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTimeAck, "OnTimeAck")
end

function TimeCtrl:RegisterAllEvents()
	self:BindGlobalEvent(LoginEventType.ENTER_GAME_SERVER_SUCC, BindTool.Bind(self.OnEnterGameServerSucc, self))
	self:BindGlobalEvent(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnGameServerDisConnect, self))
end

function TimeCtrl:GetServerTime()
	return self.server_time + (UnityEngine.Time.unscaledTime - self.last_req_time)
end

function TimeCtrl:SetServerTime(server_time)
	self.server_time = server_time
	self.last_req_time = UnityEngine.Time.unscaledTime
end

function TimeCtrl:GetServerRealStartTime()
	return self.server_real_start_time
end

function TimeCtrl:GetServerRealCombineTime()
	return self.server_real_combine_time
end

-- 开服第几天
function TimeCtrl:GetCurOpenServerDay()
	return self.cur_day
end

function TimeCtrl:GetServerTimeFormat()
	local second = self:GetServerTime()
	return os.date("*t", second)
end

function TimeCtrl:GetServerDay()
	local sec = self:GetServerTime()
	return os.date("%d", sec)
end

function TimeCtrl:SendTimeReq()
	table.insert(self.send_time_list, Status.NowTime)

	local protocol = ProtocolPool.Instance:GetProtocol(CSTimeReq)
	protocol:EncodeAndSend()
end

function TimeCtrl:GetDelayTime()
	return self.delay_time
end

function TimeCtrl:OnTimeAck(protocol)
	local send_time = table.remove(self.send_time_list, 1)
	if nil ~= send_time then
		self.delay_time = Status.NowTime - send_time
	end

	self.server_time = protocol.server_time
	self.server_real_start_time = protocol.server_real_start_time
	self.server_real_combine_time = protocol.server_real_combine_time
	self.last_req_time = Status.NowTime

	if self.cur_day ~= protocol.open_days then
		local is_new_day = self.cur_day ~= -1
		self.cur_day = protocol.open_days
		GlobalEventSystem:Fire(OtherEventType.PASS_DAY, self.cur_day, is_new_day)
		TreasureData.Instance:SetOpenDays(protocol.open_days)
		GlobalTimerQuest:AddDelayTimer(function ()
			CompetitionActivityData.Instance:SendNotice()
		end, 10)
	end
end

function TimeCtrl:OnEnterGameServerSucc()
	if not self.timer_quest then
		self:SendTimeReq()
		self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:SendTimeReq() end, 10)
	end
	self.send_time_list = {}
	self.delay_time = 0
end

function TimeCtrl:OnGameServerDisConnect()
	self:CancelTimer()
end

function TimeCtrl:CancelTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.send_time_list = {}
	self.delay_time = 500
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
	-- 服务端传入一个很小的begin_time， 去掉时分秒后os.time讲时间转换成起计算机的起始时间1970/1/1 0:0:0会返回一个nil
	local begin_zero_time = os.time({year=format_time.year, month=format_time.month, day=format_time.day, hour=0, min = 0, sec=0}) or 0

	local day_index = (now_time - begin_zero_time) / (24 * 3600);

	if is_past then
		return -day_index
	else
		return day_index
	end
end
