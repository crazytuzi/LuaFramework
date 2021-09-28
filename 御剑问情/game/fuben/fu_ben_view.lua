require("game/fuben/fu_ben_new_exp_view")
require("game/fuben/fu_ben_quality_view")
require("game/fuben/fu_ben_push_special_view")
require("game/fuben/fu_ben_phase_view")
require("game/fuben/fu_ben_guard_view")
require("game/fuben/fu_ben_tower_view")
require("game/fuben/fu_ben_many_view")
FuBenView = FuBenView or BaseClass(BaseView)

--标签顺序有改变记得改这个表(记得按顺序来)
local TAB_LIST = {
	[1] = {tab_name = "tab_phase", tab_index = TabIndex.fb_phase, funopen_name = "fb_phase"},
	[2] = {tab_name = "tab_exp", tab_index = TabIndex.fb_exp, funopen_name = "fb_exp"},
	[3] = {tab_name = "tab_tower", tab_index = TabIndex.fb_tower, funopen_name = "fb_tower"},
	[4] = {tab_name = "tab_team", tab_index = TabIndex.fb_team, funopen_name = "fb_team"},
	[5] = {tab_name = "tab_guard", tab_index = TabIndex.fb_guard, funopen_name = "fb_guard"},
	[6] = {tab_name = "tab_push_special", tab_index = TabIndex.fb_push_special, funopen_name = "fb_push_special"},
	[7] = {tab_name = "tab_quality", tab_index = TabIndex.fb_quality, funopen_name = "fb_quality"},
	[8] = {tab_name = "tab_many_people", tab_index = TabIndex.fb_many_people, funopen_name = "fb_many_people"},
	[9] = {tab_name = "tab_story", tab_index = TabIndex.fb_story, funopen_name = "fb_story"},
	[10] = {tab_name = "tab_vip", tab_index = TabIndex.fb_vip, funopen_name = "fb_vip"},
}

function FuBenView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "FuBenView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function FuBenView:__delete()
	self.cur_toggle = nil
	self.red_point_list = {}
end

