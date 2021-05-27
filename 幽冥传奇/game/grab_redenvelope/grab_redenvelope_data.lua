GrabRedEnvelopeData = GrabRedEnvelopeData or BaseClass()

function GrabRedEnvelopeData:__init()
	if GrabRedEnvelopeData.Instance then
		ErrorLog("[GrabRedEnvelopeData] Attemp to create a singleton twice !")
	end
	GrabRedEnvelopeData.Instance = self
	self.zs_num =0
	self.reward_flag = 0
	self.first_charge = 0
	self.cur_level = nil
	self.red_envlope_gold = 0
	self.record = ""
	self.record_list = {}
	self.reward_flag_list = {}
end

function GrabRedEnvelopeData:__delete()
	GrabRedEnvelopeData.Instance = nil
	
end

function GrabRedEnvelopeData:SetOnChargeRedEnvlopeData(protocol)
	self.zs_num =protocol.zs_num
	self.reward_flag = protocol.reward_flag
	self.first_charge = protocol.first_charge
	self.cur_level = protocol.cur_level
	self.red_envlope_gold = protocol.red_envlope_gold
	self.record = protocol.record
	self.record_list = {}
	local list1 = Split(self.record, ";")
	for i=1, #list1 do
		self.record_list[i] = list1[#list1 - i + 1]
	end

	self.reward_flag_list = {}
	local list = bit:d2b(self.reward_flag)
	for i=1, #list do
		self.reward_flag_list[i] = list[#list - i + 1]
	end
	--PrintTable(self.reward_flag_list)
	GlobalEventSystem:Fire(GRAP_REDENVELOPE_EVENT.GetGrapRedEnvlope)
 	--print(">>>>>>>>", self.zs_num, self.cur_level, self.red_envlope_gold, self.first_charge, self.cur_level)
 	--PrintTable(self.record_list)
end

function GrabRedEnvelopeData:GetRecordList()
	return self.record_list 
end

function GrabRedEnvelopeData:GetIsFirstCharge()
	return self.first_charge
end

function GrabRedEnvelopeData:GetZuanShiNum( ... )
	return self.zs_num
end

function GrabRedEnvelopeData:GetGrapRedEnvlope( ... )
	return self.red_envlope_gold
end


function GrabRedEnvelopeData:GetCanGetZuanSHi()
	return PayRedPackCfg.firstPayZs
end

function GrabRedEnvelopeData:GetNeedNumber()
	local cfg =  PayRedPackCfg.moneyAwards[self.cur_level or 0]
	if cfg == nil then
		return 0
	end
	local had_charge_money = OtherData.Instance:GetDayChargeGoldNum()
	local need_money = (cfg.needPay - had_charge_money)/PayRedPackCfg.moneyrate
	return need_money < 0 and 0 or need_money, need_num
end


function GrabRedEnvelopeData:GetNeedNum()
	local cfg = PayRedPackCfg.moneyAwards[self.cur_level or 0]

	if cfg == nil then
		return 1
	end
	local had_charge_money = OtherData.Instance:GetDayChargeGoldNum()
	local need_num = cfg.needPay - had_charge_money
	return need_num
end


function GrabRedEnvelopeData:HadGetAll()
	if self.cur_level == nil or self.cur_level == 0 then
		return true
	end
	return false
end

-- 默认值为nil,用于判断是否请求过数据
function GrabRedEnvelopeData:GetCurLevel()
	return self.cur_level
end


function GrabRedEnvelopeData:GetIsShowMoney(cur_level)
	local cfg = PayRedPackCfg.moneyAwards[self.cur_level or 0]
	if cfg == nil then
		return true
	end
	return cfg.needPay == 1
end


function GrabRedEnvelopeData:GetIsCanLingQu()
	if self.first_charge == 1 then --首充必领
		return 1
	end
	if self.cur_level == 0 then
		return 0
	end

	local cfg = PayRedPackCfg.moneyAwards[self.cur_level or 0]
	if cfg == nil then
		return 0
	end
	local had_charge_money = OtherData.Instance:GetDayChargeGoldNum()
	if had_charge_money >= cfg.needPay then
		if self.reward_flag_list[self.cur_level] == 0 then
			return 1
		end
	end
	return 0 
end

function GrabRedEnvelopeData:GetIsCurLvelNotQiang( ... )
	-- if self.reward_flag_list[self.cur_level] == 0 then
	-- 	return true
	-- end
end