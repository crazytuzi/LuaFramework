GuildMainView = GuildMainView or BaseClass(BaseView)

function GuildMainView:__init()
	self.title_img_path = ResPath.GetWord("word_guild")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/boss.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
	self.btn_info = {ViewDef.Guild.GuildView, ViewDef.Guild.OfferView}

	require("scripts/game/guild/guild_view").New(ViewDef.Guild.GuildView, self)
	require("scripts/game/guild/guild_offer_view").New(ViewDef.Guild.OfferView, self)

end

function GuildMainView:ReleaseCallBack()
	if self.main_guild_tabbar then 
		self.main_guild_tabbar:DeleteMe()
		self.main_guild_tabbar = nil
	end
end

function GuildMainView:LoadCallBack(index, loaded_times)
	self.tabbar_index = 1
	FubenCtrl.GetFubenEnterInfo()
	NewBossCtrl.Instance:SendBossKillInfoReq()
	self:InitTabbar()

	self:BindGlobalEvent(SceneEventType.SCENE_CHANGE_COMPLETE, function ()
		ViewManager.Instance:CloseViewByDef(ViewDef.Guild)
	end)
	self:BindGlobalEvent(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChange, self))

	EventProxy.New(GuildData.Instance, self):AddEventListener(GuildData.HaveGuildStateChange, BindTool.Bind(self.Flush, self))
end

--标签栏初始化
function GuildMainView:InitTabbar()
	self.remind_list = {}
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name

		if v.remind_name then
			self.remind_list[v.remind_name] = k
		end
	end
	self.main_guild_tabbar = Tabbar.New()
	self.main_guild_tabbar:SetTabbtnTxtOffset(2, 12)
	self.main_guild_tabbar:SetClickItemValidFunc(function(index)
		self.tabbar_index = index
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.main_guild_tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
		name_list, true, ResPath.GetCommon("toggle_110"), 25, true)
end

--选择标签回调
function GuildMainView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	--刷新标签栏显示
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.main_guild_tabbar:ChangeToIndex(k)
			break
		end
	end
end

function GuildMainView:ShowIndexCallBack(index)
	for k, v in pairs(self.btn_info) do
		if v.open then
			self.main_guild_tabbar:ChangeToIndex(k)
		end
		
		self:FlushBtnRemind(k)
	end

	self:Flush()
end

function GuildMainView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildMainView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function GuildMainView:OnFlush(param_t, index)
	local have_guild = GuildData.Instance:HaveGuild()
	self.main_guild_tabbar:SetToggleVisible(2, have_guild)
end

function GuildMainView:OnRemindChange(remind_name)
	if self:IsOpen() then
		local index = self.remind_list[remind_name]
		if index then
			self:FlushBtnRemind(index)
		end
	end
end

function GuildMainView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_name then
		local vis = RemindManager.Instance:GetRemind(btn_info.remind_name) > 0 and (not IS_ON_CROSSSERVER)
		self.main_guild_tabbar:SetRemindByIndex(index, vis)
	end
end