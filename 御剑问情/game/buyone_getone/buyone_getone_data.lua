BuyOneGetOneData = BuyOneGetOneData or BaseClass()

function BuyOneGetOneData:__init()
	if BuyOneGetOneData.Instance ~= nil then
		ErrorLog("[BuyOneGetOneData] Attemp to create a singleton twice !")
	end
	BuyOneGetOneData.Instance = self

	self.data = nil				--买一送一活动数据
end

function BuyOneGetOneData:__delete()
	BuyOneGetOneData.Instance = nil
end

--保存服务端的数据
function BuyOneGetOneData:SetBuyOneGetOneFreeInfo(protocol)
	self.buy_bit_list = bit:d2b(protocol.buy_flag)
	self.reward_bit_list = bit:d2b(protocol.free_reward_flag)

	local can_reward = false
	for k, v in pairs(self.buy_bit_list) do
		if v == 1 and self.reward_bit_list[k] == 0 then
			can_reward = true
		elseif self.reward_bit_list[k] == 1 then
			can_reward = false
		end
	end

	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE, can_reward)

	self:SortingData(self:GetBGOneDataByDay())
end

function BuyOneGetOneData:GetBGOneData()
	return self.data
end

--获取该物品是否已被购买
function BuyOneGetOneData:GetBuyBitListByIndex(index)
	return self.buy_bit_list[33 - index] --index + 1
end

--获取该物品是否已被领取
function BuyOneGetOneData:GetRewardBitListByIndex(index)
	return self.reward_bit_list[33 - index] --index + 1
end

function BuyOneGetOneData:GetBGOneDataByDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().buy_one_get_one_free
	if config == nil then return end

	return ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_BUYONE_GETONE)
end

function BuyOneGetOneData:SortingData(data)
	self.data = {}
	for k,v in pairs(data) do
		local data_config = {}
		data_config.cfg = v
		local buy_flag = self:GetBuyBitListByIndex(k)
		local free_reward_flag = self:GetRewardBitListByIndex(k)
		data_config.seq = v.seq + 1
		data_config.buy_flag = buy_flag
		data_config.free_reward_flag = free_reward_flag
		data_config.is_no_item = 0

		if buy_flag == 1 and free_reward_flag == 1 then
			data_config.is_no_item = 1
		end
		table.insert(self.data, data_config)
	end

	table.sort(self.data, SortTools.KeyLowerSorters("is_no_item", "seq"))
end