function FuBenView:LoadCallBack()
	self.cur_toggle = 1

	self.advance_content = self:FindObj("AdvanceFBContent")
	self.exp_content = self:FindObj("ExpFBContent")
	self.quality_content = self:FindObj("QualityFBContent")
	self.special_content_go = self:FindObj("PushSpecialContent")
	self.guard_content = self:FindObj("GuardContent")
	self.tower_content = self:FindObj("TowerFBContent")
	self.team_content = self:FindObj("TeamContent")

	--引导用按钮
	self.tab_tower = self:FindObj("TowerToggle")
	self.tab_exp = self:FindObj("ExpToggle")
	self.tab_story = self:FindObj("StoryToggle")
	self.tab_vip = self:FindObj("VipToggle")
	self.tab_phase = self:FindObj("PhaseToggle")
	self.tab_many_people = self:FindObj("ManyPeopleToggle")
	self.tab_quality = self:FindObj("QualityToggle")
	self.tab_guard = self:FindObj("GuardToggle")
	self.tab_push = self:FindObj("PushToggle")
	self.tab_push_special = self:FindObj("PushSpecial")
	self.tab_team = self:FindObj("TabTeam")

	self.tower_toggle = self.tab_tower.toggle
	self.exp_toggle = self.tab_exp.toggle
	self.story_toggle = self.tab_story.toggle
	self.vip_toggle = self.tab_vip.toggle
	self.quality_toggle = self.tab_quality.toggle
	self.guard_toggle = self.tab_guard.toggle
	self.phase_toggle = self.tab_phase.toggle
	self.many_people_toggle = self.tab_many_people.toggle
	self.push_toggle = self.tab_push.toggle
	self.push_special_toggle = self.tab_push_special.toggle
	self.team_toggle = self.tab_team.toggle

	-- self.tower_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_tower))
	-- self.phase_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_phase))
	-- self.exp_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_exp))
	-- self.vip_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_vip))
	-- self.quality_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_quality))
	-- self.guard_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_guard))
	-- self.story_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_story))
	-- self.push_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_push))
	-- self.push_special_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_push_special))

	self.red_point_list = {
		self:FindVariable("ShowRedPoint1"),
		self:FindVariable("ShowRedPoint2"),
		self:FindVariable("ShowRedPoint3"),
		self:FindVariable("ShowRedPoint4"),
		self:FindVariable("ShowRedPoint5"),
		self:FindVariable("ShowRedPoint6"),
		self:FindVariable("ShowRedPoint7"),
		self:FindVariable("ShowRedPoint8"),
		self:FindVariable("ShowRedPoint9"),
		self:FindVariable("ShowRedPoint10"),
		self:FindVariable("ShowRedPoint11"),
	}

	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	-- self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OpenAdvanceFB",
		BindTool.Bind(self.OpenAdvanceFB, self))
	self:ListenEvent("OpenExpFB",
		BindTool.Bind(self.OpenExpFB, self))
	self:ListenEvent("OpenStoryFB",
		BindTool.Bind(self.OpenStoryFB, self))
	self:ListenEvent("OpenVipFB",
		BindTool.Bind(self.OpenVipFB, self))
	self:ListenEvent("OpenTowerFB",
		BindTool.Bind(self.OpenTowerFB, self))
	self:ListenEvent("OpenManyPeopleFB",
		BindTool.Bind(self.OpenManyPeopleFB, self))
	self:ListenEvent("OpenQualityFB",
		BindTool.Bind(self.OpenQualityFB, self))
	self:ListenEvent("OpenPushFB",
		BindTool.Bind(self.OpenPushFB, self))
	self:ListenEvent("OpenPushSpecialFB",
		BindTool.Bind(self.OpenPushSpecialFB, self))
	self:ListenEvent("OpenGuardFB",
		BindTool.Bind(self.OpenGuardFB, self))
	self:ListenEvent("OpenTeamFB",
		BindTool.Bind(self.OpenTeamFB,self))

	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, BindTool.Bind(self.GetUiCallBack, self))

	-- 为了处理花屏
	-- self.show_mask = self:FindVariable("ShowMask")
	-- self.show_mask:SetValue(true)
	-- self.raw_image = self:FindObj("RawImage").raw_image
	-- self.raw_image:LoadSprite("uis/rawimages/moonbg", "MoonBG", function()
	-- 	self.show_mask:SetValue(false)
	-- end)
end

function FuBenView:ReleaseCallBack()
	if self.advance_view then
		self.advance_view:DeleteMe()
		self.advance_view = nil
	end

	if self.exp_view then
		self.exp_view:DeleteMe()
		self.exp_view = nil
	end

	if self.vip_view then
		self.vip_view:DeleteMe()
		self.vip_view = nil
	end

	if self.quality_view then
		self.quality_view:DeleteMe()
		self.quality_view = nil
	end

	if self.guard_view then
		self.guard_view:DeleteMe()
		self.guard_view = nil
	end

	if self.tower_view then
		self.tower_view:DeleteMe()
		self.tower_view = nil
	end

	if self.story_view then
		self.story_view:DeleteMe()
		self.story_view = nil
	end

	if self.many_people_view then
		self.many_people_view:DeleteMe()
		self.many_people_view = nil
	end

	if self.common_content_view then
		self.common_content_view:DeleteMe()
		self.common_content_view = nil
	end

	if self.special_content_view then
		self.special_content_view:DeleteMe()
		self.special_content_view = nil
	end

	if self.team_view then
		self.team_view:DeleteMe()
		self.team_view = nil
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.FuBen)
	end

	if nil ~= self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
		self.player_data_change = nil
	end

	-- 清理变量和对象
	self.red_point_list = {}
	self.tower_content = nil
	self.tab_tower = nil
	self.tab_exp = nil
	self.tab_story = nil
	self.tab_vip = nil
	self.tab_phase = nil
	self.tab_many_people = nil
	self.tab_quality = nil
	self.tower_toggle = nil
	self.tab_push = nil
	self.tab_push_special = nil
	self.exp_toggle = nil
	self.story_toggle = nil
	self.vip_toggle = nil
	self.quality_toggle = nil
	self.phase_toggle = nil
	self.many_people_toggle = nil
	self.push_toggle = nil
	self.push_special_toggle = nil
	self.gold = nil
	self.bind_gold = nil
	self.show_mask = nil
	self.raw_image = nil
	self.tab_guard = nil
	self.guard_toggle = nil
	self.tower_challenge = nil
	self.advance_content = nil
	self.exp_content = nil
	self.guard_content = nil
	self.special_content_go = nil
	self.quality_content = nil
	self.team_toggle = nil
	self.tab_team = nil
	self.team_content = nil

