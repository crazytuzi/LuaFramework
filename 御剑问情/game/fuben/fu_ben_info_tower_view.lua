FuBenInfoTowerView = FuBenInfoTowerView or BaseClass(BaseView)

function FuBenInfoTowerView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "TowerFBInFoView"}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))

	self.item_data = {}
	self.item_cells = {}
	self.title_obj = nil
	self.temp_level = nil
	self.temp_change_level = nil
	self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.pata_camera_move_quest = nil
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function FuBenInfoTowerView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.monster_name = self:FindVariable("Require1")
	self.special_reward_level = self:FindVariable("SpecailRewardLevel") 	--下一个特殊奖励层数
	-- self.show_help_tip = self:FindVariable("ShowHelpTip")
	self.tongguan_des = self:FindVariable("TongGuanDes")
	self.fight_power = self:FindVariable("FightPower")
	self.mojie_reward_layer = self:FindVariable("MoJieRewardLayer") 		--下一个魔戒奖励层数
	self.show_mojie = self:FindVariable("ShowMojie")						--展示魔戒还是特殊奖励
	self.mojie_icon = self:FindVariable("MoJieIcon")						--魔戒Icon
	self.mojie_name = self:FindVariable("MoJieName")						--魔戒名称
	-- self:ListenEvent("OnClickExit",
	-- 	BindTool.Bind(self.OnClickExit, self))
	-- self:ListenEvent("OnClicExplain",
	-- 	BindTool.Bind(self.OnClicExplain, self))
	-- self:ListenEvent("CloseHelpTip",
	-- 	BindTool.Bind(self.CloseHelpTip, self))

	-- self.task_animator = self:FindObj("TaskAnimator").animator
	-- self.shrink_btn = self:FindObj("ShrinkAnimator")

	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self.show_panel = self:FindVariable("ShowPanel")

	self.special_item = ItemCell.New()
	self.special_item:SetInstanceParent(self:FindObj("SpecialItem"))

	-- self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function FuBenInfoTowerView:ReleaseCallBack()
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

	if self.special_item then
		self.special_item:DeleteMe()
	end
	self.special_item = nil

	-- 清理变量和对象
	self.fb_name = nil
	self.total_monster = nil
	self.kill_monster = nil
	self.monster_name = nil
	self.special_reward_level = nil
	self.mojie_reward_layer = nil
	self.show_mojie = nil
	self.mojie_icon = nil
	self.mojie_name = nil
	self.tongguan_des = nil
	self.fight_power = nil
	self.show_panel = nil
end

-- function FuBenInfoTowerView:OnMainUIModeListChange(is_show)
-- 	self.show_panel:SetValue(not is_show)
-- end

function FuBenInfoTowerView:__delete()
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

	self.is_load_tittle = nil
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

function FuBenInfoTowerView:OpenCallBack()
	self.is_open_finish = false
	self:Flush()
	self.is_load_tittle = false
end

function FuBenInfoTowerView:CloseCallBack()
	-- FuBenData.Instance:ClearTowerFBInfo()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.title_obj then
		GameObject.Destroy(self.title_obj)
		self.title_obj = nil
	end

	if nil ~= self.pata_camera_move_quest then
		GlobalTimerQuest:CancelQuest(self.pata_camera_move_quest)
		self.pata_camera_move_quest = nil
	end

	self.temp_level = nil
	self.bg_animator = nil
end

function FuBenInfoTowerView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.PataFB then
		FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		self.is_first_open = true
	end
end

-- function FuBenInfoTowerView:OnClickExit()
-- 	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
-- 	local diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
-- 	local fb_info = FuBenData.Instance:GetTowerFBInfo()
-- 	if diff_time >= 0 and (fb_info.today_level + 1) <= FuBenData.Instance:MaxTowerFB() and fb_scene_info.is_pass == 0 then
-- 		local func = function()
-- 			FuBenCtrl.Instance:SendExitFBReq()
-- 		end
-- 		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.FB.ExpWarmText, nil, nil, false)
-- 		return
-- 	end
-- 	FuBenCtrl.Instance:SendExitFBReq()
-- 	print("点击退出按钮 FuBenInfoTowerView")
-- end

