RechargeContain = RechargeContain  or BaseClass(BaseCell)

function RechargeContain:__init()
	self.recharge_contain_list = {}
	for i = 1, 4 do
		self.recharge_contain_list[i] = {}
		self.recharge_contain_list[i].recharge_item = RechargeItem.New(self:FindObj("item_" .. i))
	end
	self.vip_money_bg_url = self:FindVariable("vip_money_bg_url")
	self.show_vip_money_bg = self:FindVariable("show_vip_money_bg")
end

function RechargeContain:__delete()
	for i=1,4 do
		self.recharge_contain_list[i].recharge_item:DeleteMe()
		self.recharge_contain_list[i].recharge_item = nil
	end
end

function RechargeContain:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	for i=1,4 do
		self.recharge_contain_list[i].recharge_item:SetData({item_id = self.data.item_id_list[i]})
	end

	if AssetManager.ExistedInStreaming("AgentAssets/vip_money_bg.png") then
		self.show_vip_money_bg:SetValue(false)
		local url = UnityEngine.Application.streamingAssetsPath .. "/AgentAssets/vip_money_bg.png"
		self.vip_money_bg_url:SetValue(url)
	else
		self.show_vip_money_bg:SetValue(true)
	end
end

function RechargeContain:OnFlushAllCell()
	for i=1,4 do
		self.recharge_contain_list[i].shop_item:Flush()
	end
end

----------------------------------------------------------------------------
RechargeItem = RechargeItem or BaseClass(BaseCell)

local variable_table = {
	flag_shouchong = "flag_shouchong",
	flag_tuijian = "flag_tuijian",
	word_zeng = "word_zeng",
	diamond_bg = "diamond_bg",
}

function RechargeItem:__init()
	self.money_text = self:FindVariable("money")		
	self.extra_gold = self:FindVariable("extra_gold")	
	self.gold_text = self:FindVariable("gold_text")		
	self.show_return = self:FindVariable("show_return")
	self.show_red = self:FindVariable("ShowRed")
	self.show_red:SetValue(false)
	self.recharge_icon = self:FindVariable("ReCharge")
	self.bright_red_img = self:FindVariable("brightRedImg")
	self.money_icon = self:FindVariable("money_icon")
	self.first_recharge_img = self:FindObj("FirstRechargeImg")
	self.first_over_img = self:FindObj("FirstOverImg")

	self.money_icon_url = self:FindVariable("money_icon_url")
	self.present_url = self:FindVariable("present_url")
	self.show_present = self:FindVariable("show_present")

	for k, v in pairs(variable_table) do
		self[v .. "_url"] = self:FindVariable(v .. "_url")
		self["show_" .. v] = self:FindVariable("show_" .. v)
	end

	self:ListenEvent("rechange_click", BindTool.Bind(self.OnRechargeClick, self))
end

function RechargeItem:__delete()
end

