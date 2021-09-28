ClashTerritoryData = ClashTerritoryData or BaseClass(BaseEvent)

ClashTerritoryData.INFO_CHANGE = "info_change"	--战场个人信息变化
ClashTerritoryData.GLOBAL_INFO_CHANGE = "global_info_change"	--战场全局信息变化
ClashTerritoryData.ReviveType = 1
ClashTerritoryData.ReviveGoods = 1
function ClashTerritoryData:__init()
	if ClashTerritoryData.Instance then
		print_error("[ClashTerritoryData] Attempt to create singleton twice!")
		return
	end
	ClashTerritoryData.Instance = self
	self.clash_territory_info = {}
	self:InitClashTerritoryInfo()
	self.clash_territory_cfg = ConfigManager.Instance:GetAutoConfig("territorywar_auto")
	self.shop_cfg = {}
	for k,v in ipairs(self.clash_territory_cfg.fight_shop) do
		if v.type ~= ClashTerritoryData.ReviveType or v.goods_id ~= ClashTerritoryData.ReviveGoods then
			table.insert(self.shop_cfg, v)
		end
	end
	for k,v in ipairs(self.clash_territory_cfg.relive_shop) do
		table.insert(self.shop_cfg, v)
	end
	self.build_count = 0
	for k,v in ipairs(self.clash_territory_cfg.building) do
		if v.side == 0 then
			self.build_count = self.build_count + 1
		end
	end
	self.guild_rank_list = {}
	self.territorywar_rank_list = {}

	self:AddEvent(ClashTerritoryData.INFO_CHANGE)
	self:AddEvent(ClashTerritoryData.GLOBAL_INFO_CHANGE)
end

function ClashTerritoryData:__delete()
	ClashTerritoryData.Instance = nil
end

function ClashTerritoryData:InitClashTerritoryInfo()
	self.clash_territory_info =
	{
		red_guild_credit = 0,
		blue_guild_credit = 0,
		center_relive_side = 2,
		red_fortress_max_hp = 1,
		red_fortress_curr_hp = 0,
		blue_fortress_max_hp = 1,
		blue_fortress_curr_hp = 0,
		center_relive_max_hp = 1,
		center_relive_curr_hp = 0,
		red_building_survive_flag = 0,
		blue_building_survive_flag = 0,
		current_credit = 0,
		history_credit = 0,
		credit_reward_flag = 0,
		kill_count = 0,
		assist_count = 0,
		death_count = 0,
		side = 0,	--1(红)，0(蓝)
		special_image_id = 0,
		ice_landmine_count = 0,
		fire_landmine_count = 0,
		m_read_next_can_buy_tower_wudi = 0,
		m_blue_next_can_buy_tower_wudi = 0,
		skill_list = {},
	}
end

function ClashTerritoryData:SetGlobalInfo(info)
	self.clash_territory_info.red_guild_credit = info.red_guild_credit
	self.clash_territory_info.blue_guild_credit = info.blue_guild_credit
	self.clash_territory_info.center_relive_side = info.center_relive_side
	self.clash_territory_info.red_fortress_max_hp = math.max(1, info.red_fortress_max_hp)
	self.clash_territory_info.red_fortress_curr_hp = info.red_fortress_curr_hp
	self.clash_territory_info.blue_fortress_max_hp = math.max(1, info.blue_fortress_max_hp)
	self.clash_territory_info.blue_fortress_curr_hp = info.blue_fortress_curr_hp
	self.clash_territory_info.center_relive_max_hp = math.max(1, info.center_relive_max_hp)
	self.clash_territory_info.center_relive_curr_hp = info.center_relive_curr_hp
	self.clash_territory_info.red_building_survive_flag = info.red_building_survive_flag
	self.clash_territory_info.blue_building_survive_flag = info.blue_building_survive_flag
	self.clash_territory_info.m_read_next_can_buy_tower_wudi = info.m_read_next_can_buy_tower_wudi
	self.clash_territory_info.m_blue_next_can_buy_tower_wudi = info.m_blue_next_can_buy_tower_wudi
	self:NotifyEventChange(ClashTerritoryData.GLOBAL_INFO_CHANGE)
end

