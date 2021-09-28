GuildTerritoryInfoView = GuildTerritoryInfoView or BaseClass(BaseView)

function GuildTerritoryInfoView:__init()
	self.ui_config = {"uis/views/guildview_prefab","GuildTerritoryInfoView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true

	self.itme_cell_list = {}
	self.info = {}
end

function GuildTerritoryInfoView:__delete()

end

function GuildTerritoryInfoView:LoadCallBack()
	self.itme_cell_list = {}
	for i = 1, 2 do
		self.itme_cell_list[i] = ItemCell.New()
		self.itme_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
		self.itme_cell_list[i]:SetActive(false)
	end

	self.territory_name = self:FindVariable("TerritoryName")
	self.guild_name = self:FindVariable("GuildName")

	self:ListenEvent("CloseWindow",
        BindTool.Bind(self.CloseWindow, self))
end

function GuildTerritoryInfoView:ReleaseCallBack()
	for k,v in pairs(self.itme_cell_list) do
		v:DeleteMe()
	end
	self.itme_cell_list = {}
	self.info = {}

	-- 清理变量和对象
	self.territory_name = nil
	self.guild_name = nil
end

function GuildTerritoryInfoView:OpenCallBack()
	self:Flush()
end

function GuildTerritoryInfoView:CloseCallBack()

end

function GuildTerritoryInfoView:SetInfo(info)
	self.info = info
end

function GuildTerritoryInfoView:OnFlush()
	self.guild_name:SetValue(Language.Guild.NoGuild)
	local guild_id = self.info.guild_id or 0
	if guild_id > 0 then
	 	local guild_info = GuildData.Instance:GetGuildInfoById(guild_id)
        if guild_info then
            self.guild_name:SetValue(guild_info.guild_name)
        end
	end
	local cfg = self.info.territory_config
	if cfg then
		self.territory_name:SetValue(cfg.territory_name)
		local reward_cfg = ClashTerritoryData.Instance:GetEndRewardByIndex(cfg.territory_index)
		if reward_cfg then
			self.itme_cell_list[1]:SetActive(true)
			self.itme_cell_list[1]:SetData({item_id = ResPath.CurrencyToIconId["guild_gongxian"], num = reward_cfg.banggong})
			if reward_cfg.item1 then
				self.itme_cell_list[2]:SetActive(true)
				self.itme_cell_list[2]:SetData(reward_cfg.item1)
			end
		end
	end
end

function GuildTerritoryInfoView:CloseWindow()
	self:Close()
end