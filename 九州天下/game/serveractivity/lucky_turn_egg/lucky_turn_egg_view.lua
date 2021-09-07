LuckyTurnEggView = LuckyTurnEggView or BaseClass(BaseView)

function LuckyTurnEggView:__init()
	self.ui_config = {"uis/views/serveractivity/luckyturnegg", "LuckyTurnEggView"}
	self.play_audio = true
	self.full_screen = false
	self.is_rolling = false
	self.is_click_once = false
	self.click_reward = -1
	self.is_free = false
	self:SetMaskBg()
end

function LuckyTurnEggView:__delete()

end

function LuckyTurnEggView:ReleaseCallBack()
	self.reward_pool_gold = nil
	self.text_free_this_time = nil
	self.show_dimon = nil
	self.show_red_point = nil
	self.once_money = nil
	self.tence_money = nil
	self.hour = nil
	self.min = nil
	self.sec = nil
	self.show_time = nil
	self.play_ani_toggle = nil
	self.is_show_title_text = nil
	self.ShenYuTime = nil
	self.is_click_once = false
	self.show_mask = nil
	self.had_key = nil
	self.key_num = nil
	self.egg_anim = nil
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end

	for i = 1, 8 do
		self.item_list[i]:DeleteMe()
		self.item_list[i] = nil
	end

	for i = 1, 6 do
		self.text_vip_level_list[i] = nil
		self.text_can_reward_time_list[i] = nil
		self.show_effect_list[i] = nil
		self.has_get_list[i] = nil
		self.reward_item_list[i]:DeleteMe()
		self.reward_item_list[i] = nil
		self.bg_red_list[i]	= nil
		self.reward_obj_list[i] = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	if self.show_reward_panel then
		GlobalTimerQuest:CancelQuest(self.show_reward_panel)
		self.show_reward_panel = nil
	end

	if self.show_egg_anim then
		GlobalTimerQuest:CancelQuest(self.show_egg_anim)
		self.show_egg_anim = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function LuckyTurnEggView:LoadCallBack()
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("OnClickTence", BindTool.Bind(self.OnClickTence, self))
	self:ListenEvent("Close", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("TipsClick", BindTool.Bind(self.TipsClick, self))
	self.item_list = {}
	for i = 1, 8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item"..i))
	end
	self.reward_item_list = {}
	for i = 1, 6 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_item_list[i]:SetInstanceParent(self:FindObj("rewarditem"..i))
		self:ListenEvent("button" .. i, BindTool.Bind(self.GetAwardButton, self, i))
	end

	self.reward_obj_list = {}
	for i=1,6 do
		self.reward_obj_list[i] = self:FindObj("btn"..i)
	end
	
	self.ShenYuTime = self:FindVariable("ShenYuTime")
	self.text_free_this_time = self:FindVariable("text_free_this_time")
	self.show_dimon = self:FindVariable("dimon_show")
	self.show_red_point = self:FindVariable("point_red_show")
	self.once_money = self:FindVariable("once_money")
	self.tence_money = self:FindVariable("tence_money")
	self.hour = self:FindVariable("Hour")
	self.min = self:FindVariable("Min")
	self.sec = self:FindVariable("Sec")
	self.show_time = self:FindVariable("show_time")
	self.reward_pool_gold = self:FindVariable("reward_pool_gold")
	self.is_show_title_text = self:FindVariable("IsShowTitleText")
	self.had_key = self:FindVariable("had_key")
	self.key_num = self:FindVariable("key_num")

	self.text_vip_level_list = {}
	self.text_can_reward_time_list = {}
	self.show_effect_list = {}
	self.has_get_list = {}
	self.bg_red_list = {}
	for i = 1, 6 do
		self.text_can_reward_time_list[i] = self:FindVariable("text_can_reward_time"..i)
		self.text_vip_level_list[i] = self:FindVariable("text_vip_level"..i)
		self.show_effect_list[i] = self:FindVariable("show_effect"..i)
		self.has_get_list[i] = self:FindVariable("has_get"..i)
		self.bg_red_list[i] = self:FindVariable("show_redpoint"..i)
	end
	self.show_mask = self:FindVariable("is_mask")
	self:ListenEvent("mask_click", BindTool.Bind(self.CheckBoxClick, self))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.egg_anim = self:FindObj("EggPanel").animator
end

function LuckyTurnEggView:CheckBoxClick()
	local zhuang_le_data = LuckyTurnEggData.Instance
	local is_shield = zhuang_le_data:GetIsShield()
	self.show_mask:SetValue(not is_shield)
end

function LuckyTurnEggView:OnToggleChange(is_on)
	LuckyTurnEggData.Instance:SetAniState(is_on)
end

function LuckyTurnEggView:TipsClick()
	local tips_id = 207 -- 转转乐玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function LuckyTurnEggView:GetLeijiReward(index)
	 local can_lin = LuckyTurnEggData.Instance:CanGetRewardBySeq(index)
	 if can_lin then
		LuckyTurnEggData.Instance:SetLinRewardSeq(index - 1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4 , RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD , index - 1)
	 end
end

function LuckyTurnEggView:ShowVipAndTime()
	local reward_cfg = LuckyTurnEggData.Instance:GetGridLotteryTreeAllRewardData()
	local allaTreeTime = LuckyTurnEggData.Instance:GetServerMoneyTreeTimes()
	local used_time = LuckyTurnEggData.Instance:GetFreeTime()
	local cfg_other = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local total_free_time = LuckyTurnEggData.Instance:GetZhuanZhuanLFreeTotalTimes()
	local server_total_money_tree_times = LuckyTurnEggData.Instance:GetServerMoneyTreeTimes()
	local need_once_money = cfg_other.money_tree_4_need_gold
	local need_tence_money = 10 * cfg_other.money_tree_4_need_gold
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	self.once_money:SetValue(need_once_money)
	self.tence_money:SetValue(need_tence_money)
	for i = 1, 6 do
		self.text_vip_level_list[i]:SetValue(reward_cfg[i].vip_limit)
		if allaTreeTime < reward_cfg[i].server_rock_times then
			self.text_can_reward_time_list[i]:SetValue(string.format(Language.ZhuanZhuanLe.CiShuBi , server_total_money_tree_times , reward_cfg[i].server_rock_times))
		else
			local flag = LuckyTurnEggData.Instance.server_reward_has_fetch_reward_flag[32 - i + 1]
			if 1 == flag then
				self.show_effect_list[i]:SetValue(false)
				self.text_can_reward_time_list[i]:SetValue("")
				self.bg_red_list[i]:SetValue(false)
				self.has_get_list[i]:SetValue(true)
			else
				if vip_level < reward_cfg[i].vip_limit then
					self.show_effect_list[i]:SetValue(false)
				else
					-- self.show_effect_list[i]:SetValue(true)
				end
				self.bg_red_list[i]:SetValue(true)
				self.has_get_list[i]:SetValue(false)
				self.text_can_reward_time_list[i]:SetValue(Language.ZhuanZhuanLe.KeLingQu)
			end
		end
	end
end

function LuckyTurnEggView:SetItemImage()
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = LuckyTurnEggData.Instance:GetOtherCfg()

	local cur_index = 0
	for i, v in ipairs(other_cfg) do
		if open_time_day > v.opengame_day then
			cur_index = cur_index + 1
		end
	end

	for i = 1, 8 do
		 if other_cfg[i + cur_index] then
		 	local data = TableCopy(other_cfg[i + cur_index].reward_item)
		 	data.percent = other_cfg[i + cur_index].prize_pool_percent

			if data.percent ~= "" then
				data.item_id = COMMON_CONSTS.VIRTUAL_ITEM_GOLD
			end
			self.item_list[i]:SetData(data)
		 end
	end

	local reward_cfg = LuckyTurnEggData.Instance:GetGridLotteryTreeAllRewardData()
	for i = 1, 6 do
		self.reward_item_list[i]:SetData(reward_cfg[i])
	end
end

function LuckyTurnEggView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
	local time_str = LuckyTurnEggData.Instance:GetActEndTime()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self.least_time_timer = CountDown.Instance:AddCountDown(time_str, 1, function ()
			time_str = time_str - 1
			self:FlushUpdataActEndTime(time_str)
		end)
end

function LuckyTurnEggView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
	self.click_reward = -1
	self.is_click_once = false
end

function LuckyTurnEggView:OnFlush()
	self:show_reward_pool()
	self:FlushNextTime()
	self:SetItemImage()
	self:ShowVipAndTime()
	self:SetObjActive()
	self:FlushKeyNum()
	if self.click_reward > -1 then
		if self.play_ani_toggle.isOn then
			if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_1 then
				self:TurnCellOne()
			elseif self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
				TipsCtrl.Instance:ShowTreasureView(self.click_reward)
				local quick_use_time = 0

				if self.show_reward_panel then
					GlobalTimerQuest:CancelQuest(self.show_reward_panel)
					self.show_reward_panel = nil
				end

				if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
					quick_use_time = 3
				else
					quick_use_time = 1
				end

				self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD)
				end,quick_use_time)
				self.is_click_once = false
				self.show_red_point:SetValue(false)
			end
		elseif self.is_click_once then
			self:TurnCell()
		end
	end