end

function FuBenView:CloseCallBack()
	FunctionGuide.Instance:DelWaitGuideListByName("push_yuansu")
	FunctionGuide.Instance:DelWaitGuideListByName("push_special")
	if nil ~= self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
		self.player_data_change = nil
	end

	SettingData.Instance:SetCommonTipkey("chongzhi", false)

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
		self.event_quest = nil
	end
	if self.exp_view then
		self.exp_view:CloseCallBack()
	end

	if self.tower_view then
		self.tower_view:CloseCallBack()
	end

	if self.advance_view then
		self.advance_view:CloseCallBack()
	end

	if self.common_content_view then
		self.common_content_view:CloseCallBack()
	end

	if self.special_content_view then
		self.special_content_view:CloseCallBack()
	end

	if self.quality_view then
		self.quality_view:CloseCallBack()
	end

	-- if self.guard_view then
	-- 	self.guard_view:CloseCallBack()
	-- end

	self.cur_toggle = 1
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
	if self.team_flush_timer then
		GlobalTimerQuest:CancelQuest(self.team_flush_timer)
		self.team_flush_timer = nil
	end
end

function FuBenView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function FuBenView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.tab_tower:SetActive(open_fun_data:CheckIsHide("fb_tower"))
	self.tab_exp:SetActive(open_fun_data:CheckIsHide("fb_exp"))
	self.tab_story:SetActive(open_fun_data:CheckIsHide("fb_story"))
	self.tab_vip:SetActive(open_fun_data:CheckIsHide("fb_vip"))
	self.tab_phase:SetActive(open_fun_data:CheckIsHide("fb_phase"))
	self.tab_guard:SetActive(open_fun_data:CheckIsHide("fb_guard"))
	self.tab_many_people:SetActive(open_fun_data:CheckIsHide("fb_many_people"))
	self.tab_quality:SetActive(open_fun_data:CheckIsHide("fb_quality"))
	--self.tab_push:SetActive(open_fun_data:CheckIsHide("fb_push"))
	self.tab_push_special:SetActive(open_fun_data:CheckIsHide("fb_push_special"))
	self.tab_team:SetActive(open_fun_data:CheckIsHide("fb_team"))
end

-- function FuBenView:OpenView()
-- 	if
-- 	if open_fun_data:CheckIsHide("fb_push_special") then
-- 		return
-- end

function FuBenView:OpenCallBack()
	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("push_yuansu")
	FunctionGuide.Instance:TriggerGuideByName("push_special")

	-- 监听系统事件
	if nil == self.player_data_change then
		self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_change)
	end

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:ShowOrHideTab()
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	if self.many_people_view then
		self.many_people_view:OpenCallBack()
	end

	self:ShowIndex(TabIndex.fu_ben_push_special_view)

	self:FlushRedPoint()
end

function FuBenView:OnItemDataChange()
	self:Flush("exp")
end

function FuBenView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.gold:SetValue(count)
	elseif attr_name == "bind_gold" then
		local count = vo.bind_gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.bind_gold:SetValue(count)
	end
end

function FuBenView:OnClickClose()
	-- self.close_mode = (self.tower_view and self.tower_view.is_onekey_saodang) and CloseMode.CloseVisible or CloseMode.CloseDestroy
	self:Close()
end

function FuBenView:GetFuBenExpView()
	return self.exp_view
end

function FuBenView:OpenAdvanceFB()
	-- if self.cur_toggle == 1 then
	-- 	return
	-- end
	-- if self.advance_view then
	-- 	self.advance_view:FlushView()
	-- end
	self:ShowIndex(TabIndex.fb_phase)
	self.cur_toggle = 1
	-- self.turntable_info:SetShow(self.phase_toggle.isOn or self.exp_toggle.isOn)

