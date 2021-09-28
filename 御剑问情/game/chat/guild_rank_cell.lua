-----------------------------------公会排行列表----------------------------------
GuildRankCell = GuildRankCell or BaseClass(BaseCell)
function GuildRankCell:__init(instance, parent)
	self.parent = parent
	self.rank_text = self:FindVariable("rank_text")
	self.name = self:FindVariable("name")
	self.count = self:FindVariable("count")
	self.item_text = self:FindVariable("item_text")
	self.flower_img = self:FindVariable("flower_img")
end

function GuildRankCell:__delete()
	self.parent = nil
end

function GuildRankCell:OnFlush()
	local cur_index = self.parent:GetCurIndex()
	if cur_index == GUILD_TOP_TOGGLE_NAME.QUESTION then
		local reward_cfg = {}
		local reward_num = reward_cfg.num
		local rank_list = WorldQuestionData.Instance:GetGuildQuestionRank()
		self.root_node.gameObject:SetActive(true)
		if self.index < 4 then
			reward_cfg = WorldQuestionData.Instance:GetGuildAnswerRewardList()[self.index]
			if rank_list and next(rank_list) then
				if rank_list[self.index] and next(rank_list[self.index]) and rank_list[self.index].uid ~= 0 then
					self.root_node.gameObject:SetActive(true)
					self.rank_text:SetValue(self.index)
					self.name:SetValue(rank_list[self.index].name)
					self.count:SetValue(rank_list[self.index].right_answer_num)
				else
					self.root_node.gameObject:SetActive(false)
				end
			else
				self.root_node.gameObject:SetActive(false)
			end
		else
			--自己排名
			local role_name = GameVoManager.Instance:GetMainRoleVo().role_name
			local my_answer = WorldQuestionData.Instance:GetMyQustionNum(WORLD_GUILD_QUESTION_TYPE.GUILD)
			local my_rank = WorldQuestionData.Instance:GetMyRank()
			reward_cfg = WorldQuestionData.Instance:GetMyReward(my_rank)
			local rank_text = my_rank == -1 and "-" or tostring(my_rank)
			self.rank_text:SetValue(rank_text)
			self.name:SetValue(role_name)
			self.count:SetValue(my_answer)
		end

		self.item_text:SetValue(reward_cfg.num)
		local item_cfg = ItemData.Instance:GetItemConfig(reward_cfg.item_id)
		if item_cfg and next(item_cfg) then
			self.flower_img:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
		end
	elseif cur_index == GUILD_TOP_TOGGLE_NAME.SHAI_ZI then --骰子

	end
end