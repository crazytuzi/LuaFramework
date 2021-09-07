TipsInviteView = TipsInviteView or BaseClass(BaseView)

function TipsInviteView:__init()
	self.ui_config = {"uis/views/tips/invitetip", "InviteTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)

	self.world_notice = ""
	self.guild_notice = ""

	self.open_type = ""
end

function TipsInviteView:__delete()
end

function TipsInviteView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickFriend",BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.FriendType))
	self:ListenEvent("OnClickGuild",BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.GuildType))
	self:ListenEvent("OnClickWorld",BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.WorldType))
	self:ListenEvent("OnClickNear",BindTool.Bind(self.OnClick, self, ScoietyData.InviteType.NearType))
end

function TipsInviteView:CloseWindow()
	self:Close()
end

function TipsInviteView:OnClick(value)
	if value == ScoietyData.InviteType.GuildType then
		if GuildData.Instance.guild_id <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		else
			local team_index = ScoietyData.Instance:GetTeamIndex()
			if team_index then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.GuildInvite)
				local content = ""
				if self.open_type == "" or self.open_type == ScoietyData.InviteOpenType.Normal then
					content = string.format(Language.Society.SomeOneTeamInvite, team_index, 0, self.open_type)
				elseif self.open_type == ScoietyData.InviteOpenType.ExpFuBen then
					local cfg = FuBenData.Instance:GetExpFBOtherCfg() or {}
					local min_level = cfg.open_level or 0
					content = string.format(Language.Society.TeamExpInvite, team_index, min_level, self.open_type)

				elseif self.open_type == ScoietyData.InviteOpenType.ManyFuBen then
					local fuben_layer = FuBenData.Instance:GetSelectFuBenLayer()
					local show_config = FuBenData.Instance:GetShowConfigByLayer(fuben_layer) or {}
					local min_level = show_config.level or 0
					local name = show_config.name or ""
					content = string.format(Language.FuBen.GuildNotice, name, team_index, min_level, self.open_type)
				end
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, content, CHAT_CONTENT_TYPE.TEXT)
				ScoietyCtrl.Instance:InviteUserReq(0, TEAM_INVITE_TYPE.TEAM_INVITE_TYPE_CAMP_MEMBER)
			end
		end
	elseif value == ScoietyData.InviteType.FriendType or value == ScoietyData.InviteType.NearType then
		ScoietyCtrl.Instance:ShowInviteView(value)
	else
		--等级限制
		local level = GameVoManager.Instance:GetMainRoleVo().level
		if level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
			local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
			return
		end

		local team_index = ScoietyData.Instance:GetTeamIndex()
		if team_index then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.CampInvite)
			ScoietyCtrl.Instance:InviteUserReq(0, TEAM_INVITE_TYPE.TEAM_INVITE_TYPE_CAMP_MEMBER)
			local content = ""
			if self.open_type == "" or self.open_type == ScoietyData.InviteOpenType.Normal then
				content = string.format(Language.Society.SomeOneTeamInvite, team_index, 0, self.open_type)
			elseif self.open_type == ScoietyData.InviteOpenType.ExpFuBen then
				local cfg = FuBenData.Instance:GetExpFBOtherCfg() or {}
				local min_level = cfg.open_level or 0
				content = string.format(Language.Society.TeamExpInvite, team_index, min_level, self.open_type)
			elseif self.open_type == ScoietyData.InviteOpenType.ManyFuBen then
				local fuben_layer = FuBenData.Instance:GetSelectFuBenLayer()
				local show_config = FuBenData.Instance:GetShowConfigByLayer(fuben_layer) or {}
				local min_level = show_config.level or 0
				local name = show_config.name or ""
				content = string.format(Language.FuBen.WorldNotice, name, team_index, min_level, self.open_type)
			end
			--发送国家频道提示
			ChatCtrl.SendChannelChat(CHANNEL_TYPE.CAMP, content, CHAT_CONTENT_TYPE.TEXT)
		end
	end
	self:Close()
end

function TipsInviteView:CloseCallBack()
	self.open_type = ""
end

function TipsInviteView:SetOpenType(open_type)
	self.open_type = open_type
end

function TipsInviteView:SetWorldNotice(notice)
	self.world_notice = notice or ""
end

function TipsInviteView:SetGuildNotice(notice)
	self.guild_notice = notice or ""
end