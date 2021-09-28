FuBenInfoPhaseView = FuBenInfoPhaseView or BaseClass(BaseView)

function FuBenInfoPhaseView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "PhaseFBInFoView"}

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

function FuBenInfoPhaseView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.total_boss = self:FindVariable("NeedNum2")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.kill_boss = self:FindVariable("HaveNum2")
	self.monster_name = self:FindVariable("Require1")
	self.boss_name = self:FindVariable("Require2")
	self.tongguan_des = self:FindVariable("TongGuanDes")
	-- self.show_help_tip = self:FindVariable("ShowHelpTip")

	-- self:ListenEvent("OnClickExit",
		-- BindTool.Bind(self.OnClickExit, self))
	-- self:ListenEvent("OnClicExplain",
	-- 	BindTool.Bind(self.OnClicExplain, self))
	-- self:ListenEvent("CloseHelpTip",
	-- 	BindTool.Bind(self.CloseHelpTip, self))


	for i = 1, 3 do
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	-- self.drop_item = ItemCell.New(self:FindObj("DropItem"))
	self.show_panel = self:FindVariable("ShowPanel")
	-- self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function FuBenInfoPhaseView:__delete()
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

function FuBenInfoPhaseView:ReleaseCallBack()
	-- if self.show_mode_list_event ~= nil then
	-- 	GlobalEventSystem:UnBind(self.show_mode_list_event)
	-- 	self.show_mode_list_event = nil
	-- end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}

	-- 清理变量和对象
	self.fb_name = nil
	self.total_monster = nil
	self.total_boss = nil
	self.kill_monster = nil
	self.kill_boss = nil
	self.monster_name = nil
	self.boss_name = nil
	self.tongguan_des = nil
	self.show_panel = nil
end

-- function FuBenInfoPhaseView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function FuBenInfoPhaseView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.PhaseFb then
		print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
		FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	end
end

-- function FuBenInfoPhaseView:OnClickExit()
-- 	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
-- 	local diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
-- 	if diff_time >= 0 and fb_scene_info.is_pass == 0 then
-- 		local func = function()
-- 			FuBenCtrl.Instance:SendExitFBReq()
-- 		end
-- 		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.FB.WarmText, nil, nil, false)
-- 		return
-- 	end
-- 	FuBenCtrl.Instance:SendExitFBReq()
-- 	print("点击退出按钮 FuBenInfoPhaseView")
-- end

-- 玩法说明
-- function FuBenInfoPhaseView:OnClicExplain()
-- 	self.show_help_tip:SetValue(true)
-- end

-- function FuBenInfoPhaseView:CloseHelpTip()
-- 	self.show_help_tip:SetValue(false)
-- end

function FuBenInfoPhaseView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoPhaseView:CloseCallBack()
	-- FuBenData.Instance:ClearPhaseFBInfo()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function FuBenInfoPhaseView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp

	if nil == fb_scene_info or nil == next(fb_scene_info) then return end

	local diff_time = nil
	if role_hp <= 0 and fb_scene_info.is_finish == 1 then
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
	if fb_scene_info.is_pass == 1 then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		diff_time = 10
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			local call_back = function ()
				if not self.upgrade_timer_quest then
					self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
						ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
					end, 2)
				end
			end
			TimeScaleService.StartTimeScale(call_back)
		end
		self.is_open_finish = true
	else
		diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	end
	if self.count_down == nil then
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if fb_scene_info.is_pass == 0 then
					if not self.is_open_finish then
						if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
							ViewManager.Instance:Close(ViewName.CommonTips)
						end
						GlobalTimerQuest:AddDelayTimer(function()
							ViewManager.Instance:Open(ViewName.FBFailFinishView)
						end, 2)
					end
					self.is_open_finish = true
				else
					-- FuBenCtrl.Instance:SendExitFBReq()
				end
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function FuBenInfoPhaseView:SetPhaseFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local phase_fb_info = FuBenData.Instance:GetPhaseFBInfo()
	local index = UnityEngine.PlayerPrefs.GetInt("phaseindex")
	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(index)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	MainUICtrl.Instance:SetViewState(false)

	self.fb_name:SetValue(Scene.Instance:GetSceneName())
	if monster_cfg[fuben_cfg.monster_id1].type == 0 then
		self.monster_name:SetValue(monster_cfg[fuben_cfg.monster_id1].name)
		self.boss_name:SetValue(monster_cfg[fuben_cfg.monster_id2].name)
	else
		self.monster_name:SetValue(monster_cfg[fuben_cfg.monster_id2].name)
		self.boss_name:SetValue(monster_cfg[fuben_cfg.monster_id1].name)
	end

	-- self.drop_item:SetData(fuben_cfg.drop_show[0])

	if phase_fb_info and next(phase_fb_info) then
		local reward = (phase_fb_info[index].is_pass == 0) and fuben_cfg.first_reward or fuben_cfg.normal_reward
		self.tongguan_des:SetValue((phase_fb_info[index].is_pass == 0) and Language.FB.FirstReward or Language.FB.NormalReward)
		if self.is_first_open then
			local is_set_exp = false
			for k, v in pairs(self.rewards) do
				if reward[k - 1] then
					v:SetData(reward[k - 1])
					self.item_data[k] = reward[k - 1]
					v:SetActive(true)
				else
					v:SetActive(false)
					if not is_set_exp then
						local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg.reward_exp}
						v:SetData(data)
						self.item_data[k] = data
						is_set_exp = true
						v:SetActive(true)
					end
				end
			end
		end
		self.is_first_open = false
	end
	if fb_scene_info and next(fb_scene_info) then
		self.total_monster:SetValue(fb_scene_info.total_allmonster_num - fb_scene_info.total_boss_num)
		self.total_boss:SetValue(fb_scene_info.total_boss_num)
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num)
		self.kill_boss:SetValue(fb_scene_info.kill_boss_num)
	end
end

function FuBenInfoPhaseView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function FuBenInfoPhaseView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.PhaseFb and self:IsOpen() then
		self:SetPhaseFBSceneData()
		self:SetCountDown()
	end
end