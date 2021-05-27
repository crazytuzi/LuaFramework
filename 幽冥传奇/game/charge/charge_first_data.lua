ChargeFirstData = ChargeFirstData or BaseClass()

function ChargeFirstData:__init()
	if ChargeFirstData.Instance then
		ErrorLog("[ChargeFirstData] Attemp to create a singleton twice !")
	end

	ChargeFirstData.Instance = self
end

function ChargeFirstData:__delete()
	ChargeFirstData.Instance = nil
end

--------------------------------------
-- 协议
--------------------------------------

function ChargeFirstData:SetFirstChargeInformation(protocol)
	self.first_charge_rewards_tag = protocol.first_charge_rewards
end

--------------------------------------
-- 首充
--------------------------------------
function ChargeFirstData:GetFirstChargeRemindNum()
	if self.first_charge_rewards_tag == 1 then 
		return 1 
	elseif self.first_charge_rewards_tag == 0 then
		return 2
	end
	return 0
end

function ChargeFirstData:GetFirstChargeInformation()
	return self.first_charge_rewards_tag
end

function ChargeFirstData.GetRewardCfg()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)

	local data = {}
	local need_level = nil 
	need_level = FirstRechargeCfg.openLevel
	for k1, v1 in pairs(FirstRechargeCfg.firstAward) do
		if v1.job == nil or v1.job == prof then
			local cur_data = {item_id = v1.id, num = v1.count, is_bind = 0, strengthen_level = v1.strong or 0 }
			table.insert(data, cur_data)
		end
	end
	return data, need_level
end

function ChargeFirstData:GetFirstChargeIconOpen()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local bool_reward = ChargeFirstData.Instance:GetFirstChargeInformation()
	local _, need_level = ChargeFirstData.GetRewardCfg()
	if IS_AUDIT_VERSION == true then
		return false
	else
		if level < need_level then
			return false
		else
			return bool_reward ~= 2
		end
	end
end
