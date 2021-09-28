FuBenInfoPushView = FuBenInfoPushView or BaseClass(BaseView)

function FuBenInfoPushView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "PushFbInfoView"}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.item_data = {}
	self.fail_data = {}
	self.rewards = {}
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function FuBenInfoPushView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.total_boss = self:FindVariable("NeedNum2")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.kill_boss = self:FindVariable("HaveNum2")
	self.monster_name = self:FindVariable("Require1")
	self.boss_name = self:FindVariable("Require2")
	-- self.cur_star = self:FindVariable("CurStar")
	self.cond_cap = self:FindVariable("CondCap")
	self.is_boss = self:FindVariable("IsBoss")
	self.lbl_count_down = self:FindVariable("CountDown")
	self.next_star_num = self:FindVariable("NextStar")
	self.tongguan_des = self:FindVariable("RewardDesc")
	self.type_name = self:FindVariable("TypeName")
	self.last_star = self:FindVariable("LastStar")
	self.gray_star_list = {}
	for i = 1, 3 do
		self.gray_star_list[i] = self:FindVariable("GrayStar" .. i)
	end

	self.item_cells = {}
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self.show_panel = self:FindVariable("ShowPanel")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function FuBenInfoPushView:__delete()
	self.item_data = {}
	self.fail_data = {}
	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self.is_first_open = nil
	self.is_open_finish = nil

	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function FuBenInfoPushView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.star_count ~= nil then
		GlobalTimerQuest:CancelQuest(self.star_count)
		self.star_count = nil
	end

	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.fb_name = nil
	self.total_monster = nil
	self.total_boss = nil
	self.kill_monster = nil
	self.kill_boss = nil
	self.monster_name = nil
	self.boss_name = nil
	self.tongguan_des = nil
	self.type_name = nil
	self.last_star = nil
	self.show_panel = nil
	-- self.cur_star = nil
	self.cond_cap = nil
	self.is_boss = nil
	self.gray_star_list = nil
	self.lbl_count_down = nil
	self.next_star_num = nil
end

function FuBenInfoPushView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.SCENE_TYPE_TUITU_FB then
		self.is_first_open = true
	end
end

function FuBenInfoPushView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	self.star_info_cfg = FuBenData.Instance:StarCfgInfo(fb_scene_info.param1, fb_scene_info.param2, fb_scene_info.param3)
	self:Flush()
end

function FuBenInfoPushView:AddTime()
	if self.total_use_time == nil or self.total_use_time < 0 then return end
	local cur_star_num = 0
	self.total_use_time = self.total_use_time + 1
	if self.total_use_time < self.star_info_cfg[3] then
		cur_star_num = 3
	elseif self.total_use_time < self.star_info_cfg[2] then
		cur_star_num = 2
	elseif self.total_use_time < self.star_info_cfg[1] then
		cur_star_num = 1
	end
	for i = 1, cur_star_num do
		self.gray_star_list[i]:SetValue(true)
	end
	for i = cur_star_num + 1, 3 do
		self.gray_star_list[i]:SetValue(false)
	end
	self.next_star_num:SetValue(cur_star_num - 1)
	if cur_star_num > 0 then
		self.lbl_count_down:SetValue(TimeUtil.FormatSecond(self.star_info_cfg[cur_star_num] - self.total_use_time, 2))
	else
		self.lbl_count_down:SetValue("00:00")
	end
	self.last_star:SetValue(cur_star_num <= 1)
end

function FuBenInfoPushView:CloseCallBack()
	FuBenData.Instance:ClearFBSceneLogicInfo()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.timer_countdown ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_countdown)
		self.timer_countdown = nil
	end
	if self.star_count ~= nil then
		GlobalTimerQuest:CancelQuest(self.star_count)
		self.star_count = nil
	end
end

