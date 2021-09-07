require("game/role_skill/active_skill_view")
require("game/role_skill/passive_skill_view")
require("game/role_skill/role_talent_view")
require("game/role_skill/team_skill_view")

local SKILL_ACTIVE = 0
local SKILL_PASSIVE = 1
local ROLE_TALENT = 2
RoleSkillView = RoleSkillView or BaseClass(BaseView)

function RoleSkillView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/roleskill","RoleSkillView"}
	self.play_audio = true
	self.def_index = 0
	self.cur_toggle = TabIndex.role_skill_active
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function RoleSkillView:__delete()
	
end

function RoleSkillView:ReleaseCallBack()
	self.cur_toggle = TabIndex.role_skill_active
	if self.active_skill_view then
		self.active_skill_view:DeleteMe()
		self.active_skill_view = nil
	end

	if self.passive_skill_view then
		self.passive_skill_view:DeleteMe()
		self.passive_skill_view = nil
	end

	if self.role_talent_view then
		self.role_talent_view:DeleteMe()
		self.role_talent_view = nil
	end

	if self.team_skill_view then
		self.team_skill_view:DeleteMe()
		self.team_skill_view = nil
	end

	if nil ~= self.skill_flush_event then
		GlobalEventSystem:UnBind(self.skill_flush_event)
		self.skill_flush_event = nil
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	self.toggle_active = nil
	self.toggle_passive = nil
	self.toggle_talent = nil
	self.toggle_team = nil
	self.red_point_list = nil
	self.show_talent_bg = nil
	self.show_passive_bg = nil
	self.show_team_skill_bg = nil
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.RoleSkillView)
	end
end

function RoleSkillView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))

	self.show_talent_bg = self:FindVariable("ShowTalentBg")
	self.show_passive_bg = self:FindVariable("ShowPassiveBg")
	self.show_team_skill_bg = self:FindVariable("ShowTeamSkillBg")

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	--页签
	self.toggle_active = self:FindObj("ToggleActive")
	self.toggle_passive = self:FindObj("TogglePassive")
	self.toggle_talent = self:FindObj("ToggleTalent")
	self.toggle_team = self:FindObj("ToggleTeam")

	self.toggle_active.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.role_skill_active))
	self.toggle_passive.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.role_skill_player))
	self.toggle_talent.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.role_skill_talent))
	self.toggle_team.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, TabIndex.role_skill_team))

	self.active_skill_view = ActiveSkillView.New()
	local active_skill_content = self:FindObj("SkillActiveContent")
	active_skill_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.active_skill_view:SetInstance(obj)
	end)

	self.passive_skill_view = PassiveSkillView.New()
	local passive_skill_content = self:FindObj("SkillPassiveContent")
	passive_skill_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.passive_skill_view:SetInstance(obj)
	end)
	
	self.role_talent_view = RoleTalentView.New()
	local role_talent_content = self:FindObj("SkillTalentContent")
	role_talent_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.role_talent_view:SetInstance(obj)
	end)

	self.team_skill_view = TeamSkillView.New()
	local team_skill_content = self:FindObj("SkillTeamContent")
	team_skill_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.team_skill_view:SetInstance(obj)
		self.team_skill_view:Flush()
	end)

	self.skill_flush_event = GlobalEventSystem:Bind(
		SkillEventType.SKILL_FLUSH,
		BindTool.Bind1(self.HandleSkillFlush, self))
	
	self.red_point_list = {
		[RemindName.SkillActive] = self:FindVariable("ShowSkillActiveRed"),
		[RemindName.SkillPassive] = self:FindVariable("ShowSkillPassiveRed"),
		[RemindName.RoleTalent] = self:FindVariable("ShowSkillTalentRed"),
		[RemindName.RoleTeamSkill] = self:FindVariable("ShowTeamSkillRed")
	}
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
	self:InitTab()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.RoleSkillView, BindTool.Bind(self.GetUiCallBack, self))
end

function RoleSkillView:HandleSkillFlush(item_index)
	item_index = item_index or -1
	self:Flush("all", {["index" .. item_index] = item_index})
