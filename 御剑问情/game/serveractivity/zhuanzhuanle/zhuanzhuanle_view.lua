ZhuangZhuangLeView = ZhuangZhuangLeView or BaseClass(BaseView)

local POINTER_ANGLE_LIST = {
	[1] = 0,
	[2] = -36,
	[3] = -72,
	[4] = -108,
	[5] = -144,
	[6] = -180,
	[7] = -216,
	[8] = -252,
	[9] = -288,
	[10] = -324,
}
local WINGRESID = 8104001

function ZhuangZhuangLeView:__init()
	self.ui_config = {"uis/views/serveractivity/zhuanzhuanle_prefab", "ZhuangZhuangLe"}
	self.play_audio = true
	self.full_screen = false
	self.is_rolling = false
	self.is_click_once = false
    self.click_reward = -1
    self.is_free = false
end

function ZhuangZhuangLeView:__delete()

end

function ZhuangZhuangLeView:ReleaseCallBack()
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
	self.play_ani_toggle = nil
	self.ShenYuTime = nil
	self.is_click_once = false
	self.show_ten_chou_key = nil
	self.show_ten_chou = nil
	self.ten_chou_text = nil

	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end

	for i = 1, 10 do
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
end

function ZhuangZhuangLeView:LoadCallBack()
	self.center_point = self:FindObj("center_point")
	self.display = self:FindObj("display")
	self.model = RoleModel.New("zhuanzhuanle_wing_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self.ShenYuTime = self:FindVariable("ShenYuTime")

	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))
	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickOnce, self))
	self:ListenEvent("OnClickTence", BindTool.Bind(self.OnClickTence, self))
	self:ListenEvent("close_button", BindTool.Bind(self.close_button, self))
	self:ListenEvent("TipsClick", BindTool.Bind(self.TipsClick, self))
	self:ListenEvent("open_log", BindTool.Bind(self.OnClickOpenLog, self))
    self.item_list = {}
	for i = 1, 10 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item"..i))
	end
	self.reward_item_list = {}
	for i = 1, 6 do
        self.reward_item_list[i] = ItemCell.New()
        self.reward_item_list[i]:SetInstanceParent(self:FindObj("rewarditem"..i))
	    self:ListenEvent("button" .. i, BindTool.Bind(self.GetAwardButton, self, i))
	end

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

	self.show_ten_chou_key=self:FindVariable("show_ten_chou_key")
	self.show_ten_chou=self:FindVariable("show_ten_chou")
	self.ten_chou_text=self:FindVariable("ten_chou_text")


    self.text_vip_level_list = {}
	self.text_can_reward_time_list = {}
	self.show_reward_image_list = {}
	self.show_effect_list = {}
	self.has_get_list = {}
	self.reward_bg_effct_list = {}
	for i = 1, 6 do
		self.text_can_reward_time_list[i] = self:FindVariable("text_can_reward_time"..i)
		self.show_reward_image_list[i] = self:FindVariable("reward_item_image"..i)
		self.text_vip_level_list[i] = self:FindVariable("text_vip_level"..i)
		self.show_effect_list[i] = self:FindVariable("show_effect"..i)
		self.has_get_list[i] = self:FindVariable("has_get"..i)
		self.reward_bg_effct_list[i] = self:FindVariable("show_reward_effect"..i)
		self.reward_bg_effct_list[i]:SetValue(false)
	end
    self:InitModle()
    self:FlushActEndTime()
end

function ZhuangZhuangLeView:OnToggleChange(is_on)
    ZhuangZhuangLeData.Instance:SetAniState(is_on)
end

function ZhuangZhuangLeView:InitModle()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	for i, v in pairs(cfg) do
		if open_day <= v.opengame_day then
			local res_id = v.yaoqianshu_showmodel
			self.model:ClearModel()
			self.ChangeModel(self.model, res_id)
			break
		end
	end
end

