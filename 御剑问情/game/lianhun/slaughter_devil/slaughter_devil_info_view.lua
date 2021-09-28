SlagughterDevilInfoView = SlagughterDevilInfoView or BaseClass(BaseView)

function SlagughterDevilInfoView:__init()
	self.ui_config = {"uis/views/lianhun_prefab", "DevilFBInFoView"}


	self.item_data = {}
	self.item_cells = {}
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function SlagughterDevilInfoView:LoadCallBack()
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.total_monster = self:FindVariable("NeedNum1")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.monster_name = self:FindVariable("Require1")
	self.monster_name_2 = self:FindVariable("Require2")
	self.total_monster_2 = self:FindVariable("NeedNum2")
	self.kill_monster_2 = self:FindVariable("HaveNum2")
	self.total_monster:SetValue(1)
	self.kill_monster:SetValue(0)
	self.total_monster_2:SetValue(10)
	self.kill_monster_2:SetValue(0)
	self.fb_name = self:FindVariable("FbName")
	self.total_value = self:FindVariable("TotalValue")
	self.cur_value = self:FindVariable("CurValue")
	self.cond_cap = self:FindVariable("CondCap")
	self.lbl_count_down = self:FindVariable("CountDown")
	self.next_star_num = self:FindVariable("NextStar")
	self.is_hide = self:FindVariable("IsHide")
	self.gray_star_list = {}
	for i = 1, 3 do
		self.gray_star_list[i] = self:FindVariable("GrayStar" .. i)
	end
	self.temp_time = 0
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function SlagughterDevilInfoView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self.is_first_open = nil
	self.is_open_finish = nil

end

function SlagughterDevilInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end

	-- 清理变量和对象
	self.total_monster = nil
	self.kill_monster = nil
	self.monster_name = nil
	self.fb_name = nil
	self.total_value = nil
	self.cur_value = nil
	self.show_panel = nil
	self.cond_cap = nil
	self.lbl_count_down = nil
	self.next_star_num = nil
	self.gray_star_list = nil
	self.is_hide = nil
	self.total_monster_2 = nil
	self.kill_monster_2 = nil
	self.monster_name_2 = nil
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function SlagughterDevilInfoView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	self.temp_time = 0
	self:SetStarCountDown()
	self:Flush()
end

function SlagughterDevilInfoView:CloseCallBack()
	self.temp_time = 0
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function SlagughterDevilInfoView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.ChallengeFB then
		MainUICtrl.Instance:SetViewState(false)
	end
end

function SlagughterDevilInfoView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if not next(fb_scene_info) then return end
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

	local fb_cfg = SlaughterDevilData.Instance:GetData(fb_scene_info.param2)
	fb_cfg = fb_cfg[fb_scene_info.param3]

	diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()

	if fb_scene_info.is_pass == 1 and fb_cfg.star > 0 then
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
				local item_data_list = SlaughterDevilData.Instance:GetResultData()
				if item_data_list then
					item_data_list = item_data_list.reward_item_list
				else
					item_data_list = {}
				end
				local right_list = {}
				for k,v in pairs(item_data_list) do
					if v.item_id ~= 0 then
						table.insert(right_list, v)
					end
				end
				local fb_cfg = SlaughterDevilData.Instance:GetData(fb_scene_info.param2)
				local ok_callback = function ()
					SlaughterDevilCtrl.Instance:SendEnterFb(fb_scene_info.param2, fb_scene_info.param3 + 1, true)
				end
				TipsCtrl.Instance:TipsStarNextView(ok_callback)
				fb_cfg = fb_cfg[fb_scene_info.param3]
				local is_show_next = true
				if fb_scene_info.param3 + 1 > SlaughterDevilData.Instance:GetMaxLevel() then
					is_show_next = false
				end
				ViewManager.Instance:Open(ViewName.FuBenFinishStarNextView, nil, "finish",
				 {data = right_list, pass_time = fb_scene_info.pass_time_s, star = self.cur_star,show_next = false, show_star = true, cancle_text = Language.Common.Confirm})
			end
			TimeScaleService.StartTimeScale(call_back)
		end
		self.is_open_finish = true
	end

	if self.count_down == nil then
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
end