end

function FuBenView:OpenExpFB()
	-- if self.cur_toggle == 2 then
	-- 	return
	-- end
	-- if self.exp_view then
		-- self.exp_view:FlushInfo()
		-- self.exp_view:OpenGlobalTimer()
	-- end
	self:ShowIndex(TabIndex.fb_exp)
	self.cur_toggle = 2
	self:SendExpFBProtocol()
end

function FuBenView:OpenStoryFB()
	if self.story_view then
		self.story_view:FlushView()
	end
	self:ShowIndex(TabIndex.fb_story)
	self.cur_toggle = 3
end

function FuBenView:OpenVipFB()
	if self.vip_view then
		self.vip_view:FlushView()
	end
	self:ShowIndex(TabIndex.fb_vip)
	self.cur_toggle = 4
end

function FuBenView:OpenTowerFB()
	if self.cur_toggle == 5 then
		return
	end
	if self.tower_view then
		self.tower_view:Flush()
		-- self.tower_view:AddTimerQuest()
	end
	self:ShowIndex(TabIndex.fb_tower)
	self.cur_toggle = 5
end

function FuBenView:OpenManyPeopleFB()
	if self.cur_toggle == 6 then
		return
	end
	if self.many_people_view then
		self.many_people_view:OpenCallBack()
	end
	self:ShowIndex(TabIndex.fb_many_people)
	self.cur_toggle = 6
end

function FuBenView:OpenQualityFB()
	if self.cur_toggle == 7 then
		return
	end
	-- -- if self.quality_view then
	-- -- 	self.quality_view:OpenCallBack()
	-- -- end
	self:ShowIndex(TabIndex.fb_quality)
	self.cur_toggle = 7
end

function FuBenView:OpenGuardFB()
	if self.cur_toggle == 8 then
		return
	end
	-- if self.guard_view then
	-- 	self.guard_view:OpenCallBack()
	-- end
	self:ShowIndex(TabIndex.fb_guard)
	self.cur_toggle = 8
end

function FuBenView:OpenTeamFB()
	if self.cur_toggle == 11 then
		return
	end
	self:ShowIndex(TabIndex.fb_team)
	self.cur_toggle = 11

end

function FuBenView:OpenPushFB()
	if self.cur_toggle == 9 then
		return
	end
	-- if self.common_content_view then
	-- 	self.common_content_view:OpenCallBack()
	-- end
	self:ShowIndex(TabIndex.fb_push)
	self.cur_toggle = 9
end

function FuBenView:OpenPushSpecialFB()
	if self.cur_toggle == 10 then
		return
	end
	-- if self.special_content_view then
	-- 	self.special_content_view:OpenCallBack()
	-- end
	self:ShowIndex(TabIndex.fb_push_special)
	self.cur_toggle = 10
end

function FuBenView:ChangeLeader()
	if self.many_people_view then
		self.many_people_view:ChangeLeader()
	end
end

