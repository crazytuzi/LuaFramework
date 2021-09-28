LimitedFeedbackData = LimitedFeedbackData or BaseClass()

function LimitedFeedbackData:__init()
	if LimitedFeedbackData.Instance ~= nil then
		print_error("[LimitedFeedbackData] attempt to create singleton twice!")
		return
	end
	LimitedFeedbackData.Instance = self
	RemindManager.Instance:Register(RemindName.LimitedFeedbackRemind, BindTool.Bind(self.GetLimitedFeedbackRemind, self))

	self.limit_time_rebate_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().limit_time_rebate
	self.limit_time_rebate_data = ListToMapList(self.limit_time_rebate_cfg,"opengame_day","chongzhi_count")
	--self.chongzhi_count_day_cfg = ListToMapList(self.limit_time_rebate_cfg,"chongzhi_count","chongzhi_day")
end

function LimitedFeedbackData:__delete()
	LimitedFeedbackData.Instance = nil

	RemindManager.Instance:UnRegister(RemindName.LimitedFeedbackRemind)

end

function LimitedFeedbackData:SetSCRALimitTimeRebateInfo(protocol)
	self.cur_day_chongzhi = protocol.cur_day_chongzhi
	self.chongzhi_days = protocol.chongzhi_days
	self.reward_bit_list = bit:d2b(protocol.reward_flag)
	self.chongzhi_day_list = protocol.chongzhi_day_list
end

--获取当天的充值数
function LimitedFeedbackData:GetCurDayChongZhi()
	return self.cur_day_chongzhi
end

--获取当天充值的数量
function LimitedFeedbackData:GetCurDayChongzhiByDay(chongzhi_count,day)
	local day_list = {}
	for k,v in pairs(self.chongzhi_day_list) do
		if v >= chongzhi_count then
			table.insert(day_list,v)
		end
	end
	return day_list[day] or 0
end

--获取是否已领取的标志位
function LimitedFeedbackData:GetRewardFlagByIndex(index)
	return self.reward_bit_list[32 - index]
end

function LimitedFeedbackData:GetChongZhiDay(chongzhi_count)
	local day = 0
	for k,v in pairs(self.chongzhi_day_list) do
		if v >= chongzhi_count then
			day = day + 1
		end
	end
	return day
end

function LimitedFeedbackData:GetLimitCfgByChongzhi()
	local data = ActivityData.Instance:GetRandActivityConfig(self.limit_time_rebate_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE)
	self.group_data = ListToMapList(data,"chongzhi_count")
	self.chongzhi_count_day_cfg = ListToMapList(data,"chongzhi_count","chongzhi_day")
	--return self.group_data
end

--获取一组数据的数量
function LimitedFeedbackData:GetLimitDataGroupCount()
	local count = 0
	for k,v in pairs(self.group_data) do
		count = count + 1
	end
	return count
end

function LimitedFeedbackData:GetLimitGroupData()
	return self.limit_time_rebate_data[self.open_day]
end

--获取一组数据下的数量
function LimitedFeedbackData:GetLimitDataItemByChongzhi(chongzhi_count)
	return self.group_data[chongzhi_count]
end

--获取需要充值金额的条件
function LimitedFeedbackData:GetChongZhiCount()
	local group_data = self.group_data or {}
	self.chongzhi_count_condition = {}
	for k,v in pairs(group_data) do
		table.insert(self.chongzhi_count_condition,k)
	end
	table.sort( self.chongzhi_count_condition,function (a,b)
		return a<b
	end )
	return self.chongzhi_count_condition
end

--获取活动的红点显示
function LimitedFeedbackData:GetLimitedFeedbackRemind()
	local cfg = self:GetChongZhiCount()
	for k,v in pairs(cfg) do
		for i=1,self:GetChongZhiDay(v) do
			local seq = self.chongzhi_count_day_cfg[v][i][1].seq
			-- local index = (k-1)*#self.chongzhi_count_day_cfg[v]+self.chongzhi_count_day_cfg[v][i][1].chongzhi_day-1
			--print_log("Remind Seq>>>>>>>>>>>>>>>",seq,index)
			if self:GetRewardFlagByIndex(seq) ~= 1 then
				--print_log(">>>>>>>>>>1")
				return 1
			end
		end
	end
	return 0
end

--主界面红点刷新
function LimitedFeedbackData:FlushHallRedPoindRemind()
	local remind_num = self:GetLimitedFeedbackRemind()
	--print_error(">>>>>>>>>>remind_num",remind_num)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE, remind_num > 0)
end
	