GuildHeJiuView = GuildHeJiuView or BaseClass(BaseView)

function GuildHeJiuView:__init()
	self.ui_config = {"uis/views/guildview_prefab", "GuildHeJiu"}
	self.play_audio = true
	self.view_layer = UiLayer.PopTop
	self.my_rank_index = 0
	self.black_mask_color_a = 0.7845
end

function GuildHeJiuView:__delete()
end

function GuildHeJiuView:LoadCallBack()
	self.display = self:FindObj("Display")
end

function GuildHeJiuView:ReleaseCallBack()
	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	self.display = nil
end

function GuildHeJiuView:OnFlush()

end

function GuildHeJiuView:OpenCallBack()
	GlobalTimerQuest:AddDelayTimer(function ()
		self:Close()
	end, 2.5)

	local role_info = GameVoManager.Instance:GetMainRoleVo()
	if nil == role_info then
		return
	end
	local cfg = GuildBonfireData.Instance:GetBonfireOtherCfg()
	local asset = cfg.assetbundle
	local bundle = cfg.model_name
	local daojiu_asset = "effects2/prefab/misc/daojiu_prefab"
	local daojiu_bundle = "daojiu"

	self.role_model = RoleModel.New("guild_drink_panel")
	self.role_model:SetDisplay(self.display.ui3d_display)
	self.role_model:SetMainAsset(asset, bundle)
	self.role_model:SetParticleAsset(daojiu_asset, daojiu_bundle)
end