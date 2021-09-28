MonthCardModel = BaseClass(LuaModel)

function MonthCardModel:GetInstance()
	if MonthCardModel.inst == nil then
		MonthCardModel.inst = MonthCardModel.New()
	end
	return MonthCardModel.inst
end

function MonthCardModel:__init()
	self.bGot = false -- 今天是否已领
	self.state = MonthCardConst.STATE.NOT_ACTIVE
	self.leftDays = 0
end

function MonthCardModel:__delete()
	MonthCardModel.inst = nil
end

function MonthCardModel:GetState()
	return self.state or MonthCardConst.STATE.NOT_ACTIVE
end

function MonthCardModel:GetLeftDays()
	return self.leftDays or 0
end

function MonthCardModel:IsGot()
	return self.bGot
end

function MonthCardModel:ParseMonthCardInfo(msg)
	local vaildTimeTime = msg.vaildTimeTime or 0
	vaildTimeTime = toLong(vaildTimeTime)
	if msg.state and msg.state == 1 then
		self.bGot = true
	else
		self.bGot = false
	end
	local curTime = TimeTool.GetCurTime()
	local deltaTime = vaildTimeTime - curTime
	if deltaTime <= 0 then
		self.state = MonthCardConst.STATE.NOT_ACTIVE
		self.leftDays = 0
	else
		if self:IsGot() then
			self.state = MonthCardConst.STATE.CANNOT_GET
		else
			self.state = MonthCardConst.STATE.CAN_GET
		end
		self.leftDays = math.floor( deltaTime / (3600 * 24 * 1000) )
	end
	self:DispatchEvent(MonthCardConst.E_CARDINFO_CHANGE)
	GlobalDispatcher:DispatchEvent(EventName.MonthCardStateChange)
end

function MonthCardModel:ParseRewardInfo(msg)
	-- print("rewrad==>> " .. msg.state)
	if msg.state and msg.state == 1 then
		self.bGot = true
	else
		self.bGot = false
	end
	if self.bGot then
		self.state = MonthCardConst.STATE.CANNOT_GET
	else
		self.state = MonthCardConst.STATE.CAN_GET
	end
	self:DispatchEvent(MonthCardConst.E_CARDINFO_CHANGE)
	GlobalDispatcher:DispatchEvent(EventName.MonthCardStateChange)
end

function MonthCardModel:GetRed()
	if self.state == MonthCardConst.STATE.CAN_GET then
		return true
	else
		return false
	end
end