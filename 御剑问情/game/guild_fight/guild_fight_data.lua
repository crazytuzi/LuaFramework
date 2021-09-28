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
		rank_count = 0,
		rank_list = {},
		hold_point_guild_list = {},
	}

	self.role_info = {
		kill_role_num = 0,
		history_get_person_credit = 0,
		is_add_hudun = 0,
		sos_times = 0,
	}

	self.monster_list = {}
	self.monster_id = 0
	local cfg = self:GetFlagPointCfgByIndex(0)
	if cfg then
		self.monster_id = cfg.boss_id
	end
	self.guild_war_reward_info = nil
end

function GuildFightData:__delete()
	GuildFightData.Instance = nil
	self.monster_list = {}
end

function GuildFightData:SetGlobalInfo(data)
	self.global_info.guild_score = data.guild_score
	self.global_info.guild_rank = data.guild_rank
	self.global_info.is_finish = data.is_finish
	self.global_info.rank_count = data.rank_count
	self.global_info.rank_list = data.rank_list
	self.global_info.hold_point_guild_list = data.hold_point_guild_list
	self:UpdateMonsterList()
end

function GuildFightData:SetRoleInfo(data)
	self.role_info.kill_role_num = data.kill_role_num
	self.role_info.history_get_person_credit = data.history_get_person_credit
	self.role_info.is_add_hudun = data.is_add_hudun
	self.role_info.sos_times = data.sos_times
end

function GuildFightData:GetGlobalInfo()
	return self.global_info
end

function GuildFightData:GetRoleInfo()
	return self.role_info
end

function GuildFightData:GetRoleInfoSosTimes()
	local info = self:GetRoleInfo()
	if info then
		return tonumber(info.sos_times) or 0
	end
	return 0
end

function GuildFightData:GetConfig()
	if not self.config then
		self.config = ConfigManager.Instance:GetAutoConfig("guildbattle_new_auto")
	end
	return self.config
end

function GuildFightData:GetZhaoJiIndexCost()

	local cfg = self:GetConfig()
	local times = self:GetRoleInfoSosTimes() or 0

	if cfg and cfg.sos_cfg then
		for k, v in pairs(cfg.sos_cfg) do
			if v.times == times then
				return v.cost or 0
			end
		end
	end

	return 0
end

function GuildFightData:GetSosAllTimes()
	local cfg = self:GetConfig()

	if cfg and cfg.sos_cfg then
		return #cfg.sos_cfg or 0
	end

	return 0
end

function GuildFightData:GetRemindZhaojiTimes()
	local remind_times = self:GetSosAllTimes() or 0
	remind_times = remind_times - (self:GetRoleInfoSosTimes() or 0)
	return remind_times
end

-- 通过玩家积分查询奖励的信息
function GuildFightData:GetRewardInfoByScore(score)
	if not score then return end
	local reward_info = self:GetConfig().personal_credit_reward
	if reward_info then
		table.sort(reward_info, function(a, b) return a.reward_credit_min < b.reward_credit_min end)
		local temp = nil
		local total_reward = nil
		for _,v in ipairs(reward_info) do
			if v.reward_credit_min > score then
				return temp, v, total_reward
			else
				temp = v
				if total_reward then
					total_reward.banggong = total_reward.banggong + v.banggong
					total_reward.shengwang = total_reward.shengwang + v.shengwang
					for k1,v1 in pairs(v.reward_item) do
						local flag = true
						for k2,v2 in pairs(total_reward.reward_item) do
							if v1.item_id == v2.item_id then
								v2.num = v2.num + v1.num
								flag = false
								break
							end
						end
						if flag then
							table.insert(total_reward.reward_item, TableCopy(v1))
						end
					end
				else
					total_reward = {}
					total_reward.banggong = v.banggong
					total_reward.shengwang = v.shengwang
					total_reward.reward_item = {}
					for k1,v1 in pairs(v.reward_item) do
						total_reward.reward_item[k1] = {}
						for k2,v2 in pairs(v1) do
							total_reward.reward_item[k1][k2] = v2
						end
					end
				end
			end
		end
		return temp, nil, total_reward
	end
