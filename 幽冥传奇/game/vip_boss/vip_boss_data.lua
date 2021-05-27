VipBossData = VipBossData or BaseClass()

function VipBossData:__init()
	if VipBossData.Instance then
		ErrorLog("[VipBossData]:Attempt to create singleton twice!")
	end
	VipBossData.Instance = self

	self.vip_boss_data = {}
end

function VipBossData:__delete()
	VipBossData.Instance = nil
end

function VipBossData:SetVipBossFuben(protocol)
	self.vip_boss_data = protocol.vip_boss_list
end

function VipBossData:GetVipBossData()
	return self.vip_boss_data
end

function VipBossData:GetVipBossRemind()
	for k,v in pairs(self.vip_boss_data) do
		local level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
		if level >= v.vip_lev and v.inter_time == 0 then
			return 1
		end
	end
	return 0
end