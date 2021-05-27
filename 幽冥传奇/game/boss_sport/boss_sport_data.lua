BossSportData = BossSportData or BaseClass()

BossPersonalPage = {1,2,3,4,5}

function BossSportData:__init()
	if BossSportData.Instance then
		ErrorLog("[BossSportData]:Attempt to create singleton twice!")
	end
	BossSportData.Instance = self

	self.boss_data = {}

	self:InitEquipBossCfg()
	self.equip_boss_data = {fb_point = 0, rest_time = 0,}
	self.eq_boss_target_time = 0 					-- 下一次增加点数目标时间
	self.boss_pos_t = {}

	-- 团队Boss
	self.fuben_id = 0
	self.team_id = 0
	self.team_boss_config = self:GetTeamBossConfig()
	self.team_list = {}

	self.leader_id = 0
	self.my_fuben_id = 0
	self.my_team_id = 0
	self.btn_list = {}

	self.my_team_list = {}

end

function BossSportData:__delete()
	BossSportData.Instance = nil
	self.shop_cfg = nil
	self.boss_list = nil
end

-- 个人boss
function BossSportData:GetPersonalTotalCfg()
	local personal_boss_data = {}
	for i, v in ipairs(PersonBossConfig) do
		local monster_id = v.monsters[1] and v.monsters[1].monsterId
		local scene_id = v.monsters[1] and v.monsters[1].sceneId
		local limit = v.enterTimesLimit
		local level_limit = v.enterLevelLimit
		local consume = v.enterConsume and v.enterConsume[1] and v.enterConsume[1].count or 0
		local consume_id = v.enterConsume and v.enterConsume[1] and v.enterConsume[1].id or 0
		local monster_data = ConfigManager.Instance:GetMonsterConfig(v.monsters[1] and v.monsters[1].monsterId)
		local name = monster_data.name
		personal_boss_data[i] = {boss_name = name, boss_pos = i, boss_id = monster_id, scene = scene_id, time_limit = limit, levellimit = level_limit, count = consume, enter_time = 0, consumeid = consume_id, tabIdx = v.tabIdx, boss_state = 0}
	end
	return personal_boss_data
end

function BossSportData:SetSportBossInfoData(protocol)
	if protocol.boss_list ~= nil  then
		self.boss_data = {}
		local data = BossSportData.Instance:GetPersonalTotalCfg()
		for i, v in ipairs(data) do
			if i == (protocol.boss_list[i] and protocol.boss_list[i].boss_pos) then
				v.enter_time = protocol.boss_list[i].enter_time
				v.boss_state = protocol.boss_list[i].had_kill_boss
			else
				v.enter_time = v.enter_time
				v.boss_state = v.boss_state
			end
			self.boss_data[i] = v
		end
	end
end

function BossSportData:GetBossSportData()
	return self.boss_data
end

function BossSportData:GetCankillPersonalBoss()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local num = 0
	for i,v in ipairs(self.boss_data) do
		if role_circle >= (v.levellimit[1] or 0) and role_level >= (v.levellimit[2] or 0) then
			if v.enter_time < v.time_limit then
				num = num + 1
			end
		end
	end
	return num > 0 and 1 or 0
end

function BossSportData:SetBossPosition(data)
	self.boss_pos_t = data
end

function BossSportData:GetBossPosition()
	return self.boss_pos_t
end

function BossSportData:CanEnter(index)
	--PrintTable(self.boss_data)
	local bool = false 
	if self.boss_data[index - 1] == nil then
		bool = true 
	else
		if self.boss_data[index - 1] and self.boss_data[index - 1].boss_state == 1 then
			bool = true
		end
	end
	return bool
end

--============装备Boss begin====================
function BossSportData:InitEquipBossCfg()
	self.equip_boss_cfg = {}
	for k, v in ipairs(EquipBossCfg.BossList) do
		self.equip_boss_cfg[k] = {idx = k, cost = v.costOnlineScore, enter_lv_limit = v.LevelLimit, level_limit = v.LevelLimit}
	end
end

function BossSportData:SetEquipBossSportData(protocol)
	self.equip_boss_data.fb_point = protocol.fb_point
	self.equip_boss_data.rest_time = protocol.rest_time
	if self.equip_boss_data.rest_time >= 0 then
		self.eq_boss_target_time = TimeCtrl.Instance:GetServerTime() + self.equip_boss_data.rest_time
	end
