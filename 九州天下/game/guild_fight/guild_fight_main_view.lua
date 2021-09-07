GuildFightMainView = GuildFightMainView or BaseClass(BaseRender)

local Reward_Count = 4

function GuildFightMainView:__init(instance)
	if instance == nil then
		return
	end

	self.reward_cells = {}
	for i = 1, Reward_Count do
		self.reward_cells[i] = {}
		self.reward_cells[i].obj = self:FindObj("Reward" .. i)
		self.reward_cells[i].cell = ItemCell.New(self.reward_cells[i].obj)
	end

	self.guild_name = self:FindVariable("GuildName")
	self.time = self:FindVariable("Time")
	self.master_name = self:FindVariable("MasterName")

	self:ListenEvent("Close", BindTool.Bind(self.OnClose, self))
	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
end

function GuildFightMainView:__delete()
	for k, v in pairs(self.reward_cells) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.reward_cells = {}
end

function GuildFightMainView:OnClose()
	ViewManager.Instance:Close(ViewName.GuildFight)
end

function GuildFightMainView:OnClickEnter()
	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.GUILDBATTLE)
	--GuildFightCtrl.Instance.view:OpenTrackInfoView()
end

function GuildFightMainView:Flush()
	local guild_id = GuildFightData.Instance:GetWinnerId()
	if guild_id then
		local guild_info = GuildData.Instance:GetGuildInfoById(guild_id)
		if guild_info then
			self.guild_name:SetValue(guild_info.guild_name)
			self.master_name:SetValue(guild_info.tuanzhang_name)
		end
	end
end

function GuildFightMainView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(Language.Guild.GuildBattleRule)
end