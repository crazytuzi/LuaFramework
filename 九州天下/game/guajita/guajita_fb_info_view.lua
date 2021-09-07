GuajiTaFbInfoView = GuajiTaFbInfoView or BaseClass(BaseView)

function GuajiTaFbInfoView:__init()
	self.ui_config = {"uis/views/guajitaview", "GuajiTaFbInfoView"}

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
	self.guaji_camera_move_quest = nil
	self.view_layer = UiLayer.MainUILow
	self.is_enter_next = false
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
end

function GuajiTaFbInfoView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

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
	self.bg_animator = nil
	self.is_enter_next = nil

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
	self.is_open_finish = false
	self:Flush()
end

function GuajiTaFbInfoView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if nil ~= self.guaji_camera_move_quest then
		GlobalTimerQuest:CancelQuest(self.guaji_camera_move_quest)
		self.guaji_camera_move_quest = nil
	end
	self.temp_level = nil
	self.bg_animator = nil
end

function GuajiTaFbInfoView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.RuneTower then
		-- FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		self.is_first_open = true
	end
end

function GuajiTaFbInfoView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info then return end
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

			local func = function()
				self.is_enter_next = false
				if nil ~= self.next_enter_time_quest then
					GlobalTimerQuest:CancelQuest(self.next_enter_time_quest)
					self.next_enter_time_quest = nil
				end
				Camera.Instance:SetCameraTransformByName("pata", 0.2)

				if nil ~= self.guaji_camera_move_quest then
					GlobalTimerQuest:CancelQuest(self.guaji_camera_move_quest)
					self.guaji_camera_move_quest = nil
				end

				self.guaji_camera_move_quest = GlobalTimerQuest:AddDelayTimer(function ()
					self.guaji_camera_move_quest = nil
					Camera.Instance:Reset(0.2)
				end, 2.6)


				local townx, towny = Scene.Instance:GetSceneTownPos()
				-- GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), townx, towny, 1)
				local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName("GZ_Ptfb01_Main")
				if scene:IsValid() then
					local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)
					local animator = nil
					if self.bg_animator == nil  then
						for k,v in pairs(objects:ToTable()) do
							if v.name == "Main" then
								local bg = v.transform:FindHard("Background")
								self.bg_animator = bg:GetComponent(typeof(UnityEngine.Animator))
								self.bg_animator:ListenEvent("AniFinish", function ()
									if self.bg_animator then
										self.is_enter_next = true
										self.bg_animator:SetBool("down", false)
										FuBenCtrl.Instance:SendEnterNextFBReq()
										Scene.SendGetAllObjMoveInfoReq()
									end
								end)
							end
						end
					end
				end
				if self.bg_animator then
					self.bg_animator:SetBool("down", true)
				end

				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end

				if not self.is_enter_next then
					if nil ~= self.next_enter_time_quest then
						GlobalTimerQuest:CancelQuest(self.next_enter_time_quest)
						self.next_enter_time_quest = nil
					end
					self.next_enter_time_quest = GlobalTimerQuest:AddDelayTimer(function ()
						if not ViewManager.Instance:IsOpen(ViewName.TipPaTaRewardView) then
							FuBenCtrl.Instance:SendEnterNextFBReq()
						end
					end, 5)
				end
			end

			local no_func = function ()
				FuBenCtrl.Instance:SendExitFBReq()
			end
			
			if not self.is_first_open then
				TipsCtrl.Instance:TipsPaTaRewardView(no_func, func, self.item_data)

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
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
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
		return
	end

	if tower_fb_info and next(tower_fb_info) and fb_scene_info and next(fb_scene_info) then
		local temp_td_level = tower_fb_info.fb_today_layer + 1
		local temp_level_str = ""
		for s in string.gmatch(temp_td_level, "%d") do
			temp_level_str = temp_level_str..s.."\n"
		end
		local name_str = string.format(Language.FB.CurLevel, temp_level_str)
		self.fb_name:SetValue(name_str)

		local capability = GameVoManager.Instance:GetMainRoleVo().capability
		local str_fight_power = string.format(Language.Mount.ShowGreenStr, fuben_cfg[tower_fb_info.fb_today_layer + 1].capability)
		if capability < fuben_cfg[tower_fb_info.fb_today_layer + 1].capability then
			str_fight_power = string.format(Language.Mount.ShowRedStr, fuben_cfg[tower_fb_info.fb_today_layer + 1].capability)
		end
		self.fight_power:SetValue(str_fight_power)

		self.monster_name:SetValue(monster_cfg[fuben_cfg[tower_fb_info.fb_today_layer + 1].monster_id].name or Language.FuBen.XiaoGuai)

		if self.temp_change_level and self.temp_change_level ~= tower_fb_info.fb_today_layer then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end

		self.total_monster:SetValue(fb_scene_info.total_allmonster_num)
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num)
		self.tongguan_des:SetValue(fb_scene_info.param1 > 0 and Language.FB.FirstReward or Language.FB.NormalReward)
		local reward_cfg = fb_scene_info.param1 > 0 and fuben_cfg[tower_fb_info.fb_today_layer + 1].first_reward_item
							or fuben_cfg[tower_fb_info.fb_today_layer + 1].normal_reward_item
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
			local exp_num = fb_scene_info.param1 > 0 and fuben_cfg[tower_fb_info.fb_today_layer + 1].first_reward_rune_exp or fuben_cfg[tower_fb_info.fb_today_layer + 1].normal_reward_rune_exp
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
		MainUICtrl.Instance:SetViewState(false)
		self:SetTowerFBSceneData()
		self:SetCountDown()
	end
end