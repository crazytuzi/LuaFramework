ChongzhiData = ChongzhiData or BaseClass()



function ChongzhiData:__init()
	if ChongzhiData.Instance then
		ErrorLog("[ChongzhiData]:Attempt to create singleton twice!")
	end
	ChongzhiData.Instance = self
	self.backstage_recharge_cfg_list = {}		-- 后台配置
	self.recharge_cfg_list = {}					-- 本地配置
	self:Initrechargecfg()
	self.is_open_double = 0
	self.max_times = 0
	self.files = 0
	self.chongzhi_info_list = {}
end

function ChongzhiData:__delete()
	ChongzhiData.Instance = nil
	self.backstage_recharge_cfg_list = {}
	self.is_open_double = 0
	self.max_times = 0
	self.chongzhi_info_list = {}
	self.files = 0
end

function ChongzhiData:Initrechargecfg()
	-- body
	-- 如果是IOS(不分正版越狱)的话显示的金额额度和安卓用不一样的配置
	if cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM then
		self.recharge_cfg_list = ConfigManager.Instance:GetAutoConfig("rechargeappstore_auto").recharge_list
	else
		self.recharge_cfg_list = ConfigManager.Instance:GetAutoConfig("recharge_auto").recharge_list
	end
	-- local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
	-- if "ias" == agent_id then
	-- 强制用1安卓的配置 2IOS配置
	local is_enforce_cfg = GLOBAL_CONFIG.param_list.is_enforce_cfg
	if is_enforce_cfg == 1 then
		self.recharge_cfg_list = ConfigManager.Instance:GetAutoConfig("recharge_auto").recharge_list
	elseif is_enforce_cfg == 2 then
		self.recharge_cfg_list = ConfigManager.Instance:GetAutoConfig("rechargeappstore_auto").recharge_list
	end
end

--获取充值比例
function ChongzhiData:GetRechargeRate()
	return self.recharge_cfg_list[1].gold / self.recharge_cfg_list[1].money

end

function ChongzhiData:GetRechargeCfg()
	local finial_cfg_list = {}
	if nil ~= next(self.backstage_recharge_cfg_list) then
		-- （优先使用后台发过来的配置）
		finial_cfg_list =  self.backstage_recharge_cfg_list
	else
		finial_cfg_list = self.recharge_cfg_list
	end
	if self:GetIsOpenDouble() == 1 then
		if finial_cfg_list then
			for k,v in pairs(finial_cfg_list) do
				v.show_double = 0
			end
	
			if self.chongzhi_info_list ~= nil then
				for k,v in pairs(self.chongzhi_info_list) do
					for key,value in pairs(finial_cfg_list) do
						if tonumber(v.money) == tonumber(value.gold)  then
							value.show_double = v.times
						end
					end
				end
			end
		end
	end
	return finial_cfg_list
end

-- 保存从后台过来的充值配置
function ChongzhiData:SetRechargeCfgByBackstage(data)
	self.backstage_recharge_cfg_list = {}
	for k, v in pairs(data.recharge_list) do
		local t = {id = tonumber(v.id), money = tonumber(v.money), gold = tonumber(v.gold), money_type = v.type or Language.Common.MoneyTypeStr[0]}
		table.insert(self.backstage_recharge_cfg_list, t)
	end
	table.sort(self.backstage_recharge_cfg_list, SortTools.KeyLowerSorter('id'))
end

function ChongzhiData:SetIsOpenDouble(is_open_double,max_times)
	self.is_open_double = is_open_double
	self.max_times = max_times
end

function ChongzhiData:GetIsOpenDouble()
	return self.is_open_double
end

function ChongzhiData:GetMaxTimes()
	return self.max_times
end

function ChongzhiData:SetChongZhiDoubleInfo(files,chongzhi_info_list)
	self.files = files
	self.chongzhi_info_list = chongzhi_info_list
end