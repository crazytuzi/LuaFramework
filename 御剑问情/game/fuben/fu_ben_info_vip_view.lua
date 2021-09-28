FuBenInfoVipView = FuBenInfoVipView or BaseClass(BaseView)

function FuBenInfoVipView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "VipFBInFoView"}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.item_cells = {}
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function FuBenInfoVipView:LoadCallBack()
	self.total_monster = self:FindVariable("NeedNum1")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.monster_name = self:FindVariable("Require1")
	self.vip_level = self:FindVariable("VIPLevel")

	-- self:ListenEvent("OnClickExit",
	-- 	BindTool.Bind(self.OnClickExit, self))
	-- self:ListenEvent("OnClicExplain",
	-- 	BindTool.Bind(self.OnClicExplain, self))

	-- self.task_animator = self:FindObj("TaskAnimator").animator
	-- self.shrink_btn = self:FindObj("ShrinkAnimator")

	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	self.show_panel = self:FindVariable("ShowPanel")
	-- self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function FuBenInfoVipView:__delete()
	self.item_data = {}
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

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

function FuBenInfoVipView:ReleaseCallBack()
	-- if self.show_mode_list_event ~= nil then
	-- 	GlobalEventSystem:UnBind(self.show_mode_list_event)
	-- 	self.show_mode_list_event = nil
	-- end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.total_monster = nil
	self.kill_monster = nil
	self.monster_name = nil
	self.vip_level = nil
	self.show_panel = nil
end

-- function FuBenInfoVipView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function FuBenInfoVipView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoVipView:CloseCallBack()
	FuBenData.Instance:ClearVipFBInfo()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function FuBenInfoVipView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.VipFB then
		print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
		FuBenCtrl.Instance:SendGetVipFBGetInfo()
	end
end

-- function FuBenInfoVipView:OnClickExit()
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
-- 	print("点击退出按钮 FuBenInfoVipView")
-- end

-- 玩法说明
-- function FuBenInfoVipView:OnClicExplain()
-- 	print("点击玩法说明")
-- end

function FuBenInfoVipView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	if nil == fb_scene_info then return end

	local diff_time = nil
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
					FuBenCtrl.Instance:SendExitFBReq()
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

function FuBenInfoVipView:SetVipFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local vip_fb_info = FuBenData.Instance:GetVipFBInfo()
	local fuben_cfg = FuBenData.Instance:GetVipFBLevelCfg()
	local index = UnityEngine.PlayerPrefs.GetInt("vipindex") + 1
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	MainUICtrl.Instance:SetViewState(false)

	self.vip_level:SetValue(fuben_cfg[index].enter_level)
	self.monster_name:SetValue(monster_cfg[fuben_cfg[index].boss_id].name)
	if self.is_first_open then
		for k, v in pairs(self.item_cells) do
			v:SetActive(nil ~= fuben_cfg[index].reward_item[k - 1])
			if fuben_cfg[index].reward_item[k - 1] then
				v:SetData(fuben_cfg[index].reward_item[k - 1])
				self.item_data[k] = fuben_cfg[index].reward_item[k - 1]
			end
		end
	end
	self.is_first_open = false
	if fb_scene_info and next(fb_scene_info) then
		self.total_monster:SetValue(fb_scene_info.total_boss_num or 0)
		self.kill_monster:SetValue(fb_scene_info.kill_boss_num or 0)
	end
end

function FuBenInfoVipView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
	-- if self.task_animator and self:IsOpen() then
	-- 	self.task_animator:SetBool("fold", not enable)
	-- 	self.shrink_btn.toggle.isOn = not enable
	-- end
end

function FuBenInfoVipView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.VipFB then
		self:SetVipFBSceneData()
		self:SetCountDown()
	end
end