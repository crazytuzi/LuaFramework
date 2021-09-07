DaSheTianXiaView = DaSheTianXiaView or BaseClass(BaseView)

local SHOW_TYPE = {
	ROLE = 1,
	TITLE = 2,
	OTHER = 3,
}

function DaSheTianXiaView:__init()
	self.ui_config = {"uis/views/serveractivity/dashetianxia", "DaSheTianXiaView"}
	self.play_audio = true
	self.full_screen = false
	self.click_reward = -1
	self.is_free = false
	self:SetMaskBg()
end

function DaSheTianXiaView:__delete()

end

function DaSheTianXiaView:ReleaseCallBack()
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
	self.play_ani_toggle = nil
	self.ShenYuTime = nil
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

function DaSheTianXiaView:LoadCallBack()
	self.center_point = self:FindObj("center_point")
	self.display = self:FindObj("display")
	self.model = RoleModel.New("zhuangzhuang_le_view")
	self.model:SetDisplay(self.display.ui3d_display)
	self.ShenYuTime = self:FindVariable("ShenYuTime")

	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("OnClickTence", BindTool.Bind(self.OnClickTence, self))
	self:ListenEvent("close_button", BindTool.Bind(self.close_button, self))
	self:ListenEvent("TipsClick", BindTool.Bind(self.TipsClick, self))
	self.item_list = {}
	for i = 1, 8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item"..i))
		self["show_hight_light_" .. i] = self:FindVariable("show_hight_light_" .. i)
	end
	self.reward_item_list = {}
	self.reward_obj_list = {}
	self.text_vip_level_list = {}
	self.text_can_reward_time_list = {}
	self.show_reward_image_list = {}
	self.show_effect_list = {}
	self.has_get_list = {}
	self.reward_bg_effct_list = {}
	self.bg_red_list = {}
	for i = 1, 6 do
		self.reward_item_list[i] = ItemCell.New()
		self.reward_obj_list[i] = self:FindObj("btn"..i)
		self.reward_item_list[i]:SetInstanceParent(self:FindObj("rewarditem"..i))
		self.text_can_reward_time_list[i] = self:FindVariable("text_can_reward_time"..i)
		self.show_reward_image_list[i] = self:FindVariable("reward_item_image"..i)
		self.text_vip_level_list[i] = self:FindVariable("text_vip_level"..i)
		self.show_effect_list[i] = self:FindVariable("show_effect"..i)
		self.has_get_list[i] = self:FindVariable("has_get"..i)
		self.reward_bg_effct_list[i] = self:FindVariable("show_reward_effect"..i)
		self.bg_red_list[i] = self:FindVariable("show_redpoint"..i)

		self:ListenEvent("button" .. i, BindTool.Bind(self.GetAwardButton, self, i))
	end
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	
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
	self.had_key = self:FindVariable("had_key")
	self.key_num = self:FindVariable("key_num")
	self.show_mask = self:FindVariable("is_mask")
	self:ListenEvent("mask_click", BindTool.Bind(self.CheckBoxClick, self))
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self:ResetHighLight()
	self:InitModle()
end

function DaSheTianXiaView:CheckBoxClick()
	local zhuang_le_data = DaSheTianXiaData.Instance
	local is_shield = zhuang_le_data:GetIsShield()
	self.show_mask:SetValue(not is_shield)
end

function DaSheTianXiaView:InitModle()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu_5_other
	if cfg == nil then return end
	local res_name_list = {}
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
			break
		end
	end
	self.model:ClearModel()
	self.is_show_title_icon:SetValue(false)
	if not next(res_name_list) then return end
	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local path_rel,res_id_rel = ResPath.GetRoleModel(res_name_list[prof] or res_name_list[1])
	if model_type == SHOW_TYPE.TITLE then
		self.is_show_title_icon:SetValue(true)
		self.box_show_image:SetAsset(path, res_name_list[1])

	elseif model_type == SHOW_TYPE.ROLE then
		self.model:SetMainAsset(path_rel,res_id_rel)
		self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WING], res_id_rel, DISPLAY_PANEL.ZHUANZHUANLE)

	elseif model_type == SHOW_TYPE.OTHER then
		self.model:SetMainAsset(path, res_name_list[1])
	end
	local open_activity_days = ActivityData.GetActivityDays(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5)
	-- self.is_show_title_text:SetValue(false)
end

function DaSheTianXiaView:TipsClick()
	local tips_id = 207 -- 转转乐玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function DaSheTianXiaView:GetLeijiReward(index)
	 local can_lin = DaSheTianXiaData.Instance:CanGetRewardBySeq(index)
	 if can_lin then
		DaSheTianXiaData.Instance:SetLinRewardSeq(index - 1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5 , RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD , index - 1)
	 end
end

function DaSheTianXiaView:ShowVipAndTime()
	local reward_cfg = DaSheTianXiaData.Instance:GetGridLotteryTreeAllRewardData()
	local allaTreeTime = DaSheTianXiaData.Instance:GetServerMoneyTreeTimes()
	local used_time = DaSheTianXiaData.Instance:GetFreeTime()
	local cfg_other = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local total_free_time = DaSheTianXiaData.Instance:GetZhuanZhuanLFreeTotalTimes()
	local server_total_money_tree_times = DaSheTianXiaData.Instance:GetServerMoneyTreeTimes()
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
			local flag = DaSheTianXiaData.Instance.server_reward_has_fetch_reward_flag[32 - i + 1]
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

