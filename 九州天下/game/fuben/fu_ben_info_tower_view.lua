FuBenInfoTowerView = FuBenInfoTowerView or BaseClass(BaseView)

function FuBenInfoTowerView:__init()
	self.ui_config = {"uis/views/fubenview", "TowerFBInFoView"}

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
	self.is_enter_next = false
	self.is_safe_area_adapter = true
end

function FuBenInfoTowerView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.monster_name = self:FindVariable("Require1")
	self.special_reward_level = self:FindVariable("SpecailRewardLevel")
	self.tongguan_des = self:FindVariable("TongGuanDes")
	self.fight_power = self:FindVariable("FightPower")
	self.num_color = self:FindVariable("NumColor")

	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	self.tittle_root = self:FindObj("SpecialRewardRoot")

	self.show_panel = self:FindVariable("ShowPanel")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function FuBenInfoTowerView:ReleaseCallBack()
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
	self.special_reward_level = nil
	self.tongguan_des = nil
	self.fight_power = nil
	self.tittle_root = nil
	self.show_panel = nil
	self.num_color = nil
end

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
	self.bg_animator = nil
	self.is_enter_next = nil
end

function FuBenInfoTowerView:OpenCallBack()
	self.is_open_finish = false
	self.is_load_tittle = false
	self:OnChangeScene()
end

function FuBenInfoTowerView:CloseCallBack()
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

function FuBenInfoTowerView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info then return end
	local fb_info = FuBenData.Instance:GetTowerFBInfo()
	local role_hp = GameVoManager.Instance:GetMainRoleVo().hp
	local diff_time = 0
	if fb_scene_info.is_finish == 1 and fb_scene_info.is_pass == 0 then -- role_hp <= 0 and
		ViewManager.Instance:Open(ViewName.FBFailFinishView)
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		if not self.is_open_finish then
			if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
				ViewManager.Instance:Close(ViewName.CommonTips)
			end
		end
		self.is_open_finish = true
		return
	end

	diff_time = fb_scene_info.time_out_stamp - TimeCtrl.Instance:GetServerTime()

	if fb_info.today_level and fb_scene_info.is_finish == 1 and (fb_info.today_level <= FuBenData.Instance:MaxTowerFB()) and fb_scene_info.is_pass == 1 then
		if ViewManager.Instance:IsOpen(ViewName.FuBenTowerInfoView) then
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

				if nil ~= self.pata_camera_move_quest then
					GlobalTimerQuest:CancelQuest(self.pata_camera_move_quest)
					self.pata_camera_move_quest = nil
				end

				self.pata_camera_move_quest = GlobalTimerQuest:AddDelayTimer(function ()
					self.pata_camera_move_quest = nil
					Camera.Instance:Reset(0.2)
				end, 2.6)


				local townx, towny = Scene.Instance:GetSceneTownPos()
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
						if not ViewManager.Instance:IsOpen(ViewName.TipPaTaView) then
							FuBenCtrl.Instance:SendEnterNextFBReq()
						end
					end, 5)
				end
			end
			local no_func = function ()
				FuBenCtrl.Instance:SendExitFBReq()
			end
			if not self.is_first_open then
				TipsCtrl.Instance:TipsPaTaView(no_func, func)
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
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = self.item_data})
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
		if fb_scene_info.kill_boss_num == 1 then
			self.num_color:SetValue(TEXT_COLOR.GREEN)
		else
			self.num_color:SetValue(TEXT_COLOR.RED)
		end
		return
	end

	if tower_fb_info and next(tower_fb_info) then
		local special_level_cfg = FuBenData.Instance:GetSpecialRewardLevel()
		local temp_td_level = tower_fb_info.pass_level + 1
		local temp_level_str = ""
		for s in string.gmatch(temp_td_level, "%d") do
			temp_level_str = temp_level_str..s.."\n"
		end
		local name_str = string.format(Language.FB.CurLevel, temp_level_str)
		self.fb_name:SetValue(name_str)

		local capability = GameVoManager.Instance:GetMainRoleVo().capability
		local str_fight_power = string.format(Language.Mount.ShowGreenStr, fuben_cfg[tower_fb_info.pass_level + 1].capability_show)
		if capability < fuben_cfg[tower_fb_info.pass_level + 1].capability_show then
			str_fight_power = string.format(Language.Mount.ShowRedStr, fuben_cfg[tower_fb_info.pass_level + 1].capability_show)
		end
		self.fight_power:SetValue(str_fight_power)

		self.monster_name:SetValue(monster_cfg[fuben_cfg[tower_fb_info.pass_level + 1].boss_id].name)

		if self.temp_level and self.temp_level ~= special_level_cfg.level then
			if self.title_obj then
				GameObject.Destroy(self.title_obj)
				self.title_obj = nil
				self.is_load_tittle = false
			end
		end
		if self.temp_change_level and self.temp_change_level ~= tower_fb_info.pass_level then
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end

		if special_level_cfg and not self.is_load_tittle and not self.title_obj then
			local bundle, asset = ResPath.GetTitleModel(special_level_cfg.title_id)
			self.is_load_tittle = true
			PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
				if prefab then
					local obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)
					
					local transform = obj.transform
					transform:SetParent(self.tittle_root.transform, false)
					self.title_obj = obj.gameObject
					self.is_load_tittle = false
				end
			end)
			self.temp_level = special_level_cfg.level
		end
					
		self.tongguan_des:SetValue(Language.FB.NormalReward)

		local reward_cfg = fuben_cfg[tower_fb_info.pass_level + 1].first_reward
		local reward_count = 0
		for k, v in pairs(self.item_cells) do
			if reward_cfg[k - 1] then
				reward_count = reward_count + 1
				v:SetData(reward_cfg[k - 1])
				v:SetActive(true)
				self.item_data[k] = reward_cfg[k - 1]
			else
				v:SetActive(false)
			end
		end
		if self.item_cells[reward_count + 1] then
			local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg[tower_fb_info.pass_level + 1].reward_exp}
			self.item_cells[reward_count + 1]:SetData(data)
			self.item_cells[reward_count + 1]:SetActive(true)
			self.item_data[reward_count + 1] = data
		end
		if special_level_cfg~=nil then
			self.special_reward_level:SetValue(special_level_cfg.level)
		end
		self.temp_change_level = tower_fb_info.today_level
	end
	if fb_scene_info then
		self.total_monster:SetValue(fb_scene_info.total_boss_num)
		self.kill_monster:SetValue(fb_scene_info.kill_boss_num)
		if fb_scene_info.kill_boss_num == 1 then
			self.num_color:SetValue(TEXT_COLOR.GREEN)
		else
			self.num_color:SetValue(TEXT_COLOR.RED)
		end
	end
end

function FuBenInfoTowerView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function FuBenInfoTowerView:OnFlush(param_t)
	if Scene.Instance:GetSceneType() == SceneType.PataFB then
		MainUICtrl.Instance:SetViewState(false)
		self:SetCountDown()
		self:SetTowerFBSceneData()
	end
end