function ZhuangZhuangLeView.ChangeModel(model, item_id, item_id2)
	local cfg = ItemData.Instance:GetItemConfig(item_id)
	if cfg == nil then
		return
	end
	local display_role = cfg.is_display_role
	local bundle, asset = nil, nil
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role = Scene.Instance:GetMainRole()
	local res_id = 0
	if model then
		local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
		local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
		local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
		model.display:SetRotation(Vector3(0, 0, 0))
		if display_role ~= DISPLAY_TYPE.FOOTPRINT then
			model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		end
		if halo_part then
			halo_part:RemoveModel()
		end
		if wing_part then
			wing_part:RemoveModel()
		end
		if weapon_part then
			weapon_part:RemoveModel()
		end
	end
	if display_role == DISPLAY_TYPE.MOUNT then
		for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.WING then
		for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				break
			end
		end
		if res_id then
			if res_id == WINGRESID then
				model:SetPanelName("zhuanzhuanle_8104001_wing_panel")
			else
				model:SetPanelName("zhuanzhuanle_wing_panel")
			end
		end
		model:SetRoleResid(main_role:GetRoleResId())
		model:SetWingResid(res_id)
	elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetFootResid(res_id)
			model:SetPanelName("zhuanzhuanle_foot_panel")
			model.display:SetRotation(Vector3(0, -90, 0))
			model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif display_role == DISPLAY_TYPE.FASHION then
		local weapon_res_id = 0
		local weapon2_res_id = 0
		local item_id2 = item_id2 or 0
		for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
			if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
				if v.part_type == 1 then
					res_id = v["resouce"..game_vo.prof..game_vo.sex]
				else
					weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
					local temp = Split(weapon_res_id, ",")
					weapon_res_id = temp[1]
					weapon2_res_id = temp[2]
				end
			end

		end
		if res_id == 0 then
			res_id = main_role:GetRoleResId()
		end
		if weapon_res_id == 0 then
			weapon_res_id = main_role:GetWeaponResId()
			weapon2_res_id = main_role:GetWeapon2ResId()
		end

		model:SetRoleResid(res_id)
		model:SetWeaponResid(weapon_res_id)
		if weapon2_res_id then
			model:SetWeapon2Resid(weapon2_res_id)
		end
		model:SetPanelName("zhuanzhuanle_fashion_panel")
	elseif display_role == DISPLAY_TYPE.HALO then
			for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
				if v.item_id == item_id then
					res_id = v.res_id
					break
				end
			end
			model:SetRoleResid(main_role:GetRoleResId())
			model:SetHaloResid(res_id)
	elseif display_role == DISPLAY_TYPE.SPIRIT then
		for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
			if v.item_id and v.item_id== item_id then
				bundle, asset = ResPath.GetSpiritModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
		for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				bundle, asset = ResPath.GetFightMountModel(v.res_id)
				res_id = v.res_id
				break
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENGONG then
		for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.weapon_res_id = v.res_id
				model:SetPanelName("zhuanzhuanle_xian_nv_panel")
				ItemData.SetModel(model, info)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.SHENYI then
		for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
			if v.item_id == item_id then
				res_id = v.res_id
				local info = {}
				info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
				info.wing_res_id = v.res_id
				model:SetPanelName("zhuanzhuanle_xian_nv_panel")
				ItemData.SetModel(model, info)
				return
			end
		end
	elseif display_role == DISPLAY_TYPE.XIAN_NV then
		local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
		if goddess_cfg then
			local xiannv_resid = 0
			local xiannv_cfg = goddess_cfg.xiannv
			if xiannv_cfg then
				for k, v in pairs(xiannv_cfg) do
					if v.active_item == item_id then
						xiannv_resid = v.resid
						break
					end
				end
			end
			if xiannv_resid == 0 then
				local huanhua_cfg = goddess_cfg.huanhua
				if huanhua_cfg then
					for k, v in pairs(huanhua_cfg) do
						if v.active_item == item_id then
							xiannv_resid = v.resid
							break
						end
					end
				end
			end
			if xiannv_resid > 0 then
				local info = {}
				info.role_res_id = xiannv_resid
				bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
				-- self:SetModel(info)
				-- return
			end
			res_id = xiannv_resid
		end
		model:SetPanelName("zhuanzhuanle_xian_nv_panel")
	elseif display_role == DISPLAY_TYPE.ZHIBAO then
		for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
			if v.active_item == item_id then
				bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
				res_id = v.image_id
				break
			end
		end
		model:SetPanelName("zhuanzhuanle_zhibao_panel")
	end
	if bundle and asset and model then
		if display_role == DISPLAY_TYPE.FIGHT_MOUNT then
			model:SetPanelName("zhuanzhuanle_fight_mount_panel")
		elseif display_role == DISPLAY_TYPE.SPIRIT then
			model:SetPanelName("zhuanzhuanle_spirit_panel")
		elseif display_role == DISPLAY_TYPE.FOOTPRINT then
			model:SetPanelName("zhuanzhuanle_foot_panel")
		elseif display_role == DISPLAY_TYPE.MOUNT then
			model:SetPanelName("zhuanzhuanle_mount_panel")
		end
		model:SetMainAsset(bundle, asset)
		if display_role == DISPLAY_TYPE.XIAN_NV then
			model:SetTrigger("show_idle_1")
		elseif display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
			model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
		end
	end

