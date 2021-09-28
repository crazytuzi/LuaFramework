TipsShowSkillView = TipsShowSkillView or BaseClass(BaseView)

local SKILL_TIPS_FROM_SHENBING = 0
local SKILL_TIPS_FROM_CLOAK = 1

SKILL_TIP_FROM_VIEW_TYPE = {
	["shenbing"] = SKILL_TIPS_FROM_SHENBING,
	["cloak"] = SKILL_TIPS_FROM_CLOAK,
}

function TipsShowSkillView:__init()
	self.ui_config = {"uis/views/tips/showskilltips_prefab", "ShowSkillTip"}
	self.play_audio = true
	self.from_view = 0
end

function TipsShowSkillView:ReleaseCallBack()
	self.skill_idx = -1
	self.icon = nil
	self.name = nil
	self.level = nil
	self.desc = nil
	self.state = nil
	self.active_level = nil
	self.from_view = 0
	self.show_text = nil
end

function TipsShowSkillView:LoadCallBack()
	self.icon = self:FindVariable("icon")
	self.name = self:FindVariable("name")
	self.level = self:FindVariable("level")
	self.desc = self:FindVariable("desc")
	self.state = self:FindVariable("state")
	self.active_level = self:FindVariable("active_level")
	self.show_text = self:FindVariable("show_text")
	self:ListenEvent("close_click", BindTool.Bind(self.CloseClick, self))
end

function TipsShowSkillView:OpenCallBack()
	if self.skill_idx ~= -1 then
		self:Flush()
	end
end

function TipsShowSkillView:CloseCallBack()
	self.skill_idx = -1
	self.from_view = 0
end

function TipsShowSkillView:CloseClick()
	self.skill_idx = -1
	self:Close()
	self.from_view = 0
end

function TipsShowSkillView:SetData(skill_idx, from_view)
	self.skill_idx = skill_idx
	self.from_view = SKILL_TIP_FROM_VIEW_TYPE[from_view]
	self:Flush()
end

function TipsShowSkillView:OnFlush()
	if self.from_view == SKILL_TIPS_FROM_SHENBING then
		self:OnFlushShenBingSkill()
	elseif self.from_view == SKILL_TIPS_FROM_CLOAK  then
		self:OnFlushCloakSkill()
	end
end

function TipsShowSkillView:OnFlushShenBingSkill()
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
	if cfg.param_d ~= 0 then
		desc = string.gsub(desc,"%[param_d]", tonumber(cfg.param_d)/1000)
	end
	self.desc:SetValue(desc)
	self.state:SetValue(shenbing_data:GetIsActive(self.skill_idx) and ToColorStr("("..Language.Common.YiActivate..")", TEXT_COLOR.BLUE_4) or ToColorStr("("..Language.Common.NoActivate..")", TEXT_COLOR.RED))
	self.active_level:SetValue(cfg.shenbing_level)
	self.show_text:SetValue(Language.Common.ShenBingSkillName)
	local bundle, asset = ResPath.GetShenBingSkillIcon(self.skill_idx + 1)
	self.icon:SetAsset(bundle, asset)
end

function TipsShowSkillView:OnFlushCloakSkill()
	local cloak_data = CloakData.Instance
	local cfg = cloak_data:GetCloakSkillCfgBuyIndex(self.skill_idx)
	self.name:SetValue(cfg.skill_name)
	self.level:SetValue(cfg.skill_level)
	local desc = cfg.desc
	if cfg.param_a ~= 0 then
		desc = string.gsub(desc,"%[param_a]", tonumber(cfg.param_a)/100)
	end
	if cfg.param_b ~= 0 then
		desc = string.gsub(desc,"%[param_b]", tonumber(cfg.param_b)/100)
	end
	if cfg.param_c ~= 0 then
		desc = string.gsub(desc,"%[param_c]", tonumber(cfg.param_c)/1000)
	end
	if cfg.param_d ~= 0 then
		desc = string.gsub(desc,"%[param_d]", tonumber(cfg.param_d)/1000)
	end
	self.desc:SetValue(desc)
	self.state:SetValue(cloak_data:GetSkillIsActive(self.skill_idx) and ToColorStr("("..Language.Common.YiActivate..")", TEXT_COLOR.BLUE_4) or ToColorStr("("..Language.Common.NoActivate..")", TEXT_COLOR.RED))
	self.active_level:SetValue(cfg.level)
	self.show_text:SetValue(Language.Common.PiFengSkillName)
	local bundle, asset = ResPath.GetCloakSkillIcon(self.skill_idx + 1)
	self.icon:SetAsset(bundle, asset)
end