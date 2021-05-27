ChargePlatFormData = ChargePlatFormData or BaseClass()

ChargePlatFormData.PlatformType = {
	[cc.PLATFORM_OS_WINDOWS] = 1,
	[cc.PLATFORM_OS_MAC] = 2,
	[cc.PLATFORM_OS_ANDROID] = 1,
	[cc.PLATFORM_OS_IPHONE] = 2,
	[cc.PLATFORM_OS_IPAD] = 2,
}

function ChargePlatFormData:__init()
	if ChargePlatFormData.Instance then
		ErrorLog("[ChargePlatFormData] Attemp to create a singleton twice !")
	end

	ChargePlatFormData.Instance = self
	self.charge_rebate_data = {}
end

function ChargePlatFormData:__delete()
	ChargePlatFormData.Instance = nil
end

function ChargePlatFormData:GetRechargeCfg()
	local charge_data = {}
	-- print("平台：",PLATFORM)
	-- print("windows：", cc.PLATFORM_OS_WINDOWS)
	-- print("mac:", cc.PLATFORM_OS_MAC)
	-- print("安卓", cc.PLATFORM_OS_ANDROID)
	-- print("苹果", cc.PLATFORM_OS_IPHONE)

	local src_data = {}
	local show_cfg = {}
	local flag = GLOBAL_CONFIG.param_list.is_enforce_cfg

	if 	flag == 1 then
		src_data = GameRechargeCfg[1]
		show_cfg = GameRechargeShowCfg[1]
	elseif 	flag == 2 then
		src_data = GameRechargeCfg[2]
		show_cfg = GameRechargeShowCfg[2]
	else
		src_data = GameRechargeCfg[ChargePlatFormData.PlatformType[PLATFORM]]
		show_cfg = GameRechargeShowCfg[ChargePlatFormData.PlatformType[PLATFORM]]
	end

	local audit_version = IS_AUDIT_VERSION

	local indexs = {}
	if audit_version then -- 审核版
		indexs = show_cfg["audit"]
	else
		indexs = show_cfg[AgentAdapter:GetSpid()]
		if not indexs then
			indexs = show_cfg["cfg_default"]
		end	
	end	

	local user_vo = GameVoManager.Instance:GetUserVo()
	for _,v in pairs(indexs) do
		local temp_data = src_data[v]
		if temp_data then
			if temp_data.clientShow == 2 then
				if user_vo.plat_server_id < 1500 then
					table.insert(charge_data, TableCopy(temp_data))
				end	
			else
				table.insert(charge_data, TableCopy(temp_data))
			end
		end	
	end	

	return charge_data
end

-- 获得玩家可提取元宝
function ChargePlatFormData:GetCanExtractNum(protocol)
	self.rxtract_yuanbao = protocol.can_withdraw_num
end

-- 获得充值返利信息
function ChargePlatFormData:GetChangeRebate(protocol)
	self.charge_rebate_data = protocol.charge_lengh
end

-- function ChargePlatFormData:GetRebateData()
-- 	return self.charge_rebate_data
-- end

-- 获取充值返利的配置
function ChargePlatFormData:GetChargeRebateCfg(item_id)
	for k, v in pairs(OpenServerFirstRechargeCfg.rechargeList) do
		if item_id == v.id then
			return v
		end	
	end
	return nil
end

-- 充值返利的领取次数
function ChargePlatFormData:GetRebateNum(charge_id)
	for k, v in pairs(self.charge_rebate_data) do
		if charge_id == v.id then
			return v.reward_times
		end
	end
	return 0
end
