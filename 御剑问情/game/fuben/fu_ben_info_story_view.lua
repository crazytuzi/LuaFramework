FuBenInfoStoryView = FuBenInfoStoryView or BaseClass(BaseView)

function FuBenInfoStoryView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "StoryFBInFoView"}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.fail_data = {}
	self.item_cells = {}
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function FuBenInfoStoryView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.total_boss = self:FindVariable("NeedNum2")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.kill_boss = self:FindVariable("HaveNum2")
	self.monster_name = self:FindVariable("Require1")
	self.boss_name = self:FindVariable("Require2")
	self.tongguan_des = self:FindVariable("TongGuanDes")

	for i = 1, 3 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		self.item_cells[i] = {obj = item_cell, is_show = self:FindVariable("ShowItem"..i)}
	end

	self.drop_item = ItemCell.New()
	self.drop_item:SetInstanceParent(self:FindObj("DropItem"))

	self:ListenEvent("OnClickExit",
		BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClicExplain",
		BindTool.Bind(self.OnClicExplain, self))

	self.task_animator = self:FindObj("TaskAnimator").animator
	self.shrink_btn = self:FindObj("ShrinkAnimator")

	self.show_panel = self:FindVariable("ShowPanel")
	-- self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()
end

function FuBenInfoStoryView:__delete()
	self.item_data = nil
	self.fail_data = nil
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	for k, v in pairs(self.item_cells) do
		if v.obj then
			v.obj:DeleteMe()
		end
	end
	self.item_cells = {}
	self.is_first_open = nil
	self.is_open_finish = nil

	if self.drop_item then
		self.drop_item:DeleteMe()
		self.drop_item = nil
	end

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	if self.main_view_complete ~= nil then
		GlobalEventSystem:UnBind(self.main_view_complete)
		self.main_view_complete = nil
	end
end

function FuBenInfoStoryView:ReleaseCallBack()
	-- if self.show_mode_list_event ~= nil then
	-- 	GlobalEventSystem:UnBind(self.show_mode_list_event)
	-- 	self.show_mode_list_event = nil
	-- end
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

-- function FuBenInfoStoryView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function FuBenInfoStoryView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.StoryFB then
		print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
		FuBenCtrl.Instance:SendGetStoryFBGetInfo()
	end
end

function FuBenInfoStoryView:OnClickExit()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	if diff_time >= 0 and fb_scene_info.is_pass == 0 then
		local func = function()
			FuBenCtrl.Instance:SendExitFBReq()
		end
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.FB.WarmText, nil, nil, false)
		return
	end
	FuBenCtrl.Instance:SendExitFBReq()
end

-- 玩法说明
function FuBenInfoStoryView:OnClicExplain()
	print("点击玩法说明")
end

function FuBenInfoStoryView:OpenCallBack()
	self.is_first_open = true
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoStoryView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function FuBenInfoStoryView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	if nil == fb_scene_info then return end
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
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
		diff_time = 10
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
	else
		diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
	end
	if self.count_down == nil then
		local function diff_time_func(elapse_time, total_time)
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

function FuBenInfoStoryView:SetStoryFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local story_fb_info = FuBenData.Instance:GetStoryFBInfo()
	local fuben_cfg = FuBenData.Instance:GetStoryFBLevelCfg()
	local index = UnityEngine.PlayerPrefs.GetInt("storyindex")
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	MainUICtrl.Instance:SetViewState(false)

	self.fb_name:SetValue(Scene.Instance:GetSceneName())
	if fuben_cfg[index] then
		if monster_cfg[fuben_cfg[index].monster_id1].type == 0 then
			self.monster_name:SetValue(monster_cfg[fuben_cfg[index].monster_id1].name)
			self.boss_name:SetValue(monster_cfg[fuben_cfg[index].monster_id2].name)
		else
			self.monster_name:SetValue(monster_cfg[fuben_cfg[index].monster_id2].name)
			self.boss_name:SetValue(monster_cfg[fuben_cfg[index].monster_id1].name)
		end
	end

	if story_fb_info and next(story_fb_info) then
		local reward_cfg = story_fb_info[index].is_pass == 0 and fuben_cfg[index].first_reward or fuben_cfg[index].normal_reward
		self.tongguan_des:SetValue(story_fb_info[index].is_pass == 0 and Language.FB.FirstReward or Language.FB.NormalReward)
		if self.is_first_open then
			local reward_count = 0
			for k, v in pairs(self.item_cells) do
				v.is_show:SetValue(false)
				if reward_cfg[k - 1] then
					reward_count = reward_count + 1
					v.obj:SetData(reward_cfg[k - 1])
					v.is_show:SetValue(true)
				end
				self.item_data[k] = reward_cfg[k - 1]
			end
			if self.item_cells[reward_count + 1] then
				local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg[index].reward_exp}
				self.item_cells[reward_count + 1].obj:SetData(data)
				self.item_cells[reward_count + 1].is_show:SetValue(true)
				self.item_data[reward_count + 1] = data
			end
			self.drop_item:SetData(fuben_cfg[index].drop_show[0])
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

function FuBenInfoStoryView:SwitchButtonState(enable)
	if self.task_animator and self:IsOpen() then
		self.task_animator:SetBool("fold", not enable)
		self.shrink_btn.toggle.isOn = not enable
	end
end

function FuBenInfoStoryView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.StoryFB then
		self:SetStoryFBSceneData()
		self:SetCountDown()
	end
end