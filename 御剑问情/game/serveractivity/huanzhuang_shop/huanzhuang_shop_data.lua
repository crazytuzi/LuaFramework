HuanzhuangShopData = HuanzhuangShopData or BaseClass()

HuanzhuangShopData.OPERATE = {
	RECHARGE = 0,
	BUY = 1,
}

function HuanzhuangShopData:__init()
	if HuanzhuangShopData.Instance then
		ErrorLog("[HuanzhuangShopData] attempt to create singleton twice!")
		return
	end
	HuanzhuangShopData.Instance = self
	self.first_login = true
	self.activity_info = {}
	self.activity_info.magic_shop_fetch_reward_flag = 0
	self.activity_info.magic_shop_buy_flag = 0
	self.activity_info.activity_day = 0
    self.activity_info.magic_shop_chongzhi_value = 0
    RemindManager.Instance:Register(RemindName.ShowHuanZhuangShopPoint, BindTool.Bind(self.ShowHuanZhuangShopPoint, self))
    RemindManager.Instance:Register(RemindName.TitleShopPoint, BindTool.Bind(self.TitleShopPoint, self))
    self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))

	-- self.level_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
 --    PlayerData.Instance:ListenerAttrChange(self.level_change_callback)
end

function HuanzhuangShopData:__delete()
	HuanzhuangShopData.Instance = nil
 	RemindManager.Instance:UnRegister(RemindName.ShowHuanZhuangShopPoint)
 	RemindManager.Instance:UnRegister(RemindName.TitleShopPoint)
	 if self.mainui_open_comlete then
		GlobalEventSystem:UnBind(self.mainui_open_comlete)
		self.mainui_open_comlete = nil
	end

	if self.act_time_countdown then
		GlobalTimerQuest:CancelQuest(self.act_time_countdown)
		self.act_time_countdown = nil
	end

	-- if PlayerData.Instance then
	-- 	PlayerData.Instance:UnlistenerAttrChange(self.level_change_callback)
	-- end
end

function HuanzhuangShopData:GetHuanZhuangShopCfg()
	local rand_act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	return ActivityData.Instance:GetRandActivityConfig(rand_act_cfg.magic_shop, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
end

function HuanzhuangShopData:GetHuanZhuangShopRewardCfgByShowType(show_type)
	local rand_act_cfg = self:GetHuanZhuangShopCfg()
	local list = {}
	for i,v in ipairs(rand_act_cfg) do
		if v.type == show_type and v.activity_day == self.activity_info.activity_day then
			table.insert(list, v)
		end
	end
	return list
end

function HuanzhuangShopData:SetRAMagicShopAllInfo(protocol)
	self.activity_info.magic_shop_fetch_reward_flag = protocol.magic_shop_fetch_reward_flag
	self.activity_info.magic_shop_buy_flag = protocol.magic_shop_buy_flag
	self.activity_info.activity_day = protocol.activity_day
    self.activity_info.magic_shop_chongzhi_value = protocol.magic_shop_chongzhi_value
end

function HuanzhuangShopData:GetRAMagicShopAllInfo()
	return self.activity_info
end

function HuanzhuangShopData:ShowHuanZhuangShopPoint()
	return not RemindManager.Instance:RemindToday(RemindName.ShowHuanZhuangShopPoint) and 1 or 0
end

function HuanzhuangShopData:TitleShopPoint()
	local num = 0
	local cfg = self:GetHuanZhuangShopRewardCfgByShowType(HuanzhuangShopData.OPERATE.RECHARGE)
	for i,v in ipairs(cfg) do
		if self.activity_info.magic_shop_chongzhi_value >= v.need_gold then
			local fetch = bit:d2b(self.activity_info.magic_shop_fetch_reward_flag)
			if 0 == fetch[32 - v.index] then
				num = 1
				break
			end
		end
	end
	return num
end
function HuanzhuangShopData:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
	-- MainUIView.Instance:ChangeHuanZhuangShopBtn(is_open and GameVoManager.Instance:GetMainRoleVo().level >= 130)

	-- if is_open then
	-- 	self.act_time_countdown = GlobalTimerQuest:AddRunQuest(function()
	-- 		local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
	-- 		MainUIView.Instance:SetHuanZhuangShopTimeCountDown(time)
	-- 		end, 1)
	-- end
end

-- function HuanzhuangShopData:PlayerDataChangeCallback(attr_name, value)
-- 	if attr_name == "level" then
-- 		local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
-- 		MainUIView.Instance:ChangeHuanZhuangShopBtn(is_open and GameVoManager.Instance:GetMainRoleVo().level >= 130)
-- 	end
-- end

function HuanzhuangShopData:SetLoginFlag(value)
	self.first_login = value
end

function HuanzhuangShopData:GetLoginFlag(value)
	return self.first_login
end
