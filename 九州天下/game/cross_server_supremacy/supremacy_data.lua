SupremacyData = SupremacyData or BaseClass()
function SupremacyData:__init()
	if SupremacyData.Instance then
		print_error("[ElementBattleData] attempt to create singleton twice!")
		return
	end
	SupremacyData.Instance =self
	self.boss_task_list = {}
	self.boss_info_list = {}
	self.mountment = {}
	self.SingleInfo_list = {}
	self.haoli_list = {}
end

function SupremacyData:__delete()
	SupremacyData.Instance = nil
end

function SupremacyData:SetBossTaskData(protocol)
	self.boss_task_list.next_refresh_timetamp = protocol.next_refresh_timetamp or 0
	self.boss_task_list.belong_camp = protocol.belong_camp or 0
	self.boss_task_list.is_exist = protocol.is_exist or 0
	self.boss_task_list.uesr_list = protocol.user_list or {}
end

function SupremacyData:SetBossInfoData(protocol)
	self.boss_info_list.camp_hurt_list = protocol.camp_hurt_list or {}
	self.boss_info_list.boss_hp = protocol.boss_hp or 0
end

function SupremacyData:SetMountment(protocol)
	self.mountment.monument_list = protocol.monument_list or {}
	self.mountment.treasure_num = protocol.treasure_num
end

function SupremacyData:SetSingleInfo(protocol)
	local seq = protocol.seq
	self.SingleInfo_list.item_list = protocol.item_list[seq] or {}
end

function SupremacyData:GetBossTaskData()
	return self.boss_task_list
end

function SupremacyData:GetBossInfoData()
	return self.boss_info_list
end

function SupremacyData:GetMonument()
	return self.mountment
end

function SupremacyData:GetSingleInfo()
	return self.SingleInfo_list.item_list or {}
end

function SupremacyData:GetRewardCfg()
	if not self.cfg then
		self.cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("cross_dakuafu_auto").rongyao_reward, "seq") or {}
	end
	return self.cfg
end

function SupremacyData:GetBossCfg()
	if not self.boss_cfg then
		self.boss_cfg = ConfigManager.Instance:GetAutoConfig("cross_dakuafu_auto").boss_cfg or {}
	end
	return self.boss_cfg
end

function SupremacyData:GetBossPosition()
	local t = {}
	local cfg = self:GetBossCfg()
	for k,v in pairs(cfg) do
		if v.boss_pos then
			local t = Split(v.boss_pos, ",")
			return t
		end
	end
	return t
end

function SupremacyData:GetBossId()
	local cfg = self:GetBossCfg()
	if cfg[1] then
		return cfg[1].boss_id or 0
	end
	return 0
end

function SupremacyData:GetSmallMonsterCfg()
	if not self.monster_cfg then
		self.monster_cfg = ConfigManager.Instance:GetAutoConfig("cross_dakuafu_auto").other or {}
	end
	return self.monster_cfg
end

function SupremacyData:GetSmallMonsterPos()
	local cfg = self:GetSmallMonsterCfg()
	for k,v in pairs(cfg) do
		if v.refresh_monster_point then
			local t = Split(v.refresh_monster_point, "|")
			local temp = {}
			for k,v in pairs(t) do
				table.insert(temp,Split(v, ","))
			end
			return temp
		end
	end
	return nil
end

function SupremacyData:GetMonsterId()
	if not self.guaji_cfg then
		self.guaji_cfg = ConfigManager.Instance:GetAutoConfig("cross_dakuafu_auto").guaji_cfg or {}
	end
	if self.guaji_cfg[1] then
		 return self.guaji_cfg[1].monster_id or 0
	end
	return 0
end

function SupremacyData:GetShortDistance(x,y)
	local cfg = self:GetSmallMonsterPos()
	local distance = {pos_x = 0, pos_y = 0,}
	if cfg == nil then
		return distance
	end
	for k,v in pairs(cfg) do
		if distance.dis == nil then
			distance.dis = GameMath.GetDistance(x,y,v[1],v[2],false)
			distance.pos_x = v[1]
			distance.pos_y = v[2]
		else
			if distance.dis > GameMath.GetDistance(x,y,v[1],v[2],false) then
				distance.dis = GameMath.GetDistance(x,y,v[1],v[2],false)
				distance.pos_x = v[1]
				distance.pos_y = v[2]
			end
		end
	end
	return distance
end

function SupremacyData:GetNeedHonour(num)
	local cfg = self:GetRewardCfg()
	for k,v in pairs(cfg) do
		if num < v.need_rongyao then
			return v, 1
		end
	end
	return cfg[#cfg], 0
end

function SupremacyData:SetHaoLiInfo(protocol)
	self.haoli_list.collect_num = protocol.collect_num
	self.haoli_list.collect_max = protocol.collect_max
end

function SupremacyData:GetHaoLiInfo()
	return self.haoli_list
end

function SupremacyData:IsSupremacyScene(scene_id)
	return scene_id >= 2510 and scene_id <= 2514
end
