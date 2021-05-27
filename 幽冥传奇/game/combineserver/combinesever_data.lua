------------------------------------------------------------
CombineServerData = CombineServerData or BaseClass()

ActivityType = 
{
	CombineServer = 1,
}

--根据配置位置取对应的图片
COMBINESERVERDATA_PTHOTO = {
	[1] = 7,
	[2] = 16,
	[3] = 41,
	[4] = 42,
	[5] = 24,
	[6] = 36,
}

function CombineServerData:__init()
	if CombineServerData.Instance then
		ErrorLog("[CombineServerData]:Attempt to create singleton twice!")
	end

	CombineServerData.Instance = self

	self.charge_gold_today = nil
	self.consume_gold_today = nil 
	self.charge_gold_max = nil
	self.bool_state = 0
	self.item_data = {}
	self.remain_time = 0
	self.time = 0
	self.boss_state = nil 
	self.charge_consume_data = {}
	self.gift_data_t = {}
	self.arena_type = 0
	self.show_gift_data = {}

	self:InitArenaOpenTimeTab()
end


function CombineServerData:__delete()
	CombineServerData.Instance = nil
end

function CombineServerData.GetLimitShopItemCfg()
	local combine_server_day = OtherData.Instance:GetCombindDays() == 0 and 1 or OtherData.Instance:GetCombindDays()
	local shop_list = {}
	for k,v in pairs(CombineServerCfg.giftBag.gifts) do
		if k == combine_server_day then
			for k1, v1 in pairs(v) do
				local shop_item = {item = v1.awards, consume = v1.consume[1] and v1.consume[1].count, state = 0, desc = v1.desc}
				table.insert(shop_list, shop_item)
			end
		end
	end
	return shop_list
end

function CombineServerData:SetGetLimitGiftDataState(protocol)
	self.shop_list = CombineServerData.GetLimitShopItemCfg()
	for i,v in ipairs(protocol.gift_list) do
		for k, v1 in pairs(self.shop_list) do
			if v.pos == k then
				v1.state = v.get_state
			end
		end
	end
end

function CombineServerData:GetLimitBuyShopItem()
	return self.shop_list
end

function CombineServerData:GetChargeEveryDataConfig()
	local combine_server_day = OtherData.Instance:GetCombindDays() == 0 and 1 or OtherData.Instance:GetCombindDays()
	for k,v in pairs(CombineServerCfg.dailyCharge.gifts) do
		if k == combine_server_day then
			return v
		end
	end
end

function CombineServerData:SetGetGiftDataState(protocol)
	self.bool_state = protocol.get_state
end

function CombineServerData:SetGongChengZhanWinGuildName(protocol)

end

function CombineServerData:SetChargeMoneyData(protocol)
	self.charge_gold_today = protocol.charge_gold_today
	self.consume_gold_today = protocol.consume_gold_today 
	self.charge_gold_max = protocol.charge_gold_max
end

function CombineServerData:GetChargeNum()
	return self.charge_gold_max
end

function CombineServerData:GetState()
	return self.bool_state
end

function CombineServerData:GetChargeMoney()
	return self.charge_gold_today
end

--得到攻城战奖励
function CombineServerData:GetGongchengZhenReward()
	local data = {}
	for k, v in pairs(CombineServerCfg.GuildSiege.leaderAwards) do
		data[k] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	return data
end

function CombineServerData:SetCombineServerData(protocol)
	self.remain_time = protocol.remain_time + TimeCtrl.Instance:GetServerTime()
	self.item_data = {}
	for k, v in pairs(protocol.item_list) do
		local cfg = CombineServerData.Instance:GetCfgData(protocol.activity_id, protocol.item_index, v.pos)
		local data = {index = v.index, cfg_data = cfg, buy_num = v.buy_num}
		self.item_data[k-1] = data
	end
end

function CombineServerData.GetServerConfigData(activity_id)
	if activity_id == ActivityType.CombineServer then
		return  ConfigManager.Instance:GetServerConfigEx("item/refreshLib/CombineServerMysticalShopConfig")
	end
end

function CombineServerData:GetCfgData(activity_id, index, pos)
	local cfg_data = CombineServerData.GetServerConfigData(activity_id) or {}
	for k,v in pairs(cfg_data) do
		if v.libIdx == index then
			for k1, v1 in pairs(v.lib) do
				if v1.itemIdx == pos then
					return v1
				end
			end
		end
	end
end

function CombineServerData:GetShenMiShopData()
	return self.item_data
end