end

function ZhuangZhuangLeView:TipsClick()
    local tips_id = 194 -- 转转乐玩法说明
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ZhuangZhuangLeView:OnClickOpenLog()
	ActivityCtrl.Instance:SendActivityLogSeq(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
end

function ZhuangZhuangLeView:GetLeijiReward(index)
     local can_lin = ZhuangZhuangLeData.Instance:CanGetRewardBySeq(index)
	 if can_lin then
		ZhuangZhuangLeData.Instance:SetLinRewardSeq(index - 1)
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE , RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_FETCH_REWARD , index - 1)
	 end
end

function ZhuangZhuangLeView:ShowVipAndTime()
	local reward_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardData()
	local allaTreeTime = ZhuangZhuangLeData.Instance:GetServerMoneyTreeTimes()
	local used_time = ZhuangZhuangLeData.Instance:GetFreeTime()
	local cfg_other = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local server_free_time = cfg_other .money_tree_free_times
	local server_total_money_tree_times = ZhuangZhuangLeData.Instance:GetServerMoneyTreeTimes()
	local need_once_money = cfg_other.money_tree_need_gold
	local need_tence_money = 10 * cfg_other.money_tree_need_gold
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	self.once_money:SetValue(need_once_money)
    self.tence_money:SetValue(need_tence_money)
	if server_free_time <= used_time and self.show_dimon then
        self.show_dimon:SetValue(true)
		self.show_red_point:SetValue(false)
		self.text_free_this_time:SetValue(false)
		self.show_time:SetValue(false)
		self.is_free = false
	end
	for i = 1, 6 do
		self.text_vip_level_list[i]:SetValue(reward_cfg[i].vip_limit)
		if allaTreeTime < reward_cfg[i].server_rock_times then
		    self.text_can_reward_time_list[i]:SetValue(string.format(Language.ZhuanZhuanLe.MiaoShu , server_total_money_tree_times , reward_cfg[i].server_rock_times))
		else
		    local flag = ZhuangZhuangLeData.Instance.server_reward_has_fetch_reward_flag[32 - i + 1]
			if 1 == flag then
			    self.show_effect_list[i]:SetValue(false)
		        self.text_can_reward_time_list[i]:SetValue("")
		        self.has_get_list[i]:SetValue(true)
		    	self.reward_bg_effct_list[i]:SetValue(false)

		    else
			   	if vip_level < reward_cfg[i].vip_limit then
		        	self.show_effect_list[i]:SetValue(false)
		    		self.reward_bg_effct_list[i]:SetValue(false)
		    	else
		    		self.show_effect_list[i]:SetValue(true)
		    		self.reward_bg_effct_list[i]:SetValue(true)
		    	end
		        self.text_can_reward_time_list[i]:SetValue(Language.ZhuanZhuanLe.KeLingQu)
		    end
		end
	end
end

function ZhuangZhuangLeView:SetItemImage()
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local other_cfg = ZhuangZhuangLeData.Instance:GetOtherCfg()
	local cur_index = 0
	for i, v in pairs(other_cfg) do
		if open_time_day > v.opengame_day then
			cur_index = cur_index + 1
		else
			break
		end
	end
	for i = 1, 10 do
		self.item_list[i]:SetData(other_cfg[i + cur_index].reward_item)
	end

	local reward_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeAllRewardData()
	for i = 1, 6 do
		self.reward_item_list[i]:SetData(reward_cfg[i])
    end
