GuildFightRewardView = GuildFightRewardView or BaseClass(BaseView)

function GuildFightRewardView:__init()
	self.ui_config = {"uis/views/guildfight_prefab","GuildFightRewardView"}
    self.view_layer = UiLayer.Pop
end

function GuildFightRewardView:__delete()

end

function GuildFightRewardView:LoadCallBack()
	self.item_cell = {}
	for i = 1, 6 do
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
		self.item_cell[i]:SetParentActive(false)
	end
	self.experience = self:FindVariable("Experience")
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
end

function GuildFightRewardView:ReleaseCallBack()
	for k, v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
	self.experience = nil
end

function GuildFightRewardView:OpenCallBack()
	self:Flush()
end

function GuildFightRewardView:OnFlush()
	local role_info = GuildFightData.Instance:GetRoleInfo()
	self.experience:SetValue(0)
	if role_info then
		local score = role_info.history_get_person_credit
		local info, next_info, total_reward = GuildFightData.Instance:GetRewardInfoByScore(score)
		if total_reward then
			for i = 1, 3 do
				local item_info = total_reward.reward_item[i - 1]
				if item_info then
					self.item_cell[i]:SetParentActive(true)
					self.item_cell[i]:SetData(item_info)
				else
					self.item_cell[i]:SetParentActive(false)
				end
			end
			self.experience:SetValue(total_reward.banggong)
		end
	end
end