function FuBenView:AsyncLoadView(index)
	if index == TabIndex.fb_phase and self.advance_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "AdvanceFBContent",
			function(obj)
				obj.transform:SetParent(self.advance_content.transform, false)
				obj = U3DObject(obj)
				self.advance_view = FuBenPhaseView.New(obj)
				self:Flush("phase")
			end)
	end
	if index == TabIndex.fb_exp and self.exp_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "ExpFBContent2",
			function(obj)
				obj.transform:SetParent(self.exp_content.transform, false)
				obj = U3DObject(obj)
				self.exp_view = FuBenNewExpView.New(obj)
				self:Flush("exp")
			end)
	end
	if index == TabIndex.fb_quality and self.quality_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "QualityFBContent",
			function(obj)
				obj.transform:SetParent(self.quality_content.transform, false)
				obj = U3DObject(obj)
				self.quality_view = FuBenQualityView.New(obj)
				self.quality_view:OpenCallBack()
				self:Flush("quality")
			end)
	end
	if index == TabIndex.fb_push_special and self.special_content_go.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "PushSpecialContent",
			function(obj)
				obj.transform:SetParent(self.special_content_go.transform, false)
				obj = U3DObject(obj)
				self.special_content_view = PushSpecialView.New(obj)
				self:Flush("push_special")
			end)
	end
	if index == TabIndex.fb_guard and self.guard_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "DefenseContent",
			function(obj)
				obj.transform:SetParent(self.guard_content.transform, false)
				obj = U3DObject(obj)
				self.guard_view = FuBenGuardView.New(obj)
				self:Flush("tower_defend")
			end)
	end
	if index == TabIndex.fb_tower and self.tower_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "TowerFBContent",
			function(obj)
				obj.transform:SetParent(self.tower_content.transform, false)
				obj = U3DObject(obj)
				self.tower_view = FuBenTowerView.New(obj)
				self:Flush("tower")
			end)
	end
	if index == TabIndex.fb_team and self.team_content.transform.childCount == 0 then
		UtilU3d.PrefabLoad("uis/views/fubenview_prefab", "TeamFBContent",
			function(obj)
				obj.transform:SetParent(self.team_content.transform, false)
				obj = U3DObject(obj)
				self.team_view = TeamFBContent.New(obj)
				self:Flush("team")
			end)
	end
end

function FuBenView:ShowIndexCallBack(index)
	FuBenData.Instance:SetHasRemind(index)
	self:AsyncLoadView(index)
	if index ~= TabIndex.fb_team and self.team_flush_timer then
		GlobalTimerQuest:CancelQuest(self.team_flush_timer)
		self.team_flush_timer = nil
	end
	if self.tower_view and index ~= TabIndex.fb_tower then
		self.tower_view:ResetEffect()
	end
	if index == TabIndex.fb_tower then
		self.tower_toggle.isOn = true
		-- self:OpenTowerFB()
		self:Flush("tower")
	elseif index == TabIndex.fb_phase then
		-- self:OpenAdvanceFB()
		self.phase_toggle.isOn = true
		self:Flush("phase")
	elseif index == TabIndex.fb_exp then
		-- self:OpenExpFB()
		self:SendExpFBProtocol()
		self.cur_toggle = 2
		self.exp_toggle.isOn = true
		self:Flush("exp")
	elseif index == TabIndex.fb_vip then
		-- self:OpenVipFB()
		self.vip_toggle.isOn = true
		self:Flush("vip")
	elseif index == TabIndex.fb_quality then
		self.quality_toggle.isOn = true
		self:Flush("quality")
	elseif index == TabIndex.fb_guard then
		self.guard_toggle.isOn = true
		self:Flush("tower_defend")
	elseif index == TabIndex.fb_story then
		-- self:OpenStoryFB()
		self.story_toggle.isOn = true
		self:Flush("story")
	elseif index == TabIndex.fb_many_people then
		-- self:OpenStoryFB()
		self.many_people_toggle.isOn = true
		self:Flush("manypeople")
	elseif index == TabIndex.fb_push  then
		self.push_toggle.isOn = true
		self:Flush("push")
	elseif index == TabIndex.fb_push_special then
		self.push_special_toggle.isOn = true
		self:Flush("push_special")
	elseif index == TabIndex.fb_team then
		self.team_toggle.isOn = true
		if self.team_view then
			local choose, flag = TeamFbData.Instance:GetDefaultChoose()
			if flag then
				self.team_view:ChangeIndex(choose)
			else
				self.team_view:ChangeIndex()
			end
		end
		if not self.team_flush_timer then
			self.team_flush_timer = GlobalTimerQuest:AddRunQuest(function ()
				if self.team_view then
					self.team_view:ChangeIndex()
				end
			end,3)
		end
		self.cur_toggle = 11
	 	self:Flush("team")
	else
		local first_index = self:GetFirstOpenTab()
		self:ShowIndex(first_index)
	end

	if index ~= TabIndex.fb_tower then
		if self.tower_view then
			self.tower_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.fb_quality then
		if self.quality_view then
			self.quality_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.fb_push_special then
		if self.special_content_view then
			self.special_content_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.fb_exp then
		if self.exp_view then
			self.exp_view:CloseCallBack()
		end
	end
	if index ~= TabIndex.fb_phase then
		if self.advance_view then
			self.advance_view:CloseCallBack()
		end
	end
	self:ClearQuest(index)
