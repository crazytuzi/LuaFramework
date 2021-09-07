ZhuaGuiView = ZhuaGuiView or BaseClass(BaseView)

function ZhuaGuiView:__init()
	self.ui_config = {"uis/views/zhuaguiview", "ZhuaGuiView"}
	self.view_layer = UiLayer.MainUI
	self.play_audio = true
	self.is_safe_area_adapter = true
end

function ZhuaGuiView:RleaseCallBack()
	-- if self.delay_time then
	-- 	GlobalTimerQuest:CancelQuest(self.delay_time)
	-- end

	if self.hunli_item then
		self.hunli_item:DeleteMe()
	end

	if self.mojing_item then
		self.mojing_item:DeleteMe()
	end
end

function ZhuaGuiView:LoadCallBack()
	self.to_left = false
	self.open_timer = true

	self.show_view = self:FindVariable("ShowView")
	self.normal_num = self:FindVariable("NormalNum")
	self.special_num = self:FindVariable("SpecialNum")
	-- self.hun_li = self:FindVariable("HunLi")


	self.spouse_addtion = self:FindVariable("spouse_addtion")
	self.fuli_gui_probability = self:FindVariable("FuLiGui")
	self.team_addtion = self:FindVariable("team_addtion")
	self.show_couple = self:FindVariable("show_couple")
	self.zudui_fuli_addtion = self:FindVariable("zudui_fuli_addtion")
	self.countdown_text = self:FindVariable("count_down")
	self.is_open_timer = self:FindVariable("open_timer")

	-- self.rank_view = self:FindObj("FbView")
	-- self.panel_animator = self.rank_view.animator
	-- self.panel_animator:ListenEvent("ToLeft", BindTool.Bind(self.ToLeft, self))
	self:ListenEvent("ChangeState", BindTool.Bind(self.ChangeState, self))

	self.hunli_item_obj = self:FindObj("hunli_item")
	self.hunli_item = ItemCell.New(self.hunli_item_obj)

	self.mojing_item_obj = self:FindObj("mojing_item")
	self.mojing_item = ItemCell.New(self.mojing_item_obj)

	FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickIcon, self))

	self:UpRewardData()
end

function ZhuaGuiView:OpenCallBack()
	local per_info = ZhuaGuiData.Instance:GetZhuaGuiPerInfo()
	self.show_couple:SetValue(false)
	if per_info.couple_hunli_add_per > 0 then
		self.show_couple:SetValue(true)
	end
	-- self.panel_animator:SetBool("toleft", false)
	self.is_open_timer:SetValue(false)

	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	FuBenCtrl.Instance:ShowMonsterHadFlush(true)
	local monster_info = ZhuaGuiData.Instance:GetBaseHunLi()
	FuBenCtrl.Instance:SetMonsterInfo(monster_info.monster_id or 304)
end

function ZhuaGuiView:CloseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function ZhuaGuiView:SwitchButtonState(state)
	self.show_view:SetValue(state)
end

function ZhuaGuiView:ChangeState()
	self.to_left = not self.to_left
	-- self.panel_animator:SetBool("toleft", self.to_left)
end

function ZhuaGuiView:ToLeft(state)
	self.to_left = (state == "1") and true or false
end

function ZhuaGuiView:FlushHunLi()
	-- self.hun_li:SetValue(now_hunli)
end

function ZhuaGuiView:FlushFuBenList()
	local fb_list = ZhuaGuiData.Instance:GetZhuaGuiFBInfo()
	self.normal_num:SetValue(fb_list.monster_count)
	local boss_num = 0
	if fb_list.ishave_boss == 1 and fb_list.boss_isdead == 0 then
		boss_num = 1
	else
		boss_num = 0
	end
	self.special_num:SetValue(boss_num)

	-- 胜利后进入
	if fb_list.kick_time ~= 0 and self.open_timer then
		self.open_timer = false
		self.is_open_timer:SetValue(true)
		self:FlushTime(fb_list)
		 FuBenCtrl.Instance:ShowMonsterHadFlush(false)
		 FuBenCtrl.Instance:SetMonsterDiffTime(Language.Boss.HadKill)
	end