function ClashTerritoryData:SetRoleInfo(info)
	self.clash_territory_info.current_credit = info.current_credit
	self.clash_territory_info.history_credit = info.history_credit
	self.clash_territory_info.credit_reward_flag = info.credit_reward_flag
	self.clash_territory_info.kill_count = info.kill_count
	self.clash_territory_info.assist_count = info.assist_count
	self.clash_territory_info.death_count = info.death_count
	self.clash_territory_info.side = info.side
	self.clash_territory_info.special_image_id = info.special_image_id
	self.clash_territory_info.skill_list = info.skill_list
	self.clash_territory_info.ice_landmine_count = info.ice_landmine_count
	self.clash_territory_info.fire_landmine_count = info.fire_landmine_count
	for k,v in pairs(self.clash_territory_info.skill_list) do
		local cfg = self:GetTerritorySkillCfg(v.skill_index)
		if nil ~= cfg then
			local cd = math.min(math.max(v.last_perform_time + cfg.cd_s - TimeCtrl.Instance:GetServerTime(), 0), cfg.cd_s)
			v.cd_end_time = Status.NowTime + cd
		end
	end
	self:NotifyEventChange(ClashTerritoryData.INFO_CHANGE)
end

function ClashTerritoryData:GetMainRoleTerritoryWarSide()
	return self.clash_territory_info.side
end

function ClashTerritoryData:GetTerritoryWarData()
	return self.clash_territory_info
end

function ClashTerritoryData:GetTerritoryShopCfg()
	return self.shop_cfg
end

function ClashTerritoryData:GetSkillList()
	return self.clash_territory_info.skill_list
end

function ClashTerritoryData:GetSkillInfoById(skill_index)
	for k,v in pairs(self.clash_territory_info.skill_list) do
		if v.skill_index == skill_index then
			return v
		end
	end
	return nil
end

function ClashTerritoryData:IsTowerId(monster_id)
	local magic_tower = self.clash_territory_cfg.magic_tower or {}
	for k, v in ipairs(magic_tower) do
		if monster_id == v.magic_tower_id then
			return true
		end
	end
	return false
end

function ClashTerritoryData:GetReviveCost()
	for k,v in ipairs(self.clash_territory_cfg.fight_shop) do
		if v.type == ClashTerritoryData.ReviveType and v.goods_id == ClashTerritoryData.ReviveGoods then
			return v.cost_credit
		end
	end
	return 0
end

function ClashTerritoryData:SetQualification(info)
	self.guild_rank_list = info.guild_rank_list
	self.territorywar_rank_list = info.territorywar_rank_list
end

function ClashTerritoryData:GetTerritoryWarMatch(guild_id)
	local guild_name = Language.Activity.TerritoryWaMatchTxt[1]
	if guild_id == 0 then
		guild_name = Language.Activity.TerritoryWaMatchTxt[2]
	end
	local match_guild_id = 0
	local rank_list = self.territorywar_rank_list
	if self.territorywar_rank_list[1] == 0 then
		rank_list = self.guild_rank_list
	end
	for i,v in ipairs(rank_list) do
		if v == guild_id then
			if i % 2 == 0 then
				match_guild_id = rank_list[i - 1] or 0
			else
				match_guild_id = rank_list[i + 1] or 0
			end
			if match_guild_id == 0 then
				guild_name = Language.Activity.TerritoryWaMatchTxt[3]
			end
			break
		end
	end
	if match_guild_id > 0 then
		for k,v in pairs(GuildDataConst.GUILD_INFO_LIST.list) do
			if v.guild_id == match_guild_id then
				guild_name = v.guild_name
			end
		end
	end
	return guild_name
end

function ClashTerritoryData:GetTerritoryMonsterSide(monster_id)
	for k,v in pairs(self.clash_territory_cfg.building) do
		if v.building_id == monster_id then
			return v.side
		end
	end
	return nil
end

function ClashTerritoryData:GetTerritorySkillCfg(index)
	for k,v in pairs(self.clash_territory_cfg.skill_list) do
		if v.skill_index == index then
			return v
		end
	end
end

function ClashTerritoryData:GetTerritorySkillIcon(index)
	for k,v in pairs(self.clash_territory_cfg.skill_list) do
		if v.skill_index == index then
			return v.icon_res
		end
	end
	return nil
end

function ClashTerritoryData:CheckTerritoryMonsterKillLimit(monster_id)
	local value = true
	for k,v in pairs(self.clash_territory_cfg.building) do
		if v.building_id == monster_id then
			for k1,v1 in pairs(self.clash_territory_cfg.building) do
				if v1.building_id == v.preposition_monster_1 or v1.building_id == v.preposition_monster_2 then
					if self:GetOneTerritoryMonsterSurvive(v1.side, v1.building_index) then
						value = false
					end
				end
			end
		end
	end
	return value
end

