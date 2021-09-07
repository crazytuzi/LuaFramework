require("game/tips/tips_achieve_cfg_level_view")

TipsAchieveCfgLevelCtrl = TipsAchieveCfgLevelCtrl or BaseClass(BaseController)

function TipsAchieveCfgLevelCtrl:__init()
	if TipsAchieveCfgLevelCtrl.Instance ~= nil then
		error("[TipsAchieveCfgLevelCtrl] attempt to create singleton twice!")
		return
	end
	TipsAchieveCfgLevelCtrl.Instance = self

	self.tips_achieve_cfg_level_view = TipsAchieveCfgLevelView.New(ViewName.TipsAchieveCfgLevelView)

	if not self.change_callback then
		self.change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.change_callback)
	end
end

function TipsAchieveCfgLevelCtrl:__delete()
	if self.tips_achieve_cfg_level_view then
		self.tips_achieve_cfg_level_view:DeleteMe()
		self.tips_achieve_cfg_level_view = nil
	end

	if self.change_callback then
		if PlayerData.Instance then
			PlayerData.Instance:UnlistenerAttrChange(self.change_callback)
		end
		self.change_callback = nil
	end
end

function TipsAchieveCfgLevelCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		local remind_level_cfg = PlayerData.Instance:GetRemindLevelCfg()
		if value == nil or old_value == nil or value == old_value or remind_level_cfg == nil then return end
		for k,v in pairs(remind_level_cfg) do
			if v.need_achieve_level == value then
				self.tips_achieve_cfg_level_view:SetLevel(value)
				self:OpenTipsAchieveCfgLevelView()
			end
		end
	end
end

function TipsAchieveCfgLevelCtrl:OpenTipsAchieveCfgLevelView()
	if self.tips_achieve_cfg_level_view ~= nil then
		self.tips_achieve_cfg_level_view:Open()
	end
end