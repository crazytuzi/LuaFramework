FuBenInfoTeamSpecialView = FuBenInfoTeamSpecialView or BaseClass(BaseView)

function FuBenInfoTeamSpecialView:__init()
	self.ui_config = {"uis/views/funfubenview", "TeamSpecialFBInfoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true

	self.item_data = {}
	self.is_open_finish = false
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
	self.customs_pass = self:FindVariable("CustomsPass")
	-- self.special_remind = self:FindVariable("SpecialRemind")
	-- self.can_jump = self:FindVariable("CanJump")
	self.rewards = {}
	for i = 1, 3 do
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
	self.show_panel = self:FindVariable("ShowPanel")

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function FuBenInfoTeamSpecialView:__delete()
	self.item_data = {}
	self.is_open_finish = nil
end

function FuBenInfoTeamSpecialView:ReleaseCallBack()
	if self.rewards then
		for k, v in pairs(self.rewards) do
			v:DeleteMe()
		end
		self.rewards = {}
	end
	
	if self.show_or_hide_other_button then 
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	
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

function FuBenInfoTeamSpecialView:OpenCallBack()
	self.is_open_finish = false
	self:Flush()
end

function FuBenInfoTeamSpecialView:CloseCallBack()
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	if self.obj_del_event ~= nil then
		GlobalEventSystem:UnBind(self.obj_del_event)
		self.obj_del_event = nil
	end
end

function FuBenInfoTeamSpecialView:SetPhaseFBSceneData()
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	local monster_cfg = FuBenData.Instance:GetMonsterCfg()

	local len_cfg = FuBenData.Instance:GetTeamSpecialCfglen()
	local scene_id = Scene.Instance:GetSceneId() or 0
	local scene_cfg = FuBenData.Instance:GetTeamSpecialInfo(self.personal_or_team, scene_id)
	if scene_cfg == nil then
		return
	end
	self.customs_pass:SetValue(scene_cfg.show_layer .. " / " .. len_cfg)

	self.fb_name:SetValue(Language.FuBen.TeamFbName[1])
	self.monster_name:SetValue(monster_cfg[scene_cfg.monster_id].name)
	self.boss_name:SetValue(monster_cfg[scene_cfg.boss_id].name)
	self.tongguan_des:SetValue(Language.FB.NormalReward)
	for k, v in pairs(self.rewards) do
		local data = scene_cfg.drop_items[k - 1]
		v:SetData(data)
		self.item_data[k] = data
	end

	if fb_scene_info and next(fb_scene_info) then
		self.total_monster:SetValue(fb_scene_info.total_allmonster_num - fb_scene_info.total_boss_num)
		self.total_boss:SetValue(fb_scene_info.total_boss_num)
		self.kill_monster:SetValue(fb_scene_info.kill_allmonster_num - fb_scene_info.kill_boss_num)
		self.kill_boss:SetValue(fb_scene_info.kill_boss_num)
	end

	local special_result = FuBenData.Instance:GetTeamSpecialResult()
	if special_result and special_result.is_passed == 1 and scene_cfg.show_layer == len_cfg then
		local reward_info = FuBenData.Instance:GetTeamSpecialCfg().other
		local reward_list = {}
		if special_result.is_first_passed == 0 then 
			for k,v in pairs(reward_info[1].show_item_id) do
				table.insert(reward_list, v)
			end
			table.insert(reward_list, reward_info[1].fb_first_reward[0])
		else
			for k,v in pairs(reward_info[1].show_item_id) do
				table.insert(reward_list, v)
			end
		end
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = reward_list})
		end, 1)
	end
end

function FuBenInfoTeamSpecialView:SwitchButtonState(enable)
	if self.show_panel then
		self.show_panel:SetValue(enable)
	end
end

function FuBenInfoTeamSpecialView:OnFlush(param_t)
	if self:IsOpen() then
		self:SetPhaseFBSceneData()
	end
end