function FuBenInfoPushView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info then return end
	local fb_info = FuBenData.Instance:GetTuituFbResultInfo()
	local max_level = FuBenData.Instance:GetMaxLevelByTypeAndChapter(fb_scene_info.param1, fb_scene_info.param2)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local diff_time = 0
	if not next(fb_info) then return end
	if fb_info.star < 1 and fb_scene_info.is_pass == 0 and fb_scene_info.is_finish == 1 then -- role_hp <= 0 and
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
	if next(fb_info) and (fb_scene_info.param3 + 1 <= max_level) and fb_scene_info.is_pass == 1 and fb_info.star >= 1 and fb_scene_info.is_finish == 1 then
		local fuben_next_cfg = FuBenData.Instance:GetPushFBInfo(fb_scene_info.param1, fb_scene_info.param2, fb_scene_info.param3 + 1)
		local next_chapter = fb_scene_info.param2
		local next_level = fb_scene_info.param3 + 1
		if fb_scene_info.param3 >= 3 and fb_scene_info.param1 == 1 then
			fuben_next_cfg = FuBenData.Instance:GetPushFBInfo(fb_scene_info.param1, fb_scene_info.param2 + 1, 0)
			next_chapter = fb_scene_info.param2 + 1
			next_level = 0
		end
		local next_is_pass = FuBenData.Instance:GetOneLevelIsPass(fb_scene_info.param1, next_chapter, next_level)
		local request = false
		if fb_scene_info.param1 == 1 then
			request = FuBenData.Instance:GetOneLevelIsPass(fuben_next_cfg.need_pass_fb_type, fuben_next_cfg.need_pass_chapter, fuben_next_cfg.need_pass_level)
		end
		local have_enter_times = FuBenData.Instance:GetCanEnterPushFB(fb_scene_info.param1)
		if self.upgrade_timer_quest then
			GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
			self.upgrade_timer_quest = nil
		end
		if ViewManager.Instance:IsOpen(ViewName.FuBenPushInfoView) then
			diff_time = 15
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end

			local func = function ()
				FuBenCtrl.Instance:SendEnterNextFBReq()
			end

			if not self.is_first_open and (have_enter_times or not next_is_pass) and (fb_scene_info.param1 == 0 and role_level >= fuben_next_cfg.enter_level_limit) or
				(fb_scene_info.param1 == 1 and fb_info.star >= 3 and request) then
				local call_back = function ()
					TipsCtrl.Instance:TipsStarNextView(func)
					self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						ViewManager.Instance:Open(ViewName.FuBenFinishStarNextView, nil, "finish", {data = fb_info.reward_item_list, pass_time = fb_scene_info.pass_time_s, star = fb_info.star})
					end, 2)
				end
				TimeScaleService.StartTimeScale(call_back)
			elseif not self.is_first_open then
				local call_back = function ()
					self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "finish", {data = fb_info.reward_item_list, pass_time = fb_scene_info.pass_time_s, star = fb_info.star})
					end, 2)
				end
				TimeScaleService.StartTimeScale(call_back)
			else
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end
		else
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
		end
		self.is_open_finish = true
	elseif fb_info.star and fb_info.star > 0 and (fb_scene_info.param3 + 1 > max_level) and fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 1 then
		diff_time = 15
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_first_open then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			local call_back = function ()
				self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
					ViewManager.Instance:Open(ViewName.FBFinishStarView, nil, "finish", {data = fb_info.reward_item_list, pass_time = fb_scene_info.pass_time_s, star = fb_info.star})
				end, 2)
			end
			TimeScaleService.StartTimeScale(call_back)
		end
		self.is_open_finish = true
	end
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if fb_scene_info.time_out_stamp ~= 0 then
		local function diff_time_fun(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 and fb_scene_info.is_finish == 1 then
					if not self.is_open_finish then
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
					self.is_open_finish = true
				elseif fb_scene_info.is_finish == 1 then
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

	if next(fb_info) then
		self.is_first_open = false
	end
end

function FuBenInfoPushView:SetPhaseFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if fb_scene_info == nil then return end
	self.total_use_time = fb_scene_info.pass_time_s
	if self.star_count ~= nil then
		GlobalTimerQuest:CancelQuest(self.star_count)
		self.star_count = nil
	end
	self:AddTime()
	self.star_count = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.AddTime, self), 1)

	local fuben_cfg = FuBenData.Instance:GetPushFBInfo(fb_scene_info.param1, fb_scene_info.param2, fb_scene_info.param3)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	MainUICtrl.Instance:SetViewState(false)

	self.fb_name:SetValue(fuben_cfg.fb_name)

	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local str_fight_power = fuben_cfg.capability
	if capability < fuben_cfg.capability then
		str_fight_power = fuben_cfg.capability
	end
	self.cond_cap:SetValue(str_fight_power)

	local history_star = FuBenData.Instance:GetPushFBLeveLInfo(fb_scene_info.param1, fb_scene_info.param2, fb_scene_info.param3).pass_star
	self.tongguan_des:SetValue(history_star <= 0 and Language.FB.FirstPassReward or Language.FB.RewardShow)
	self.type_name:SetValue(fb_scene_info.param1 > 0 and Language.FuBen.PushBossName or Language.FuBen.PushCommonName)
	local reward_cfg = history_star <= 0 and fuben_cfg.first_pass_reward or fuben_cfg.normal_reward_item
	self.item_data = {}
	for k, v in pairs(self.item_cells) do
		v:SetActive(false)
		if reward_cfg[k - 1] and reward_cfg[k - 1].item_id > 0 then
			v:SetActive(true)
			v:SetData(reward_cfg[k - 1])
			self.item_data[k] = reward_cfg[k - 1]
		end
	end

	self.is_first_open = false

	-- if fb_scene_info and next(fb_scene_info) then
	-- 	if fb_scene_info.param1 == 0 then
	-- 		self.is_boss:SetValue(false)
	-- 		if monster_cfg[fuben_cfg.monster_0].type == 0 then
	-- 			self.monster_name:SetValue(monster_cfg[fuben_cfg.monster_0].name)
	-- 			self.boss_name:SetValue(monster_cfg[fuben_cfg.monster_1].name)
	-- 		else
	-- 			self.monster_name:SetValue(monster_cfg[fuben_cfg.monster_1].name)
	-- 			self.boss_name:SetValue(monster_cfg[fuben_cfg.monster_0].name)
	-- 		end
	-- 		self.total_monster:SetValue(fb_scene_info.total_allmonster_num - fb_scene_info.total_boss_num)
	-- 		self.total_boss:SetValue(fb_scene_info.total_boss_num)
	-- 		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num)
	-- 		self.kill_boss:SetValue(fb_scene_info.kill_boss_num)
	-- 	else
	-- 		self.is_boss:SetValue(true)
	-- 		self.total_monster:SetValue(fb_scene_info.total_boss_num)
	-- 		self.kill_monster:SetValue(fb_scene_info.kill_boss_num)
	-- 		self.monster_name:SetValue(monster_cfg[fuben_cfg.monster_0].name)
	-- 	end
	-- end
end

function FuBenInfoPushView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function FuBenInfoPushView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.SCENE_TYPE_TUITU_FB and self:IsOpen() then
		self:SetPhaseFBSceneData()
		self:SetCountDown()
	end
end