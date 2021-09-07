KfBossData = KfBossData or BaseClass()

function KfBossData:__init()
	if KfBossData.Instance then
		print_error("[KfBossData] Attempt to create singleton twice!")
		return
	end
	KfBossData.Instance = self

	self.scene_boss_list = {}			--场景内boss列表

	self.cur_score = 0					--剩余积分
	self.left_relive_times = 0			--剩余复活次数
	self.notify_reason = 0				--通知原因
	self.cur_honor = 0					--荣耀
	self.cur_elite_honor = 0			--精英荣耀

	self.remain_second = 0				--离关闭服务器剩余秒数

	self.level_count = 0

	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.other_cfg = ConfigManager.Instance:GetAutoConfig("cross_boss_auto").other
	self.hurt_score_cfg = ConfigManager.Instance:GetAutoConfig("cross_boss_auto").hurt_score
	self.crossboss_cfg = ConfigManager.Instance:GetAutoConfig("cross_boss_auto").crossboss_cfg
	self:SetBossLevelList()
end

function KfBossData:__delete()
	KfBossData.Instance = nil
end

function KfBossData:SetPlayerInfo(info)
	self.cur_score = info.cur_score
	self.left_relive_times = info.left_relive_times
	self.notify_reason = info.notify_reason
	self.cur_honor = info.cur_honor
	self.cur_elite_honor = info.cur_elite_honor
end

local function SortBossList(a, b)
	if a.is_alive > b.is_alive then
		return true
	elseif  a.is_alive == b.is_alive then
		local cfg = ConfigManager.Instance:GetAutoConfig("monster_auto")
		local level_1 = cfg.monster_list[a.boss_id].level
		local level_2 = cfg.monster_list[b.boss_id].level
		return level_1 < level_2
	else
		return false
	end
end

function KfBossData:SetBossList(pro)
	self.scene_boss_list = {}
	for k, v in ipairs(pro.boss_list) do
		if v.boss_id > 0 then
			table.insert(self.scene_boss_list, v)
		end
	end
	table.sort(self.scene_boss_list, SortBossList)
end

function KfBossData:OnCrossBossBossInfoAck(protocol)
	self.kf_boss_list = protocol.boss_list
end

function KfBossData:GetKfInfoList()
	return self.crossboss_cfg
end

function KfBossData:GetBossList()
	return self.scene_boss_list
end

function KfBossData:SetServerShutdown(remain_second)
	self.remain_second = remain_second
end

function KfBossData:SetBossLevelList()
	self.boss_level_list = {}
	for k, v in ipairs(self.crossboss_cfg) do
		if not self.boss_level_list[v.scene_level] then
			self.boss_level_list[v.scene_level] = v.scene_level
			self.level_count = self.level_count + 1
		end
	end
end

function KfBossData:GetLevelCount()
	return self.level_count
end

function KfBossData:GetCrossBossLevelList(scene_level)
	return self.boss_level_list[scene_level]
end

function KfBossData:GetCrossBossInfoByLevel(level)
	local boss_info = {}
	for k, v in ipairs(self.crossboss_cfg) do
		if level == v.scene_level then
			table.insert(boss_info, v)
		end
	end
	return boss_info
end

function KfBossData:GetCrossBossSingleInfo(scene_level, boss_id)
	local boss_info = self:GetCrossBossInfoByLevel(scene_level)
	for k, v in ipairs(boss_info) do
		if scene_level == v.scene_level and v.boss_id == boss_id then
			return v
		end
	end
end

function KfBossData:SetCurInfo(scene_level, boss_id)
	self.scene_level = scene_level
	self.boss_id = boss_id
end

function KfBossData:GetCurInfo()
	return self:GetCrossBossSingleInfo(self.scene_level, self.boss_id)
end

function KfBossData:GetCrossBossInfo()
	local boss_info = {}
	local level = 1
	local index = 1
	for k, v in ipairs(self.crossboss_cfg) do
		if level == v.scene_level then
			boss_info[index] = v
			index = index + 1
			level = level + 1
		end
	end
	return boss_info
end

function KfBossData:GetMonsterNameById(monster_id)
	local monster_name = ""
	for k, v in pairs(self.monster_cfg) do
		if monster_id == v.id then
			monster_name = v.name
			break
		end
	end
	return monster_name
end

function KfBossData:GetBossResIdById(monster_id)
	local monster_res_id = 0
	for k, v in pairs(self.monster_cfg) do
		if monster_id == v.id then
			monster_res_id = v.resid
			break
		end
	end
	return monster_res_id
end

function KfBossData:GetKfBossState(layer, boss_id)
	for k,v in pairs(self.kf_boss_list) do
		if layer - 1 == v.layer and boss_id == v.boss_id then
			return v.next_flush_time == 0
		end
	end
end

function KfBossData:GetKfRemainCount(layer)
	local boss_list = self:GetCrossBossInfoByLevel(layer)
	local count = 0
	for k,v in pairs(boss_list) do
		if self:GetKfBossState(layer, v.boss_id) then
			count = count + 1
		end
	end
	return count
end

function KfBossData:GetCanToSceneLevel(scene_level)
    local level = GameVoManager.Instance:GetMainRoleVo().level
    for k,v in pairs(self.crossboss_cfg) do
        if v.scene_level == scene_level then
            return v.min_lv <= level, v.min_lv
        end
    end
    return true
end

function KfBossData:GetKfCanGoLevel()
	local scene_level_list = {1, 2, 3, 4}
	for k,v in pairs(scene_level_list) do
		if self:GetCanToSceneLevel(v) == false then
			if k ~= 1 then
				return k - 1
			else
				return 1
			end
		end
	end
	if not self:GetCanToSceneLevel(1) then
		return 1
	elseif self:GetCanToSceneLevel(4) then
		return 4
	end
end