GuildFirstView = GuildFirstView or BaseClass(BaseView)

function GuildFirstView:__init()
	self.ui_config = {"uis/views/citycombatview_prefab","GuildFirstView"}
	self.play_audio = true

	self.act_id = ACTIVITY_TYPE.GUILDBATTLE
end

function GuildFirstView:__delete()

end

function GuildFirstView:ReleaseCallBack()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	-- 清理变量和对象
	self.role_display = nil
	self.explain = nil
	self.guild_name = nil
	self.hui_zhang_name = nil
	self.title = nil
	self.desc = nil
end

function GuildFirstView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))

	self.role_display = self:FindObj("RoleDisplay")

	self.explain = self:FindVariable("Explain")
	self.guild_name = self:FindVariable("GuildName")
	self.hui_zhang_name = self:FindVariable("HuiZhangName")
	self.title = self:FindVariable("Title")
	self.desc = self:FindVariable("desc")

	local title_id = TitleData.Instance:GetActivityTitleByType(ACTIVITY_TYPE.GUILDBATTLE)
	if title_id then
		self.title:SetAsset(ResPath.GetTitleIcon(title_id))
	end
	self.desc:SetValue(Language.Daily.GuildFirstDesc)
end

function GuildFirstView:OpenCallBack()
	self:FlushTuanZhangModel()
	self.activity_call_back = BindTool.Bind(self.ActivityCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
	self:Flush()
end

function GuildFirstView:CloseCallBack()
	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end
end

function GuildFirstView:CloseWindow()
	self:Close()
end

function GuildFirstView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function GuildFirstView:ClickEnter()
	self:Close()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
	end
end

function GuildFirstView:FlushTuanZhangModel(uid, info)
	info = GameVoManager.Instance:GetMainRoleVo()
	if not self.role_model then
		self.role_model = RoleModel.New("guil_first_panle")
		self.role_model:SetDisplay(self.role_display.ui3d_display)
	end
	if self.role_model then
		self.role_model:SetModelResInfo(info, false, true, true)
	end
end

function GuildFirstView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self.explain:SetValue(act_info.dec)
end

function GuildFirstView:ActivityCallBack(activity_type)
	if activity_type == self.act_id then
		self:Flush()
	end
end