FuBenInfoTeamSpecialView = FuBenInfoTeamSpecialView or BaseClass(BaseView)

function FuBenInfoTeamSpecialView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "TeamSpecialFBInfoView"}

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE,
		BindTool.Bind(self.Flush, self))
	self.item_data = {}
	self.fail_data = {}
	self.rewards = {}
	-- self.is_first_open = true
	self.is_open_finish = false
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true

	self.personal_or_team = 1
end

function FuBenInfoTeamSpecialView:LoadCallBack()
	self.fb_name = self:FindVariable("FBName")
	self.total_monster = self:FindVariable("NeedNum1")
	self.total_boss = self:FindVariable("NeedNum2")
	self.kill_monster = self:FindVariable("HaveNum1")
	self.kill_boss = self:FindVariable("HaveNum2")
	self.monster_name = self:FindVariable("Require1")
	self.boss_name = self:FindVariable("Require2")
	self.tongguan_des = self:FindVariable("TongGuanDes")
	-- self.special_remind = self:FindVariable("SpecialRemind")
	-- self.can_jump = self:FindVariable("CanJump")
	self.customs_pass = self:FindVariable("CustomsPass")

	for i = 1, 3 do
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	self.show_panel = self:FindVariable("ShowPanel")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
	self:Flush()

end

function FuBenInfoTeamSpecialView:__delete()
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

function FuBenInfoTeamSpecialView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
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
	self.customs_pass = nil
end

function FuBenInfoTeamSpecialView:OnChangeScene()
	if Scene.Instance:GetSceneType() == SceneType.TeamSpecialFb then
		print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
		-- FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	end
end

function FuBenInfoTeamSpecialView:OpenCallBack()
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoTeamSpecialView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end
end

function FuBenInfoTeamSpecialView:SetCountDown()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if nil == fb_scene_info or nil == next(fb_scene_info) then return end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end
	local call_back = function ()
		if not self.upgrade_timer_quest then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
				ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "teamSpecial", {data = {Language.FuBen.TeamSpecialFinishDes}})
			end, 2)
		end
	end
	TimeScaleService.StartTimeScale(call_back)
end

function FuBenInfoTeamSpecialView:SetPhaseFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local phase_fb_info = FuBenData.Instance:GetPhaseFBInfo()
	local fuben_cfg = FuBenData.Instance:GetCurFbCfgByIndex(index)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list

	local len_cfg = FuBenData:GetTeamSpecialCfglen()
	local scene_id = Scene.Instance:GetSceneId() or 0
	local scene_cfg = FuBenData.Instance:GetTeamSpecialCfg(self.personal_or_team, scene_id)
	if scene_cfg == nil then
		return
	end
	self.customs_pass:SetValue(scene_cfg.show_layer .. " / " .. len_cfg)

	MainUICtrl.Instance:SetViewState(false)

	self.fb_name:SetValue(Language.FuBen.TeamFbName[1])
	self.monster_name:SetValue(monster_cfg[scene_cfg.monster_id].name)
	self.boss_name:SetValue(monster_cfg[scene_cfg.boss_id].name)

	-- self.drop_item:SetData(fuben_cfg.drop_show[0])
	-- if phase_fb_info and next(phase_fb_info) then
		-- local reward = (phase_fb_info[index].is_pass == 0) and fuben_cfg.first_reward or fuben_cfg.normal_reward
		self.tongguan_des:SetValue(Language.FB.NormalReward)
		-- if self.is_first_open then
			-- local is_set_exp = false
			for k, v in pairs(self.rewards) do
				-- if reward[k - 1] then
				-- 	v:SetData(reward[k - 1])
				-- 	self.item_data[k] = reward[k - 1]
				-- 	v:SetActive(true)
				-- else
				-- 	v:SetActive(false)
					-- if not is_set_exp then
						local data = scene_cfg.drop_items[k - 1]
						v:SetData(data)
						self.item_data[k] = data
						-- is_set_exp = true
						-- v:SetActive(true)
					-- end
				end
			-- end
		-- end
		-- self.is_first_open = false
	-- end
	if fb_scene_info and next(fb_scene_info) then
		self.total_monster:SetValue(fb_scene_info.total_allmonster_num - fb_scene_info.total_boss_num)
		self.total_boss:SetValue(fb_scene_info.total_boss_num)
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num)
		self.kill_boss:SetValue(fb_scene_info.kill_boss_num)
	end
end

function FuBenInfoTeamSpecialView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function FuBenInfoTeamSpecialView:OnFlush(param_t)
	if self:IsOpen() then
		self:SetPhaseFBSceneData()
		-- self:SetCountDown()
	end
end