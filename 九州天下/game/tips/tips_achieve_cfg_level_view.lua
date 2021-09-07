TipsAchieveCfgLevelView = TipsAchieveCfgLevelView or BaseClass(BaseView)

function TipsAchieveCfgLevelView:__init()
	self.ui_config = {"uis/views/tips/achievecfgleveltips", "AchieveCfgLevelView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

	self.cfg_level = 0
end

function TipsAchieveCfgLevelView:__delete()

end

function TipsAchieveCfgLevelView:LoadCallBack()
	self.level_text = self:FindVariable("LevelText")
	self.content_text = self:FindVariable("ContentText")

	self:ListenEvent("CloseCfgLevelTip", BindTool.Bind(self.OnCloseCfgLevelTip, self))
	self:ListenEvent("GoToSkillTalent", BindTool.Bind(self.OnGoToSkillTalent, self))
end

function TipsAchieveCfgLevelView:ReleaseCallBack()
	self.level_text = nil
	self.content_text = nil
	self.cfg_level = 0
end

function TipsAchieveCfgLevelView:OpenCallBack()
	self:Flush()
end

function TipsAchieveCfgLevelView:OnCloseCfgLevelTip()
	self:Close()
end

function TipsAchieveCfgLevelView:OnGoToSkillTalent()
	ViewManager.Instance:Open(ViewName.RoleSkillView, TabIndex.role_skill_talent)
	self:OnCloseCfgLevelTip()
end

function TipsAchieveCfgLevelView:SetLevel(value)
	if value == nil then return end
	self.cfg_level = value
end

function TipsAchieveCfgLevelView:OnFlush()
	self.level_text:SetValue(string.format(Language.Common.AchieveCfgLevelText,self.cfg_level))
	self.content_text:SetValue(Language.Common.AchieveCfgLevelContentText)
end