function ClashTerritoryData:GetOneTerritoryMonsterSurvive(side, building_index)
	local flag = 0
	if side == 0 then
		flag = self.clash_territory_info.blue_building_survive_flag
	elseif side == 1 then
		flag = self.clash_territory_info.red_building_survive_flag
	end
	return bit:_and(1, bit:_rshift(flag, building_index)) == 0
end

function ClashTerritoryData:GetEndReward(win_side)
	local data = {}
	data.reward_list = {}
	local activity_close_reward_cfg = self.clash_territory_cfg.activity_close_reward
	local room_index = 0
	if self:GetTerritoryRankById() then
		local rank = self:GetTerritoryRankById()
		room_index = math.max(math.ceil(rank / 2) - 1, 0)
	end
	local reward_index = 0
	if win_side ~= self.clash_territory_info.side then
		reward_index = 1
	end
	for k,v in pairs(activity_close_reward_cfg) do
		if v.room_index == room_index and v.reward_index == reward_index then
			for i = 1, 3 do
				if v["item" .. i] then
					table.insert(data.reward_list, v["item" .. i])
				end
			end
		end
	end

	return data
end

function ClashTerritoryData:GetTerritoryRewawrdCfg()
	local cfg = self.clash_territory_cfg.personal_credit_reward
	for i,v in ipairs(cfg) do
		if self.clash_territory_info.history_credit < v.person_credit_min then
			return v, false
		end
	end
	return cfg[#cfg], true
end

local count = 0
local count_t = {}
function ClashTerritoryData:GetTerritoryBuildCount()
	count = self.build_count
	count_t = {}
	if side == 0 then
		count_t = bit:d2b(self.clash_territory_info.blue_building_survive_flag)
	elseif side == 1 then
		count_t = bit:d2b(self.clash_territory_info.red_building_survive_flag)
	end
	for k,v in pairs(count_t) do
		if v == 1 then
			count = count -1
		end
	end
	return math.max(0, count)
end

function ClashTerritoryData:GetMonsterResId(goods_id, guild_id)
	local player_guild_id = PlayerData.Instance.role_vo.guild_id or 0
	local side = self.clash_territory_info.side
	if guild_id ~= player_guild_id and guild_id ~= 0 then
		side = side == 0 and 1 or 0
	end
	for k,v in pairs(self.clash_territory_cfg.fight_shop) do
		if v.type == 0 and v.goods_id == goods_id - 1 then
			if side == 0 then
				return v.image_id
			else
				return v.image_id2
			end
		end
	end
	return 0
end

function ClashTerritoryData:IsTerritoryWarNpc(npc_id)
	return npc_id == self.clash_territory_cfg.other[1].red_npc_id or npc_id == self.clash_territory_cfg.other[1].blue_npc_id
end

-- 得到公会排名
function ClashTerritoryData:GetTerritoryRankById(guild_id)
	guild_id = guild_id or PlayerData.Instance.role_vo.guild_id
	if guild_id == nil or guild_id < 1 then return nil end
	for k,v in ipairs(self.territorywar_rank_list) do
		if v == guild_id then
			return k, true
		end
	end
	for k,v in ipairs(self.guild_rank_list) do
		if v == guild_id then
			return k, false
		end
	end
end

function ClashTerritoryData:GetGuildIdByRank(rank)
	if rank == nil or rank < 1 then return nil end
	for k,v in ipairs(self.territorywar_rank_list) do
		if k == rank and v > 0 then
			return v, true
		end
	end
	for k,v in ipairs(self.guild_rank_list) do
		if k == rank then
			return v, false
		end
	end
end

function ClashTerritoryData:GetGuajiXY()
	local config = self.clash_territory_cfg.other[1]
	local data = self:GetTerritoryWarData()
	if data.side == 0 then
		return config.blue_guaji_x, config.blue_guaji_y
	else
		return config.red_guaji_x, config.red_guaji_y
	end
end

function ClashTerritoryData:GetMonsterName(monster_vo)
	local config = self.clash_territory_cfg.other[1]
	if monster_vo.monster_id == config.resurrection_id then
		return monster_vo.name .. (Language.ClashTerritory.ReliveSide[self.clash_territory_info.center_relive_side] or "")
	else
		return monster_vo.name
	end
end

function ClashTerritoryData:GetEndRewardByIndex(index)
	local activity_close_reward_cfg = self.clash_territory_cfg.activity_close_reward
	local room_index = math.max(math.ceil(index / 2) - 1, 0)
	local reward_index = (index + 1) % 2
	for k,v in pairs(activity_close_reward_cfg) do
		if v.room_index == room_index and v.reward_index == reward_index then
			return v
		end
	end
end