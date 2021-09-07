LuckyBoxView = LuckyBoxView or BaseClass(BaseView)

local POINTER_ANGLE_LIST = {
	[1] = 2,
	[2] = -42,
	[3] = -88,
	[4] = -132,
	[5] = -178,
	[6] = -222,
	[7] = -266,
	[8] = -311,
	[9] = -288,
	[10] = -324,
}

local SHOW_TYPE = {
	ROLE = 1,
	TITLE = 2,
	OTHER = 3,
}

function LuckyBoxView:__init()
	self.ui_config = {"uis/views/serveractivity/zhuanzhuanletwo", "ZhuangZhuangLeTwo"}
	self.play_audio = true
	self.full_screen = false
	self.is_rolling = false
	self.is_click_once = false
	self.click_reward = -1
	self.is_free = false
	self:SetMaskBg()
end

function LuckyBoxView:__delete()

end

function LuckyBoxView:ReleaseCallBack()
	self.slider = nil
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
	self.center_point = nil
	self.display = nil
	self.show_hight_light_1 = nil
	self.show_hight_light_2 = nil
	self.show_hight_light_3 = nil
	self.show_hight_light_4 = nil
	self.show_hight_light_5 = nil
	self.show_hight_light_6 = nil
	self.show_hight_light_7 = nil
	self.show_hight_light_8 = nil
	self.show_hight_light_9 = nil
	self.show_hight_light_10 = nil
	self.zhandouli = nil
	for i = 1, 6 do
		self["slider_reward_"..i] = nil
	end
	self.play_ani_toggle = nil
	self.is_show_title_text = nil
	self.ShenYuTime = nil
	self.is_click_once = false
	self.show_mask = nil
	self.box_show_image	= nil
	self.is_show_title_icon = nil
	self.had_key = nil
	self.key_num = nil
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
		self.show_reward_image_list[i] = nil
		self.text_can_reward_time_list[i] = nil
		self.show_effect_list[i] = nil
		self.has_get_list[i] = nil
		self.reward_item_list[i]:DeleteMe()
		self.reward_item_list[i] = nil
		self.reward_bg_effct_list[i] = nil
		self.bg_red_list[i]	= nil
		self.reward_obj_list[i] = nil
	end

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.show_reward_panel then
		GlobalTimerQuest:CancelQuest(self.show_reward_panel)
		self.show_reward_panel = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
end

function LuckyBoxView:LoadCallBack()
	self.center_point = self:FindObj("center_point")
	self.display = self:FindObj("display")
	self.model = RoleModel.New("zhuangzhuang_le_view")
	self.model:SetDisplay(self.display.ui3d_display)
	self.ShenYuTime = self:FindVariable("ShenYuTime")
	self.slider = self:FindObj("Slider"):GetComponent(typeof(UnityEngine.UI.Slider))

	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("OnClickTence", BindTool.Bind(self.OnClickTence, self))
	self:ListenEvent("close_button", BindTool.Bind(self.close_button, self))
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
	self.box_show_image	= self:FindVariable("box_show_image")
	self.is_show_title_icon = self:FindVariable("IsShowTitleIcon")

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
	self.show_hight_light_1 = self:FindVariable("show_hight_light_1")
	self.show_hight_light_2 = self:FindVariable("show_hight_light_2")
	self.show_hight_light_3 = self:FindVariable("show_hight_light_3")
	self.show_hight_light_4 = self:FindVariable("show_hight_light_4")
	self.show_hight_light_5 = self:FindVariable("show_hight_light_5")
	self.show_hight_light_6 = self:FindVariable("show_hight_light_6")
	self.show_hight_light_7 = self:FindVariable("show_hight_light_7")
	self.show_hight_light_8 = self:FindVariable("show_hight_light_8")
	self.show_hight_light_9 = self:FindVariable("show_hight_light_9")
	self.show_hight_light_10 = self:FindVariable("show_hight_light_10")
	self.zhandouli = self:FindVariable("zhandouli")

	for i = 1, 6 do
		self["slider_reward_".. i] = self:FindVariable("slider_reward_" .. i)
	end
	self.had_key = self:FindVariable("had_key")
	self.key_num = self:FindVariable("key_num")

	self.text_vip_level_list = {}
	self.text_can_reward_time_list = {}
	self.show_reward_image_list = {}
	self.show_effect_list = {}
	self.has_get_list = {}
	self.reward_bg_effct_list = {}
	self.bg_red_list = {}
	for i = 1, 6 do
		self.text_can_reward_time_list[i] = self:FindVariable("text_can_reward_time"..i)
		self.show_reward_image_list[i] = self:FindVariable("reward_item_image"..i)
		self.text_vip_level_list[i] = self:FindVariable("text_vip_level"..i)
		self.show_effect_list[i] = self:FindVariable("show_effect"..i)
		self.has_get_list[i] = self:FindVariable("has_get"..i)
		self.reward_bg_effct_list[i] = self:FindVariable("show_reward_effect"..i)
		self.bg_red_list[i] = self:FindVariable("show_redpoint"..i)
	end
	self.show_mask = self:FindVariable("is_mask")
	self:ListenEvent("mask_click", BindTool.Bind(self.CheckBoxClick, self))
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self:InitModle()
end

