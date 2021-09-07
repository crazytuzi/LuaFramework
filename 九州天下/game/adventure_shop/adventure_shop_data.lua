AdventureShopData = AdventureShopData or BaseClass()

function AdventureShopData:__init()
	if AdventureShopData.Instance ~= nil then
		ErrorLog("[AdventureShopData] Attemp to create a singleton twice !")
	end
	AdventureShopData.Instance = self
	self.is_can_play_ani = true
	self.adventure = {}
	self.adventure.open_left_times = 0
	self.adventure.histroy_chongzhi = 0
	self.adventure.has_fetch = 0
	self.adventure.open_times = 0
	self.adventure.can_fetch = 0
	self.adventure.reward_index = -1

	RemindManager.Instance:Register(RemindName.AdventureShop, BindTool.Bind(self.GetRemind, self))
end

function AdventureShopData:__delete()
	AdventureShopData.Instance = nil
	self.adventure.reward_index = -1

	RemindManager.Instance:UnRegister(RemindName.AdventureShop)
end

function AdventureShopData:SetAdventureShop(protocol)
	self.adventure.open_left_times = protocol.open_left_times
	self.adventure.histroy_chongzhi = protocol.histroy_chongzhi
	self.adventure.has_fetch = protocol.has_fetch
	self.adventure.open_times = protocol.open_times
	self.adventure.can_fetch = protocol.can_fetch
	self.adventure.reward_index = protocol.reward_index
end

-- 奖励配置
function AdventureShopData:GetAdventureShopRewards()
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	-- 默认不可能达到的值
	local shield = 9999999
	for _, v in pairs(agent_cfg) do
		if spid == v.spid then
			shield = v.qiyu_shop
		end
	end

	self.reward_list = {}
	local rewards_cfg = ConfigManager.Instance:GetAutoConfig("qiyu_shop_auto").rewards
	local index = 0

	local total_charge = self.adventure.histroy_chongzhi or 0
	if self.adventure.histroy_chongzhi >= rewards_cfg[1].max_limit_charge then
		total_charge = rewards_cfg[1].max_limit_charge
	end
	for k, v in pairs(rewards_cfg) do
		if total_charge >= v.histroy_chongzhi and  total_charge < v.need_chongzhi and (shield ~= nil and v.need_chongzhi < shield) then
			if v.reward_item.item_id > 0 then
				local data = TableCopy(v)
				data.reward_item = v.reward_item
				table.insert(self.reward_list, data)
			else
				local data = TableCopy(v)
				data.reward_item = {is_bind = 1, item_id = COMMON_CONSTS.VIRTUAL_ITEM_GOLD, num = 1}
				table.insert(self.reward_list, data)
			end
			index = index + 1
		end
		
		if index == 8 then
			break
		end
	end
	
	return self.reward_list
end

function AdventureShopData:GetDrawReward()
	if nil == self.reward_list or nil == next(self.reward_list) then return end

	if self.adventure.reward_index ~= nil and self.adventure.reward_index ~= -1 then
		return {[1] = self:GetAdventureShopRewards()[self.adventure.reward_index + 1].reward_item}
	end

	return {[1] = self:GetAdventureShopRewards()[1].reward_item}
end

function AdventureShopData:GetAdventureShopNeedChongzhi()
	if nil == self.reward_list or nil == next(self.reward_list) then return end
	
	if next(self:GetAdventureShopRewards()) ~= nil and self:GetAdventureShopRewards()[1].need_chongzhi ~= nil then
		return self:GetAdventureShopRewards()[1].need_chongzhi
	end

	return 0
end

function AdventureShopData:GetChargeLevel()
	if nil == self.reward_list or nil == next(self.reward_list) then return end
	
	return self:GetAdventureShopRewards()[1].charge_id
end

function AdventureShopData:GetAdventureShopCanGet()
	return self.adventure.can_fetch
end

function AdventureShopData:GetAdventureShopHasGet()
	return self.adventure.has_fetch
end

function AdventureShopData:GetRemind()
	if self.adventure.can_fetch > 0 and self.adventure.has_fetch == 0 then
		return 1
	end

	return 0
end

function AdventureShopData:GetActEndTime()
	return self.adventure.open_left_times
end

--返回奖励索引
function AdventureShopData:GetRewardIndex()
	return self.adventure.reward_index
end

function AdventureShopData:GetIsOpenShopView(histroy_chongzhi)
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	-- 默认不可能达到的值
	local shield = 9999999
	for _, v in pairs(agent_cfg) do
		if spid == v.spid then
			shield = v.qiyu_shop
		end
	end

	local rewards_cfg = ConfigManager.Instance:GetAutoConfig("qiyu_shop_auto").rewards
	local need_chongzhi = 0
	for k, v in pairs(rewards_cfg) do
		if histroy_chongzhi >= v.histroy_chongzhi then
			need_chongzhi = v.need_chongzhi
		end
	end

	if need_chongzhi <= shield then
		return true
	end

	return false
end