function CombineServerData:GetRemainTime()
	return self.remain_time
end

-- function CombineServerData:SetTime(num)
-- 	self.remain_time = self.remain_time + num
-- end

--获得刷新神秘商店所需消耗
function CombineServerData.GetRefreshConsume()
	return CombineServerCfg.mysticalShop.refreshConsume 
end

function CombineServerData:GetBoolShowFlag()
	local combine_server_day = OtherData.Instance:GetCombindDays() == 0 and 1 or OtherData.Instance:GetCombindDays()
	local data = CombineServerData.GetCurData(4)
	if combine_server_day >= data[1] and combine_server_day <= data[#data] then
		if self.bool_state == 1 then
			return 0
		else
			local cur_data = CombineServerData.Instance:GetChargeEveryDataConfig() or {}
			if (cur_data.needChargeSingle or 0) <= (self:GetChargeNum() or 0) then
				return 1
			else
				return 0
			end
		end
	else
		return 0
	end
end

function CombineServerData:GetCombineRemindTime(index)
	local combine_server_time = OtherData.Instance:GetCombindServerTime()
	local hour = os.date("%H",combine_server_time)
	local min = os.date("%M",combine_server_time)
	local sec = os.date("%S",combine_server_time)
	local time = os.date("%Y/%m/%d %H:%M", combine_server_time)
	local data = 24*3600 - hour * 3600 + min * 60 + sec
	local day_times = CombineServerData.GetCurData(index) or {}
	
	local combine_server_day = OtherData.Instance:GetCombindDays() == 0 and 1 or OtherData.Instance:GetCombindDays()
	local remain_time = 0
	local start_time = 0
	local end_time = 0
	if #day_times <= 1 then
		if day_times[#day_times] == combine_server_day then
			remain_time = combine_server_time + (day_times[1]-1) * 24*3600 + data
			start_time = combine_server_time + (day_times[1]-1)*24*3600
			end_time = 0
		else
			remain_time = 0
			start_time = 0
			end_time = 0
		end
	else
		if (day_times[2] - day_times[1] ~= 1) then
			for k, v in pairs(day_times) do
				if v == combine_server_day then	
					remain_time = combine_server_time + (v-1)*24*3600 + data
					start_time = combine_server_time + (v-1)*24*3600 
					end_time = 0
				end
			end
		elseif (day_times[2] - day_times[1] == 1) then
			if index == TabIndex.combine_activity_super_boss then
				if day_times[1] <= combine_server_day and combine_server_day <= day_times[#day_times] then
					for k,v in pairs(day_times) do
						if v == combine_server_day then
							remain_time = combine_server_time + (v-1)*24*3600 + data
						end
					end
					start_time = combine_server_time + (day_times[1] -1)*24*3600
					end_time = combine_server_time + (day_times[#day_times] -1)*24*3600
				end
			elseif day_times[1] <= combine_server_day and combine_server_day <= day_times[#day_times] then
				remain_time = combine_server_time + (#day_times-1) *24*3600 + data
				start_time = combine_server_time + (day_times[1] -1)*24*3600
				end_time = combine_server_time + (day_times[#day_times] -1)*24*3600
			end
		end
	end
	return remain_time, start_time, end_time
end

function CombineServerData.GetCurData(index)
	if index == TabIndex.combine_activity_double_exp then
		return CombineServerCfg.doubleExp.day
	elseif index == TabIndex.combine_activity_explore then
		return CombineServerCfg.dmkj.day
	elseif index == TabIndex.combine_activity_limittime_shop then
		return CombineServerCfg.giftBag.day
	elseif index == TabIndex.combine_activity_charge_everyDay then
		return CombineServerCfg.dailyCharge.day
	elseif index == TabIndex.combine_activity_mysterious_shop then
		return CombineServerCfg.mysticalShop.day
	elseif index == TabIndex.combine_activity_lc_zb then
		return CombineServerCfg.GuildSiege.day
	elseif index == TabIndex.combine_activity_super_boss then
		return CombineServerCfg.bossParty.day
	elseif index == TabIndex.combine_activity_charge_rank then
		return CombineServerCfg.RechargeRank.day
	elseif index == TabIndex.combine_activity_consume_rank then
		return CombineServerCfg.ConsumeRank.day
	elseif index == TabIndex.combine_activity_gift then
		return {1, 2, 3, 4, 5, 6, 7}
	elseif  index == TabIndex.combine_activity_arena then
		return {1, 2, 3, 4, 5, 6, 7}
	end
end

function CombineServerData:SetLoadTime(index)
	if index == TabIndex.combine_activity_super_boss then
		self.time = CombineServerData.Instance:GetCombineRemindTime(TabIndex.combine_activity_super_boss) - 4*3600  
	else
		self.time = CombineServerData.Instance:GetCombineRemindTime(index)
	end
end

function CombineServerData:GetTime()
	return self.time
end

function CombineServerData:BoolOpen()
	return (OtherData.Instance:GetCombindDays() <= 7 and OtherData.Instance:GetCombindDays() > 0) and true or false
end

function CombineServerData.GetBossActivityType()
	local combine_server_day = OtherData.Instance:GetCombindDays()
	local boss_time_data = CombineServerData.GetCurData(7) or {}
	for k,v in pairs(boss_time_data) do
		if v == combine_server_day then
			return k
		end
	end
end

function CombineServerData:SetBossRreshTime(protocol)
	self.boss_state = protocol.boss_refresh_state
end

function CombineServerData:GetBossRreshTime()
	return self.boss_state
end

-- 累计充值和消费
function CombineServerData:GetRechangeRankCfg()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local data = {needMinValue = CombineServerCfg.RechargeRank.needMinValue}
	for k, v in pairs(CombineServerCfg.RechargeRank.Awards) do
		local tmp = {desc = v.desc, icon = 9, award = {}}
		for k2, v2 in ipairs(v.awards) do
			if (v2.job == nil or v2.job == prof) then
				if (v2.sex == sex and (v2.job == nil or v2.job == prof)) or (v2.sex == nil and (v2.job == nil or v2.job == prof)) then
					table.insert(tmp.award, {item_id = v2.id, num = v2.count, is_bind = v2.bind})
				end
			end
		end
		table.insert(data, tmp)
	end
	return data
end

function CombineServerData:GetConsumeRankCfg()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local data = {needMinValue = CombineServerCfg.ConsumeRank.needMinValue}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(CombineServerCfg.ConsumeRank.Awards) do
		local tmp = {desc = v.desc, icon = 9, award = {}}
		for k2, v2 in ipairs(v.awards) do
			if (v2.job == nil or v2.job == prof) then
				if (v2.sex == sex and (v2.job == nil or v2.job == prof)) or (v2.sex == nil and (v2.job == nil or v2.job == prof)) then
					table.insert(tmp.award, {item_id = v2.id, num = v2.count, is_bind = v2.bind})
				end
			end
		end
		table.insert(data, tmp)
	end
	return data
end

function CombineServerData:SetChargeConsumeRank(protocol)
	self.charge_consume_data = self.charge_consume_data or {}
	if protocol.type == 1 then
		self.charge_consume_data[TabIndex.combine_activity_charge_rank] = self.charge_consume_data[TabIndex.combine_activity_charge_rank] or {my_rank = 0, my_money = 0}
		self.charge_consume_data[TabIndex.combine_activity_charge_rank].my_rank = protocol.my_rank
		self.charge_consume_data[TabIndex.combine_activity_charge_rank].my_money = protocol.my_charconsume
		
	else
		self.charge_consume_data[TabIndex.combine_activity_consume_rank] = self.charge_consume_data[TabIndex.combine_activity_consume_rank] or {my_rank = 0, my_money = 0}
		self.charge_consume_data[TabIndex.combine_activity_consume_rank].my_rank = protocol.my_rank
		self.charge_consume_data[TabIndex.combine_activity_consume_rank].my_money = protocol.my_charconsume
	end
end

function CombineServerData:GetChanrgeConsumeRankData(index)
	return self.charge_consume_data[index] or {my_rank = 0, my_money = 0}
end

function CombineServerData:SetCombineServerGiftConfigData()
	self.gift_data_t = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)			-- 职业
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)			-- 性别
	for k, v in ipairs(CombineServerCfg.gift.giftData) do
		local t1 = {gift_type = k, gifts = {}, total_cnt = #v,CombineDay = nil}
		for i2, v2 in ipairs(v) do
			if v2.CombineDay then
				t1.CombineDay = v2.combineDay
			end
			local t2 = {
						getReward = 0,
						cost = v2.yuanbao,
						awards = {},
						name = v2.sItemName,
						name_id = v2.Nameid,
						picture_id = v2.pictureid,	
						effec_id = v2.effectid or 1,
						is_can_buy = false,	
						gift_type = k,
					}
			for i3, v3 in ipairs(v2.awards) do
				if v3.job == nil or v3.job == prof then

					 if (v3.sex == nil or v3.sex == sex) then
						 table.insert(t2.awards, {item_id = v3.id, num = v3.count, is_bind = v3.bind, 
										quality = v3.quality, type = v3.type, level = v3.importantLevel,
										strengthen_level = v3.strong or 0 })
					 end
				end
			end
			t1.gifts[i2] = t2
		end
		self.gift_data_t[k] = t1
	end
end


function CombineServerData:SetGiftInfoData(protocol)
	
	local buy_info_group = protocol.gift_info
	for i1,v1 in ipairs(self.gift_data_t) do
		local info = buy_info_group[v1.gift_type]
		if info then
			local index = info.gift_level
			local state = info.had_get
			if index == 1 then
				for i2,v2 in ipairs(v1.gifts) do
					v2.getReward = 0
				end	
			elseif index == #v1.gifts and state == 1 then
				for i2,v2 in ipairs(v1.gifts) do
					v2.getReward = 1
				end
			else
				for i = index - 1, 1, -1 do
					v1.gifts[i].getReward = 1
				end 
			end	
		end
	end	
end

function CombineServerData:FilterOpenDayGift()
	local gift_data = {}
	local combin_day =  OtherData.Instance:GetCombindDays()
	for k, v in ipairs(self.gift_data_t) do
		local rest_num = #v.gifts
		for k2, v2 in ipairs(v.gifts) do
			if v2.getReward == 1 then
				rest_num = rest_num - 1
			end
		end
		if rest_num > 0 then
			if v.CombineDay then
				table.insert(gift_data, v)
			else
				table.insert(gift_data, v)
			end
		end
	end
	return gift_data
end

function CombineServerData:GetGiftData()
	return self:FilterOpenDayGift()
end


function CombineServerData:GetCanGiftDataByType(type)
	local group = self.gift_data_t[type] or {}

	for i1, v1 in ipairs(group.gifts) do
		if v1.getReward == 0 then
			return true,i1,v1
		end	
	end	
	return false,#group.gifts,group.gifts[#group]
end	

-- 是否显示特惠礼包
function CombineServerData:IsShowGiftTab()
	for i1,v1 in ipairs(self.gift_data_t) do
		for i2,v2 in ipairs(v1.gifts) do
			if v2.getReward == 0 then
				return true
			end
		end	
	end	

	return false
	--return self.show_gift_data ~= nil and next(self.show_gift_data) ~= nil
end

--得到礼包的Index
function CombineServerData:GetIndexByType(gift_type)
	local data = self:GetGiftData()
	for k,v in pairs(data) do
		if k == gift_type then
			return k 
		end
	end
	return 0 
end

-- 得到合服擂台的报名状态
function CombineServerData:GetCombineServerArenaType(protocol)
	self.arena_type = protocol.enroll_state
end

function CombineServerData:CombineServerArenaState()
	return self.arena_type
end

function CombineServerData:GetArenaRewards(index)
	local reward_data = {}
	if index <= 2 then
		local awar_cfg_1 = CombineServerArenaCfg.fight.scoreRank.rankAwards[index] and CombineServerArenaCfg.fight.scoreRank.rankAwards[index].awards[1]
		for i, v in ipairs(awar_cfg_1.award) do
			table.insert(reward_data, {item_id = v.id, num = v.count, is_bind = v.bind})
		end
	else
		local awar_cfg_2 = CombineServerArenaCfg.arena.scoreRank.rankAwards[index - 2] and CombineServerArenaCfg.arena.scoreRank.rankAwards[index - 2].awards[1]
		for i1, v1 in ipairs(awar_cfg_2.award) do
			table.insert(reward_data, {item_id = v1.id, num = v1.count, is_bind = v1.bind})
		end
	end
	return reward_data
end

function CombineServerData:InitArenaOpenTimeTab()
	self.arena_open_time_t = {}
	-- local now_time = ActivityData.Instance:GetNowShortTime()
	for k, v in pairs(CombineServerArenaCfg.arena.activeTime) do
		local time = {
			start_time = ActivityData.GetTimesSecond(v[1]),
			end_time = ActivityData.GetTimesSecond(v[2]),
		}
		table.insert(self.arena_open_time_t, time)
	end
end

function CombineServerData:CheckArenaOpenState()
	local now_time = ActivityData.Instance:GetNowShortTime()
	for k, v in pairs(self.arena_open_time_t) do
		if now_time >= v.start_time and now_time <= v.end_time then
			return true
		end
	end

	return false
end
