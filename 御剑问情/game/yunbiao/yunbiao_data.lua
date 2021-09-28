YunbiaoData = YunbiaoData or BaseClass()

function YunbiaoData:__init()
	if YunbiaoData.Instance ~= nil then
		print_error("[YunbiaoData] attempt to create singleton twice!")
		return
	end
	YunbiaoData.Instance = self

	self.lingqucishu = 0
	self.goumaicishu = 0
	self.refreshfreetime = 0
	self.accept_in_activitytime = 0
	self.task_ids = 24001
	self.yunbiao_item_id = 26901
	self.toggle_red_state = true
	self.toggle_auto_state = true
end

function YunbiaoData:__delete()
	YunbiaoData.Instance = nil
end

function YunbiaoData:SetLingQuCishu(value)
	if value then
		self.lingqucishu = value
	end
end

function YunbiaoData:GetLingQuCishu()
	return self.lingqucishu
end

function YunbiaoData:SetGouMaiCishu(value)
	if value then
		self.goumaicishu = value
	end
end

function YunbiaoData:GetGouMaiCishu()
	return self.goumaicishu
end

function YunbiaoData:SetRefreshFreeTime(value)
	if value then
		self.refreshfreetime = value
	end
end

function YunbiaoData:GetRefreshFreeTime()
	return self.refreshfreetime
end

function YunbiaoData:GetTaskColor()
	local color = GameVoManager.Instance:GetMainRoleVo().husong_color
	return color == 0 and 1 or color
end

function YunbiaoData:GetTaskId()
	return GameVoManager.Instance:GetMainRoleVo().husong_taskid
end


function YunbiaoData:SetAcceptInActivitytime(value)
	if value then
		self.accept_in_activitytime = value
	end
end

function YunbiaoData:GetAcceptInActivitytime()
	return self.accept_in_activitytime
end

function YunbiaoData:GetTaskIdByCamp()
	return self.task_ids
end

function YunbiaoData:GetIsHuShong()
	return self:GetTaskId() > 0
end

function YunbiaoData:GetYubiaoPreTaskId()
	return ConfigManager.Instance:GetAutoConfig("husongcfg_auto").other[1].pretask_id
end

--获得余下可运送次数
function YunbiaoData:GetHusongRemainTimes()
	local buytimes = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_HUSONG_TASK_VIP_BUY_COUNT) --已购买次数
	local complete_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT) --完成次数
	return self:GetTotalFreeHusonTimes() + buytimes - complete_times
end

function YunbiaoData:GetTotalFreeHusonTimes()
	return ConfigManager.Instance:GetAutoConfig("husongcfg_auto").other[1].free_husong_times
end

-- 获取剩余免费刷新次数
function YunbiaoData:GetFreeHusongNum()
	return self:GetTotalFreeHusonTimes() - self:GetLingQuCishu()
end

-- 获取剩余购买次数
function YunbiaoData:GetMaxGoumaiNum()
	local buy_time_limit = VipPower.Instance:GetParam(VipPowerId.husong_buy_times)
	return buy_time_limit - self:GetGouMaiCishu()
end

-- 获取vip15的购买次数
function YunbiaoData:GetMaxGoumaiCiShu()
	local config = VipData.Instance:GetVipLevelCfg()
	if config then
		local auth_config = config[VIPPOWER.HUSONG_BUY_TIMES]
		if auth_config then
			return auth_config["param_15"] or 0
		end
	end
	return 0
end

-- 获取免费刷新次数
function YunbiaoData:GetFreeRefreshNum()
	return ConfigManager.Instance:GetAutoConfig("husongcfg_auto").other[1].free_refresh_times - self:GetRefreshFreeTime()
end


-- 获取刷新消耗描述
function YunbiaoData:GetRefreshConsumeStr()
	local str = ''
	if self:GetFreeRefreshNum() <= 0 then
		local other_config = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").other[1]
		if nil ~= other_config then
			local item_id = other_config.flush_itemid
			local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
			local color = item_num >= 1 and COLOR3B.GREEN or COLOR3B.RED
			str = item_num .. "/1"
			str = HtmlTool.GetHtml(str, color)
		end
	else
		str = string.format(Language.YunBiao.MianFei, self:GetFreeRefreshNum())
	end
	return str
end

-- 获取刷新次数描述
function YunbiaoData:GetConsumeYbStr()
	local n = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").other[1].free_husong_times + self:GetGouMaiCishu()
	return string.format(Language.YunBiao.HuSongCiShu, n - self:GetLingQuCishu(), n)
end

-- 获取购买次数描述
function YunbiaoData:GetConsumeNumStr()
	local num = self:GetMaxGoumaiNum()
	return string.format(Language.YunBiao.KeGouMaiCiShu, num < 0 and 0 or num)
end

function YunbiaoData:GetRewardConfig()
	local husong_act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	local list = {}
	local reward_config = YunbiaoData.GetRewardCfgByLv(GameVoManager.Instance:GetMainRoleVo().level)

	if reward_config then
		for i=1,5 do
			local factor = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_factor_list[i] and ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_factor_list[i].factor or 0
			local exp = math.floor(reward_config.commit_exp * factor / 100)
			local bind_coin = math.floor(reward_config.commit_bind_coin * factor / 100)
			if husong_act_isopen then
				exp = math.floor(exp)
				bind_coin = math.floor(bind_coin * 2)
			else
				exp = math.floor(exp)
			end
			table.insert(list,{exp = exp, bind_coin = bind_coin})
		end
	end
	return list
end

function YunbiaoData.GetRewardCfgByLv(lv)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_list) do
		if lv >= v.min_limit_level and lv <= v.max_limit_level then
			return v
		end
	end
	return nil
end

--获得当前身上玩家接的护送任务对应的奖励
function YunbiaoData:GetCurExitTaskRewardCfg()
	local list = self:GetRewardConfig()
	return list[self:GetTaskColor()]
end

-- 是否开放护
function YunbiaoData:IsOpenHuSong()
	return FunOpen.Instance:GetFunIsOpened(FunName.HusongTask)
end

function YunbiaoData:SetIsUseHuDun(is_use_hudun)
	self.is_use_hudun = is_use_hudun
end

function YunbiaoData:GetIsUseHuDun()
	return self.is_use_hudun == 1
end

function YunbiaoData:SetToggleRed(state)
	self.toggle_red_state = state
end

function YunbiaoData:SetToggleAuto(state)
	self.toggle_red_state = state
end

function YunbiaoData:GetToggleRed()
	return self.toggle_red_state
end

function YunbiaoData:GetToggleAuto()
	return self.toggle_red_state
end