end

function BossSportData:CheckReqEqBossData()
	if self.equip_boss_data.rest_time == -1 then
		return
	end
	if self:GetEqBossAddRestTime() < 1 then
		BossSportCtrl.Instance:EquipBossReq(1, fb_idx)
	end
	
end

function BossSportData:GetEquipBossData()
	return self.equip_boss_data.fb_point, self.equip_boss_data.rest_time
end

function BossSportData:GetEqBossAddRestTime()
	return self.eq_boss_target_time - TimeCtrl.Instance:GetServerTime()
end

function BossSportData:GetEquipBossCfg()
	return self.equip_boss_cfg
end

function BossSportData:GetEquipBossRemind()
	if not self.equip_boss_cfg then return 0 end
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local remind_num = 0
	for k, v in ipairs(self.equip_boss_cfg) do
		if self.equip_boss_data.fb_point >= v.cost and role_circle >= v.enter_lv_limit[1]
		and role_level >= v.enter_lv_limit[2] then
			remind_num = 1
			break
		end
	end

	return remind_num
end

function BossSportData:GetTeamBossConfig()
	local data = {}
	for k,v in pairs(TeamFubenConfig) do
		data[k] = {
			scene_id = v.sceneId,
			fuben_id = v.fubenId,
			name = v.fubenId,
			fubenName = v.fubenName,
			maxnum = 0,
			remain_num = 0,
			star_time = v.star,
			tongguang_reward = v.starAwards,
			show_reward = v.showAwards,
			limit = v.levelLimit,
			need_zhanli = v.needPower,
		}
	end
	return data
end

-- 团队Boss
function BossSportData:SetGetPlayerAllEnterFuBenTime(protocol)
	self.fuben_id = protocol.fuben_id
	self.team_id = protocol.team_id
	self.btn_list = {}
	for k,v in pairs(self.team_boss_config) do
		for k1,v1 in pairs(protocol.enter_fuben_list) do
			if v.fuben_id == v1.fuben_id then
				v.maxnum = v1.max_time
				v.remain_num  = v1.remain_time
			end
		end
	end
end

function BossSportData:GetMyData()
	return self.fuben_id, self.team_id, self.team_boss_config
end

function BossSportData:SetCurAllFubenTeamList(protocol)
	self.team_list = {}
	self.team_list = protocol.team_list
end

function BossSportData:GetCurAllFubenTeamList()
	return self.team_list
end

function BossSportData:SetMyTeamListData(protocol)
	self.leader_id = protocol.teamleader_id
	self.fuben_id = protocol.fuben_id
	self.team_id = protocol.team_id
	self.my_team_list = protocol.member_list
	for k,v in pairs(self.my_team_list) do
		v.is_leader = 0 
		if v.member_id == self.leader_id then
			v.is_leader = 1
		end
		v.fuben_id = self.fuben_id
	end
end

function BossSportData:GetMyTeamListData()
	return self.leader_id, self.my_team_list
end

function BossSportData:SetHadJionTeamData(protocol)
	self.fuben_id = protocol.fuben_id
	self.team_id = protocol.team_id
end

function BossSportData:SetTeamID(team_id)
	self.team_id = team_id
end

function BossSportData:GetTeamBossTongGuangReward(page, star)
	for k,v in pairs(self.team_boss_config) do
		if k == page then
			for k1,v1 in pairs(v.tongguang_reward) do
				if k1 == star then
					return v1
				end
			end
		end
	end
	return {}
end

function BossSportData:GetBossToTalTime(page)
	for k,v in pairs(self.team_boss_config) do
		if k == page then
			return v.star_time[1] or 300
		end
	end
	return 0
end

function BossSportData:GetTeamBossStar(page, time)
	local n = 1
	for k,v in pairs(self.team_boss_config) do
		if k == page then
			local use_time = v.star_time[1] - time
			if use_time < v.star_time[3] then
				n = 3
			elseif use_time >= v.star_time[3] and use_time < v.star_time[2] then
				n = 2
			elseif use_time >= v.star_time[2] and use_time < v.star_time[1] then
				n = 1 
			end
		end
	end
	return n
end