function LuckyBoxView:CheckBoxClick()
	local zhuang_le_data = LuckyBoxData.Instance
	local is_shield = zhuang_le_data:GetIsShield()
	self.show_mask:SetValue(not is_shield)
end

function LuckyBoxView:OnToggleChange(is_on)
	LuckyBoxData.Instance:SetAniState(is_on)
end

function LuckyBoxView:InitModle()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu_3_other

	if cfg == nil then return end
	local res_name_list = {}
	local power = 0
	local path = cfg[1].path
	local model_type = 0
	for i, v in ipairs(cfg) do
		if open_day <= v.opengame_day then
			path = v.path
			model_type = v.model_type
			res_name_list[1] = v.name1
			res_name_list[2] = v.name2
			res_name_list[3] = v.name3
			res_name_list[4] = v.name4
			power = v.power
			scale = v.scale
			break
		end
	end
	self.model:ClearModel()
	self.is_show_title_icon:SetValue(false)
	if not next(res_name_list) then return end
	
	local model_scale = Vector3(scale,scale,scale)
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local path_rel,res_id_rel = ResPath.GetRoleModel(res_name_list[prof] or res_name_list[1])
	if model_type == SHOW_TYPE.TITLE then
		self.is_show_title_icon:SetValue(true)
		self.box_show_image:SetAsset(path, res_name_list[1])
	elseif model_type == SHOW_TYPE.ROLE then
		self.model:SetMainAsset(path_rel,res_id_rel)
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WING], res_id_rel, DISPLAY_PANEL.ZHUANZHUANLE)
		self.model:SetModelScale(model_scale)
	elseif model_type == SHOW_TYPE.OTHER then
		self.model:SetMainAsset(path, res_name_list[1])
		self.model:SetModelScale(model_scale)
	end
	local open_activity_days = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_3)
	self.is_show_title_text:SetValue(false)
	self.zhandouli:SetValue(power or 0)

end

function LuckyBoxView:TipsClick()
	local tips_id = 207 -- 转转乐玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function LuckyBoxView:GetLeijiReward(index)
	 local can_lin = LuckyBoxData.Instance:CanGetRewardBySeq(index)
	 if can_lin then
		LuckyBoxData.Instance:SetLinRewardSeq(index - 1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_3 , RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD , index - 1)
	 end
end

function LuckyBoxView:ShowVipAndTime()
	local reward_cfg = LuckyBoxData.Instance:GetGridLotteryTreeAllRewardData()
	local allaTreeTime = LuckyBoxData.Instance:GetServerMoneyTreeTimes()
	local used_time = LuckyBoxData.Instance:GetFreeTime()
	local cfg_other = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local total_free_time = LuckyBoxData.Instance:GetZhuanZhuanLFreeTotalTimes()
	local server_total_money_tree_times = LuckyBoxData.Instance:GetServerMoneyTreeTimes()
	local need_once_money = cfg_other.money_tree_need_gold
	local need_tence_money = 10 * cfg_other.money_tree_need_gold
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	self.once_money:SetValue(need_once_money)
	self.tence_money:SetValue(need_tence_money)

	for i = 1, 6 do
		self.text_vip_level_list[i]:SetValue(reward_cfg[i].vip_limit)
		if allaTreeTime < reward_cfg[i].server_rock_times then
			self.text_can_reward_time_list[i]:SetValue(string.format(Language.ZhuanZhuanLe.CiShuBi , server_total_money_tree_times , reward_cfg[i].server_rock_times))
		else
			local flag = LuckyBoxData.Instance.server_reward_has_fetch_reward_flag[32 - i + 1]
			if 1 == flag then
				self.show_effect_list[i]:SetValue(false)
				self.text_can_reward_time_list[i]:SetValue("")
				self.bg_red_list[i]:SetValue(false)
				self.has_get_list[i]:SetValue(true)
				self.reward_bg_effct_list[i]:SetValue(false)

			else
				if vip_level < reward_cfg[i].vip_limit then
					self.show_effect_list[i]:SetValue(false)
					self.reward_bg_effct_list[i]:SetValue(false)
				else
					self.reward_bg_effct_list[i]:SetValue(true)
				end
				self.bg_red_list[i]:SetValue(true)
				self.has_get_list[i]:SetValue(false)
				self.text_can_reward_time_list[i]:SetValue(Language.ZhuanZhuanLe.KeLingQu)
			end
		end
	end
