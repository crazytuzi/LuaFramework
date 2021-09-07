TipsZhiBaoSkillView = TipsZhiBaoSkillView or BaseClass(BaseView)

function TipsZhiBaoSkillView:__init()
	self.ui_config = {"uis/views/tips/zhibaoskilltips", "ZhiBaoSkillTips"}
	self.skill_data = nil
	self.next_skill_data = nil
	self.play_audio = true
end

function TipsZhiBaoSkillView:__delete()

end

function TipsZhiBaoSkillView:SetData(skill_data, next_skill_data)
	self.skill_data = skill_data
	self.next_skill_data = next_skill_data
end

-- 创建完调用
function TipsZhiBaoSkillView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self.skill_name = self:FindVariable("SkillName")
	self.skill_level = self:FindVariable("SkillLevel")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextEffect")
	self.upgrade_condition = self:FindVariable("UpgradeCondition")
	self.active_text = self:FindVariable("ActiveText")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.is_maxlevel = self:FindVariable("is_maxlevel")
	self.next_title = self:FindVariable("NextTitle")
end

function TipsZhiBaoSkillView:ReleaseCallBack()
	-- 清理变量和对象
	self.skill_name = nil
	self.skill_level = nil
	self.current_effect = nil
	self.next_effect = nil
	self.upgrade_condition = nil
	self.active_text = nil
	self.skill_icon = nil
	self.is_maxlevel = nil
	self.next_title = nil
end

function TipsZhiBaoSkillView:CloseView()
	self:Close()
end

function TipsZhiBaoSkillView:OpenCallBack()
	if self.skill_data ~= nil then
		--激活
		self.active_text:SetValue("")
		--TODO目前没有图标
		self.skill_icon:SetAsset(ResPath.GetBaoJuSkillIcon(self.skill_data.skill_idx + 1))
		self.skill_name:SetValue(self.skill_data.skill_name)
		self.skill_level:SetValue(self.skill_data.skill_level)
		self.current_effect:SetValue(self.skill_data.skill_dec)
	else
		--未激活
		self.skill_name:SetValue(self.next_skill_data.skill_name)
		--TODO目前没有图标
		self.skill_icon:SetAsset(ResPath.GetBaoJuSkillIcon(self.next_skill_data.skill_idx + 1))
		self.active_text:SetValue("("..ToColorStr(Language.Common.NoActivate, TEXT_COLOR.RED)..")")
		self.current_effect:SetValue(Language.Common.No)
		self.skill_level:SetValue(0)
	end

	if self.next_skill_data ~= nil then
		self.is_maxlevel:SetValue(false)
		self.upgrade_condition:SetValue(Language.BaoJu.ZhiBaoUpGrade..ToColorStr(self.next_skill_data.zhibao_level, TEXT_COLOR.GREEN)..Language.Common.Ji)
		self.next_title:SetValue(Language.BaoJu.NextSkill)
		self.next_effect:SetValue(self.next_skill_data.skill_dec)
	else
		self.is_maxlevel:SetValue(true)
		self.next_effect:SetValue("")
		self.next_title:SetValue(Language.Common.YiManJi)
		self.upgrade_condition:SetValue(Language.Common.MaxLevel)
	end
end

