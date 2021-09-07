PlayPawnData = PlayPawnData or BaseClass()

function PlayPawnData:__init()
	if PlayPawnData.Instance ~= nil then
		print_error("[PlayPawnData] Attemp to create a singleton twice !")
	end
	PlayPawnData.Instance = self

end

function PlayPawnData:__delete()
	PlayPawnData.Instance = nil
end

-- 保存公会骰子排名信息
function PlayPawnData:SetGuildPawnRankInfo(protocol)
	self.pawn_rank_info = protocol.guild_saizi_rank_list
	self.pao_saizi_num = protocol.pao_saizi_num
	self.today_guild_pao_saizi_times = protocol.today_guild_pao_saizi_times
	self.today_last_guild_pao_saizi_time = protocol.today_last_guild_pao_saizi_time
end

-- 获取公会骰子排名信息
function PlayPawnData:GetGuildPawnRankInfo()
	return self.pawn_rank_info
end

-- 获取抛骰子信息
function PlayPawnData:GetCurrPawnScore()
	return self.pao_saizi_num or 0
end

-- 获取最后抛骰子时间
function PlayPawnData:GetLastPaoSaiTime()
	return self.today_last_guild_pao_saizi_time or 0
end


-- 获取玩家已经抛骰子的次数
function PlayPawnData:GetPlayedCount()
	return self.today_guild_pao_saizi_times or 0
end

-- 获取积分大于零的玩家
function PlayPawnData:GetGuildPawnRankInfoByScore()
	local currInfo = self:GetGuildPawnRankInfo()
	if currInfo then
		local temp_tab = {}
		local count = 0
		for k,v in pairs(currInfo) do
			if v.score > 0 then 
				count = count + 1
				temp_tab[count] = v
			end
		end
		return temp_tab
	end
end
-- 获取积分大于零的玩家数量
function PlayPawnData:GetGuildPawnRankNum()
	local currInfo = self:GetGuildPawnRankInfo()
	if currInfo then
		local count = 0
		for k,v in pairs(currInfo) do
			if v.score > 0 then 
				count = count + 1
			end
		end
		return count
	end
	return 0
end


-- 判断是否抛骰子的冷却时间是否结束
function PlayPawnData:GetPlayCDFlag()
	local guild_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").other_config[1]
	if guild_cfg then
		local last_time = self:GetLastPaoSaiTime()
		-- 抛骰子配置冷却时间
		local cd_sen = guild_cfg.siai_cold_down
		-- 抛骰子已经冷却时间
		local time = math.max(TimeCtrl.Instance:GetServerTime() - last_time, 0)
		if time > cd_sen then
			return 1
		end
	end
	return 0
end

-- 获取抛骰子的冷却时间
function PlayPawnData:GetPlayCDTime()
	local guild_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").other_config[1]
	if guild_cfg then
		local last_time = self:GetLastPaoSaiTime()
		-- 抛骰子配置冷却时间
		local cd_sen = guild_cfg.siai_cold_down
		-- 抛骰子已经冷却时间
		local time = math.max(TimeCtrl.Instance:GetServerTime() - last_time, 0)
 		local result = cd_sen - time
 		return result
	end
	return 0
end


-- 判断玩家是否还有抛骰子次数
function PlayPawnData:CanPlayPwan()
	local guild_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").other_config[1]
	if guild_cfg then
		-- 抛骰子配置次数
		local saizi_count = guild_cfg.today_saizi_count
		-- 已经抛骰子的次数
		local play_count = self:GetPlayedCount()
		--还可以抛骰子 
		if play_count < saizi_count then
			return true
		end
	end
	return false
end

-- 查询玩家抛骰子次数
function PlayPawnData:GetCanPlayPwanNum()
	local guild_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").other_config[1]
	if guild_cfg then
		-- 抛骰子配置次数
		local saizi_count = guild_cfg.today_saizi_count
		-- 已经抛骰子的次数
		local play_count = self:GetPlayedCount()
		--还可以抛骰子 
		if play_count < saizi_count then
			return saizi_count - play_count
		end
	end
	return 0
end


-- 获取当前玩家的骰子积分数据
function PlayPawnData:CanCurrRoleInfo()
	local rolevo = GameVoManager.Instance:GetMainRoleVo()
	local guild_info = self:GetGuildPawnRankInfo()
	local result = {}
	if guild_info then
		for k,v in pairs(guild_info) do 
			if rolevo.name == v.name and rolevo.role_id == v.uid then
				result = v
				result["rank_num"] = k
	 			return result
			end
		end
	end
	-- 无排名时返回
	result["name"] = rolevo.name
	result["rank_num"] = 0
	result["score"] = 0
	return result
end

-- 获取公会骰子排名奖励   排名：rank_num 
function PlayPawnData:GetRankReward(rank_num)
	local guild_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").saizi
	if guild_cfg and next(guild_cfg) then
		for k, v in pairs(guild_cfg) do
			if rank_num > 0 and rank_num <= guild_cfg[#guild_cfg].rank2 then
				if rank_num <= guild_cfg[#guild_cfg].rank1 then
					return guild_cfg[rank_num].reward_item[0]
				end
				return guild_cfg[#guild_cfg].reward_item[0]
			end
		end
	end
	return {}
end