-- -- 玩法说明
-- function FuBenInfoTowerView:OnClicExplain()
-- 	self.show_help_tip:SetValue(true)
-- end

-- function FuBenInfoTowerView:CloseHelpTip()
-- 	self.show_help_tip:SetValue(false)
-- end

function FuBenInfoTowerView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info then return end
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
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
	local time_out_stamp = fb_scene_info.time_out_stamp or TimeCtrl.Instance:GetServerTime()
	diff_time = time_out_stamp - TimeCtrl.Instance:GetServerTime()

	if fb_info.today_level and fb_scene_info.is_finish == 1 and ((fb_info.today_level + 1) <= FuBenData.Instance:MaxTowerFB()) and fb_scene_info.is_pass == 1 then
		if ViewManager.Instance:IsOpen(ViewName.FuBenTowerInfoView) then
			diff_time = 15
			if self.count_down ~= nil then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end

			local func = function()

				Camera.Instance:SetCameraTransformByName("pata", 0.1)

				if nil ~= self.pata_camera_move_quest then
					GlobalTimerQuest:CancelQuest(self.pata_camera_move_quest)
					self.pata_camera_move_quest = nil
				end

				self.pata_camera_move_quest = GlobalTimerQuest:AddDelayTimer(function ()
					self.pata_camera_move_quest = nil
					Camera.Instance:Reset(0.1)
				end, 2.6)

				local townx, towny = Scene.Instance:GetSceneTownPos()
				-- GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), townx, towny, 1)
				local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName("Xzptfb01_Main")
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
										self.bg_animator:SetBool("down", false)
										FuBenCtrl.Instance:SendEnterNextFBReq()
										Scene.SendGetAllObjMoveInfoReq()
									 end
								end)
							end
						end
					end
				-- 场景异常，直接跳到下一关
				else
					GlobalTimerQuest:AddDelayTimer(function() FuBenCtrl.Instance:SendEnterNextFBReq()
					end,4)
				end
				if self.bg_animator then
					self.bg_animator:SetBool("down", true)
				end

				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end
			local no_func = function ()
				FuBenCtrl.Instance:SendExitFBReq()
			end
			if not self.is_first_open then
				-- TipsCtrl.Instance:ShowCommonTip(func, nil, Language.FB.EnterNextFBText, nil, no_func, false, true)
				local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
				if next(tower_fb_info) ~= nil then
					local level = tower_fb_info.pass_level
				end
				if FuBenData.Instance:GetIsMojieLayer() then
					TipsCtrl.Instance:TipsTowerRewardInfoShow(no_func, func)
				else
					TipsCtrl.Instance:TipsPaTaView(no_func, func)
				end
			else
				diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
			end
			-- 请求开服活动信息
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PATA, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
		else
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
		end
	elseif fb_info.today_level and (fb_info.today_level + 1) > FuBenData.Instance:MaxTowerFB() then
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

	if next(fb_info) and fb_scene_info.is_finish then
		self.is_first_open = false
	end
end

