--------------------------------------------------------------------------
-- GuildPawnRankCell 	骰子积分排名
--------------------------------------------------------------------------
GuildPawnRankCell = GuildPawnRankCell or BaseClass(BaseCell)

function GuildPawnRankCell:__init(instance)
	self:RankInit()
end

function GuildPawnRankCell:__delete()
 	self.RoleName  = nil
 	self.RoleScore  = nil
 	self.RoleRankNum  = nil
 	self.Flower  = nil
 	self.FlowerCount  = nil
end

function GuildPawnRankCell:RankInit()
	self.RoleName    = self:FindVariable("RoleName")
	self.RoleScore   = self:FindVariable("RoleScore")
	self.RoleRankNum = self:FindVariable("RoleRankNum")
	self.Flower      = self:FindVariable("Flower")
	self.FlowerCount = self:FindVariable("FlowerCount")

end

function GuildPawnRankCell:OnFlush()
	if not next(self.data) then return end
	self.RoleName:SetValue(self.data.name)
	self.RoleScore:SetValue(self.data.score)
	self.RoleRankNum:SetValue(self:GetIndex())

	local guild_rank_reward = PlayPawnData.Instance:GetRankReward(self:GetIndex())
	if guild_rank_reward and next(guild_rank_reward) then
		-- 奖励物品
		if guild_rank_reward.item_id then
			local item_cfg = ItemData.Instance:GetItemConfig(guild_rank_reward.item_id)
			if item_cfg and next(item_cfg) then
				self.Flower:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
			end
		end
		if guild_rank_reward.num then
			self.FlowerCount:SetValue(guild_rank_reward.num)
		end
	end
end

function GuildPawnRankCell:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function GuildPawnRankCell:LoadCallBack(uid, raw_img_obj, path)

end