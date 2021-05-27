OpenSerRaceStandardData = OpenSerRaceStandardData or BaseClass()
-- 开服达标比拼活动类型
OPEN_SER_RACE_STANDARD_TYPE = {
	Level = 1, 			-- 等级达标  
	Wing = 2, 			-- 翅膀达标  
	FuWen = 3, 			-- 符文达标  
	SoulBead = 4, 		-- 灵珠达标（魂珠） 
	SpecRing = 5, 		-- 特戒达标 
	FightSoul = 6, 		-- 武魂达标（宝石）
	Meridian = 7, 		-- 经脉达标 
	Strong = 8,			-- 注灵达标 
	Diamond = 9,		-- 宝石达标（魂石）
	Vip = 10,			-- 会员达标
}

OpenSerRaceStandardData.ComposeEqToActType = {
	[EquipData.EquipIndex.SealBead] = OPEN_SER_RACE_STANDARD_TYPE.SoulBead,
	[EquipData.EquipIndex.SpecialRing] = OPEN_SER_RACE_STANDARD_TYPE.SpecRing,
	[EquipData.EquipIndex.SpecialRingR] = OPEN_SER_RACE_STANDARD_TYPE.SpecRing,
	[EquipData.EquipIndex.EquipDiamond] = OPEN_SER_RACE_STANDARD_TYPE.FightSoul,
}

function OpenSerRaceStandardData:__init()
	if OpenSerRaceStandardData.Instance then
		ErrorLog("[OpenSerRaceStandardData] Attemp to create a singleton twice !")
	end

	OpenSerRaceStandardData.Instance = self
end

function OpenSerRaceStandardData:__delete()
	OpenSerRaceStandardData.Instance = nil
end

function OpenSerRaceStandardData.IsStageStar(act_id)
	if act_id == OPEN_SER_RACE_STANDARD_TYPE.Level or 
		act_id == OPEN_SER_RACE_STANDARD_TYPE.SoulBead or
		act_id == OPEN_SER_RACE_STANDARD_TYPE.SpecRing or
		act_id == OPEN_SER_RACE_STANDARD_TYPE.FightSoul or
		act_id == OPEN_SER_RACE_STANDARD_TYPE.Meridian or 
		act_id == OPEN_SER_RACE_STANDARD_TYPE.FuWen then

		return true
	end
	return false
end

function OpenSerRaceStandardData:InitOpenSerRaceStandardData()
	local open_day = OtherData.Instance:GetOpenServerDays()
	local cfg = OpenServiceAcitivityData.GetServerCfg(OPEN_SERVER_CFGS_NAME[4])
	local day_limit = cfg and #cfg or 10
	if not cfg or open_day > day_limit then return end
	if self.open_ser_race_standard_data == nil then
		self.open_ser_race_standard_data = cfg
		for k, v in ipairs(self.open_ser_race_standard_data) do
			v.is_open = open_day >= v.openDay
			v.is_over = open_day > v.endDay
			v.act_id = k
			for k2, v2 in ipairs(v.Rewards) do
				v2.state = OPEN_ATHLETICS_FETCH_STATE.NOT_COMPLETE
				v2.idx = k2
				v2.rest_cnt = 0
				v2.act_id = k
			end
			v.my_rank = 0
			v.my_stage = 0
			v.my_star = 0
			v.top1_name = nil
			v.top1_stage = 0
			v.top1_star = 0
			v.is_stage_star = OpenSerRaceStandardData.IsStageStar(k) 
		end
	else
		for k, v in ipairs(self.open_ser_race_standard_data) do
			v.is_open = open_day >= v.openDay
			v.is_over = open_day > v.endDay
		end
	end
end

function OpenSerRaceStandardData:GetOpenSerRaceStandardData()
	local data = {}
	local idx = 0
	for k, v in ipairs(self.open_ser_race_standard_data) do
		if v.is_open then
			data[idx] = v
			idx = idx + 1
		end
	end
	idx = idx
	return data, idx
end

function OpenSerRaceStandardData:SetActAwardData(protocol)
	if not self.open_ser_race_standard_data then return end
	local act_id = protocol.act_id
	local data = protocol.act_data
	local is_need_fire = false
	local cur_act_data = self.open_ser_race_standard_data[act_id]
	if cur_act_data == nil then return end
	is_need_fire = cur_act_data.top1_name ~= data.top1_name or cur_act_data.top1_stage ~= data.top1_stage or cur_act_data.top1_star ~= data.top1_star or cur_act_data.my_rank ~= data.my_rank or cur_act_data.my_stage ~= data.my_stage or cur_act_data.my_star ~= data.my_star
	cur_act_data.my_rank = data.my_rank
	cur_act_data.my_stage = data.my_stage
	cur_act_data.my_star = data.my_star
	cur_act_data.top1_name = data.top1_name
	cur_act_data.top1_stage = data.top1_stage
	cur_act_data.top1_star = data.top1_star
	for k, v in pairs(cur_act_data.Rewards) do
		local info = data.standard_info[v.idx]
		if info then
			if is_need_fire == false then
				is_need_fire = v.state ~= info.state or v.rest_cnt ~= info.rest_cnt
			end
			v.state = info.state
			v.rest_cnt = info.rest_cnt
		end
	end
	if is_need_fire then
		-- print("发射", act_id)
		GlobalEventSystem:Fire(OpenServerActivityEventType.OPENSERVER_RACE_STAND, act_id - 1, cur_act_data)
	end
end

function OpenSerRaceStandardData:IsShowMainUiEntryIcon()
	-- if not self.open_ser_race_standard_data then return false end
	-- for k, v in ipairs(self.open_ser_race_standard_data) do
	-- 	if v.is_open and not v.is_over then
	-- 		return true
	-- 	end
	-- end
	return false
end

function OpenSerRaceStandardData:GetRemindNum()
	if not self.open_ser_race_standard_data or not self:IsShowMainUiEntryIcon() then return 0 end
	for k, v in ipairs(self.open_ser_race_standard_data) do
		for _, v2 in pairs(v.Rewards) do
			if v2.state == OPEN_ATHLETICS_FETCH_STATE.CAN_FETCH then
				return 1
			end
		end
	end
	return 0
end