end

function GuildFightData:GetFlagPointCfgByIndex(index)
	local cfg = self:GetConfig()
	if cfg then
		local point_cfg = cfg.point
		if point_cfg then
			for k,v in pairs(point_cfg) do
				if v.index == index - 1 then
					return v
				end
			end
		end
	end
end

function GuildFightData:GetFlagPositionByIndex(index)
	local cfg = self:GetFlagPointCfgByIndex(index)
	local x = 0
	local y = 0
	if cfg then
		x = cfg.pos_x
		y = cfg.pos_y
	end
	return x, y
end

function GuildFightData:GetMonsterId()
	return self.monster_id
end

function GuildFightData:MonsterIsEnemy(id, x, y)
	local flag = true
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local list = self.monster_list[guild_id]
	if list then
		for k,v in pairs(list) do
			if v.boss_id == id and v.pos_x == x and v.pos_y == y then
				flag = false
				break
			end
		end
	end
	return flag
end

function GuildFightData:UpdateMonsterList()
	self.monster_list = {}
	for k,v in ipairs(self.global_info.hold_point_guild_list) do
		if v.guild_id > 0 then
			local cfg = self:GetFlagPointCfgByIndex(k)
			if not self.monster_list[v.guild_id] then
				self.monster_list[v.guild_id] = {}
			end
			table.insert(self.monster_list[v.guild_id], cfg)
		end
	end
end

function GuildFightData:GetIndexFlagName(index)
	local cfg = self:GetConfig()
	local flag_name = ""

	if cfg and cfg.point and cfg.point[index] then
		flag_name = cfg.point[index].flag_name or ""
	end

	return flag_name
end

function GuildFightData:GetGuildNameByPos(monster_id, x, y)
	local guild_name = ""
	local index = 0
	local cfg = self:GetConfig()
	local flag_name = ""
	if cfg then
		local point_cfg = cfg.point
		if point_cfg then
			for k,v in pairs(point_cfg) do
				if v.boss_id == monster_id and v.pos_x == x and v.pos_y == y then
					index = v.index + 1
					flag_name = v.flag_name or ""
				end
			end
		end
	end
	if index > 0 then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		local info = self.global_info.hold_point_guild_list[index] or {}
		guild_name = info.guild_name or ""
		if guild_name ~= "" then
			if guild_id == info.guild_id then
				guild_name = ToColorStr(info.guild_name, TEXT_COLOR.YELLOW)
			else
				guild_name = ToColorStr(info.guild_name, TEXT_COLOR.RED)
			end
		end
	end
	if guild_name == "" then
		guild_name = Language.GuildBattle.WeiZhanLing
	end
	return flag_name .. " " .. guild_name
end

function GuildFightData:SetGuildBattleDailyRewardFlag(data)
	self.guild_war_reward_info = {}
	self.guild_war_reward_info.my_guild_rank = data.my_guild_rank		-- 自己公会排名 0表示前五名之后
	self.guild_war_reward_info.had_fetch = data.had_fetch				-- 是否领取，0否1是
end

function GuildFightData:GetGuildBattleDailyRewardFlag()
	return self.guild_war_reward_info
end

function GuildFightData:GetRewardMountSpecialId()
	local other_cfg = self:GetConfig().other[1]
	local mount_special_image_id = other_cfg.mount_special_image_id
	local mount_cfg = MountData.Instance:GetSpecialImagesCfg()
	for k,v in pairs(mount_cfg) do
		if v.image_id == mount_special_image_id then
			return v.item_id
		end
	end
	return 0
end

function GuildFightData:IsCanZhaoJi()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id or 0
	local sos_times = self:GetRoleInfoSosTimes() or 0
	local all_times = self:GetSosAllTimes() or 0

	return (guild_id > 0) and (sos_times < all_times)
end