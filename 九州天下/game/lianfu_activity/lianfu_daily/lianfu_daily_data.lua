LianFuDailyData = LianFuDailyData or BaseClass()

IS_CARRY_BAG = false 	-- 抗麻袋状态

-- 据点ID
LianFuDailyData.JuDianGatherIdList = {
	1384, 1385, 1386, 1387, 1388, 1389,
}

LianFuDailyData.MiDaoMonsterId = 6007
LianFuDailyData.QingLouMonsterId = 6008
LianFuDailyData.FlagId = {
	[0] = 6005,
	[1] = 6006,
}

function LianFuDailyData:__init()
	if LianFuDailyData.Instance ~= nil then
		print_error("[LianFuDailyData] Attemp to create a singleton twice !")
		return
	end
	LianFuDailyData.Instance = self

	self.own_judian_info_list = {}
	self.source_item_list = {}
	self.judian_info = {
		id = 0,
		is_zhanling = 0,
		progress = 0,
	}
	self.server_group_list = {}
	self.is_midao_fb_open = {}
	self.midao_info_list = {}
end

function LianFuDailyData:__delete()
	LianFuDailyData.Instance = nil
end

function LianFuDailyData:GetCrossXYJDCfg()
	return ConfigManager.Instance:GetAutoConfig("cross_xyjd_auto") or {}
end

function LianFuDailyData:GetCrossXYCityCfg()
	return ConfigManager.Instance:GetAutoConfig("cross_xycity_auto") or {}
end

function LianFuDailyData:GetCrossXYCityOtherCfg()
	local cfg = self:GetCrossXYCityCfg()
	if cfg and cfg.other then
		return cfg.other[1]
	end
	return nil
end

function LianFuDailyData:GetJuDianGroupCfg(group)
	local cfg = self:GetCrossXYJDCfg()
	if nil == self.judian_group_cfg then
		self.judian_group_cfg = ListToMapList(cfg.judian, "group")
	end
	return self.judian_group_cfg[group]
end

function LianFuDailyData:GetJuDianIdCfg(id)
	local cfg = self:GetCrossXYJDCfg()
	if nil == self.judian_id_cfg then
		self.judian_id_cfg = ListToMapList(cfg.judian, "id")
	end
	return self.judian_id_cfg[id]
end

function LianFuDailyData:GetSignleJuDianCfg(id, group)
	local cfg = self:GetCrossXYJDCfg()
	if nil == self.signle_judian_cfg then
		self.signle_judian_cfg = ListToMap(cfg.judian, "id", "group")
	end
	return self.signle_judian_cfg[id][group]
end

function LianFuDailyData:GetXYCityGroupCfg(group)
	local cfg = self:GetCrossXYCityCfg()
	if nil == self.xycity_scene_cfg then
		self.xycity_scene_cfg = ListToMap(cfg.group, "group")
	end
	return self.xycity_scene_cfg[group]
end

function LianFuDailyData:SetServerGroupScoreParam(protocol)
	self.own_judian_info_list = protocol.own_judian_info_list or {}
	self.source_item_list = protocol.source_item_list or {}
end

function LianFuDailyData:GetOwnJuDianInfoList()
	return self.own_judian_info_list
end

function LianFuDailyData:GetSourceItemList()
	return self.source_item_list
end

function LianFuDailyData:SetCrossXYJDJudianInfo(protocol)
	self.judian_info.id = protocol.id or 0
	self.judian_info.is_zhanling = protocol.is_zhanling or 0
	self.judian_info.progress = protocol.progress or 0
end

function LianFuDailyData:GetCrossXYJDJudianInfo()
	return self.judian_info
end

function LianFuDailyData:SetCrossXYCityFBInfo(protocol)
	self.is_midao_fb_open = protocol.is_midao_fb_open or {}
end

function LianFuDailyData:GetMiDaoIsOpen()
	return self.is_midao_fb_open
end

function LianFuDailyData:GetIsInJuDianRange(x, y)
	local cfg = self:GetCrossXYJDCfg()
	for k, v in pairs(cfg.judian) do
		local center_pos = Split(v.center_pos, ",")
		local dis = GameMath.GetDistance(center_pos[1], center_pos[2], x, y, true)
		if dis <= v.range then
			return true
		end
	end

	return false
end

function LianFuDailyData:GetJuDianNum()
	local judian_info = self:GetOwnJuDianInfoList()
	local num_list = {0, 0}
	for k, v in pairs(judian_info) do
		if v == 0 then
			num_list[1] = num_list[1] + 1
		elseif v == 1 then
			num_list[2] = num_list[2] + 1
		end
	end

	return num_list
end

function LianFuDailyData:GetRewardByRank(rank)
	local cfg = self:GetCrossXYCityCfg()
	for k, v in pairs(cfg.contribute_reward) do
		if v.rank == rank then
			return v.reward_server_gold_per
		end
	end
	
	return 0
end

function LianFuDailyData:GetMyRankInfo()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local rank_info = RankData.Instance:GetCrossPersonRankList()
	for k, v in pairs(rank_info) do
		if vo.origin_role_id == v.user_id then
			return k, v
		end
	end

	return 0, {}
end

function LianFuDailyData:SetCampBattleServerGroupInfo(protocol)
	self.server_group_list = protocol.server_group_list or {}
end

function LianFuDailyData:GetCampBattleServerGroupInfo()
	return self.server_group_list or {}
end

function LianFuDailyData:SetCrossMiDaoInfo(protocol)
	self.midao_info_list = protocol.midao_info_list
end

function LianFuDailyData:GetCrossMiDaoInfo()
	return self.midao_info_list
end

function LianFuDailyData:GetMiDaoBossInfo()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local midao_boss_data = self:GetCrossMiDaoInfo()
	if role_vo and midao_boss_data then
		for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
			if midao_boss_data[i] and midao_boss_data[i].group_type == role_vo.server_group then
				return midao_boss_data[i]
			end
		end
	end
	return nil
end