end

function ZhuaGuiView:UpRewardData()
	-- local now_hunli, now_mojing, kill_boss_count = ZhuaGuiData.Instance:GetCurFBSelfhunliAndmojing()
	local kill_boss_count = ZhuaGuiData.Instance:GetCurDayZhuaGuiInfo().zhuagui_day_catch_count or 0
	local zhuagui_cfg = ZhuaGuiData.Instance:GetZhuaGuiOtherCfg()
	local item_data = {}

	local per_info = ZhuaGuiData.Instance:GetZhuaGuiPerInfo()
	self.spouse_addtion:SetValue(per_info.couple_hunli_add_per)
	self.fuli_gui_probability:SetValue(per_info.couple_boss_add_per)
	self.team_addtion:SetValue(per_info.team_hunli_add_per)
	self.zudui_fuli_addtion:SetValue(per_info.team_boss_add_per)
	if zhuagui_cfg then
		if kill_boss_count < zhuagui_cfg.mojing_reward_time then
			self.hunli_item_obj:SetActive(true)
			self.mojing_item_obj:SetActive(false)
			local base_hunli = ZhuaGuiData.Instance:GetBaseHunLi().give_hunli
			local add_data = ZhuaGuiData.Instance:GetAddHunLiDataByTime(kill_boss_count)
			local team_num = ScoietyData.Instance:GetTeamNum()
			local per_num = ZhuaGuiData.Instance:GetTeamAllPreByNum(team_num)

			local per_couple = 0
			if per_info.couple_hunli_add_per > 0 then
				per_couple = ZhuaGuiData.Instance:GetmarriedHunliAddPer()
			end
			local all_num = 0
			-- if kill_boss_count > ZhuaGuiData.Instance:GetAddHunLiDataByTime(1).kill_monster then
			-- 	all_num = base_hunli * ((per_num + per_couple + 100)/100*add_data.reward_per/100)
			-- else
				all_num = base_hunli * ((per_num + per_couple + 100)/100*add_data.reward_per/100)
			-- end
			item_data = {item_id = ResPath.CurrencyToIconId["hunli"], num = all_num}
			self.hunli_item:SetData(item_data)
		else
			self.hunli_item_obj:SetActive(false)
			self.mojing_item_obj:SetActive(true)
			item_data = {item_id = ResPath.CurrencyToIconId["shengwang"], num = zhuagui_cfg.mojing_reward}
			self.mojing_item:SetData(item_data)
		end
	end
end

function ZhuaGuiView:OnFlush()
	self:FlushHunLi()
	self:FlushFuBenList()
end

function ZhuaGuiView:FlushTime(fb_list)
	-- local item_data = {}
	-- item_data[1] = {item_id = ResPath.CurrencyToIconId["hunli"], num = ZhuaGuiData.Instance:GetCurFBSelfhunliAndmojing()}
	-- if fb_list.item_count > 0 then
	-- 	for i=2,fb_list.item_count + 2 do
	-- 		item_data[i] = fb_list.zhuagui_item_list[i - 1]
	-- 	end
	-- end
	-- ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = item_data})
	-- self.delay_time = GlobalTimerQuest:AddDelayTimer(function() ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	-- 	FuBenCtrl.Instance:SendExitFBReq() end, 5)
	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		local remain_time = fb_list.kick_time - math.floor(TimeCtrl.Instance:GetServerTime())

		if remain_time < 0 then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		else
			self.countdown_text:SetValue(remain_time)
		end
	end, 0)
end

function ZhuaGuiView:OnClickIcon()
	local cfg_info = ZhuaGuiData.Instance:GetBaseHunLi()
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), cfg_info.flush_pos_x, cfg_info.flush_pos_y, 10, 1)
end