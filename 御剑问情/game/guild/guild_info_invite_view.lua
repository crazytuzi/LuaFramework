GuildInfoInviteView = GuildInfoInviteView or BaseClass(BaseView)

function GuildInfoInviteView:__init()
	self.ui_config = {"uis/views/guildview_prefab","InviteWindow"}
	self.view_layer = UiLayer.Pop
end

function GuildInfoInviteView:__delete()

end

function GuildInfoInviteView:LoadCallBack()
	self:ListenEvent("ClickLevelInput",
		BindTool.Bind(self.ClickLevelInput, self))
	self:ListenEvent("ClickFPInput",
		BindTool.Bind(self.ClickFPInput, self))
	self:ListenEvent("OnSaveSetting",
		BindTool.Bind(self.OnSaveSetting, self))
	self:ListenEvent("ClickNoLimit",
		BindTool.Bind(self.ClickNoLimit, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))	

	self.toggle_forbid = self:FindObj("ToggleForbid").toggle
	self.toggle_approver = self:FindObj("ToggleApprover").toggle
	self.toggle_unlimited = self:FindObj("ToggleUnlimited").toggle
	self.level_input = self:FindObj("LevelInput"):GetComponent("InputField")
	self.fp_input = self:FindObj("FpInput"):GetComponent("InputField")

	self.gray = self:FindVariable("Gray")

end

function GuildInfoInviteView:OpenCallBack()
	self.gray:SetValue(true)
	self.level_input.text = Language.Daily.CapNoLimmit
	self.fp_input.text = Language.Daily.CapNoLimmit
	if GuildDataConst.GUILDVO.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.APPROVAL then
		self.toggle_approver.isOn = true
	elseif GuildDataConst.GUILDVO.applyfor_setup == GuildDataConst.GUILD_SETTING_MODEL.FORBID then
		self.toggle_forbid.isOn = true
	else
		self.toggle_unlimited.isOn = true
		self.gray:SetValue(false)
		self.level_input.text = tostring(GuildDataConst.GUILDVO.applyfor_need_level)
		self.fp_input.text = tostring(GuildDataConst.GUILDVO.applyfor_need_capability)
	end
end

function GuildInfoInviteView:ReleaseCallBack()
	self.toggle_forbid = nil
	self.toggle_approver = nil
	self.toggle_unlimited = nil
	self.level_input = nil
	self.fp_input = nil
	self.gray = nil
end

function GuildInfoInviteView:CloseCallBack()

end

function GuildInfoInviteView:OnFlush()

end

function GuildInfoInviteView:ClickLevelInput()
	TipsCtrl.Instance:OpenCommonInputView(self.level_input.text, function(num) self.level_input.text = num end, nil, 1000)
end

function GuildInfoInviteView:ClickFPInput()
	TipsCtrl.Instance:OpenCommonInputView(self.fp_input.text, function(num) self.fp_input.text = num end, nil, 999999)
end

function GuildInfoInviteView:ClickNoLimit(switch)
	if not switch then
		self.level_input.text = Language.Daily.CapNoLimmit
		self.fp_input.text = Language.Daily.CapNoLimmit
	else
		self.level_input.text = "0"
		self.fp_input.text = "0"
	end
	self.gray:SetValue(not switch)
end

function GuildInfoInviteView:OnSaveSetting()
	local need_capability = 0
	local need_level = 0
	local model = GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS
	if self.toggle_unlimited.isOn then
		model = GuildDataConst.GUILD_SETTING_MODEL.AUTOPASS
		need_capability = tonumber(self.fp_input.text) or 0
		need_level = tonumber(self.level_input.text) or 0
	elseif self.toggle_forbid.isOn then
		model = GuildDataConst.GUILD_SETTING_MODEL.FORBID
	else
		model = GuildDataConst.GUILD_SETTING_MODEL.APPROVAL
	end
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		GuildCtrl.Instance:SendSettingGuildReq(guild_id, model, need_capability, need_level)
		 GuildDataConst.GUILDVO.applyfor_setup = model
		 GuildDataConst.GUILDVO.applyfor_need_level = need_level
		 GuildDataConst.GUILDVO.applyfor_need_capability = need_capability
	end
	self:Close()
end