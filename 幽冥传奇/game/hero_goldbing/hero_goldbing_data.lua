HeroGoldBingData = HeroGoldBingData or BaseClass()

function HeroGoldBingData:__init()
	if HeroGoldBingData.Instance then
		ErrorLog("[HeroGoldBingData]:Attempt to create singleton twice!")
	end
	HeroGoldBingData.Instance = self
	self:InitEquipGoldBingCfg()
end

function HeroGoldBingData:__delete()
	HeroGoldBingData.Instance = nil
end

function HeroGoldBingData:InitEquipGoldBingCfg()
	self.equip_boss_cfg = {}
	for k, v in ipairs(HeroGodWeaponRechargeConfig.awards) do
		self.equip_boss_cfg[#self.equip_boss_cfg + 1] = v
	end
	self.oper_cnt = 0
	self.charge_money = 0
end

function HeroGoldBingData:GetEquipBossCfg()
	return self.equip_boss_cfg
end

function HeroGoldBingData:setChargeInfo(oper_cnt,charge_money)
	self.oper_cnt = oper_cnt
	self.charge_money = charge_money
end

function HeroGoldBingData:getChargeInfo()
	return self.oper_cnt,self.charge_money
end
