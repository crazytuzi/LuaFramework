PrayData = PrayData or BaseClass()

function PrayData:__init()
	if PrayData.Instance then
		ErrorLog("[PrayData]:Attempt to create singleton twice!")
	end
	PrayData.Instance = self
	self.pray_data = {
		oper_type = 0,
		oper_cnt = 0,
		awar_info = {},	
	}
	self.pray_data1 = {
		oper_type = 0,
		oper_cnt = 0,
		awar_info = {},	
	}
end

function PrayData:__delete()
	PrayData.Instance = nil
end

function PrayData:SetPrayMoneyData(protocol)
	if protocol and protocol.oper_type == 1 then
		self.pray_data.oper_type = protocol.oper_type
		self.pray_data.oper_cnt = protocol.oper_cnt	
		self.pray_data.awar_info = protocol.awar_info
	elseif protocol and protocol.oper_type == 2 then
		self.pray_data1.oper_type = protocol.oper_type
		self.pray_data1.oper_cnt = protocol.oper_cnt	
		self.pray_data1.awar_info = protocol.awar_info
	end
end

function PrayData:GetPrayMoneyData(index)
	if index == 1 then
		return self.pray_data
	elseif index == 2 then
		return self.pray_data1
	end
end

function PrayData.GetPrayMaxCnt(index)
	local vip_cnt = VipData.GetPrivilegeAddCntByType(PrivilegeData.AddCntTypeT.PrayAddCnt)
	local max_cnt = MoneyTreeCfg[index] and MoneyTreeCfg[index].operateTimesCfg.maxTimes or 10
	max_cnt = max_cnt + vip_cnt
	return max_cnt
end

function PrayData:GetPrayCostStrByTime(index)
	if not index then return end
	local cfg = MoneyTreeCfg[index].consumes
	local str = ""
	if cfg then
		local max_cnt = PrayData.GetPrayMaxCnt(index)
		local nxt_time,flag
		if index == 1 then
			nxt_time = self.pray_data.oper_cnt + 1
			flag = self.pray_data.oper_cnt
		else
			nxt_time = self.pray_data1.oper_cnt + 1
			flag = self.pray_data1.oper_cnt
		end
		if nxt_time > #cfg then
			nxt_time = #cfg
		end
		local cost_cfg = cfg[nxt_time]
		if cost_cfg and flag < max_cnt then
			local cost_count = cost_cfg[1].count
			if cost_count > 0 then
				local price_type = MoneyAwarTypeToMoneyType[cost_cfg[1].type]
				local money_name
				if price_type then
					money_name = ShopData.GetMoneyTypeName(price_type)
				end
				if money_name then
					str = string.format(Language.Pray.CostTxts[2], cost_count, money_name)
				end
			else
				str = Language.Pray.CostTxts[1]
			end
		elseif flag >= max_cnt then
			str = Language.Pray.CostTxts[3]
		end
	end
	return str
end

function PrayData.GetCurGetMoneyStr(cur_cnt,index)
	str = ""
	local cfg = MoneyTreeCfg[index] and MoneyTreeCfg[index].awards
	if cfg and cfg[cur_cnt] then
		local price_type = MoneyAwarTypeToMoneyType[cfg[cur_cnt][1].type]
		local money_name
		if price_type then
			money_name = ShopData.GetMoneyTypeName(price_type)
		end
		if money_name then
			str = string.format(Language.Pray.ThisTimeGetNum, CommonDataManager.ConverMoney(cfg[cur_cnt][1].count), money_name)
		end
	end
	return str
end