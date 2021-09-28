TimeLimitSaleData = TimeLimitSaleData or BaseClass()

RA_RUSH_BUYING_OPERA_TYPE =
{
	RA_RUSH_BUYING_OPERA_TYPE_QUERY_ALL_INFO = 0,			-- 请求所有信息
	RA_RUSH_BUYING_OPERA_TYPE_BUY_ITEM = 1,					-- 抢购物品
}

function TimeLimitSaleData:__init()
	if TimeLimitSaleData.Instance ~= nil then
		ErrorLog("[TimeLimitSaleData] Attemp to create a singleton twice !")
	end

	TimeLimitSaleData.Instance = self

	self.buy_end_timestamp = 0
	self.buy_phase = 0
end

function TimeLimitSaleData:__delete()
	TimeLimitSaleData.Instance = nil
end

function TimeLimitSaleData:GetRushBuyingCfg()
	if nil == self.rush_buying_cfg then
		self.rush_buying_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().rush_buying
	end
	return self.rush_buying_cfg
end

--获取每次限时抢购时间
function TimeLimitSaleData:GetRushBuyingDuration()
	local other_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	return other_cfg.rush_buying_duration
end

--根据阶段获取物品列表
function TimeLimitSaleData:GetItemListBySeq(seq)
	local item_list = nil
	local rush_buying_cfg = self:GetRushBuyingCfg()
	local list = ActivityData.Instance:GetRandActivityConfig(rush_buying_cfg,ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RUSH_BUYING)
	if nil == rush_buying_cfg then
		return item_list
	end

	for _, v in ipairs(list) do
		if v.seq == seq then
			if nil == item_list then
				item_list = {}
			end
			table.insert(item_list, v)
		end
	end

	return item_list
end

--获取总阶段时间列表
function TimeLimitSaleData:GetPhaseTimeList()
	local time_list = nil
	local rush_buying_cfg = self:GetRushBuyingCfg()
	if nil == rush_buying_cfg then
		return time_list
	end

	local seq_list = {}
	for _, v in ipairs(rush_buying_cfg) do
		if nil == seq_list[v.seq] then
			seq_list[v.seq] = true
			if nil == time_list then
				time_list = {}
			end
			table.insert(time_list, v.buying_begin_time)
		end
	end

	return time_list
end

function TimeLimitSaleData:SetAllInfo(protocol)
	self.buy_end_timestamp = protocol.buy_end_timestamp				--抢购结束时间
	self.buy_phase = protocol.buy_phase								--可购买的阶段
	self.item_buy_times_list = protocol.item_buy_times_list			--阶段物品购买次数列表
end

function TimeLimitSaleData:GetBuyEndTimeStamp()
	return self.buy_end_timestamp
end

function TimeLimitSaleData:GetBuyPhase()
	return self.buy_phase
end

--获取该阶段每个物品已购买的数量
function TimeLimitSaleData:GetBuyTimesInSeq(seq, index)
	local buy_times_list = nil
	if nil == self.item_buy_times_list or self.buy_phase ~= seq then
		return buy_times_list
	end

	for k, v in ipairs(self.item_buy_times_list) do
		if k == index + 1 then
			if nil == buy_times_list then
				buy_times_list = {}
			end
			buy_times_list.server_buy_times = v.server_buy_times
			buy_times_list.role_buy_times = v.role_buy_times
			break
		end
	end

	return buy_times_list
end

function TimeLimitSaleData:FlushRedPoint()
	self.is_in_phase = false

	local time_list = self:GetPhaseTimeList()
	if nil == time_list then
		return false
	end

	local server_time = TimeCtrl.Instance:GetServerTime()
	server_time = math.floor(server_time)
	local rush_buying_duration = self:GetRushBuyingDuration()
	local rush_buying_second = rush_buying_duration * 60
	local h = tonumber(os.date("%H", server_time))
	local m = tonumber(os.date("%M", server_time))
	local s = tonumber(os.date("%S", server_time))

	local second = m * 60 + s
	for _, v in ipairs(time_list) do
		if h == v then
		--小时相同的时候检查秒数
			if second < rush_buying_second then
				self.is_in_phase = true
			end
		end
	end

	return self.is_in_phase
end