end

function LuckyTurnEggView:FlushKeyNum()
	local num = LuckyTurnEggData.Instance:GetZhuanZhuanLeKeyNum()
	self.had_key:SetValue(num > 0)
	self.key_num:SetValue(num)
end

function LuckyTurnEggView:SetObjActive()
	local reward_cfg = LuckyTurnEggData.Instance:GetGridLotteryTreeAllRewardData()
	if reward_cfg and next(reward_cfg) then
		local first_day = reward_cfg[1].opengame_day
		for i = 1, 6 do
			self.reward_obj_list[i]:SetActive(reward_cfg[i].opengame_day == first_day)
		end
	end
end

function LuckyTurnEggView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), 60)
end

function LuckyTurnEggView:FlushUpdataActEndTime(time_str)
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
  	local str = ""
 	if time_tab.day > 0 then
   		time_str = time_str - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond2HMS(time_str)
	self.ShenYuTime:SetValue(str)
end

function LuckyTurnEggView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
end

function LuckyTurnEggView:FlushCanNextTime()
	local time_str = LuckyTurnEggData.Instance:GetMianFeiTime()
	local cfg_time = LuckyTurnEggData.Instance:GetZhuanZhuanLFreeInterval()
	local next_free_time = cfg_time - time_str
	local use_free_times = LuckyTurnEggData.Instance:GetFreeTime()
	local total_free_times = LuckyTurnEggData.Instance:GetZhuanZhuanLFreeTotalTimes()
	self.is_free = false
	if use_free_times < total_free_times then
		--有免费次数
		if next_free_time <= 0 then
			--免费时间已到
			-- 移除计时器
			if self.next_timer then
				GlobalTimerQuest:CancelQuest(self.next_timer)
				self.next_timer = nil
			end

			self.show_time:SetValue(false)
			self.show_dimon:SetValue(false)
			self.show_red_point:SetValue(true)
			self.text_free_this_time:SetValue(true)
			self.is_free = true
		else
			self.show_time:SetValue(true)
			self.show_dimon:SetValue(true)
			self.show_red_point:SetValue(false)
			self.text_free_this_time:SetValue(false)

			local time_tab = TimeUtil.Format2TableDHMS(next_free_time)
			self.hour:SetValue(time_tab.hour)
			self.min:SetValue(time_tab.min)
			self.sec:SetValue(time_tab.s)
		end
	else
		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		self.show_dimon:SetValue(true)
		self.show_red_point:SetValue(false)
		self.text_free_this_time:SetValue(false)
		self.show_time:SetValue(false)
	end
