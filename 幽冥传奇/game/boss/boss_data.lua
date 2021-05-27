BossData = BossData or BaseClass()

BossData.UPDATE_BOSS_DATA = "update_boss_data"
BossData.BOSS_DATA_REFRESH = "boss_data_refresh"
BossData.NEWLY_BOSS_REMIND = "newly_boss_remind"

BossData.BossTypeEnum = {
	WILD_BOSS = 1,			-- 野外boss
	HOUSE_BOSS = 2,			-- boss之家boss
	SECRET_BOSS = 3,		-- 秘境boss
}
function BossData:__init()
	if BossData.Instance then
		ErrorLog("[BossData]:Attempt to create singleton twice!")
	end
	BossData.Instance = self
	self.boss_list = {}
	self.scene_id_key_boss_list = {}
	self.refresh_boss_list = {}
	self.boss_remind_flag_list = {}
	self:SetDefaultBossRemindFlag()
	--self.OnlineRefresh = 0  --在线时有boss刷新
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function BossData:GetGameBossInfoById(id)
	return self.refresh_boss_list[id]
end

function BossData:GetSceneRefreshBossList()
	return self.refresh_boss_list
end

function BossData:__delete()
	BossData.Instance = nil
end

function BossData:SetDefaultBossRemindFlag()
	for i = 1, 5 do
		self.boss_remind_flag_list[i] = bit:d2b(0, true)
	end
end

function BossData:SetAllRemindFlag(list)
	for k, v in pairs(list) do
		self.boss_remind_flag_list[k] = bit:d2b(v, true)
	end
	self:DispatchEvent(BossData.BOSS_DATA_REFRESH)
end

-- 根据类型和bossid 取提醒索引
function BossData:GetRemindex(boss_type, boss_id)
	if nil == boss_type or nil == boss_id then return end
	for i,v in ipairs(ModBossConfig[boss_type]) do
		if v.BossId == boss_id then return i end
	end
end

function BossData:SetOneTypeRemindFlag(type, index, value)
	if self.boss_remind_flag_list[type] then
		self.boss_remind_flag_list[type][index] = value
	end
end

function BossData:GetOneTypeRemindInt64Value(type)
	local arg = self.boss_remind_flag_list[type]
	if arg then
		return bit:b2int64(arg)
	end
end

function BossData:GetRemindFlag(type, index)
	return self.boss_remind_flag_list[type] and self.boss_remind_flag_list[type][64-index] or 0
end

function BossData.GetMosterCfg(monster_id)
	return StdMonster and StdMonster[monster_id] or {}
end

function BossData.GetMosterModelCfg(model_id)
	if nil == BossData.monster_model_cfg then
		local cfg = {}
		BossData.monster_model_cfg = cfg
		for k, v in pairs(StdMonster) do
			if nil == cfg[v.modelid] then
				cfg[v.modelid] = {modelScale = 1}
			end
			if nil ~= v.modelScale then
				cfg[v.modelid].modelScale = v.modelScale
			end
		end
	end
	return BossData.monster_model_cfg[model_id]
end

function BossData:GetSceneBossList()
	return self.boss_list
end

function BossData:GetSceneBossListByType(type)
	return self.boss_list[type] or {}
end

function BossData:GetSceneBossListBySceneId(scene_id)
	return self.scene_id_key_boss_list[scene_id] or {}
end

function BossData:GetOneSceneBossList(scene_id)
	local data = {}
	for k,v in pairs(self.scene_id_key_boss_list[scene_id] or {}) do
		if v.refresh_time == 0 then
			table.insert(data, v.boss_id)
		end
	end
	return data
end

