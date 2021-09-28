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
	local vip_level = PlayerData.Instance:GetRoleVo().vip_level
	local show_list = {}
	local other_cfg = self:GetGoldCfg()
	if other_cfg == nil then
		return show_list
	end
	local other_day = self:GetShowOtherDay()
	for i, v in ipairs(other_cfg) do
		if v.opengame_day == other_day and v.vip_min <= vip_level and vip_level <= v.vip_max then
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

function SecretrShopData:GetNowPage()
	local num = #(self:GetRewardCfg()) or 0
	local page_num = math.ceil(num / 3)
	local cfg = self:GetRewardCfg()

	for i = 1, num do
		if self.buy_count_list and self.buy_count_list[i] and cfg[i] and cfg[i].count_limit then
			if self.buy_count_list[i] < cfg[i].count_limit then
				return math.floor(i / 3)
			end
		end
	end

	return 0
end

function SecretrShopData:GetSortRewardCfg()
	local show_list = self:GetRewardCfg()
	if self.buy_count_list == nil then
		return show_list
	end
	-- local show_list = self:GetRewardCfg()
	show_list = TableSortByCondition(show_list, function (v)
		return self.buy_count_list[v.index + 1] < v.count_limit
	end)
	return show_list
end