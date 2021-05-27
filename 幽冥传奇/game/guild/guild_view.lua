local GuildView = GuildView or BaseClass(SubView)

function GuildView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.title_img_path = ResPath.GetWord("word_guild")
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"guild_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}, true, 999},
	}

	self.remind_temp = {}
	self.view_table = {
		[true] = {-- 有行会
			views = {
				ViewDef.Guild.GuildView.GuildInfo,
				ViewDef.Guild.GuildView.GuildMember,
				ViewDef.Guild.GuildView.GuildBuild,
				ViewDef.Guild.GuildView.GuildList,
				ViewDef.Guild.GuildView.GuildStorage,
				ViewDef.Guild.GuildView.GuildActivity,
				ViewDef.Guild.GuildView.GuildEvents,
				-- ViewDef.Guild.GuildView.GuildRobRedEnvelope,
				ViewDef.Guild.GuildView.GuildJoinReqList,
				ViewDef.Guild.GuildView.GuildAddMember,
				ViewDef.Guild.GuildView.GuildOffer,
			},
			tabbar = nil,
		},
		[false] = {-- 无行会
			views = {
				ViewDef.Guild.GuildView.GuildJoinList,
				-- ViewDef.Guild.GuildView.GuildCreate,
			},
			tabbar = nil,
		}
	}

	require("scripts/game/guild/guild_child_view/guild_join_list_view").New(ViewDef.Guild.GuildView.GuildJoinList)
	-- require("scripts/game/guild/guild_child_view/guild_create_view").New(ViewDef.Guild.GuildView.GuildCreate)
	require("scripts/game/guild/guild_child_view/guild_info_view").New(ViewDef.Guild.GuildView.GuildInfo)
	require("scripts/game/guild/guild_child_view/guild_member_view").New(ViewDef.Guild.GuildView.GuildMember)
	require("scripts/game/guild/guild_child_view/guild_build_view").New(ViewDef.Guild.GuildView.GuildBuild)
	require("scripts/game/guild/guild_child_view/guild_list_view").New(ViewDef.Guild.GuildView.GuildList)
	require("scripts/game/guild/guild_child_view/guild_storage_view").New(ViewDef.Guild.GuildView.GuildStorage)
	require("scripts/game/guild/guild_child_view/guild_activity_view").New(ViewDef.Guild.GuildView.GuildActivity)
	require("scripts/game/guild/guild_child_view/guild_events_view").New(ViewDef.Guild.GuildView.GuildEvents)
	require("scripts/game/guild/guild_child_view/guild_rob_red_envelope_view").New(ViewDef.Guild.GuildView.GuildRobRedEnvelope)
	require("scripts/game/guild/guild_child_view/guild_join_req_list_view").New(ViewDef.Guild.GuildView.GuildJoinReqList)
	require("scripts/game/guild/guild_child_view/guild_add_member_view").New(ViewDef.Guild.GuildView.GuildAddMember)

	-- GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))
end

function GuildView:__delete()
end

function GuildView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	GuildCtrl.GetAllGuildInfo()
	FubenMutilCtrl.SendGetFubenEnterTimes(FubenMutilType.Hhjd)
end

function GuildView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildView:ReleaseCallBack()
	for k, v in pairs(self.view_table) do
		if nil ~= v.tabbar then
			v.tabbar:DeleteMe()
			v.tabbar = nil
		end
	end

	self.play_eff = nil
end

function GuildView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
    	self:InitTabbar()

    	-- EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.HaveGuildStateChange, BindTool.Bind(self.OnHaveGuildState, self))
	    self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
    end
end

function GuildView:ShowIndexCallBack(index)
	self:FlushTabbar()
	self:ShowCurSelectView()
end

function GuildView:OnFlush(param_t, index)
end

--------------------------------------------------------------------
function GuildView:FlushTabbar()
	local have_guild = GuildData.Instance:HaveGuild()
	for k, v in pairs(self.view_table) do
		v.tabbar:SetVisible(k == have_guild)
		for index, vdef in pairs(v.views) do
			local have_open_view = false
			if self:GetViewManager():IsOpen(vdef) then
				v.tabbar:ChangeToIndex(index)
				have_open_view = true
				break
			end
			if not have_open_view then
				v.tabbar:ChangeToIndex(1)
			end
		end
	end
end

function GuildView:ShowCurSelectView()
	local have_guild = GuildData.Instance:HaveGuild()
	local view_info = self.view_table[GuildData.Instance:HaveGuild()]
	local tabbar = view_info.tabbar
	if nil ~= tabbar then
		local vdef = view_info.views[tabbar:GetCurSelectIndex()]
		if not self:GetViewManager():IsOpen(vdef) then
			self:GetViewManager():OpenViewByDef(vdef)
		end
	end

	self.node_t_list.layout_bg.node:setVisible(have_guild)
end

function GuildView:InitTabbar()
	for k, v in pairs(self.view_table) do
		if nil == v.tabbar then
			local name_group = {}
			for i, vdef in ipairs(v.views) do
				name_group[i] = vdef.name
			end
			v.tabbar = ScrollTabbar.New()
			v.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 10, -5,
				BindTool.Bind(self.SelectTabCallback, self, v), name_group, 
				true, ResPath.GetCommon("toggle_120"))
			v.tabbar:SetSpaceInterval(3)
		end
	end

	self:FlushTabbar()
	self:ShowCurSelectView()
end

function GuildView:SelectTabCallback(view_info, index)
	self:GetViewManager():OpenViewByDef(view_info.views[index])
end

function GuildView:OnGameCondChange(cond)
	if cond == "CondId62" or cond == "CondId63" then
		self:FlushTabbar()
		self:ShowCurSelectView()
	end
end

return GuildView