GuildFightData = GuildFightData or BaseClass()

function GuildFightData:__init()
	if GuildFightData.Instance then
		print_error("[GuildFightData] Attempt to create singleton twice!")
		return
	end
	GuildFightData.Instance = self

	self.global_info = {
		guild_score = 0,
		guild_rank = 0,
		is_finish = 0,
		reserve_1 = 0,
		reserve_2 = 0,
		husong_end_time = 0,
		gold_box_total_count = 0,
		sliver_box_total_count = 0,
		boss_current_hp = 0,
		boss_maxhp = 0,
		RANK_NUM = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.role_info = {
		kill_role_num = 0,
		husong_goods_color = 0,
		history_get_person_credit = 0,
		history_get_guild_credit = 0,
		husong_goods_index = 0,
		is_add_hudun = 0,
		task_list = {},
	}

	self.role_worship_info = {
		next_addexp_timestamp = 0,
		next_worship_timestamp = 0,
		worship_time = 0,
	}

	self.global_worship_info = {
		is_open = 0,
		reserve_ch = 0,
		reserve_sh = 0,
		worship_end_timestamp = 0,
	}

	self.role_reward_info = {
		person_credit = 0,
		guild_credit = 0,
		count = 0,
		item_list = {},
	}

	self.camp_king_uid_list = {}

	self.config = nil									 -- 通过GetConfig()方法调用
end

function GuildFightData:__delete()
	GuildFightData.Instance = nil
end

function GuildFightData:SetGlobalInfo(data)
	if data then
		for k,v in pairs(data) do
			self.global_info[k] = v
		end
	end
end

function GuildFightData:SetRoleInfo(data)
	if data then
		for k,v in pairs(data) do
			self.role_info[k] = v
		end
	end
end

function GuildFightData:GetGlobalInfo()
	return self.global_info
end

function GuildFightData:GetRoleInfo()
	return self.role_info
end

function GuildFightData:GetConfig()
	if not self.config then
		self.config = ConfigManager.Instance:GetAutoConfig("guildbattle_auto")
	end
	return self.config
end

function GuildFightData:GetOtherConfig()
	local config = self:GetConfig()
	return config.other[1]
end 

function GuildFightData:GetWorshipConfig()
	local config = self:GetConfig()
	return config.worship_scene
end

function GuildFightData:GetNpcId()
	return self:GetOtherConfig().npc_id
end

function GuildFightData:GetBossPos()
	local config = self:GetConfig()
	if config then
		return config.other[1].boss_x, config.other[1].boss_y
	end
end

function GuildFightData:GetBoxLevelById(box_id)
	local config = self:GetConfig()
	if config then
		local goods_config = config.goods_credit
		if goods_config then
			for k,v in pairs(goods_config) do
				if box_id == v.gather_id then
					return v.items_level
				end
			end
		end
	end
	return 99
end

function GuildFightData:GetBoxIdByLevel(box_level)
	local config = self:GetConfig()
	if config then
		local goods_config = config.goods_credit
		if goods_config then
			for k,v in pairs(goods_config) do
				if box_level == v.items_level then
					return v.gather_id
				end
			end
		end
	end
end

function GuildFightData:SetWinnerInfo(protocol)
	self.guild_id = protocol.guild_id
	self.camp_king_uid_list = protocol.camp_king_uid_list
end

function GuildFightData:GetWinnerId()
	return self.guild_id
end

function GuildFightData:GetKingIdList()
	return self.camp_king_uid_list
end

function GuildFightData:GetRandomWoodBoxPos()
	local config = self:GetConfig()
	if config then
		local other_config = config.other[1]
		if other_config then
			local pos_x = other_config.woodcase_x1
			local pos_y = other_config.woodcase_y1
			if math.random() > 0.5 then
				pos_x = other_config.woodcase_x2
				pos_y = other_config.woodcase_y2
			end
			return pos_x, pos_y
		end
	end
end

function GuildFightData:SetGoodsColor(color)
	self.role_info.husong_goods_color = color
end

function GuildFightData:SetWorshipInfo(protocol)
	if protocol then
		for k,v in pairs(protocol) do
			self.role_worship_info[k] = v
		end
	end
end

function GuildFightData:GetWorshipInfo()
	return self.role_worship_info
end

function GuildFightData:SetWorshipActivityInfo(protocol)
	if protocol then
		for k,v in pairs(protocol) do
			self.global_worship_info[k] = v
		end
	end
end

function GuildFightData:GetWorshipActivityInfo()
	return self.global_worship_info
end

function GuildFightData:SetGoldBoxPositionInfo(protocol)
	self.pos_list = protocol.pos_list
end

function GuildFightData:GetGoldBoxPositionInfo()
	return self.pos_list
end

function GuildFightData:SetGuildBattelRewardInfo(protocol)
	if protocol then
		for k,v in pairs(protocol) do
			self.role_reward_info[k] = v
		end
	end
end

function GuildFightData:GetRewardItemListInfo()
	return self.role_reward_info
end