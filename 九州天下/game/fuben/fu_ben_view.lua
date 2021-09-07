require("game/fuben/fu_ben_new_exp_view")
require("game/fuben/fu_ben_many_view")
FuBenView = FuBenView or BaseClass(BaseView)

function FuBenView:__init()
	self.ui_config = {"uis/views/fubenview", "FuBenView"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self:SetMaskBg()
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function FuBenView:__delete()
	self.cur_toggle = nil
end

function FuBenView:LoadCallBack()
	self.cur_toggle = 1
	local advance_content = self:FindObj("AdvanceFBContent")
	advance_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.advance_view = FuBenPhaseView.New(obj)
	end)

	local exp_content = self:FindObj("ExpFBContent")
	exp_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exp_view = FuBenNewExpView.New(obj)
	end)

	local vip_content = self:FindObj("VipFBContent")
	vip_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.vip_view = FuBenVipView.New(obj)
	end)

	self.tower_content = self:FindObj("TowerFBContent")
	self.tower_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.tower_view = FuBenTowerView.New(obj)
		--引导要用按钮
		self.tower_challenge = self.tower_view.tower_challenge
	end)

	--个人塔防
	local guard_content = self:FindObj("PersonGuardContent")
	guard_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.guard_view = FuBenGuardView.New(obj)
	end)


	local story_content = self:FindObj("StoryFBContent")
	story_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.story_view = FuBenStoryView.New(obj)
	end)

	local many_people_content = self:FindObj("ManyPeopleContent")
	many_people_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.many_people_view = TeamFBContent.New(obj)
		self.many_people_view:OpenCallBack()
	end)

	local push_common_content = self:FindObj("PushCommonContent")
	push_common_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.push_common_view = PushCommonView.New(obj)
		self.push_common_view:OpenCallBack()
	end)

	local push_special_content = self:FindObj("PushSpecialContent")
	push_special_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.push_special_view = PushSpecialView.New(obj)
		self.push_special_view:OpenCallBack()
	end)

	--引导用按钮
	self.tab_tower = self:FindObj("TowerToggle")
	self.tab_exp = self:FindObj("ExpToggle")
	self.tab_story = self:FindObj("StoryToggle")
	self.tab_vip = self:FindObj("VipToggle")
	self.tab_phase = self:FindObj("PhaseToggle")
	self.tab_many_people = self:FindObj("ManyPeopleToggle")
	self.tab_push_common = self:FindObj("PushCommonToggle")
	self.tab_push_special = self:FindObj("PushSpecialToggle")
	self.tab_person_guard_common = self:FindObj("PersonGuardCommon")

	self.tower_toggle = self.tab_tower.toggle
	self.exp_toggle = self.tab_exp.toggle
	self.story_toggle = self.tab_story.toggle
	self.vip_toggle = self.tab_vip.toggle
	self.phase_toggle = self.tab_phase.toggle
	self.many_people_toggle = self.tab_many_people.toggle
	self.push_common_toggle = self.tab_push_common.toggle
	self.push_special_toggle = self.tab_push_special.toggle
	self.tab_person_guard_common_toggle = self.tab_person_guard_common.toggle

	self.tower_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_tower))
	self.phase_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_phase))
	self.exp_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_exp))
	self.vip_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_vip))
	self.story_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_story))
	self.story_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_push_common))
	self.story_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_push_special))
	self.tab_person_guard_common_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.fb_person_guard))

	self.red_point_list = {
	[RemindName.FuBenAdvance] = self:FindVariable("ShowRedPoint1"),
	[RemindName.FuBenExp] = self:FindVariable("ShowRedPoint2"),
	[RemindName.FuBenStory] = self:FindVariable("ShowRedPoint3"),
	[RemindName.FuBenVip] = self:FindVariable("ShowRedPoint4"),
	[RemindName.FuBenTower] = self:FindVariable("ShowRedPoint5"),
	[RemindName.FuBenPeople] = self:FindVariable("ShowRedPoint6"),
	[RemindName.FuBenCommon] = self:FindVariable("ShowRedPoint7"),
	[RemindName.FuBenSpecial] = self:FindVariable("ShowRedPoint8"),						
}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.show_tower_bg = self:FindVariable("ShowTowerBg")
	self.show_exp_fuben_bg = self:FindVariable("ShowEXPFubenBg")

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
	self:ListenEvent("OpenPushCommon",
		BindTool.Bind(self.OpenPushCommonFB, self))
	self:ListenEvent("OpenPushSpecial",
		BindTool.Bind(self.OpenPushSpecialFB, self))
	self:ListenEvent("OpenGuardFB",
		BindTool.Bind(self.OpenGuardFB, self))


	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)
	
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function FuBenView:DoRemind()
	RemindManager.Instance:Fire(RemindName.FuBenAdvance)
	RemindManager.Instance:Fire(RemindName.FuBenExp)
	RemindManager.Instance:Fire(RemindName.FuBenStory)
	RemindManager.Instance:Fire(RemindName.FuBenVip)
	RemindManager.Instance:Fire(RemindName.FuBenTower)
	RemindManager.Instance:Fire(RemindName.FuBenPeople)
	RemindManager.Instance:Fire(RemindName.FuBenCommon)
	RemindManager.Instance:Fire(RemindName.FuBenSpecial)			
