MakeMoonCakeData = MakeMoonCakeData or BaseClass()
function MakeMoonCakeData:__init()
	if nil ~= MakeMoonCakeData.Instance then
		return
	end
	MakeMoonCakeData.Instance = self
	self.collect_exchange_info = {}
end

function MakeMoonCakeData:__delete()
	MakeMoonCakeData.Instance = nil
end

-- 匠心月饼活动兑换次数
function MakeMoonCakeData:SetCollectExchangeInfo(exchange_times)
	self.collect_exchange_info = exchange_times
end

function MakeMoonCakeData:GetCollectExchangeInfo()
	return self.collect_exchange_info
end

--匠心月饼红点
function MakeMoonCakeData:IsShowMakeMoonCakeRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2) then
		return 0 
	end

	local rand_act_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	if nil == rand_act_cfg or nil == rand_act_cfg.item_collection_2 then
		return 0
	end

	local can_get = 0
	for k, v in pairs(rand_act_cfg.item_collection_2) do
		if v.seq then
			can_get = self:SingleMakeMoonCakeRedPoint(v.seq)
			if can_get then
				can_get = 1
				break
			end
		end
	end
	if not can_get then
		can_get = 0
	end
	return can_get
end

--判断单个月饼的红点出现
function MakeMoonCakeData:SingleMakeMoonCakeRedPoint(seq)
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2) then 
		return false 
	end
	local rand_act_cfg = PlayerData.Instance:GetCurrentRandActivityConfig()
	local times_t = MakeMoonCakeData.Instance:GetCollectExchangeInfo()
	if nil == times_t or nil == rand_act_cfg or nil == rand_act_cfg.item_collection_2 then
		return false
	end
	local can_get = false
	for k, v in pairs(rand_act_cfg.item_collection_2) do	
		if seq == v.seq then
			local times = times_t[v.seq + 1] or 0
			if times < v.exchange_times_limit then
				can_get = true
				for i = 1, 4 do
					local num = ItemData.Instance:GetItemNumInBagById(v["stuff_id" .. i].item_id)
					if v["stuff_id" .. i].item_id > 0 and num < v["stuff_id" .. i].num then
						can_get = false
					end
				end
				if can_get then
					break
				end
			end
		end
	end
	return can_get
end