function SlagughterDevilInfoView:SetStarCountDown()
	local fb_scene_info = SlaughterDevilData.Instance:GetFBSceneLogicInfo()
	if fb_scene_info == nil then return end
	local star_info = SlaughterDevilData.Instance:StarCfgInfo(fb_scene_info.param2, fb_scene_info.param3)
	-- for i = 1, 3 do
	-- 	self.gray_star_list[i]:SetValue(false)
	-- end
	self.cur_star = 0
	self.total_time = 0
	for i = 3, 1, -1 do
		if fb_scene_info.pass_time_s <= star_info[i] then
			self.cur_star = i
			self.total_time = star_info[i] - fb_scene_info.pass_time_s
			self.temp_time = self.total_time
			break
		end
	end
	local function diff_time_fun(elapse_time, total_time)
		self.is_hide:SetValue(self.cur_star <= 0)
		if self.cur_star <= 0 then return end
		local left_time = math.floor(self.total_time - elapse_time + 0.5)
		self.lbl_count_down:SetValue(TimeUtil.FormatSecond(left_time, 2))
		self.next_star_num:SetValue(self.cur_star - 1)
		if self.cur_star > 0 then
			-- for i = 1, self.cur_star do
			-- 	self.gray_star_list[i]:SetValue(true)
			-- end
			for i = 1, 3 do
				self.gray_star_list[i]:SetValue(self.cur_star >= i)
			end
		end
		if left_time <= 0 then
			if nil ~= self.star_count_down then
				CountDown.Instance:RemoveCountDown(self.star_count_down)
				self.star_count_down = nil
			end
			self.cur_star = self.cur_star - 1
			self.is_hide:SetValue(self.cur_star <= 0)
			-- for i = 1, 3 do
			-- 	self.gray_star_list[i]:SetValue(false)
			-- end
			if self.cur_star <= 0 then return end
			self.total_time = star_info[self.cur_star] - star_info[self.cur_star + 1]
			-- diff_time_fun(0, self.total_time)
			self.star_count_down = CountDown.Instance:AddCountDown(self.total_time, 0.5, diff_time_fun)
		end
	end
	if self.star_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.star_count_down)
		self.star_count_down = nil
	end
	self.star_count_down = CountDown.Instance:AddCountDown(self.total_time, 0.5, diff_time_fun)
end

function SlagughterDevilInfoView:SetQualityFBSceneData()
	local fb_scene_info = SlaughterDevilData.Instance:GetFBSceneLogicInfo()
	if fb_scene_info == nil then return end
	local fb_cfg = SlaughterDevilData.Instance:GetData(fb_scene_info.param2)
	fb_cfg = fb_cfg[fb_scene_info.param3]
	local fb_info = SlaughterDevilData.Instance:GetViewData()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	local total_layer = 10

	self.fb_name:SetValue(fb_cfg.Checkpoint_name)
	self.total_value:SetValue(total_layer)
	self.cur_value:SetValue(fb_info.pass_level + 1)
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local str_fight_power = fb_cfg.capability
	if capability < fb_cfg.capability then
		str_fight_power = fb_cfg.capability
	end
	self.cond_cap:SetValue(str_fight_power)
	self.monster_name:SetValue(monster_cfg[fb_cfg.monster_0].name)
	self.monster_name_2:SetValue(monster_cfg[fb_cfg.monster_1].name)


	self.kill_monster:SetValue(fb_scene_info.kill_boss_num)
	self.kill_monster_2:SetValue(fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num)
	if fb_cfg.is_pass_chapter == 1 then
		if self.star_count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.star_count_down)
			self.star_count_down = nil
		end
	end

end

function SlagughterDevilInfoView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function SlagughterDevilInfoView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.SCENE_TYPE_TUITU_FB then
		MainUICtrl.Instance:SetViewState(false)
		self:SetQualityFBSceneData()
		self:SetCountDown()
		for k, v in pairs(param_t) do
			if k == "star_info" then
				self:SetStarCountDown()
			end
		end
	end
end