end

function LuckyBoxView:SetItemImage()
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = LuckyBoxData.Instance:GetOtherCfg()

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

	local reward_cfg = LuckyBoxData.Instance:GetGridLotteryTreeAllRewardData()
	for i = 1, 6 do
		self.reward_item_list[i]:SetData(reward_cfg[i])
	end
end

function LuckyBoxView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_3, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
	self:InitModle()
	local time_str = LuckyBoxData.Instance:GetActEndTime()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self.least_time_timer = CountDown.Instance:AddCountDown(time_str, 1, function ()
			time_str = time_str - 1
			self:FlushUpdataActEndTime(time_str)
		end)

end

function LuckyBoxView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
	self.click_reward = -1
	self.is_click_once = false
end

function LuckyBoxView:OnFlush()
	self:show_reward_pool()
	self:FlushNextTime()
	self:SetItemImage()
	self:ShowVipAndTime()
	-- self:FlushActEndTime()
	self:SetObjActive()
	self:FlushKeyNum()
	self:SliderReward()
	self:FlushSlider()
	if self.click_reward > -1 then
		self:TurnCellOne()
	end
end

function LuckyBoxView:SliderReward()
	local reward_cfg = LuckyBoxData.Instance:GetGridLotteryTreeAllRewardData()
	for i = 1,6 do 
		self["slider_reward_"..i]:SetValue(reward_cfg[i].server_rock_times or 0)
	end
end

function LuckyBoxView:FlushSlider()
	local slider_reward_list = {}
	local server_total_money_tree_times = LuckyBoxData.Instance:GetServerMoneyTreeTimes()
	local reward_cfg = LuckyBoxData.Instance:GetGridLotteryTreeAllRewardData()

	for i=1,6 do
		slider_reward_list[i] = reward_cfg[i].server_rock_times
	end
	--0.095,0.28,0.46,0.64,0.82,1  
	if server_total_money_tree_times >= slider_reward_list[6] then 
		self.slider.value = 1
	elseif server_total_money_tree_times <= slider_reward_list[1] then 
		local Percentage = server_total_money_tree_times / slider_reward_list[1]
		self.slider.value = Percentage * 0.095
	elseif server_total_money_tree_times >	slider_reward_list[1] and server_total_money_tree_times <= slider_reward_list[2] then 
		local Percentage = (server_total_money_tree_times - slider_reward_list[1]) / (slider_reward_list[2] - slider_reward_list[1])
		self.slider.value = Percentage * (0.28 - 0.095) + 0.095
	elseif server_total_money_tree_times > slider_reward_list[5] then
		local Percentage = (server_total_money_tree_times - slider_reward_list[5]) /	(slider_reward_list[6] - slider_reward_list[5])
		self.slider.value = Percentage * (1 - 0.82) + 0.82
	else
		local Percentage = (server_total_money_tree_times - slider_reward_list[2]) / (slider_reward_list[5] - slider_reward_list[2])
		self.slider.value = Percentage * (0.82 - 0.28)  + 0.28 
	end

end


function LuckyBoxView:FlushKeyNum()
	local num = LuckyBoxData.Instance:GetZhuanZhuanLeKeyNum()
	self.had_key:SetValue(num > 0)
	self.key_num:SetValue(num)
end

function LuckyBoxView:SetObjActive()
	local reward_cfg = LuckyBoxData.Instance:GetGridLotteryTreeAllRewardData()
	if reward_cfg and next(reward_cfg) then
		local first_day = reward_cfg[1].opengame_day
		for i = 1, 6 do
			self.reward_obj_list[i]:SetActive(reward_cfg[i].opengame_day == first_day)
		end
	end
end

function LuckyBoxView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), 60)
end

function LuckyBoxView:FlushUpdataActEndTime(time_str)
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
  	local str = ""
 	if time_tab.day > 0 then
   		time_str = time_str - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond2HMS(time_str)
	self.ShenYuTime:SetValue(str)