function BossData:SetSceneBossList(list)
	local flush_explore_rareplace = false

	self.refresh_boss_list = {}
	for k,v in pairs(list) do
		v.monster_lv = 0
		v.monster_circle = 0
		v.monster_lunhui = 0
		local cfg = BossData.GetMosterCfg(v.boss_id)
		if cfg then
			v.monster_lv = cfg.level
			v.monster_circle = cfg.circle
			v.monster_lunhui = cfg.lunhui
		end

		local boss_type = v.boss_type or -1
		self.boss_list[boss_type] = self.boss_list[boss_type] or {}
		
		if self.boss_list[boss_type][v.boss_id] then
			if(self.boss_list[boss_type][v.boss_id].refresh_time > 0 and v.refresh_time == 0 ) then
				self.refresh_boss_list[v.boss_id] = v
			end
			self.boss_list[boss_type][v.boss_id].refresh_time = v.refresh_time
			self.boss_list[boss_type][v.boss_id].now_time = v.now_time
		else
			self.boss_list[boss_type][v.boss_id] = v
			self.refresh_boss_list[v.boss_id] = v
		end

		self.scene_id_key_boss_list[v.scene_id] = self.scene_id_key_boss_list[v.scene_id] or {}
		self.scene_id_key_boss_list[v.scene_id][v.boss_id] = v
		if v.boss_type == BossData.BossTypeEnum.SECRET_BOSS then
			flush_explore_rareplace = true
		end
	end

	if flush_explore_rareplace then
		RemindManager.Instance:DoRemindDelayTime(RemindName.ExploreRareplace)
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.WildBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.CircleBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.VipBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.XinghunBossKill)
	RemindManager.Instance:DoRemindDelayTime(RemindName.MjingBossKill)

	self:DispatchEvent(BossData.UPDATE_BOSS_DATA)
	self:DispatchEvent(BossData.BOSS_DATA_REFRESH)
end

function BossData.BossIsEnoughAndTip(data)
	local is_enough = true
	local text_str = ""
	local style = 0

	if data then
		local need_level = data.boss_level or data.level or 0
		local need_circle = data.boss_circle or data.circle or 0
		local need_vip = data.viplv or data.vip_level or 0
		local need_lunhui = data.boss_lunhui or 0
		local zs_vip = data.boss_zslv or data.zslv or 0
		local card_lv = data.cardlv or 0
		local swinglv = data.swinglv or 0
		if need_level > 0 then
			text_str = string.format(Language.Role.XXJi, need_level)
			if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < need_level then
				is_enough = false
			else
				is_enough = true
			end
		end
		if need_circle > 0 then
			text_str = string.format(Language.Common.ZhuanFormat, need_circle)
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) < need_circle then
				is_enough = false
			else
				is_enough = true
			end
		end
		if need_lunhui > 0 then
			text_str = string.format(Language.Role.XXDao, need_lunhui)
			local lunhui_level = 0
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) >= need_circle then 
				lunhui_level = LunHuiData.Instance:GetLunGrade() + 1
			end
			if lunhui_level < need_lunhui then
				is_enough = false
			else
				is_enough = true
			end
		end
		if need_vip > 0 then 
			text_str = "VIP" .. need_vip
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE) < need_vip then 
				is_enough = false
			else
				is_enough = true
			end
		end
		if zs_vip > 0 then 
			local index = (zs_vip+2)/ZsVipView.ENUM_JIE 
			text_str = Language.Boss.ZsBossBtn[index]
			if ZsVipData.Instance:GetZsVipLv() < zs_vip then 
				is_enough = false
			else
				is_enough = true
			end
		end

		if swinglv > 0 then 
			style = 1
			text_str = string.format("  翅膀%s阶" , WingData.GetWingLevelAndGrade(swinglv))
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL) < swinglv then 
				is_enough = false
			else
				is_enough = true
			end
		end
	end
	return is_enough, text_str, style
end

-- 设置boss死亡
function BossData:SetBossDie(protocol)
	local boss_id = protocol.boss_id or 0

	-- 公会boss死亡处理
	local act_boss_info = StdActivityCfg[DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS].bossInfo or {}
	local act_boss_id = act_boss_info[#act_boss_info].monId
	if boss_id == act_boss_id then
		ActivityCtrl.Instance:OnGuildBossDie()
	end
end