end

function LuckyTurnEggView:TurnCell()
	local quick_use_time = 0
	if is_rolling then return end
	self.is_rolling = true

	if self.show_egg_anim then
		GlobalTimerQuest:CancelQuest(self.show_egg_anim)
		self.show_egg_anim = nil
	end

	local is_play_ani = not TipsCtrl.Instance:GetTreasurePlayAniFlag(TREASURE_TYPE.LUCKY_TURN_EGG) and LuckyTurnEggData.Instance:GetAniState()
	local time = is_play_ani and 1 or 0

	if is_play_ani then
		self.egg_anim:SetTrigger("Start")
	end
	
	self.show_egg_anim = GlobalTimerQuest:AddDelayTimer(function ()
		self.is_rolling = false
		TipsCtrl.Instance:ShowTreasureView(self.click_reward)

		if self.show_reward_panel then
			GlobalTimerQuest:CancelQuest(self.show_reward_panel)
			self.show_reward_panel = nil
		end

		if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
			quick_use_time = 3
		else
			quick_use_time = 1
		end
		self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD)
		end, quick_use_time)
	end, time)
end

function LuckyTurnEggView:TurnCellOne()
	self.is_rolling = false
	TipsCtrl.Instance:ShowTreasureView(self.click_reward)
	if self.show_reward_panel then
		GlobalTimerQuest:CancelQuest(self.show_reward_panel)
		self.show_reward_panel = nil
	end
	if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10 then
		quick_use_time = 3
	else
		quick_use_time = 1
	end
	self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD)
	end, quick_use_time)
end

function LuckyTurnEggView:show_reward_pool()
	self.reward_pool_gold:SetValue(LuckyTurnEggData.Instance:GetServerMoneyTreePoolGold())
end

function LuckyTurnEggView:GetAwardButton(index)
	self.is_click_once = false
	self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_GET_REWARD
	local allTreeTime = LuckyTurnEggData.Instance:GetServerMoneyTreeTimes()
	self:GetLeijiReward(index)
end

function LuckyTurnEggView:OnClickOnce()
	if self.is_rolling then
		return
	end
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_4_need_gold
	local func = function()
		self.is_click_once = true
		LuckyTurnEggData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_1
		self:PointerTrunAround(1)
	end
	if self.is_free then
		func()
	else
		local tip_text = string.format(Language.ZhuanZhuanLe.TiShiOnce, need_diamon)
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, false)
	end
end

function LuckyTurnEggView:OnClickTence()
	if self.is_rolling then
		return
	end
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_4_need_gold * 10
	local func = function()
		self.is_click_once = true
		LuckyTurnEggData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_LUCKY_TURN_EGG_MODE_10
		self:PointerTrunAround(10)
	end
	local tip_text = string.format(Language.ZhuanZhuanLe.TiShiTence, need_diamon)
	local key_num = LuckyTurnEggData.Instance:GetZhuanZhuanLeKeyNum()
	if key_num == 0 then
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, false)
	else
		func()
	end
end

function LuckyTurnEggView:OnClose()
	if self.is_rolling then
		return
	end
	self:Close()
end

function LuckyTurnEggView:PointerTrunAround(index)
	if self.is_rolling then return end
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		if index == 1 then
			self.show_red_point:SetValue(false)
		end
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,index)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end