function RechargeItem:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").show_recharge_multiple
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local multiple = 1
	for k, v in pairs(agent_cfg) do
		if spid == v.spid then
			multiple = v.multiple
		end
	end

	self.root_node:SetActive(true)

	if not self.data.item_id or self.data.item_id == RechargeData.InVaildId then
		self.root_node:SetActive(false)
		return
	end

	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.data.item_id) 
	local reward_cfg = RechargeData.Instance:NewGetChongzhiRewardCfgById(recharge_cfg.gold)
	if reward_cfg == nil or next(reward_cfg) == nil then
		return
	end

	local other_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
	local reward_flag = DailyChargeData.Instance:GetFristChargeRewardFlag(self.data.item_id)

	local bundle, gold_asset = ResPath.GetYuanBaoIcon(0)
	local bundle1, bind_gold_asset = ResPath.GetYuanBaoIcon(1)
	local str_img_name = "bright_red"
	self.money_text:SetValue(recharge_cfg.money)
	self.first_over_img:SetActive(false)
	if reward_flag == 1 then	--已经首冲
		if recharge_cfg.if_tuijian and recharge_cfg.if_tuijian == 1 then
			self.first_over_img:SetActive(RechargeData.Instance:IsFirstRecharge())
		end
		self.first_recharge_img:SetActive(false)
		self.extra_gold:SetValue(self:ConverMoney(reward_cfg.not_first_chongzhi_reward_bing_gold))
		self.gold_text:SetValue(self:ConverMoney(recharge_cfg.money * 10 * multiple))

		local bundle, asset = ResPath.GetRechargeIcon("word_recharge")
		self.recharge_icon:SetAsset(bundle, asset)

		str_img_name = "red_star"
	elseif reward_flag == 0 then
		self.first_recharge_img:SetActive(true)
		self.extra_gold:SetValue(self:ConverMoney(reward_cfg.extra_bind_gold))
		self.gold_text:SetValue(self:ConverMoney(recharge_cfg.money * 10 * multiple))

		local bundle, asset = ResPath.GetRechargeIcon("word_first_recharge")
		self.recharge_icon:SetAsset(bundle, asset)
		
		str_img_name = "bright_red"
	end

	if AssetManager.ExistedInStreaming("AgentAssets/" ..  str_img_name .. ".png") then
		self.show_present:SetValue(false)
		local url = UnityEngine.Application.streamingAssetsPath .. "/AgentAssets/" ..  str_img_name .. ".png"
		self.present_url:SetValue(url)
	else
		self.show_present:SetValue(true)
		local bright_bundle, bright_asset = ResPath.GetRechargeIcon(str_img_name)
		self.bright_red_img:SetAsset(bright_bundle, bright_asset)
	end

	for k, v in pairs(variable_table) do
		if AssetManager.ExistedInStreaming("AgentAssets/" .. v .. ".png") then
			if self["show_" .. v] then
				self["show_" .. v]:SetValue(false)
			end
			if self[v .. "_url"] then
				local url = UnityEngine.Application.streamingAssetsPath .. "/AgentAssets/" .. v .. ".png"
				self[v .. "_url"]:SetValue(url)
			end
		else
			if self["show_" .. v] then
				self["show_" .. v]:SetValue(true)
			end
		end
	end

	local img_id = self.data.item_id > 2 and self.data.item_id - 1 or self.data.item_id
	if AssetManager.ExistedInStreaming("AgentAssets/Diamond" ..  img_id .. ".png") then
		local url = UnityEngine.Application.streamingAssetsPath .. "/AgentAssets/Diamond" ..  img_id .. ".png"
		self.money_icon_url:SetValue(url)
	else
		self.money_icon:SetAsset(ResPath.GetRechargeVipIcon("Diamond" .. img_id))
	end

	if IS_AUDIT_VERSION then
		self.show_return:SetValue(false)
	end
end

function RechargeItem:OnRechargeClick()
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.data.item_id)
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
	local vip_chongzhi_num = DailyChargeData.Instance:CheckIsFirstRechargeById(self.data.item_id)
	local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").show_recharge_multiple
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local multiple = 1
	for k, v in pairs(agent_cfg) do
		if spid == v.spid then
			multiple = v.multiple
		end
	end

	if (nil == reward_cfg and recharge_cfg.id ~= RechargeData.SPEC_ID) or not recharge_cfg then return end
	local discretion = ""
	if recharge_cfg.id == RechargeData.SPEC_ID then
		local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
		if has_buy_7day_rechange then
			RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
			return
		end
		discretion = string.format(Language.Recharge.RechargeDes, reward_18yuan_cfg.chongzhi_seven_day_reward_bind_gold)
		str_recharge = string.format(Language.Recharge.FirstBing, 18)
	else
		discretion = reward_cfg.discretion
		str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold * multiple)
	end
	-- local str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
	if vip_chongzhi_num == true then
		chongzhi_show_str = str_recharge .. "\n\n" .. string.format(discretion) .. "\n\n" .. Language.Recharge.WarmPrompt
	else
		chongzhi_show_str = str_recharge .. "\n\n" .. Language.Recharge.WarmPrompt
	end
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind2(self.SendRecharge, self, recharge_cfg), nil, chongzhi_show_str)
end


function RechargeItem:SendRecharge(recharge_cfg)
	RechargeCtrl.Instance:Recharge(recharge_cfg.money)
end

function RechargeItem:ConverMoney(value)
	local result
	if value >= 100000 and value < 100000000 then
		result = math.floor(value / 10000) .. Language.Common.Wan
	else
		result = value
	end
	return result
end