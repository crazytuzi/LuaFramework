
OtherData = OtherData or BaseClass()

-- 0不可领取，1可领取，2已领取，-1数据不可用(未收到服务端数据)
SUPER_CHEST_STATE_ENUM = {
	CAN_NOT_REC = 0,
	CAN_REC = 1,
	ALREADY_REC = 2,
	DATA_IS_DISABLE = -1,
}

function OtherData:__init()
	if OtherData.Instance ~= nil then
		ErrorLog("[OtherData] attempt to create singleton twice!")
		return
	end
	OtherData.Instance = self

	self.cross_server_state = 0
	self.open_server_day = 0
	self.combined_server_day = 0
	self.combined_server_time = 0
	self.open_server_time = 0

	self.day_charge_gold_num = 0	-- 今日充值的元宝数
	self.day_consume_gold_num = 0	-- 今日消费的元宝数

	self.super_chest_state = SUPER_CHEST_STATE_ENUM.DATA_IS_DISABLE

	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.OpenServerDay, BindTool.Bind(self.CondOpenServerDay, self))
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.OpenServerRange, BindTool.Bind(self.CondOpenServerDayRange, self))
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.CombindDayRange, BindTool.Bind(self.CondCombindDayRange, self))
end

function OtherData:__delete()
	OtherData.Instance = nil
end

function OtherData:PassDay()
	if self.open_server_time > 0 then
		local date_t = os.date("*t", self.open_server_time)
		local calc_open_server_time = self.open_server_time - ((date_t.hour * 60 + date_t.min) * 60 + date_t.sec)
		self.open_server_day = math.ceil((TimeCtrl.Instance:GetServerTime() - calc_open_server_time) / 86400)
	end
end

function OtherData:SetCrossServerState(state)
	self.cross_server_state = state
end

function OtherData:SetOpenServerDays(protocol)
	local old_combined_day = self.combined_server_day
	local old_open_day = self.open_server_day
	self.open_server_day = protocol.open_server_day
	self.combined_server_day = protocol.combined_server_day
	self.combined_server_time = protocol.combined_server_time
	self.open_server_time = protocol.open_server_time
	if old_open_day ~= self.open_server_day then
		GlobalEventSystem:Fire(OtherEventType.OPEN_DAY_CHANGE, self.open_server_day)
	end

	if old_combined_day ~= self.combined_server_day then
		GlobalEventSystem:Fire(OtherEventType.COMBINED_DAY_CHANGE, self.combined_server_day)
	end

	GlobalEventSystem:Fire(OtherEventType.OPEN_DAY_GET)

	GameCondMgr.Instance:CheckCondType(GameCondType.OpenServerDay)
	GameCondMgr.Instance:CheckCondType(GameCondType.OpenServerRange)
	GameCondMgr.Instance:CheckCondType(GameCondType.CombindDayRange)
end

--得到开服第几天
function OtherData:GetOpenServerDays()
	return self.open_server_day
end

--合服第几天
function OtherData:GetCombindDays()
	return self.combined_server_day
end

-- 是否合服
function OtherData:IsCombindServer()
	return self.combined_server_time > COMMON_CONSTS.SERVER_TIME_OFFSET
end

--合服时间
function OtherData:GetCombindTime()
	return self.combined_server_time
end

function OtherData:GetOpenServerTime()
	return self.open_server_time
end

function OtherData:SetSuperChestState(flag)
	self.super_chest_state = flag
end

-- 超级宝箱领取状态
function OtherData:GetSuperChestState()
	return self.super_chest_state
end

function OtherData:SetDayChargeGoldNum(num)
	if self.day_charge_gold_num ~= num then
		self.day_charge_gold_num = num
		GlobalEventSystem:Fire(OtherEventType.TODAY_CHARGE_GOLD_CHANGE, self.day_charge_gold_num)
	end
end

function OtherData:GetDayChargeGoldNum()
	return self.day_charge_gold_num
end

function OtherData:SetDayConsumeGoldNum(num)
	if self.day_consume_gold_num ~= num then
		self.day_consume_gold_num = num
		GlobalEventSystem:Fire(OtherEventType.TODAY_CONSUME_GOLD_CHANGE, self.day_consume_gold_num)
	end
end

function OtherData:GetDayConsumeGoldNum()
	return self.day_consume_gold_num
end

function OtherData:CondOpenServerDay(param)
	return self.open_server_day >= param
end

function OtherData:CondOpenServerDayRange(param)
	return self.open_server_day >= param[1] and self.open_server_day <= param[2]
end

function OtherData:CondCombindDayRange(param)
	return self.combined_server_day >= param[1] and self.combined_server_day <= param[2]
end