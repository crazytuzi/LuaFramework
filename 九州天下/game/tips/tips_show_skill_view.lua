TipsShowSkillView = TipsShowSkillView or BaseClass(BaseView)

function TipsShowSkillView:__init()
	self.ui_config = {"uis/views/tips/show_skill_tips", "ShowSkillTip"}
	self.play_audio = true
end

function TipsShowSkillView:ReleaseCallBack()
	self.skill_idx = -1
	self.icon = nil
	self.name = nil
	self.level = nil
	self.desc = nil
	self.state = nil
	self.active_level = nil
end

function TipsShowSkillView:LoadCallBack()
	self.icon = self:FindVariable("icon")
	self.name = self:FindVariable("name")
	self.level = self:FindVariable("level")
	self.desc = self:FindVariable("desc")
	self.state = self:FindVariable("state")
	self.active_level = self:FindVariable("active_level")
	self:ListenEvent("close_click", BindTool.Bind(self.CloseClick, self))
end

function TipsShowSkillView:OpenCallBack()
	if self.skill_idx ~= -1 then
		self:Flush()
	end
end

function TipsShowSkillView:CloseCallBack()
	self.skill_idx = -1
end

function TipsShowSkillView:CloseClick()
	self.skill_idx = -1
	self:Close()
end

function TipsShowSkillView:SetData(skill_idx)
	self.skill_idx = skill_idx
	self:Flush()
end

function TipsShowSkillView:OnFlush()
	local shenbing_data = ShenBingData.Instance
	local cfg = shenbing_data:GetShenBingSkillCfg(self.skill_idx)
	self.name:SetValue(cfg.skill_name)
	self.level:SetValue(cfg.skill_level)
	local desc = cfg.skill_dec
	if cfg.param_a ~= 0 then
		desc = string.gsub(desc,"%[param_a]", tonumber(cfg.param_a)/100)
	end
	if cfg.param_b ~= 0 then
		desc = string.gsub(desc,"%[param_b]", tonumber(cfg.param_b)/100)
	end
	if cfg.param_c ~= 0 then
		desc = string.gsub(desc,"%[param_c]", tonumber(cfg.param_c)/1000)
	end
	if cfg.param_c ~= 0 then
		desc = string.gsub(desc,"%[param_d]", tonumber(cfg.param_d)/1000)
	end
	self.desc:SetValue(desc)
	self.state:SetValue(shenbing_data:GetIsActive(self.skill_idx) and "("..Language.Common.YiActivate..")" or ToColorStr("("..Language.Common.NoActivate..")", TEXT_COLOR.RED))
	self.active_level:SetValue(cfg.shenbing_level)
	local bundle, asset = ResPath.GetShenBingSkillIcon(self.skill_idx + 1)
	self.icon:SetAsset(bundle, asset)
end
