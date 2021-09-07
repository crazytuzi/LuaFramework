GuildFightRewardView = GuildFightRewardView or BaseClass(BaseRender)

function GuildFightRewardView:__init(instance)
	if instance == nil then
		return
	end

	self.item_cell = {}
	for i = 1, 6 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
		self.item_cell[i].obj:SetActive(false)
	end
	self.experience = self:FindVariable("Experience")
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
end

function GuildFightRewardView:__delete()
	for k, v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}
end

function GuildFightRewardView:OnFlush()
	local reward_info = GuildFightData.Instance:GetRewardItemListInfo()
	if not reward_info then return end
	for i = 1, reward_info.count do
		self.item_cell[i].obj:SetActive(true)
		self.item_cell[i].cell:SetData(reward_info.item_list[i])
	end
	self.experience:SetValue(reward_info.person_credit)
end

function GuildFightRewardView:Close()
	GuildFightCtrl.Instance.view:Close()
end