end

function FuBenView:ClearQuest(index)
	if index ~= TabIndex.fb_exp and self.exp_view then
		self.exp_view:DeleteQuest()
	end
end

--获取第一个开启的标签
function FuBenView:GetFirstOpenTab()
	local tab_index = TabIndex.fb_phase
	for _, v in ipairs(TAB_LIST) do
		if self[v.tab_name] and OpenFunData.Instance:CheckIsHide(v.funopen_name) then
			tab_index = v.tab_index
			break
		end
	end
	return tab_index
end

function FuBenView:SendExpFBProtocol()
	if ScoietyData.Instance:GetTeamState() then
		local team_info = ScoietyData.Instance:GetTeamInfo()
		local team_type = team_info.team_type or 0
		if team_type ~= FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
		end
	else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	end
end

function FuBenView:FlushRedPoint()
	self.red_point_list[1]:SetValue(FuBenData.Instance:GetPushRed(0) or FuBenData.Instance:GetPushReWardRed())
	self.red_point_list[2]:SetValue(FuBenData.Instance:IsShowPhaseFBRedPoint())
	self.red_point_list[3]:SetValue(FuBenData.Instance:IsShowExpFBRedPoint())
	self.red_point_list[4]:SetValue(FuBenData.Instance:IsShowStoryFBRedPoint())
	self.red_point_list[5]:SetValue(FuBenData.Instance:IsShowVipFBRedPoint())
	self.red_point_list[6]:SetValue(FuBenData.Instance:IsShowTowerFBRedPoint())
	self.red_point_list[7]:SetValue(FuBenData.Instance:IsShowKuafuFbRedPoint())
	self.red_point_list[8]:SetValue(FuBenData.Instance:IsShowQualityFBRedPoint())
	self.red_point_list[9]:SetValue(FuBenData.Instance:IsShowGuardFBRedPoint())
	self.red_point_list[10]:SetValue(FuBenData.Instance:GetPushRed(1))
	self.red_point_list[11]:SetValue(FuBenData.Instance:IsShowTeamFbRedPoint())
end

function FuBenView:OnFlush(param_t)
	RemindManager.Instance:Fire(RemindName.FuBenSingle)
	for k, v in pairs(param_t) do
		if k == "phase" then
			self.red_point_list[2]:SetValue(FuBenData.Instance:IsShowPhaseFBRedPoint())
			if self.advance_view then
				self.advance_view:FlushView()
			end
		elseif k == "exp" then
			self.red_point_list[3]:SetValue(FuBenData.Instance:IsShowExpFBRedPoint())
			if self.exp_view and self.exp_toggle.isOn == true then
				self.exp_view:FlushInfo()
			end
		elseif k == "vip" then
			self.red_point_list[5]:SetValue(FuBenData.Instance:IsShowVipFBRedPoint())
			if self.vip_view then
				self.vip_view:FlushView()
			end
		elseif k == "quality" then
			self.red_point_list[8]:SetValue(FuBenData.Instance:IsShowQualityFBRedPoint())
			if self.quality_view then
				self.quality_view:FlushView()
			end
		elseif k == "story" then
			self.red_point_list[4]:SetValue(FuBenData.Instance:IsShowStoryFBRedPoint())
			if self.story_view then
				self.story_view:FlushView()
			end
		elseif k == "tower" then
			self.red_point_list[6]:SetValue(FuBenData.Instance:IsShowTowerFBRedPoint())
			if self.tower_toggle.isOn then
				self.tower_content:SetActive(true)
			end
			if self.tower_view then
				self.tower_view:Flush()
			end
		elseif k == "kaifu_to_tower" then
			self.red_point_list[7]:SetValue(FuBenData.Instance:IsShowTowerFBRedPoint())
			if self.tower_view then
				self.tower_view:Flush()
			end
			self.tower_toggle.isOn = true
		elseif k == "tower_defend" then
			self.red_point_list[9]:SetValue(FuBenData.Instance:IsShowGuardFBRedPoint())
			if self.guard_view then
				self.guard_view:Flush("update")
			end
		elseif k == "kaifu_to_exp" then
			-- self.red_point_list[2]:SetValue(FuBenData.Instance:IsShowTowerFBRedPoint())
			if self.exp_view then
				self.exp_view:FlushInfo()
			end
			self.exp_toggle.isOn = true
		elseif k == "manypeople" then
			if self.many_people_view then
				self.many_people_view:Flush()
			end
		elseif k == "push" then
			self.red_point_list[1]:SetValue(FuBenData.Instance:GetPushRed(0) or FuBenData.Instance:GetPushReWardRed())
			if self.common_content_view then
				self.common_content_view:Flush()
			end
		elseif k == "push_special" then
			self.red_point_list[10]:SetValue(FuBenData.Instance:GetPushRed(1))
			if self.special_content_view then
				self.special_content_view:Flush()
			end
		elseif k == "team" then
			self.red_point_list[11]:SetValue(FuBenData.Instance:IsShowTeamFbRedPoint())
			if self.team_view then
				self.team_view:Flush()
			end
		end
		-- self.red_point_list[6]:SetValue(FuBenData.Instance:IsShowKuafuFbRedPoint())
		self:IsShowEffect()
		-- self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
	end
