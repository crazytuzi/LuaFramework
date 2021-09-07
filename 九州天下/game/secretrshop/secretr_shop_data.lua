 SecretrShopData = SecretrShopData or BaseClass()

function SecretrShopData:__init()
	if SecretrShopData.Instance then
		print_error("[SecretrShopData] Attemp to create a singleton twice !")
	end
	SecretrShopData.Instance = self
	self.is_first = true
	RemindManager.Instance:Register(RemindName.SecretrShop, BindTool.Bind(self.IsSecretBuyPoindRemind, self))
end

function SecretrShopData:__delete()
	SecretrShopData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.SecretrShop)
end

function SecretrShopData:GetGoldCfg()
	if self.active_cfg == nil then
		self.active_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().rmb_buy_chest_shop
	end
	return self.active_cfg
end

function SecretrShopData:SetRARmbBugChestShopInfo(protocol)
	self.buy_count_list = protocol.buy_count_list
end

function SecretrShopData:GetRewardCfg()
	local show_list = {}
	local other_cfg = self:GetGoldCfg()
	if other_cfg == nil then
		return show_list
	end
	local other_day = self:GetShowOtherDay()
	for i, v in ipairs(other_cfg) do
		if v.opengame_day == other_day then 
			table.insert(show_list, TableCopy(v))
		end
	end
	return show_list
end

function SecretrShopData:GetShowOtherDay()
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = self:GetGoldCfg()
	local other_day = other_cfg[1].opengame_day
	for i, v in ipairs(other_cfg) do
		if open_time_day <= v.opengame_day then
			other_day = v.opengame_day
			return other_day
		end
	end
	return other_day
end

function SecretrShopData:SecretrShopOpen()
	self.is_first = false
	RemindManager.Instance:Fire(RemindName.SecretrShop)
end

function SecretrShopData:GetSecretBuyNum(index)
	if not self.buy_count_list then
		return 0
	end
	return self.buy_count_list[index + 1]
end

function SecretrShopData:IsSecretBuyPoindRemind()
	return self.is_first and 1 or 0
end