end

function LuckyBoxView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
end

function LuckyBoxView:FlushCanNextTime()
	local time_str = LuckyBoxData.Instance:GetMianFeiTime()
	local cfg_time = LuckyBoxData.Instance:GetZhuanZhuanLFreeInterval()
	local next_free_time = cfg_time - time_str
	local use_free_times = LuckyBoxData.Instance:GetFreeTime()
	local total_free_times = LuckyBoxData.Instance:GetZhuanZhuanLFreeTotalTimes()
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

function LuckyBoxView:TurnCell()
	local other_cfg = LuckyBoxData.Instance:GetGridLotteryTreeRewardData()
	local reward_list = LuckyBoxData.Instance:GetRewardList()
	local quick_use_time = 0
	self:ResetVariable()
	self:ResetHighLight()
	local time = 0
	local tween = self.center_point.transform:DORotate(
	Vector3(0, 0, -360 * 20),20,
	DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local angle = POINTER_ANGLE_LIST[reward_list[1] % 8 + 1]
			local tween1 = self.center_point.transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self:ShowHightLight()
				TipsCtrl.Instance:ShowTreasureView(self.click_reward)
				if self.show_reward_panel then
					GlobalTimerQuest:CancelQuest(self.show_reward_panel)
					self.show_reward_panel = nil
				end
				if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_10 then
					quick_use_time = 3
				else
					quick_use_time = 1
				end
				self.show_reward_panel = GlobalTimerQuest:AddDelayTimer(function ()
					ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_RA_MONEY_TREE_REWARD)
					end,quick_use_time)
			end)
		end
	end)
end

function LuckyBoxView:TurnCellOne()
	self:ResetVariable()
	self:ResetHighLight()
	self:ShowHightLight()
	TipsCtrl.Instance:ShowTreasureView(self.click_reward)
end

function LuckyBoxView:show_reward_pool()
	self.reward_pool_gold:SetValue(LuckyBoxData.Instance:GetServerMoneyTreePoolGold())
end

function LuckyBoxView:GetAwardButton(index)
	self.is_click_once = false
	self.click_reward = -1
	local allTreeTime = LuckyBoxData.Instance:GetServerMoneyTreeTimes()
	self:GetLeijiReward(index)
end

function LuckyBoxView:ShowHightLight()
	local reward_list = LuckyBoxData.Instance:GetRewardList()
	local hight_light_index = reward_list[1] % 10 + 1
	self["show_hight_light_"..hight_light_index]:SetValue(true)
end

function LuckyBoxView:OnClickOnce()
	local ZhuanZhuanLeInfo =  LuckyBoxData.Instance:GetZhuanZhuanLeInfo()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold
	if self.is_free then
		self.is_click_once = true
		LuckyBoxData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_1
		self:PointerTrunAround(1)
	else
		local func = function()
			self.is_click_once = true
			LuckyBoxData.Instance:SetAniState(self.play_ani_toggle.isOn)
			self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_1
			self:PointerTrunAround(1)
		end
		local tip_text = string.format(Language.ZhuanZhuanLe.TiShiOnce, need_diamon)
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, false)
	end
end

function LuckyBoxView:OnClickTence()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold * 10
	local func = function()
		self.is_click_once = true
		LuckyBoxData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_lUCKY_BOX_10
		self:PointerTrunAround(10)
	end
	local tip_text = string.format(Language.ZhuanZhuanLe.TiShiTence, need_diamon)
	local key_num = LuckyBoxData.Instance:GetZhuanZhuanLeKeyNum()

	if key_num == 0 then
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, false)
	else
		func()
	end
end

function LuckyBoxView:close_button()
	self:Close()
end

function LuckyBoxView:PointerTrunAround(index)
	-- if self.is_rolling then return end
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		if index == 1 then
			self.show_red_point:SetValue(false)
		end
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_3, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,index)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function LuckyBoxView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function LuckyBoxView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function LuckyBoxView:ResetHighLight()
	self.show_hight_light_5:SetValue(false)
	self.show_hight_light_6:SetValue(false)
	self.show_hight_light_7:SetValue(false)
	self.show_hight_light_8:SetValue(false)
	self.show_hight_light_9:SetValue(false)
	self.show_hight_light_10:SetValue(false)
	self.show_hight_light_1:SetValue(false)
	self.show_hight_light_2:SetValue(false)
	self.show_hight_light_3:SetValue(false)
	self.show_hight_light_4:SetValue(false)
end
