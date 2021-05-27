ChargeFashionData = ChargeFashionData or BaseClass()

function ChargeFashionData:__init()
	if ChargeFashionData.Instance then
		ErrorLog("[ChargeFashionData]:Attempt to create singleton twice!")
	end
	ChargeFashionData.Instance = self
	self:InitEquipGoldBingCfg()
end

function ChargeFashionData:__delete()
	ChargeFashionData.Instance = nil
end

function ChargeFashionData:InitEquipGoldBingCfg()
	self.oper_cnt = 0
	self.charge_money = 0
end

function ChargeFashionData:setChargeInfo(oper_cnt,charge_money)
	self.oper_cnt = oper_cnt
	self.charge_money = charge_money
end

function ChargeFashionData:getChargeInfo()
	return self.oper_cnt,self.charge_money
end

function ChargeFashionData:GetChargeFasionIconOpen()
	local bool_reward = ChargeFirstData.Instance:GetFirstChargeInformation()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local _, need_level = ChargeFirstData.GetRewardCfg()
	if IS_AUDIT_VERSION == true then
		return false
	else
		if level < need_level then
			return false
		end
		if bool_reward == 2 then
			return self.charge_money ~= 1
		else
			return false
		end
	end
end

function ChargeFashionData:GetRechargeFashionNum()
	if self.oper_cnt >= FashionRechargeConfig.yb and self.charge_money == 0 then
		return 1
	else
		return 0
	end
end