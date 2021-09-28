TipSkillView = TipSkillView or BaseClass(BaseView)

local PASSIVE_TYPE = 73

function TipSkillView:__init()
	self.ui_config = {"uis/views/tips/skilltip_prefab","SkillTip"}
	self.view_layer = UiLayer.Pop
	self.skill_id = 0
	self.skill_level = 0
	self.has_active = 0
	self.play_audio = true
end

-- 创建完调用
function TipSkillView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.level = self:FindVariable("Level")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextEffect")
	self.is_Active_text = self:FindVariable("IsActive")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.skill_name = self:FindVariable("SkillName")
	self.skill_type = self:FindVariable("SkillType")

	self.show_up_level_tip = self:FindVariable("ShowUpLevelTip")
	self.can_up_level_grade = self:FindVariable("Grade")
	self.show_effect = self:FindVariable("ShowEffect")
end

function TipSkillView:ReleaseCallBack()
	-- 清理变量和对象
	self.level = nil
	self.current_effect = nil
	self.next_effect = nil
	self.is_Active_text = nil
	self.skill_icon = nil
	self.skill_name = nil
	self.skill_type = nil

	self.show_up_level_tip = nil
	self.can_up_level_grade = nil
	self.show_effect = nil
end

function TipSkillView:__delete()

end

function TipSkillView:OnClickCloseButton()
	self:Close()
end

function TipSkillView:CloseCallBack()

end

function TipSkillView:SetData(skill_id, skill_level, has_active)
	self.skill_id = skill_id
	self.skill_level = skill_level
	self.has_active = has_active == nil and true or has_active
	if self.skill_id > 0 then
		self:Open()
		self:Flush()
	end
end

function TipSkillView:OnFlush(param_list)
	self.is_Active_text:SetValue(self.has_active and "" or ("<color=#ff0000>(" .. Language.Common.NoActivate .. ")</color>"))
	self.level:SetValue(self.skill_level)
	local skill_type = self.skill_id ~= PASSIVE_TYPE and Language.Common.ZhuDongSkill or Language.Common.BeiDongSkill
	self.skill_type:SetValue(skill_type)
	local skill_cfg = SkillData.GetSkillinfoConfig(self.skill_id)
	if skill_cfg then
		self.skill_icon:SetAsset(ResPath.GetRoleSkillIconTwo(skill_cfg.skill_icon))
		self.skill_name:SetValue(skill_cfg.skill_name)
		self.current_effect:SetValue(SkillData.RepleCfgContent(self.skill_id, self.skill_level))
	end
end