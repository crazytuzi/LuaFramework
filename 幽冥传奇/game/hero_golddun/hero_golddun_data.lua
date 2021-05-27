HeroGoldDunData = HeroGoldDunData or BaseClass()

function HeroGoldDunData:__init()
	if HeroGoldDunData.Instance then
		ErrorLog("[HeroGoldDunData]:Attempt to create singleton twice!")
	end
	HeroGoldDunData.Instance = self
	self:InitEquipGoldBossCfg()
end

function HeroGoldDunData:__delete()
	HeroGoldDunData.Instance = nil
end

function HeroGoldDunData:InitEquipGoldBossCfg()
	self.equip_boss_cfg = {}
	self.equip_boss_cfg.is_active = 0
	self.equip_boss_cfg.bossLost = {}
	for k, v in ipairs(GodShieldBossConfig.bossList) do
		self.equip_boss_cfg.bossLost[#self.equip_boss_cfg.bossLost + 1] = {
		bossIdx = v.bossIdx,
		DropsShow = v.DropsShow,
		enterConsume = v.enterConsume,
		enterLevelLimit = v.enterLevelLimit,
		state = 0,
		monsters = v.monsters
	}
	end
end

function HeroGoldDunData:setEquipGoldBossCfg(data)
	if not data then return end
	self.equip_boss_cfg.is_active = data.is_active
	if data.bossInfo then
		for i,v in ipairs(data.bossInfo) do
			self.equip_boss_cfg.bossLost[i].state = v.state
		end
	end
	GlobalEventSystem:Fire(HeroGoldEvent.HeroGoldDun,data)
end

function HeroGoldDunData:GetEquipBossCfg()
	return self.equip_boss_cfg.bossLost
end

function HeroGoldDunData:GetEquipDunState()
	return self.equip_boss_cfg.is_active
end