end

function FuBenView:IsShowEffect()
	if self.quality_toggle.isOn and self.quality_view then
		self.quality_view:IsShowEffect()
	elseif self.phase_toggle.isOn and self.advance_view then
		self.advance_view:IsShowEffect()
	elseif self.exp_toggle.isOn and self.exp_view then
		self.exp_view:IsShowEffect()
	elseif self.guard_toggle.isOn and self.guard_view then
		self.guard_view:IsShowEffect()
	end
end

--引导用函数
function FuBenView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.fb_tower then
		self:OpenAdvanceFB()
		self.tab_tower.toggle.isOn = true
	elseif index == TabIndex.fb_exp then
		self:OpenExpFB()
		self.tab_exp.toggle.isOn = true
	elseif index == TabIndex.fb_story then
		self:OpenStoryFB()
		self.tab_story.toggle.isOn = true
	elseif index == TabIndex.fb_phase then
		self:OpenTowerFB()
		self.tab_phase.toggle.isOn = true
	elseif index == TabIndex.fb_push then
		self:OpenPushFB()
		self.tab_push.toggle.isOn = true
	elseif index == TabIndex.fb_push_special then
		self:OpenPushSpecialFB()
		self.tab_push_special.toggle.isOn = true
	end
end


function FuBenView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == "tab" then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.fb_tower then
			if self.tab_tower.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_tower)
				return self.tab_tower, callback
			end
		elseif index == TabIndex.fb_exp then
			if self.tab_exp.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_exp)
				return self.tab_exp, callback
			end
		elseif index == TabIndex.fb_story then
			if self.tab_story.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_story)
				return self.tab_story, callback
			end
		elseif index == TabIndex.fb_phase then
			if self.tab_phase.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_phase)
				return self.tab_phase, callback
			end
		elseif index == TabIndex.fb_push then
			if self.tab_push.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_push)
				return self.tab_push, callback
			end
		elseif index == TabIndex.fb_push_special then
			if self.tab_push_special.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_push_special)
				return self.tab_push_special, callback
			end
		end
	elseif ui_name == GuideUIName.MountAttrBtn then
		if self.advance_view then
			local list = self.advance_view.list
			if list then
				for k, v in pairs(list) do
					local index = v:GetIndex()
					if index == 1 then
						local challenge_button = v.challenge_button
						if challenge_button and challenge_button.gameObject.activeInHierarchy then
							return challenge_button
						end
					end
				end
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	elseif ui_name == GuideUIName.StroyFbChangeBtn then
		if self.story_view then
			local list = self.story_view.list
			if list then
				for k, v in pairs(list) do
					local index = v:GetIndex()
					if index == 1 then
						local one_challenge = v.one_challenge
						if one_challenge and one_challenge.gameObject.activeInHierarchy then
							return one_challenge
						end
					end
				end
			end
		end
	end
end