end

function ZhuangZhuangLeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
end

function ZhuangZhuangLeView:CloseCallBack()
	self.click_reward = -1
	self.is_click_once = false
end

function ZhuangZhuangLeView:OnFlush()
	self:show_reward_pool()
	self:FlushNextTime()
	self:SetItemImage()
	self:ShowVipAndTime()
	if self.is_click_once and not self.play_ani_toggle.isOn then
	    self:TurnCell(self.play_ani_toggle.isOn)
	elseif self.click_reward > -1 then
		self:TurnCell(self.play_ani_toggle.isOn)
		local quick_use_time = 0
		TipsCtrl.Instance:ShowTreasureView(self.click_reward)
		if self.show_reward_panel then
			GlobalTimerQuest:CancelQuest(self.show_reward_panel)
			self.show_reward_panel = nil
		end
		if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
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

	self:FlushKeyShow()
end

function ZhuangZhuangLeView:FlushActEndTime()
	-- 活动倒计时
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
	self:FlushUpdataActEndTime()
	self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushUpdataActEndTime, self), 60)
end

function ZhuangZhuangLeView:FlushUpdataActEndTime()
	local time_str = ZhuangZhuangLeData.Instance:GetActEndTime()
	local time_tab = TimeUtil.Format2TableDHMS(time_str)
 	self.ShenYuTime:SetValue(string.format(Language.JingLing.RevengeDayStr2, time_tab.hour, time_tab.min, time_tab.s))
 	if time_str <= 0  then
 		-- 移除计时器
		if self.act_next_timer then
			GlobalTimerQuest:CancelQuest(self.act_next_timer)
			self.act_next_timer = nil
		end

 	end
end

function ZhuangZhuangLeView:GetFreeTimes()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu_other[1].free_time or 0
end

function ZhuangZhuangLeView:FlushNextTime()
	local cfg_time = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
    local uesd_times = ZhuangZhuangLeData:GetFreeTime()

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	-- 免费倒计时
	self:FlushCanNextTime()
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanNextTime, self), 1)
end

function ZhuangZhuangLeView:FlushCanNextTime()
	local time_str = ZhuangZhuangLeData.Instance:GetMianFeiTime()
	local cfg_time = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local next_free_time = cfg_time.money_tree_free_interval - time_str
	local time_tab = TimeUtil.Format2TableDHMS(next_free_time)
    local uesd_times = ZhuangZhuangLeData.Instance:GetFreeTime()
    local times = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_free_times
	self.hour:SetValue(time_tab.hour)
	self.min:SetValue(time_tab.min)
	self.sec:SetValue(time_tab.s)
 	if next_free_time <= 0  then
 		self.show_time:SetValue(false)
 		-- 移除计时器
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
        if uesd_times < times then
	        self.show_dimon:SetValue(false)
	        self.show_red_point:SetValue(true)
	        self.text_free_this_time:SetValue(true)
	        self.is_free = true
	    end
    else
    	self.show_red_point:SetValue(false)
    	self.is_free = false
    	self.show_dimon:SetValue(true)
    	self.text_free_this_time:SetValue(false)
    	if uesd_times < times then
	    	self.show_time:SetValue(true)
	    else
		    self.show_time:SetValue(false)
		    -- 移除计时器
			if self.next_timer then
				GlobalTimerQuest:CancelQuest(self.next_timer)
				self.next_timer = nil
			end
	    end
 	end
end

--10抽钥匙图标显示
function ZhuangZhuangLeView:FlushKeyShow()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_id = randact_cfg.other[1].money_tree_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	self.show_ten_chou:SetValue(item_num <= 0)
	self.show_ten_chou_key:SetValue(item_num > 0)
	self.ten_chou_text:SetValue(item_cfg.name..Language.Common.X..item_num)
end