end

function FuBenView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function FuBenView:OnToggleChange(index, ison)
	ClickOnceRemindList[RemindName.FuBenAdvance] = 0
	RemindManager.Instance:Fire(RemindName.FuBenAdvance)

	if index == self.show_index then
		return
	end
	if ison then
		self.show_index = index
	end
	self.show_tower_bg:SetValue(index == TabIndex.fb_tower)
	self.show_exp_fuben_bg:SetValue(index == TabIndex.fb_exp)
end

function FuBenView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
	end
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

	if self.tower_view then
		self.tower_view:DeleteMe()
		self.tower_view = nil
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	if self.story_view then
		self.story_view:DeleteMe()
		self.story_view = nil
	end

	if self.many_people_view then
		self.many_people_view:DeleteMe()
		self.many_people_view = nil
	end

	if self.push_common_view ~= nil then
		self.push_common_view:DeleteMe()
		self.push_common_view = nil
	end

	if self.push_special_view ~= nil then
		self.push_special_view:DeleteMe()
		self.push_special_view = nil
	end

	if self.guard_view then
		self.guard_view:DeleteMe()
		self.guard_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.red_point_list = nil
	self.tower_content = nil
	self.tab_tower = nil
	self.tab_exp = nil
	self.tab_story = nil
	self.tab_vip = nil
	self.tab_phase = nil
	self.tab_many_people = nil
	self.tower_toggle = nil
	self.exp_toggle = nil
	self.story_toggle = nil
	self.vip_toggle = nil
	self.phase_toggle = nil
	self.many_people_toggle = nil
	self.tower_challenge = nil
	self.show_tower_bg = nil
	self.show_exp_fuben_bg = nil
	self.tab_person_guard_common = nil
	self.tab_person_guard_common_toggle = nil

	self.tab_push_common = nil
	self.tab_push_special = nil
	self.push_common_toggle = nil
	self.push_special_toggle = nil
end

function FuBenView:CloseCallBack()
	-- UnityEngine.PlayerPrefs.DeleteKey("chongzhi")
	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
		self.event_quest = nil
	end
	
	if self.tower_view then
		self.tower_view:CloseCallBack()
	end

	if self.advance_view then
		self.advance_view:CloseCallBack()
	end

	if self.push_common_view then
		self.push_common_view:CloseCallBack()
	end

	self.cur_toggle = 1
	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	ClickOnceRemindList[RemindName.FuBenAdvance] = 0
	if RemindManager ~= nil and RemindManager.Instance ~= nil then
		RemindManager.Instance:Fire(RemindName.FuBenAdvance)
	end
end

function FuBenView:ShowOrHideTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.tab_tower:SetActive(open_fun_data:CheckIsHide("fb_tower"))
	self.tab_exp:SetActive(open_fun_data:CheckIsHide("fb_exp"))
	self.tab_story:SetActive(false)--(open_fun_data:CheckIsHide("fb_story"))
	--self.tab_vip:SetActive(open_fun_data:CheckIsHide("fb_vip"))
	self.tab_phase:SetActive(open_fun_data:CheckIsHide("fb_phase"))
	self.tab_many_people:SetActive(open_fun_data:CheckIsHide("fb_many_people"))
	self.tab_push_common:SetActive(open_fun_data:CheckIsHide("fb_push_common"))
	self.tab_person_guard_common:SetActive(open_fun_data:CheckIsHide("fb_person_guard"))
	--self.tab_push_special = SetActive(open_fun_data:CheckIsHide("fb_push_special"))	