end

function RoleSkillView:InitTab()
	if not self:IsOpen() then return end

	self.toggle_active:SetActive(OpenFunData.Instance:CheckIsHide("role_skill_active"))
	self.toggle_passive:SetActive(OpenFunData.Instance:CheckIsHide("role_skill_player"))
	self.toggle_talent:SetActive(OpenFunData.Instance:CheckIsHide("role_skill_talent"))
	self.toggle_team:SetActive(OpenFunData.Instance:CheckIsHide("role_skill_team"))
end

function RoleSkillView:OpenCallBack()

end

function RoleSkillView:CloseCallBack()
	if self.active_skill_view then
		self.active_skill_view:CloseCallBack()
	end
	if self.passive_skill_view then
		self.passive_skill_view:CloseCallBack()
	end
end

function RoleSkillView:ShowIndexCallBack(index)
	self.show_talent_bg:SetValue(TabIndex.role_skill_talent == index)
	self.show_passive_bg:SetValue(TabIndex.role_skill_player == index)
	self.show_team_skill_bg:SetValue(TabIndex.role_skill_team == index)
	if index == TabIndex.role_skill_active then
		self.toggle_active.toggle.isOn = true
		self.active_skill_view:SetFirstOpen(true)
	elseif index == TabIndex.role_skill_player then
		self.toggle_passive.toggle.isOn = true
	elseif index == TabIndex.role_skill_talent then
		self.toggle_talent.toggle.isOn = true
		local talent_data = RoleSkillData.Instance:GetRoleTalentData()
		if talent_data.page_index then
			local page_index = talent_data.page_index
			RoleSkillCtrl.Instance:SendTalentSystemOperateReq(TALENT_SYSTEM_REQ_TYPE.TALENT_SYSTEM_REQ_TYPE_GET_INFO, page_index)
		end
	elseif index == TabIndex.role_skill_team then
		self.toggle_team.toggle.isOn = true

	end
	if self.active_skill_view then
		self.active_skill_view:CloseCallBack()
	end
	if self.passive_skill_view then
		self.passive_skill_view:CloseCallBack()
	end

	self:Flush()
end

function RoleSkillView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			if self.show_index == TabIndex.role_skill_active then
				if self.active_skill_view then
					self.active_skill_view:Flush()
				end

			elseif self.show_index == TabIndex.role_skill_player then
				if self.passive_skill_view then
					self.passive_skill_view:Flush()
					self.active_skill_view:StopLevelUp()
				end

			elseif self.show_index == TabIndex.role_skill_talent then
				if self.role_talent_view then
					self.role_talent_view:Flush()
					self.active_skill_view:StopLevelUp()
				end

			elseif self.show_index == TabIndex.role_skill_team then
				self.team_skill_view:Flush()
			end
			RemindManager.Instance:Fire(RemindName.SkillActive)
		elseif k == "add_exp" then
			if self.show_index == TabIndex.role_skill_team and self.team_skill_view then
				self.team_skill_view:Flush("add_exp")
			end
		end
	end
end
function RoleSkillView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

-- 关闭事件
function RoleSkillView:HandleClose()
	if self.active_skill_view then
		self.active_skill_view:StopLevelUp()
	end
	ViewManager.Instance:Close(ViewName.RoleSkillView)
end

function RoleSkillView:OnToggleChange(index, ison)
	if self.cur_toggle == index then return end
	self.cur_toggle = index
	if ison then
		self:ChangeToIndex(index)
		if index ~= TabIndex.role_skill_team and self.team_skill_view:GetIsInAuto() then
			self:StopTeamSkillUpGrade()
		end
	end
end

function RoleSkillView:TeamSkillAutoUpGrade()
	self.team_skill_view:AutoUpGradeTimeQuest()
end

function RoleSkillView:StopTeamSkillUpGrade()
	self.team_skill_view:StopAutoUpGrade()
end

function RoleSkillView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		else
			return NextGuideStepFlag
		end
	else
		if ui_name == GuideUIName.SkillAutoLevel then
			return self.active_skill_view:GetAutoButton()
		end
	end
end