function ZhuangZhuangLeView:TurnCell(not_show)
	if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD then
		return
	end

 	local other_cfg = ZhuangZhuangLeData.Instance:GetGridLotteryTreeRewardData()
	local reward_list = ZhuangZhuangLeData.Instance:GetRewardList()
	local quick_use_time = 0
	if is_rolling then return end
	self:ResetVariable()
	self:ResetHighLight()
	self.is_rolling = true
	local time = 0
	if not_show then
		local angle = POINTER_ANGLE_LIST[reward_list[1] % 10 + 1]
		self.center_point.transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ShowHightLight()
		self.is_rolling = false
	else
		local tween = self.center_point.transform:DORotate(
		Vector3(0, 0, -360 * 20),20,
		DG.Tweening.RotateMode.FastBeyond360)
		tween:SetEase(DG.Tweening.Ease.OutQuart)
		tween:OnUpdate(function ()
			time = time + UnityEngine.Time.deltaTime
			if time >= 1 then
				tween:Pause()
				local angle = POINTER_ANGLE_LIST[reward_list[1] % 10 + 1]
				local tween1 = self.center_point.transform:DORotate(
						Vector3(0, 0, -360 * 3 + angle),
						2,
						DG.Tweening.RotateMode.FastBeyond360)
				tween1:OnComplete(function ()
					self.is_rolling = false
					self:ShowHightLight()
					TipsCtrl.Instance:ShowTreasureView(self.click_reward)
					if self.show_reward_panel then
						GlobalTimerQuest:CancelQuest(self.show_reward_panel)
						self.show_reward_panel = nil
					end
					if self.click_reward == CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10 then
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
end

function ZhuangZhuangLeView:show_reward_pool()
	self.reward_pool_gold:SetValue(ZhuangZhuangLeData.Instance:GetServerMoneyTreePoolGold())
end

function ZhuangZhuangLeView:GetAwardButton(index)
	self.is_click_once = false
	self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_GET_REWARD
	local allTreeTime = ZhuangZhuangLeData.Instance:GetServerMoneyTreeTimes()
	self:GetLeijiReward(index)
end

function ZhuangZhuangLeView:ShowHightLight()
	local reward_list = ZhuangZhuangLeData.Instance:GetRewardList()
	local hight_light_index = reward_list[1] % 10 + 1
	self["show_hight_light_"..hight_light_index]:SetValue(true)
end

function ZhuangZhuangLeView:OnClickOnce()
	local ZhuanZhuanLeInfo =  ZhuangZhuangLeData.Instance:GetZhuanZhuanLeInfo()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold
	if self.is_rolling then
		return
	end
	if self.is_free then
		self.is_click_once = true
		ZhuangZhuangLeData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1
	    self:PointerTrunAround(1)
    else
    	local func = function()
			self.is_click_once = true
			ZhuangZhuangLeData.Instance:SetAniState(self.play_ani_toggle.isOn)
			self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_1
		    self:PointerTrunAround(1)
        end
        local tip_text = string.format(Language.ZhuanZhuanLe.TiShiOnce, need_diamon)
	    TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, true)
	end
end

--10抽
function ZhuangZhuangLeView:OnClickTence()
	local need_diamon = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_need_gold * 10
	if self.is_rolling then
		return
	end
	local func = function()
		self.is_click_once = true
		ZhuangZhuangLeData.Instance:SetAniState(self.play_ani_toggle.isOn)
		self.click_reward = CHEST_SHOP_MODE.CHEST_RANK_ZHUANZHUANLE_MODE_10
	    self:PointerTrunAround(10)
	end
	--发现有10抽的钥匙就不展示花费元宝提示面板
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_id = randact_cfg.other[1].money_tree_consume_item
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if item_num > 0 then
			func()
			return
		end

    local tip_text = string.format(Language.ZhuanZhuanLe.TiShiTence, need_diamon )
	TipsCtrl.Instance:ShowCommonAutoView("use_diamon", tip_text, func, nil, nil, nil, nil, nil, true, true)
end

function ZhuangZhuangLeView:close_button()
	if self.is_rolling then
		return
	end
    self:Close()
end

function ZhuangZhuangLeView:PointerTrunAround(index)
    if self.is_rolling then return end
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if bags_grid_num > 0 then
		if index == 1 then
        	self.show_red_point:SetValue(false)
		end
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_CHOU,index)
    else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function ZhuangZhuangLeView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function ZhuangZhuangLeView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function ZhuangZhuangLeView:ResetHighLight()
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
