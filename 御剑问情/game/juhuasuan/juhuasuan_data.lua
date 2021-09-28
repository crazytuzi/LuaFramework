JuHuaSuanData = JuHuaSuanData or BaseClass()

XIANYUAN_TREAS_OPERA_TYPE =
	{
		QUERY_INFO = 0,				-- 请求活动信息
		BUY = 1,						-- 单个购买请求
		BUY_ALL = 2,					-- 全部购买请求
		FETCH_REWARD = 3,				-- 领取奖励
	}

function JuHuaSuanData:__init()
	if JuHuaSuanData.Instance then
		ErrorLog("[JuHuaSuanData] attempt to create singleton twice!")
		return
	end
	JuHuaSuanData.Instance =self
	self.all_buy_gift_fetch_flag = 0
	self.xianyuan_list = {}
	RemindManager.Instance:Register(RemindName.JuHuaSuan, BindTool.Bind(self.GetRemind, self))
end

function JuHuaSuanData:__delete()
	JuHuaSuanData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.JuHuaSuan)
end

function JuHuaSuanData:SetJuHuaSuanInfo(info)
	self.all_buy_gift_fetch_flag = info.all_buy_gift_fetch_flag
	self.xianyuan_list = info.xianyuan_list
end

--是否可领取
function JuHuaSuanData:GetCanReceiveGift(index)
	local open_days = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS)
	if open_days > 0 and self.xianyuan_list[index] and self.xianyuan_list[index].buy_day_index > 0 then
		return self.xianyuan_list[index].num < (open_days - self.xianyuan_list[index].buy_day_index + 1)
				and self.xianyuan_list[index].num < self:GetJuHuaSuanMaxRewardDay(index)
	end
	return false
end

--是否可购买
function JuHuaSuanData:HasBuyGift(index)
	if self.xianyuan_list[index] then
		return self.xianyuan_list[index].buy_day_index > 0
	end
	return false
end

--领取次数
function JuHuaSuanData:GetReceiceGiftNum(index)
	if self.xianyuan_list[index] then
		return self.xianyuan_list[index].num
	end
	return 0
end

--是否全部购买
function JuHuaSuanData:HasBuyAllGift()
	for k,v in pairs(ServerActivityData.Instance:GetCurrentRandActivityConfig().xianyuan_treas) do
		if not self:HasBuyGift(v.seq) then
			return false
		end
	end
	return true
end

--购买全部礼包需要花费
function JuHuaSuanData:BuyAllNeed()
	local gold = 0
	for k,v in pairs(ServerActivityData.Instance:GetCurrentRandActivityConfig().xianyuan_treas) do
		if not self:HasBuyGift(v.seq) then
			gold = gold + v.consume_gold
		end
	end
	return gold
end

function JuHuaSuanData:GetRemind()
	for k,v in pairs(ServerActivityData.Instance:GetCurrentRandActivityConfig().xianyuan_treas) do
		if self:HasBuyGift(v.seq) and self:GetCanReceiveGift(v.seq) then
			return 1
		end
	end
	return 0
end

--最大领取天数
function JuHuaSuanData:GetJuHuaSuanMaxRewardDay(index)
	for k,v in pairs(ServerActivityData.Instance:GetCurrentRandActivityConfig().xianyuan_treas) do
		if v.seq == index then
			return v.max_reward_day
		end
	end
	return 0
end

--获取排序后的数据
function JuHuaSuanData:GetJuHuaSuanData()
	local juhuasuan_data = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().xianyuan_treas
	for k,v in ipairs(cfg) do
		table.insert(juhuasuan_data, v)
	end
	table.sort(juhuasuan_data, function (a, b)
		local a_can_do = not self:HasBuyGift(a.seq) or self:GetCanReceiveGift(a.seq)
		local b_can_do = not self:HasBuyGift(b.seq) or self:GetCanReceiveGift(b.seq)
		if a_can_do ~= b_can_do then
			return a_can_do
		else
			return a.seq < b.seq
		end
		end)
	return juhuasuan_data
end