end

function FuBenView:OpenCallBack()
	FuBenCtrl.Instance:SendGetTowerFBGetInfo()

	-- 首次刷新数据
	self:ShowOrHideTab()
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	if self.item_change_callback == nil then
		self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	end

	if self.many_people_view then
		self.many_people_view:OpenCallBack()
	end
	-- self:FlushRedPoint()
end

function FuBenView:OnItemDataChange()
	if self.push_common_view then
		self.push_common_view:Flush()
	end
end

function FuBenView:FlushCommonView()
	if self.push_common_view then
		self.push_common_view:Flush()
	end
end

function FuBenView:OnClickClose()
	-- self.close_mode = (self.tower_view and self.tower_view.is_onekey_saodang) and CloseMode.CloseVisible or CloseMode.CloseDestroy
	self:Close()
end

function FuBenView:OpenAdvanceFB()
	if self.advance_view then
		self.advance_view:FlushView()
	end
	self:ShowIndex(TabIndex.fb_phase)
	self.cur_toggle = 1
end

function FuBenView:OpenExpFB()
	self:ShowIndex(TabIndex.fb_exp)
	self.cur_toggle = 2
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
	-- FuBenCtrl.Instance:SendGetTowerFBGetInfo()
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

function FuBenView:OpenPushCommonFB()
	if self.cur_toggle == 7 then
		return
	end

	FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_ALL_INFO)
	if self.push_common_view then
		self.push_common_view:OpenCallBack()
	end
	self:ShowIndex(TabIndex.fb_push_common)
	self.cur_toggle = 7
end

function FuBenView:OpenPushSpecialFB()
	if self.cur_toggle == 8 then
		return
	end
	if self.push_special_view then
		self.push_special_view:OpenCallBack()
	end
	self:ShowIndex(TabIndex.fb_push_special)
	self.cur_toggle = 8
end

function FuBenView:ChangeLeader()
	if self.many_people_view then
		self.many_people_view:ChangeLeader()
	end
end

function FuBenView:ShowIndexCallBack(index)
	if not self:IsRendering() then return end
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
		self.exp_toggle.isOn = true
	elseif index == TabIndex.fb_vip then
		-- self:OpenVipFB()
		self.vip_toggle.isOn = true
		self:Flush("vip")
	elseif index == TabIndex.fb_story then
		-- self:OpenStoryFB()
		self.story_toggle.isOn = true
		self:Flush("story")
	elseif index == TabIndex.fb_many_people then
		-- self:OpenStoryFB()
		self.many_people_toggle.isOn = true
		self:Flush("manypeople")
	elseif index == TabIndex.fb_push_common then
		self.push_common_toggle.isOn = true
		self:Flush("push_common")
	elseif index == TabIndex.fb_push_special then
		self.push_special_toggle.isOn = true
		self:Flush("push_special")
	end
end

function FuBenView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "tower" then
			if self.tower_view then
				self.tower_view:Flush()
			end	
		elseif k == "phase" then
			if self.advance_view then
				self.advance_view:Flush()
			end	
		elseif  k == "manypeople" or k == "team" then
			if self.many_people_view then
				self.many_people_view:Flush()
			end	
		elseif  k == "manypeople_reward" then
			if self.many_people_view then
				self.many_people_view:FlushItemReward()
			end
		end
	end
end

function FuBenView:SetRendering(value)
	BaseView.SetRendering(self, value)
	if value then
		self:ShowIndexCallBack(self.show_index)
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
	elseif index == TabIndex.fb_push_common then
		self:OpenPushCommonFB()
		self.tab_push_common.toggle.isOn = true
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
		elseif index == TabIndex.fb_push_common then
			if self.tab_push_common.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.fb_push_common)
				return self.tab_push_common, callback
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

function FuBenView:OpenGuardFB()
	if self.cur_toggle == 8 then
		return
	end
	if self.guard_view then
		self.guard_view:OpenCallBack()
	end
	-- self:ShowIndex(TabIndex.fb_guard)
	self.cur_toggle = 8
end