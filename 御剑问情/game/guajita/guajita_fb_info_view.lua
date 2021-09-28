GuajiTaFbInfoView = GuajiTaFbInfoView or BaseClass(BaseView)

function GuajiTaFbInfoView:__init()
	self.ui_config = {"uis/views/guajitaview_prefab", "GuajiTaFbInfoView"}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.item_cells = {}
	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function GuajiTaFbInfoView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.monster_name = self:FindVariable("Require1")
	self.tongguan_des = self:FindVariable("TongGuanDes")
	self.fight_power = self:FindVariable("FightPower")

	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self.show_panel = self:FindVariable("ShowPanel")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self.set_flag = false		--当前关卡信息（名称、推荐战力等）是否已初始化
end

function GuajiTaFbInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	self:RemoveDelayTime()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.fb_name = nil
	self.total_monster = nil
	self.kill_monster = nil
	self.monster_name = nil
	self.tongguan_des = nil
	self.fight_power = nil
	self.show_panel = nil
	self.upgrade_timer_quest = nil
end

function GuajiTaFbInfoView:__delete()
	self.item_data = nil
	self.fail_data = nil
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = nil
	self.is_open_finish = nil

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function GuajiTaFbInfoView:OpenCallBack()
	MainUICtrl.Instance.view:SetViewState(false)
	self.is_open_finish = false
	self:Flush()
end

function GuajiTaFbInfoView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.temp_level = nil
end

function GuajiTaFbInfoView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		-- FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		self.is_first_open = true
	end
	self.set_flag = false
end

function GuajiTaFbInfoView:RemoveDelayTime()
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function GuajiTaFbInfoView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info or not next(fb_scene_info) then return end
	local fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	local diff_time = 0
	if fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 0 then -- role_hp <= 0 and
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBFailFinishView)
			end, 2)
		end
		self.is_open_finish = true
		return
	end
	diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	if fb_info.fb_today_layer and fb_scene_info.is_finish == 1 and ((fb_info.fb_today_layer + 1) <= GuaJiTaData.Instance:GetRuneMaxLayer()) and fb_scene_info.is_pass == 1 then
		if ViewManager.Instance:IsOpen(ViewName.RuneTowerFbInfoView) then
			diff_time = 15
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end

			local no_func = function ()
				FuBenCtrl.Instance:SendExitFBReq()
			end
			local func = function ()
				-- FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_GUAJI_TA)
				FuBenCtrl.Instance:SendEnterNextFBReq()
			end

			if not self.is_first_open then
				local call_back = function ()
					if self.upgrade_timer_quest == nil then
						self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
							local special_level_cfg = GuaJiTaData.Instance:GetSpecialRewardCfg(fb_info.fb_today_layer)
							if fb_info.pass_layer <= fb_info.fb_today_layer and special_level_cfg then
								GuaJiTaCtrl.Instance:OpenRuneTowerUnlockView(special_level_cfg)
							else
								TipsCtrl.Instance:TipsPaTaRewardView(no_func, func, self.item_data)
							end
							self:RemoveDelayTime()
						end, 1)
					end
				end
				TimeScaleService.StartTimeScale(call_back)
			else
				diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end
		else
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
		end
	elseif fb_info.fb_today_layer and (fb_info.fb_today_layer + 1) > GuaJiTaData.Instance:GetRuneMaxLayer() then
		diff_time = 15
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			local call_back = function ()
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
			end
			TimeScaleService.StartTimeScale(call_back)
		end
		self.is_open_finish = true
	end
	if self.count_down == nil and fb_scene_info.time_out_stamp ~= 0 then
		local function diff_time_fun(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 then
					if not self.is_open_finish then
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
					self.is_open_finish = true
				else
					FuBenCtrl.Instance:SendExitFBReq()
				end
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
		end

		diff_time_fun(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_fun)
	end

	if next(fb_info) and fb_scene_info.is_finish then
		self.is_first_open = false
	end
end

function GuajiTaFbInfoView:SetTowerFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local tower_fb_info = GuaJiTaData.Instance:GetRuneTowerInfo()
	local fuben_cfg = GuaJiTaData.Instance:GetRuneTowerFBLevelCfg()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	if fb_scene_info.is_finish == 1 then
		if self.is_first_open then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			FuBenCtrl.Instance:SendEnterNextFBReq()
		end
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num)
	end

	if tower_fb_info and next(tower_fb_info) and fb_scene_info and next(fb_scene_info) then

		local max_tower_layer = fuben_cfg[#fuben_cfg].fb_layer
		local temp_td_level = tower_fb_info.fb_today_layer
		if temp_td_level ~= max_tower_layer then
			temp_td_level = temp_td_level + 1
		end

        local flag = false
        if  self.set_flag == false then
        	flag = true
        	self.set_flag = true
        end
		local temp_level_str = ""
		for s in string.gmatch(temp_td_level, "%d") do
			temp_level_str = temp_level_str..s
		end
		local name_str = string.format(Language.FB.CurLevel, temp_level_str)

        if flag then
        	self.fb_name:SetValue(name_str)
        end

		local capability = GameVoManager.Instance:GetMainRoleVo().capability
		local str_fight_power = string.format(Language.Mount.ShowGreenStr1, fuben_cfg[temp_td_level].capability)
		if capability < fuben_cfg[temp_td_level].capability then
			str_fight_power = string.format(Language.Mount.ShowRedStr, fuben_cfg[temp_td_level].capability)
		end

        if flag then
        	self.fight_power:SetValue(str_fight_power)
        end

        if flag then
        	self.monster_name:SetValue(monster_cfg[fuben_cfg[temp_td_level].monster_id].name)
        end

		if self.temp_change_level and self.temp_change_level ~= tower_fb_info.fb_today_layer then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end

		self.total_monster:SetValue(fb_scene_info.total_allmonster_num or 0)
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num or 0)
		self.tongguan_des:SetValue(fb_scene_info.param1 > 0 and Language.FB.FirstReward or Language.FB.NormalReward)
		local reward_cfg = fb_scene_info.param1 > 0 and fuben_cfg[temp_td_level].first_reward_item
							or fuben_cfg[temp_td_level].normal_reward_item
		local reward_count = 0
		self.item_data = {}
		for k, v in pairs(self.item_cells) do
			v:SetActive(false)
			if reward_cfg[k - 1] and reward_cfg[k - 1].item_id > 0 then
				reward_count = reward_count + 1
				v:SetActive(true)
				v:SetData(reward_cfg[k - 1])
				self.item_data[k] = reward_cfg[k - 1]
			end
		end
		if self.item_cells[reward_count + 1] then
			local exp_num = fb_scene_info.param1 > 0 and fuben_cfg[temp_td_level].first_reward_rune_exp or fuben_cfg[temp_td_level].normal_reward_rune_exp
			local data = {item_id = ResPath.CurrencyToIconId.rune_jinghua, num = exp_num}
			self.item_cells[reward_count + 1]:SetActive(true)
			self.item_cells[reward_count + 1]:SetData(data)
			self.item_data[reward_count + 1] = data
		end
		self.temp_change_level = tower_fb_info.fb_today_layer
	end
end

function GuajiTaFbInfoView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function GuajiTaFbInfoView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		self:SetTowerFBSceneData()
		self:SetCountDown()
	end
end