function DaSheTianXiaView:OnToggleChange(is_on)
	DaSheTianXiaData.Instance:SetAniState(is_on)
end

function DaSheTianXiaView:SetItemImage()
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = DaSheTianXiaData.Instance:GetOtherCfg()
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

	local reward_cfg = DaSheTianXiaData.Instance:GetGridLotteryTreeAllRewardData()
	for i = 1, 6 do
		self.reward_item_list[i]:SetData(reward_cfg[i])
	end
end

function DaSheTianXiaView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
	self:InitModle()
	local time_str = DaSheTianXiaData.Instance:GetActEndTime()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
	self.least_time_timer = CountDown.Instance:AddCountDown(time_str, 1, function ()
			time_str = time_str - 1
			self:FlushUpdataActEndTime(time_str)
		end)
end

function DaSheTianXiaView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
	self.click_reward = -1
end

function DaSheTianXiaView:OnFlush()
	self:show_reward_pool()
	self:FlushNextTime()
	self:SetItemImage()
	self:ShowVipAndTime()
	self:SetObjActive()
	self:FlushKeyNum()
	if self.click_reward > -1 then
		self:TurnCellOne()
	end
end

function DaSheTianXiaView:FlushKeyNum()
	local num = DaSheTianXiaData.Instance:GetZhuanZhuanLeKeyNum()
	self.had_key:SetValue(num > 0)
	self.key_num:SetValue(num)
end

function DaSheTianXiaView:SetObjActive()
	local reward_cfg = DaSheTianXiaData.Instance:GetGridLotteryTreeAllRewardData()
	if reward_cfg and next(reward_cfg) then
		local first_day = reward_cfg[1].opengame_day
		for i = 1, 6 do
			self.reward_obj_list[i]:SetActive(reward_cfg[i].opengame_day == first_day)
		end
	end
end

function DaSheTianXiaView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), 60)
end

function DaSheTianXiaView:FlushUpdataActEndTime(time_str)
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
  	local str = ""
 	if time_tab.day > 0 then
   		time_str = time_str - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond2HMS(time_str)
	self.ShenYuTime:SetValue(str)
end

function DaSheTianXiaView:GetFreeTimes()
	local free_time =  DaSheTianXiaData.Instance:GetZhuanZhuanLeOtherCfg().free_time
	return free_time or 0
end

function DaSheTianXiaView:FlushNextTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
end

function DaSheTianXiaView:FlushCanNextTime()
	local time_str = DaSheTianXiaData.Instance:GetMianFeiTime()
	local cfg_time = DaSheTianXiaData.Instance:GetZhuanZhuanLFreeInterval()
	local next_free_time = cfg_time - time_str
	local use_free_times = DaSheTianXiaData.Instance:GetFreeTime()
	local total_free_times = DaSheTianXiaData.Instance:GetZhuanZhuanLFreeTotalTimes()
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

function DaSheTianXiaView:TurnCellOne()
	self:ResetVariable()
	self:ResetHighLight()
	self:ShowHightLight()
	TipsCtrl.Instance:ShowTreasureView(self.click_reward)
end

function DaSheTianXiaView:show_reward_pool()
	self.reward_pool_gold:SetValue(DaSheTianXiaData.Instance:GetServerMoneyTreePoolGold())
end

function DaSheTianXiaView:GetAwardButton(index)
	self.click_reward = -1
	local allTreeTime = DaSheTianXiaData.Instance:GetServerMoneyTreeTimes()
	self:GetLeijiReward(index)
end

function DaSheTianXiaView:ShowHightLight()
	local reward_list = DaSheTianXiaData.Instance:GetRewardList()
	local hight_light_index = reward_list[1] % 10 + 1
	self["show_hight_light_"..hight_light_index]:SetValue(true)
	AudioManager.PlayAndForget(AssetID("audios/sfxs/other", "darts_hit"))
end

function DaSheTianXiaView:OnClickOnce()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold
	if self.is_free then
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_1
		self:PointerTrunAround(1)
	else
		local func = function()
			self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_1
			self:PointerTrunAround(1)
		end
		local tip_text = string.format(Language.ZhuanZhuanLe.TiShiOnce, need_diamon)
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, false)
	end
end

function DaSheTianXiaView:OnClickTence()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold * 10
	local func = function()
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_DASHE_TIAN_XIA_MODE_10
		self:PointerTrunAround(10)
	end
	local tip_text = string.format(Language.ZhuanZhuanLe.TiShiTence, need_diamon)
	local key_num = DaSheTianXiaData.Instance:GetZhuanZhuanLeKeyNum()
	if key_num == 0 then
		TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, false)
	else
		func()
	end
end

function DaSheTianXiaView:close_button()
	self:Close()
end

function DaSheTianXiaView:PointerTrunAround(index)
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		if index == 1 then
			self.show_red_point:SetValue(false)
		end
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,index)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function DaSheTianXiaView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function DaSheTianXiaView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function DaSheTianXiaView:ResetHighLight()
	self.show_hight_light_1:SetValue(false)
	self.show_hight_light_2:SetValue(false)
	self.show_hight_light_3:SetValue(false)
	self.show_hight_light_4:SetValue(false)
	self.show_hight_light_5:SetValue(false)
	self.show_hight_light_6:SetValue(false)
	self.show_hight_light_7:SetValue(false)
	self.show_hight_light_8:SetValue(false)
end