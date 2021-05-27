LimitedActivityData = LimitedActivityData or BaseClass()

function LimitedActivityData:__init()
	if LimitedActivityData.Instance then
		ErrorLog("[LimitedActivityData] Attemp to create a singleton twice !")
	end
	LimitedActivityData.Instance = self
	self.plan_num = nil
	self.remain_time = nil
	self.remain_time_1 = nil
	self.rewaed_money = nil
	self.rewaed_money_1 = nil
	self.length = nil
	self.rewardv = {}
	self.limit_goods_remain_time = 0
	self.limit_goods_rest_count = 0
end

function LimitedActivityData:__delete()
	LimitedActivityData.Instance = nil
end


---------------------------- 累计充值 ----------------------------
function LimitedActivityData:SetLimitRewardData(protocol)
	self.plan_num = protocol.plan_num
	self.remain_time = protocol.remain_time + Status.NowTime
	self.rewaed_money = protocol.rewaed_money
	self.rewardv = protocol.rewardv
end

function LimitedActivityData:GetChargeCfg()
	local data = TotalRechargeCfg[self.plan_num]
	local cur_data_1 = data and data.Rewards or {}
	local cur_data = {}
	for k, v in ipairs(cur_data_1) do
		local t = {
					state = self.rewardv[k],
					money = data and data.Gold and data.Gold[k],
					awards = {},
				}
		for k_2, v_2 in ipairs(v) do
			local t_2 = {item_id = v_2.id, num = v_2.count, is_bind = v_2.bind}
			table.insert(t.awards, t_2)
		end
		table.insert(cur_data, t)
	end
	return cur_data
end

function LimitedActivityData:GetRewardMoney()
	return self.rewaed_money
end

function LimitedActivityData:GetRewardDaojishi()
	return self.remain_time
end


---------------------------- 累计消费 ----------------------------
function LimitedActivityData:SetLimitConsumeData(protocol)
	self.plan_num_1 = protocol.plan_num
	self.remain_time_1 = protocol.remain_time + Status.NowTime
	self.rewaed_money_1 = protocol.rewaed_money
	self.rewardv_1 = protocol.rewardv
end

function LimitedActivityData:GetConsumeCfg()
	local data = TotalCostCfg[self.plan_num_1]
	local cur_data_1 = data and data.Rewards or {}
	local cur_data = {}
	for k, v in ipairs(cur_data_1) do
		local t = {
					state = self.rewardv_1[k],
					money = data and data.Gold and data.Gold[k],
					awards = {},
				}
		for k_2, v_2 in ipairs(v) do
			local t_2 = {item_id = v_2.id, num = v_2.count, is_bind = v_2.bind}
			table.insert(t.awards, t_2)
		end
		table.insert(cur_data, t)
	end
	return cur_data
end

function LimitedActivityData:GetConsumeMoney()
	return self.rewaed_money_1
end

function LimitedActivityData:GetConsumeDaojishi()
	return self.remain_time_1
end

----------------------------限时商品--------------------------------------
function LimitedActivityData:SetTimeLimitedGoodsData(protocol)
	self.limit_goods_remain_time = protocol.remain_time + Status.NowTime
	self.limit_goods_rest_count = protocol.rest_count
	self.limit_goods_plan_id = protocol.plan_id
end

function LimitedActivityData:GetLimitGoodsInfo()
	local data_list = {}
	local cfg = TimeLimitShoppingCfg[self.limit_goods_plan_id] and TimeLimitShoppingCfg[self.limit_goods_plan_id]
	-- PrintTable(cfg)
	if not cfg then return end

	local recharge_money_t = cfg.Money
	local recharge_ingot_t = cfg.Gold
	for k, v in ipairs(cfg.Rewards) do
		local data = {	awards = {}, 
						ingot = string.format(Language.Limited.TextTitle, recharge_ingot_t[k]),	-- 元宝
						money = recharge_money_t[k],				-- 充值人民币数
						idx = k,
					}

		for _, v_2 in ipairs(v) do
			local item_info = {
						item_id = v_2.id, 
						num = v_2.count,
						is_bind = v_2.bind,
					}
			table.insert(data.awards, item_info)
		end
		table.insert(data_list, data)
	end

	
	return data_list
end

function LimitedActivityData:GetLimitGoodsRemainTime()
	return self.limit_goods_remain_time
end

function LimitedActivityData:GetLimitGoodsRestCount()
	return self.limit_goods_rest_count
end