function FuBenInfoTowerView:SetTowerFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
	local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	if fb_scene_info.is_finish == 1 then
		if self.is_first_open then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
			FuBenCtrl.Instance:SendEnterNextFBReq()
		end
		self.kill_monster:SetValue(fb_scene_info.kill_boss_num)
		return
	end

	if tower_fb_info and next(tower_fb_info) then
		local temp_td_level = tower_fb_info.today_level + 1
		local temp_level_str = temp_td_level
		-- for s in string.gmatch(temp_td_level, "%d") do
		-- 	temp_level_str = temp_level_str..s.."\n"
		-- end
		local name_str = string.format(Language.FB.CurLevel, temp_level_str)
		self.fb_name:SetValue(name_str)

		local capability = GameVoManager.Instance:GetMainRoleVo().capability
		local str_fight_power = string.format(Language.Mount.ShowGreenStr, fuben_cfg[tower_fb_info.today_level + 1].capability)
		if capability < fuben_cfg[tower_fb_info.today_level + 1].capability then
			str_fight_power = string.format(Language.Mount.ShowRedStr, fuben_cfg[tower_fb_info.today_level + 1].capability)
		end
		self.fight_power:SetValue(str_fight_power)

		self.monster_name:SetValue(monster_cfg[fuben_cfg[tower_fb_info.today_level + 1].boss_id].name)

		if self.temp_change_level and self.temp_change_level ~= tower_fb_info.today_level then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
		local reward_cfg = tower_fb_info.pass_level < tower_fb_info.today_level + 1 and fuben_cfg[tower_fb_info.today_level + 1].first_reward
							or fuben_cfg[tower_fb_info.today_level + 1].normal_reward
		self.tongguan_des:SetValue(tower_fb_info.pass_level < tower_fb_info.today_level + 1
			and Language.FB.FirstReward or Language.FB.NormalReward)

		local reward_count = 0
		for k, v in pairs(self.item_cells) do
			v:SetActive(false)
			if reward_cfg[k - 1] then
				reward_count = reward_count + 1
				v:SetData(reward_cfg[k - 1])
				v:SetActive(true)
				self.item_data[k] = reward_cfg[k - 1]
			end
		end
		if self.item_cells[reward_count + 1] then
			local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg[tower_fb_info.today_level + 1].reward_exp}
			self.item_cells[reward_count + 1]:SetData(data)
			self.item_cells[reward_count + 1]:SetActive(true)
			self.item_data[reward_count + 1] = data
		end
		self.temp_change_level = tower_fb_info.today_level

		-- 设置令牌奖励信息
		local special_reward_cfg = FuBenData.Instance:GetSpecialRewardItemCfg()
		if special_reward_cfg then
			self.special_item:SetData(special_reward_cfg.show_item_list[0])
			self.special_reward_level:SetValue(special_reward_cfg.level)
		end

		-- 设置爬塔魔戒奖励信息
		local next_reward_mojie_cfg = FuBenData.Instance:GetNextRewardTowerMojieCfg()
		if next_reward_mojie_cfg then
			self.mojie_reward_layer:SetValue(next_reward_mojie_cfg.pata_layer)						--设置下一个魔戒所在层数
		    local bundle, asset = ResPath.GetTowerMojieIcon(next_reward_mojie_cfg.skill_id + 1)
		    self.mojie_icon:SetAsset(bundle, asset) 												--设置魔戒Icon
		    self.mojie_name:SetValue(next_reward_mojie_cfg.mojie_name) 								--设置魔戒名称
		end

		--对比下一个获得魔戒和称号的层数，显示最小的那一个
		if next_reward_mojie_cfg and special_reward_cfg then
		    self.show_mojie:SetValue(next_reward_mojie_cfg.pata_layer <= special_reward_cfg.level)
		elseif next_reward_mojie_cfg then
			self.show_mojie:SetValue(true)
		elseif special_reward_cfg then
			self.show_mojie:SetValue(false)
		end
	end

	if fb_scene_info then
		self.total_monster:SetValue(fb_scene_info.total_boss_num or 0)
		self.kill_monster:SetValue(fb_scene_info.kill_boss_num or 0)
	end
end

function FuBenInfoTowerView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
	-- if self.task_animator and self:IsOpen() then
	-- 	self.task_animator:SetBool("fold", not enable)
	-- 	self.shrink_btn.toggle.isOn = not enable
	-- end
end

function FuBenInfoTowerView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.PataFB then
		MainUICtrl.Instance:SetViewState(false)
		self:SetTowerFBSceneData()
		self:SetCountDown()
	end
end