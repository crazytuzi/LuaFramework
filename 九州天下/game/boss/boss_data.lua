BossData = BossData or BaseClass(BaseEvent)

BOSS_ENTER_TYPE = {
	TYPE_BOSS_WORLD = 0,
	TYPE_BOSS_FAMILY = 1,
	TYPE_BOSS_MIKU = 2,
	TYPE_BOSS_DABAO = 3,
	LEAVE_BOSS_SCENE = 4,
	TYPE_BOSS_ACTIVE = 5,
	TYPE_BOSS_NEUTRAL = 6,
	TYPE_BOSS_BABY = 7,
}

BossData.Boss_State = {
	not_start = 0,
	ready = 1,
	death = 2,
	time_over = 3,
}

BossData.BossType = {
	WORLD_BOSS = 0,
	BOSS_HOME = 1,
	ELITE_BOSS = 2,
	DABAO_MAP = 3,
	BABY_BOSS = 4,
}

BossData.FOLLOW_BOSS_OPE_TYPE = {
	FOLLOW_BOSS = 0,					--关注boss
	UNFOLLOW_BOSS = 1,					--取消关注
	GET_FOLLOW_LIST = 2,				--获取关注列表
}

--怪物平台位置
BossData.PingTai = {
	Vector3(-264.74, 485.13, 676.71),	--平台1
	Vector3(-267.12, 485.13, 678.94),	--平台2
	Vector3(-269.57, 485.13, 676.71),	--平台3
	Vector3(-267.11, 485.13, 672.96),	--平台4
}

BOSS_TYPE =
{
	FAMILY_BOSS = 0,
	MIKU_BOSS = 1,
	NEUTRAL_BOSS = 2,
	BABY_BOSS = 3,
}

BossData.WORLD_BOSS_ENTER_TYPE = {
	WORLD_BOSS_ENTER = 0,				-- 进入
	WORLD_BOSS_LEAVE = 1,				-- 离开
}

BossData.DABAO_BOSS = "dabao_boss"
BossData.FAMILY_BOSS = "family_boss"
BossData.MIKU_BOSS = "miku_boss"
BossData.ACTIVE_BOSS = "active_boss"
BossData.NEUTRAL_BOSS = "neutral_boss"
BossData.BABY_BOSS = "baby_boss"

function BossData:__init()
	if BossData.Instance then
		print_error("[BossData] Attempt to create singleton twice!")
		return
	end
	BossData.Instance = self
	self.boss_family_cfg = ConfigManager.Instance:GetAutoConfig("bossfamily_auto")
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	self.worldboss_auto = ConfigManager.Instance:GetAutoConfig("worldboss_auto")
	self.baby_boss_cfg = ConfigManager.Instance:GetAutoConfig("baby_boss_config_auto")

	self.boss_family_cfg_boss = ListToMap(self.boss_family_cfg.boss_family, "bossID")
	self.boss_family_cfg_scene = ListToMapList(self.boss_family_cfg.boss_family, "scene_id")

	self.dabao_boss_cfg_boss =  ListToMap(self.boss_family_cfg.dabao_boss, "bossID")
	self.dabao_boss_cfg_scene = ListToMapList(self.boss_family_cfg.dabao_boss, "scene_id")

	self.miku_boss_cfg_boss = ListToMap(self.boss_family_cfg.miku_boss, "bossID")
	self.miku_boss_cfg_scene = ListToMapList(self.boss_family_cfg.miku_boss, "scene_id", "camp_type")

	self.neutral_boss_cfg_boss = ListToMap(self.boss_family_cfg.neutral_boss, "boss_id")
	self.neutral_boss_cfg_scene = ListToMapList(self.boss_family_cfg.neutral_boss, "scene_id", "boss_id")

	self.enter_condition_cfg = ListToMap(self.boss_family_cfg.enter_condition, "scene_id")

	self.active_boss_cfg_boss = ListToMap(self.boss_family_cfg.active_boss, "bossID")
	self.active_boss_cfg_scene = ListToMapList(self.boss_family_cfg.active_boss, "scene_id")

	self.baby_boss_list_scene = ListToMapList(self.baby_boss_cfg.scene_cfg, "scene_id")
	self.baby_boss_list_boss = ListToMap(self.baby_boss_cfg.scene_cfg, "monster_id")
	self.baby_layer_limit = ListToMap(self.baby_boss_cfg.enter_limit, "layer")

	--self.active_boss_cfg = self.boss_family_cfg.active_boss
	self.dabao_cost_cfg = ListToMap(self.boss_family_cfg.dabao_cost, "times")

	self.all_boss_list = self.worldboss_auto.worldboss_list

	self.all_boss_info = {}
	self.worldboss_list = {}
	self.follow_boss_list = {}
	--self:CalToWelfareTime()

	for k,v in pairs(self.all_boss_list) do
		table.insert(self.worldboss_list, v)
	end

	local scene_id = 0
	self.active_boss_level_list = {}

	for k,v in pairs(self.active_boss_cfg_scene) do
		if v ~= nil then
			table.insert(self.active_boss_level_list, k)
		end
	end
	self.worldboss_list[0] = table.remove(self.worldboss_list, 1)

	self.next_monster_invade_time = 0
	self.next_refresh_time = 0

	self.boss_personal_hurt_info = {
		my_hurt = 0,
		self_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_guild_hurt_info = {
		my_guild_hurt = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_week_rank_info = {
		my_guild_kill_count = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}
	self.worldboss_weary = 0
	self.worldboss_weary_last_die_time = 0
	self.dabao_angry_value = 0
	self.dabao_enter_count = 0
	self.active_angry_value = 0
	self.active_enter_count = 0
	self.family_boss_list = {}
	self.family_boss_list.boss_list = {}
	self.miku_boss_info = {
		miku_boss_weary = 0,
		boss_list = {}
	}

	self.world_boss_activity = {}
	self.neutral_boss_info = {}
	self.neutral_boss_info.boss_list = {}
	self.dabao_flush_info = {}
	self.active_flush_info = {}
	self:AddEvent(BossData.DABAO_BOSS)
	self:AddEvent(BossData.FAMILY_BOSS)
	self:AddEvent(BossData.MIKU_BOSS)
	self:AddEvent(BossData.ACTIVE_BOSS)
	self:AddEvent(BossData.NEUTRAL_BOSS)
	self:AddEvent(BossData.BABY_BOSS)

	self.boss_baby_role_info = {}
	self.boss_baby_all_info = {}
end

function BossData:__delete()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	BossData.Instance = nil
end

function BossData:ClearCache()
	self.boss_personal_hurt_info = {
		my_hurt = 0,
		self_rank = 0,
		rank_count = 0,
		rank_list = {},
	}

	self.boss_guild_hurt_info = {
		my_guild_hurt = 0,
		my_guild_rank = 0,
		rank_count = 0,
		rank_list = {},
	}
end

function BossData:SetNextMonsterInvadeTime(time)
	self.next_monster_invade_time = time
end

function BossData:GetNextMonsterInvadeTime()
	return self.next_monster_invade_time
end

function BossData:GetBossState(boss_id)
	return BossData.Boss_State.ready
end

function BossData:OnSCFollowBossInfo(protocol)
	self.follow_boss_list = protocol.follow_boss_list
	if #self.follow_boss_list ~= 0 then
		self:CalToRemind()
	end
end

--获取关注列表
function BossData:GetFollowBossList()
	return self.follow_boss_list
end

--boss是否被关注 true被关注, false 没关注
function BossData:BossIsFollow(boss_id)
   for k,v in pairs(self.follow_boss_list) do
		if v.boss_id == boss_id then
			return true
		end
	end
	return false
end

--boss提醒功能
function BossData:CalToRemind()
	local boss_id, timer, boss_info = self:GetFocusBossFlush()
	if boss_id == 0 or timer == 0 then
		return
	end
	self.forcus_boss = boss_id
	timer = timer - TimeCtrl.Instance:GetServerTime()

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer = timer - UnityEngine.Time.deltaTime
		if timer <= 10 then
			local ok_call_back = function()
				if self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
					self:ToAttackBossFamily()
				elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
					self:ToAttackBossMiKu()
				elseif self.focus_boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL then
					if boss_info then
						self:ToAttackBossNeutral(boss_info)
					end
				end
			end
			if self.open_boss_id == nil or self.open_boss_id ~= boss_id and self:GetCanShowFocusTip() then
				TipsCtrl.Instance:OpenFocusBossTip(boss_id, ok_call_back, false, false, timer)
				self.open_boss_id = boss_id
			end
			self.forcus_boss, timer = self:GetFocusBossFlush()
			if self.forcus_boss == 0 or timer == 0 then
				GlobalTimerQuest:CancelQuest(self.time_quest)
				self.time_quest = nil
				self.open_boss_id = nil
			else
				timer = timer - TimeCtrl.Instance:GetServerTime()
			end
		end
	end, 0)
end

function BossData:SetWorldBossWearyInfo(protocol)
	self.worldboss_weary = protocol.worldboss_weary or 0
	self.worldboss_weary_last_die_time = protocol.worldboss_weary_last_die_time or 0
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
end

function BossData:GetWroldBossWeary()
	return self.worldboss_weary
end

function BossData:GetWroldBossWearyLastDie()
	return self.worldboss_weary_last_die_time
end

--boss之家 密窟
function BossData:SetBossType(boss_type)
	self.boss_type = boss_type
end

--boss之家 密窟
function BossData:GetBossType()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsFamilyBossScene(scene_id) then
		return BOSS_TYPE.FAMILY_BOSS
	elseif BossData.IsMikuBossScene(scene_id) then
		return BOSS_TYPE.MIKU_BOSS
	elseif BossData.IsNeutralBossScene(scene_id) then
		return BossType.NEUTRAL_BOSS
	elseif BossData.IsBabyBossScene(scene_id) then
		return BOSS_TYPE.BABY_BOSS
	end
end

function BossData:SetAutoComeFlag(auto_come_flag)
	self.auto_come_flag = auto_come_flag
end

function BossData:GetAutoComeFlag()
	return self.auto_come_flag
end

function BossData:ToAttackBossFamily()
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	if self:GetFamilyBossCanGoByVip(self.foucs_boss_info.scene_id) then
		ViewManager.Instance:CloseAll()
		self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
		self:SetBossType(BOSS_TYPE.FAMILY_BOSS)
		self.auto_come_flag = true
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
	else
		local _, cost_gold = self:GetBossVipLismit(self.foucs_boss_info.scene_id)
		local ok_fun = function ()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if vo.gold + vo.bind_gold >= cost_gold then
				ViewManager.Instance:CloseAll()
				self:SetBossType(BOSS_TYPE.FAMILY_BOSS)
				self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
				self.auto_come_flag = true
				BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.foucs_boss_info.scene_id)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		end
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Boss.BossFamilyLimitStr, cost_gold))
	end
end

function BossData:ToAttackBossMiKu()
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.foucs_boss_info.scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	ViewManager.Instance:CloseAll()
	self:SetBossType(BOSS_TYPE.MIKU_BOSS)
	self.auto_come_flag = true
	local role_vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	self:SetCurInfo(self.foucs_boss_info.scene_id, self.foucs_boss_info.boss_id)
	BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.foucs_boss_info.scene_id + (role_vo_camp * 4 - 4), 0, self.foucs_boss_info.boss_id)
end

function BossData:ToAttackBossNeutral(boss_info)
	if not self:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end

	if boss_info == nil or next(boss_info) == nil then
		return
	end

	if boss_info.scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	ViewManager.Instance:CloseAll()
	self:SetCurInfo(boss_info.scene_id, boss_info.boss_id)
	self.auto_come_flag = true
	local boss_list = self:GetNeutralBossList(boss_info.scene_id)

	local get_boss_id = boss_info.boss_id - 3059

	if get_boss_id and boss_list[get_boss_id] then
		TaskCtrl.SendFlyByShoe(boss_info.scene_id, boss_list[get_boss_id].born_x, boss_list[get_boss_id].born_y, nil, 1)
	end
end

--获得最快刷新的一个boss
function BossData:GetFocusBossFlush()
	if #self.follow_boss_list == 0 then
		return 0, 0
	end
	local list = {}
	for k,v in pairs(self.follow_boss_list) do
		local temp_list = {}
		if v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
			local status = self:GetBossFamilyStatusByBossId(v.boss_id, v.scene_id)
			if status == 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetFamilyBossRefreshTime(v.boss_id, v.scene_id)
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
			local role_vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
			local status = self:GetBossMikuStatusByBossId(v.boss_id, v.scene_id + (role_vo_camp * 4 - 4))
			if status == 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetMikuBossRefreshTime(v.boss_id, v.scene_id + (role_vo_camp * 4 - 4)) 
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		elseif v.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL then
			local status = self:GetBossNeutralStatusByBossId(v.boss_id, v.scene_id)
			if status == 0 then
				temp_list.boss_id = v.boss_id
				temp_list.flush_time = self:GetNeutralBossRefreshTime(v.boss_id, v.scene_id) 
				temp_list.boss_type = v.boss_type
				temp_list.scene_id = v.scene_id
			end
		end
		if temp_list.flush_time and temp_list.flush_time > 0 then
			table.insert(list, temp_list)
		end
	end

	local boss_id = 0
	local min_value = 0
	local server_time = TimeCtrl.Instance:GetServerTime()
	if #list ~= 0 then
		min_value = list[1].flush_time
		for k,v in pairs(list) do
			if v.flush_time ~= 0 and v.flush_time <= min_value and v.flush_time - server_time > 60 then
				min_value = v.flush_time
				boss_id = v.boss_id
				self.focus_boss_type = v.boss_type
				self.foucs_boss_info = v
			end
		end
	end
	return boss_id, min_value, self.foucs_boss_info
end
-----------------------------------世界Boss---------------------------------------------

-- 获取可击杀列表信息
function BossData:GetCanKillList()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local can_kill_list = {}
	for k,v in pairs(self.all_boss_info) do
		if 1 == v.status then
			local boss_cfg = self:GetBossCfgById(v.boss_id)
			if nil ~= boss_cfg and boss_cfg.boss_level <= role_level then
				local boss_info = {}
				boss_info.boss_type = boss_cfg.boss_tag
				boss_info.name = boss_cfg.boss_name
				boss_info.scene_id = boss_cfg.scene_id
				boss_info.x = boss_cfg.born_x
				boss_info.y = boss_cfg.born_y
				boss_info.boss_level = boss_cfg.boss_level

				boss_info.status = v.status
				boss_info.boss_id = v.boss_id
				can_kill_list[#can_kill_list + 1] = boss_info
			end
		end
	end

	table.sort(can_kill_list, BossData.CanKillKeySort("boss_type", "boss_level"))

	return can_kill_list
end

-- 可击杀排序
function BossData.CanKillKeySort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] < b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] > b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a > order_b
	end
end

function BossData:GetWorldBossNum()
	if 0 == #self.worldboss_list then
		return nil
	end
	return #self.worldboss_list
end

function BossData:GetBossCfg()
	return self.worldboss_list
end

-- 根据boss_id获取世界boss信息
function BossData:GetBossCfgById(boss_id)
	for k,v in pairs(self.all_boss_list) do
		if boss_id == v.bossID then
			return v
		end
	end
	return nil
end

-- 根据boss_id获取boss状态   1.可击杀   0.未刷新
function BossData:GetBossStatusByBossId(boss_id)
	if nil ~= self.all_boss_info[boss_id] then
		return self.all_boss_info[boss_id].status
	end
	return 0
end

-- 根据boss_id获取boss之家状态   1.可击杀   0.未刷新
function BossData:GetBossFamilyStatusByBossId(boss_id, scene_id)
	if nil ~= self.family_boss_list.boss_list[scene_id] then
		for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.status
			end
		end
	end
	return 0
end

function BossData:GetDaBaoStatusByBossId(boss_id, scene_id)
	if nil ~= self.dabao_flush_info[scene_id] then
		for k,v in pairs(self.dabao_flush_info[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetActiveStatusByBossId(boss_id, scene_id)
	if nil ~= self.active_flush_info[scene_id] then
		for k,v in pairs(self.active_flush_info[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time
			end
		end
	end
	return 0
end

function BossData:GetBossMikuStatusByBossId(boss_id, scene_id)
	if nil ~= self.miku_boss_info.boss_list[scene_id] then
		for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.status
			end
		end
	end
	return 0
end

function BossData:GetBossNeutralStatusByBossId(boss_id, scene_id)
	if nil ~= self.neutral_boss_info.boss_list[scene_id] then
		for k,v in pairs(self.neutral_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.status
			end
		end
	end
	return 0
end

function BossData:SetBossInfo(protocol)
	self.next_refresh_time = protocol.next_refresh_time
	local boss_list = protocol.boss_list
	self.all_boss_info = {}
	self.all_boss_info.fuli_killer_name = protocol.fuli_killer_name
	self.all_boss_info.fuli_killer_uid = protocol.fuli_killer_uid
	self.all_boss_info.fuli_boss_status = protocol.fuli_boss_status
	self.all_boss_info.boss_id = protocol.cur_fuli_boss_id
	for k,v in pairs(boss_list) do
		self.all_boss_info[v.boss_id] = v
	end
end

function BossData:FlushWorldBossInfo(protocol)
	for k,v in pairs(self.all_boss_info) do
		if k == protocol.boss_id then
			v.status = protocol.status
		end
	end
end

function BossData:GetCurBossID()
	if self.all_boss_info.boss_id then
		return self.all_boss_info.boss_id
	end
	return 0
end

-- 获取世界boss列表
function BossData:GetWorldBossList()
	local boss_list = {}
	for i=0,#self.worldboss_list + 1 do
		if nil ~= self.worldboss_list[i] then
			boss_list[i + 1] = {}
			boss_list[i + 1].bossID = self.worldboss_list[i].bossID
			boss_list[i + 1].boss_type = self.worldboss_list[i].boss_tag
			boss_list[i + 1].status = self:GetBossStatusByBossId(self.worldboss_list[i].bossID)
			boss_list[i + 1].min_lv = self.worldboss_list[i].min_lv
		end
	end
	function sortfun(a, b)
		if a.status > b.status then
			return true
		elseif  a.status == b.status then
			local level_1 = self:GetWorldBossInfoById(a.bossID).boss_level
			local level_2 = self:GetWorldBossInfoById(b.bossID).boss_level
			return level_1 < level_2
		else
			return false
		end
	end
	table.sort(boss_list, sortfun)
	return boss_list
end

-- 根据索引获取boss信息
function BossData:GetWorldBossInfoById(boss_id)
	local cur_info = nil
	for k,v in pairs(self.worldboss_list) do
		if boss_id == v.bossID then
			cur_info = v
			break
		end
	end
	if nil == cur_info then return end

	local monster_info = self:GetMonsterInfo(boss_id) or {}

	local boss_info = {}
	boss_info.boss_name = cur_info.boss_name
	boss_info.boss_level = cur_info.boss_level
	boss_info.boss_id = cur_info.bossID
	boss_info.scene_id = cur_info.scene_id
	boss_info.born_x = cur_info.born_x
	boss_info.born_y = cur_info.born_y
	local scene_config = ConfigManager.Instance:GetSceneConfig(boss_info.scene_id)
	boss_info.map_name = scene_config.name
	boss_info.refresh_time = cur_info.refresh_time
	boss_info.recommended_power = cur_info.recommended_power

	local item_list = {}
	for i = 1, 8 do
		local item_id = cur_info["show_item_id" .. i]
		if item_id then
			table.insert(item_list, item_id)
		end
	end

	boss_info.item_list = item_list
	boss_info.boss_capability = cur_info.boss_capability
	boss_info.resid = monster_info.resid
	if nil ~= self.all_boss_info[cur_info.bossID] then
		boss_info.status = self.all_boss_info.fuli_boss_status or 0
		boss_info.last_kill_name = self.all_boss_info.fuli_killer_name or ""
		boss_info.last_kill_uid = self.all_boss_info.fuli_killer_uid or 0
	end

	return boss_info
end

function BossData:GetMonsterInfo(boss_id)
	if boss_id ~= nil then
		if self.monster_cfg[boss_id] ~= nil then
			return self.monster_cfg[boss_id]
		end
	end
	return nil
end

function BossData:GetBossNextReFreshTime()
	return self.next_refresh_time
end

function BossData.KeyDownSort(sort_key_name1, sort_key_name2)
	return function(a, b)
		local order_a = 100000
		local order_b = 100000
		if a[sort_key_name1] > b[sort_key_name1] then
			order_a = order_a + 10000
		elseif a[sort_key_name1] < b[sort_key_name1] then
			order_b = order_b + 10000
		end

		if nil == sort_key_name2 then  return order_a < order_b end

		if a[sort_key_name2] > b[sort_key_name2] then
			order_a = order_a + 1000
		elseif a[sort_key_name2] < b[sort_key_name2] then
			order_b = order_b + 1000
		end

		return order_a < order_b
	end
end

function BossData:SetBossPersonalHurtInfo(protocol)
	self.boss_personal_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_personal_hurt_info[k] = v
	end
end

function BossData:SetBossGuildHurtInfo(protocol)
	self.boss_guild_hurt_info = {}
	for k,v in pairs(protocol) do
		self.boss_guild_hurt_info[k] = v
	end
end

function BossData:SetBossWeekRankInfo(protocol)
	for k,v in pairs(protocol) do
		self.boss_week_rank_info[k] = v
	end
end

function BossData:OnSCDabaoBossNextFlushInfo(protocol)
	self.dabao_flush_info[protocol.scene_id] = protocol.boss_list
end

function BossData:OnSCActiveBossNextFlushInfo(protocol)
	self.active_flush_info[protocol.scene_id] = protocol.boss_list
end

function BossData:FlushDaBaoFlushInfo(protocol)
	local have_scene = false
	for k,v in pairs(self.dabao_flush_info) do
		if protocol.scene_id == k then
			have_scene = true
			for k,v in pairs(v) do
				if v.boss_id == protocol.boss_id then
					v.next_refresh_time = protocol.next_refresh_time
					return
				end
			end
		end
	end
	if have_scene then
		local list = {}
		list.boss_id = protocol.boss_id
		list.next_refresh_time = protocol.next_refresh_time
		table.insert(self.dabao_flush_info[protocol.scene_id], list)
	else
		self.dabao_flush_info[protocol.scene_id] = {}
		self.dabao_flush_info[protocol.scene_id][1] = {}
		self.dabao_flush_info[protocol.scene_id][1].boss_id = protocol.boss_id
		self.dabao_flush_info[protocol.scene_id][1].next_refresh_time = protocol.next_refresh_time
	end
end

function BossData:FlushActiveFlushInfo(protocol)
	local have_scene = false
	for k,v in pairs(self.active_flush_info) do
		if protocol.scene_id == k then
			have_scene = true
			for k,v in pairs(v) do
				if v.boss_id == protocol.boss_id then
					v.next_refresh_time = protocol.next_refresh_time
					return
				end
			end
		end
	end
	if have_scene then
		local list = {}
		list.boss_id = protocol.boss_id
		list.next_refresh_time = protocol.next_refresh_time
		table.insert(self.active_flush_info[protocol.scene_id], list)
	else
		self.active_flush_info[protocol.scene_id] = {}
		self.active_flush_info[protocol.scene_id][1] = {}
		self.active_flush_info[protocol.scene_id][1].boss_id = protocol.boss_id
		self.active_flush_info[protocol.scene_id][1].next_refresh_time = protocol.next_refresh_time
	end
end

function BossData:GetBossPersonalHurtInfo()
	return self.boss_personal_hurt_info
end

function BossData:GetBossGuildHurtInfo()
	return self.boss_guild_hurt_info
end

function BossData:GetBossWeekRankInfo()
	return self.boss_week_rank_info
end

function BossData:GetBossWeekRewardConfig()
	return self.worldboss_auto.week_rank_reward
end

function BossData:GetBossOtherConfig()
	return self.worldboss_auto.other[1]
end

function BossData:GetWorldBossIdBySceneId(scene_id)
	if not scene_id then return end
	local config = self:GetBossCfg()
	if config then
		for k,v in pairs(config) do
			if v.scene_id == scene_id then
				return v.bossID
			end
		end
	end
end

function BossData:SetDabaoBossInfo(protocol)
	self.dabao_angry_value  = protocol.dabao_angry_value
	self.dabao_enter_count  = protocol.dabao_enter_count
	self.dabao_kick_time = protocol.kick_time
	self:NotifyEventChange(BossData.DABAO_BOSS)
end

function BossData:SetActiveBossInfo(protocol)
	self.active_angry_value  = protocol.active_angry_value
	self.active_enter_count  = protocol.enter_count
	self.active_kick_time = protocol.kick_time
	self:NotifyEventChange(BossData.ACTIVE_BOSS)
end

function BossData:GetDabaoBossInfo()
	return self.dabao_angry_value
end

function BossData:GetActiveBossInfo()
	return self.active_angry_value
end

function BossData:GetDabaoBossCount()
	return self.dabao_enter_count
end

function BossData:GetActiveBossCount()
	return self.active_enter_count
end

function BossData:GetDabaoFreeTimes()
	return self.boss_family_cfg.other[1].dabao_free_times
end

function BossData:GetBossOtherCfg()
	return self.boss_family_cfg.other[1]
end

function BossData:GetDaBaoKickTime()
	return self.dabao_kick_time
end

function BossData:GetActiveKickTime()
	return self.active_kick_time
end

function BossData:GetActiveFirstEnter()
	return self.active_first_enter or 0
end

function BossData:GetDabaoMaxValue()
	return self.boss_family_cfg.other[1].max_value
end

function BossData:GetActiveMaxValue()
	return self.boss_family_cfg.other[1].max_value
end

function BossData:GetDabaoEnterGold(count)
   -- for k,v in pairs(self.boss_family_cfg.dabao_cost) do
   --      if v.times == count then
   --          return v.cost_gold
   --      end
   -- end
   if count ~= nil then
		return self.dabao_cost_cfg[count]
   end
   return self.boss_family_cfg.dabao_cost[#self.boss_family_cfg.dabao_cost].cost_gold
end

function BossData:CanGoActiveBoss(scene_id)
	local _a, _b, item_id, num = self:GetBossVipLismit(scene_id)
	local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
	local is_first_enter = self:GetActiveFirstEnter()
	local angry_val = self:GetActiveBossInfo()
	if is_first_enter == 0 and my_count >= num then
		return true
	elseif is_first_enter ~= 0 and angry_val < 100 then
		return true
	elseif is_first_enter ~= 0 and my_count >= num then
		return true
	else
		return false
	end
   -- return my_count >= num
   return true
end


function BossData:SetFamilyBossInfo(protocol)
	self.family_boss_list.boss_list[protocol.scene_id] = protocol.boss_list
	self:NotifyEventChange(BossData.FAMILY_BOSS)
end

function BossData:GetFamilyBossInfo(scene_id)
	return self.family_boss_list.boss_list[scene_id]
end

function BossData:OnSCBossInfoToAll(protocol)
	if protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
	   for k,v in pairs(self.family_boss_list.boss_list) do
			if k == protocol.scene_id then
				for k1,v1 in pairs(v) do
					if v1.boss_id == protocol.boss_id then
						v1.status = protocol.status
						v1.next_refresh_time = protocol.next_refresh_time
					end
				end
			end
		 end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		 for k,v in pairs(self.miku_boss_info.boss_list) do
			if k == protocol.scene_id then
				for k1,v1 in pairs(v) do
					if v1.boss_id == protocol.boss_id then
						v1.status = protocol.status
						v1.next_refresh_time = protocol.next_refresh_time
					end
				end
			end
		 end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		if self.dabao_flush_info then
			local data = {}
			data.boss_id = protocol.boss_id
			data.next_refresh_time = protocol.next_refresh_time
			table.insert(self.dabao_flush_info, data)
		end
	elseif protocol.boss_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		if self.active_flush_info then
			local data = {}
			data.boss_id = protocol.boss_id
			data.next_refresh_time = protocol.next_refresh_time
			table.insert(self.active_flush_info, data)
		end
	end
end

function BossData:GetFamilyBossRefreshTime(boss_id, scene_id)
	if self.family_boss_list.boss_list[scene_id] and #self.family_boss_list.boss_list[scene_id] ~= 0 then
		for k,v in pairs(self.family_boss_list.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetCanShowFocusTip()
	local scene_id = Scene.Instance:GetSceneId()
	local scene_config = ConfigManager.Instance:GetAutoConfig("fb_scene_config_auto")
	local can_go = true
	for k,v in pairs(scene_config) do
		if scene_id == v.scene_type then
			return v.pb_show_boss_tip == 0 -- 0表示显示
		end
	end
	return true
end

function BossData:SetMikuBossInfo(protocol)
	self.miku_boss_info.miku_boss_weary = protocol.miku_boss_weary
	self.miku_boss_info.boss_list[protocol.scene_id] = protocol.boss_list
	self:NotifyEventChange(BossData.MIKU_BOSS)
end

function BossData:SetMikuPiLaoInfo(protocol)
	self.miku_boss_info.miku_boss_weary = protocol.miku_boss_weary
	self:NotifyEventChange(BossData.MIKU_BOSS)
end

function BossData:GetMikuBossInfo()
	return self.miku_boss_info
end

function BossData:GetMikuBossInfoList(scene_id)
	return self.miku_boss_info.boss_list[scene_id]
end

function BossData:GetMikuBossRefreshTime(boss_id, scene_id)
	if self.miku_boss_info.boss_list[scene_id] and #self.miku_boss_info.boss_list[scene_id] ~= 0 then
		for k,v in pairs(self.miku_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetMikuBossWeary()
	return self.miku_boss_info.miku_boss_weary
end

function BossData:SetNeutralBossInfo(protocol)
	self.neutral_boss_scene_id = protocol.scene_id
	self.neutral_boss_info.boss_list[self.neutral_boss_scene_id] = protocol.boss_list
	self:NotifyEventChange(BossData.NEUTRAL_BOSS)
end

function BossData:GetNeutralBossScene(scene_id)
	return self.neutral_boss_info.boss_list[scene_id]
end

function BossData:GetNeutralBossRefreshTime(boss_id, scene_id)
	if self.neutral_boss_info.boss_list[scene_id] and #self.neutral_boss_info.boss_list[scene_id] ~= 0 then
		for k,v in pairs(self.neutral_boss_info.boss_list[scene_id]) do
			if v.boss_id == boss_id then
				return v.next_refresh_time, v.status
			end
		end
	end
	return 0, 0
end

function BossData:GetBossFamilyList(scene_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.boss_family) do
	--     if v.scene_id == scene_id then
	--         table.insert(list, v)
	--     end
	-- end
	if scene_id ~= nil then
		local cfg = self.boss_family_cfg_scene[scene_id]
		if cfg ~= nil then
			list = cfg
		end
	end
	function sortfun(a, b)
		local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
		local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
		return level_a < level_b
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetDaBaoBossList(scene_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.dabao_boss) do
	--     if v.scene_id == scene_id then
	--         table.insert(list, v)
	--     end
	-- end
	if scene_id ~= nil then
		local cfg = self.dabao_boss_cfg_scene[scene_id]
		if cfg ~= nil then
			list = cfg
		end
	end
	function sortfun(a, b)
		local state_a = self:GetDaBaoStatusByBossId(a.bossID, scene_id)
		local state_b = self:GetDaBaoStatusByBossId(b.bossID, scene_id)
		if state_a ~= state_b then
			return state_a < state_b
		else
			local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
			local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
			return level_a < level_b
		end
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetActiveBossList(scene_id)
	local list = {}
	-- for k,v in pairs(self.active_boss_cfg) do
	--     if v.scene_id == scene_id then
	--         table.insert(list, v)
	--     end
	-- end

	if scene_id ~= nil then
		local cfg = self.active_boss_cfg_scene[scene_id]
		if cfg ~= nil then
			list = cfg
		end
	end

	function sortfun(a, b)
		local state_a = self:GetActiveStatusByBossId(a.bossID, scene_id)
		local state_b = self:GetActiveStatusByBossId(b.bossID, scene_id)
		if state_a ~= state_b then
			return state_a < state_b
		else
			local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
			local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
			return level_a < level_b
		end
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetMikuBossList(scene_id)
	local list = {}
	local role_vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	-- for k,v in pairs(self.boss_family_cfg.miku_boss) do
	--     if v.scene_id  == scene_id + (role_vo_camp * 4 - 4) and role_vo_camp == v.camp_type then
	--         table.insert(list, v)
	--     end
	-- end
	if scene_id ~= nil and role_vo_camp ~= nil then
		local cfg = self.miku_boss_cfg_scene[scene_id + (role_vo_camp * 4 - 4)]
		if cfg ~= nil and cfg[role_vo_camp] ~= nil then
			list = cfg[role_vo_camp]
		end
	end
	function sortfun(a, b)
		local level_a = self.monster_cfg[a.bossID] and self.monster_cfg[a.bossID].level or 0
		local level_b = self.monster_cfg[b.bossID] and self.monster_cfg[b.bossID].level or 0
		return level_a < level_b
	end
	table.sort(list, sortfun)
	return list
end 

function BossData:GetNeutralBossList(scene_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.neutral_boss) do
	--     if v.scene_id == scene_id then
	--         table.insert(list, v)
	--     end
	-- end
	if scene_id ~= nil then
		local cfg = self.neutral_boss_cfg_scene[scene_id]
		if cfg ~= nil then
			for k,v in pairs(cfg) do
				table.insert(list, v[1])
			end
		end
	end

	function sortfun(a, b)
		local level_a = self.monster_cfg[a.boss_id] and self.monster_cfg[a.boss_id].level or 0
		local level_b = self.monster_cfg[b.boss_id] and self.monster_cfg[b.boss_id].level or 0
		return level_a < level_b
	end
	table.sort(list, sortfun)
	return list
end

function BossData:GetNeutralBossInfo(scene_id, boss_id)
	-- for k,v in pairs(self.boss_family_cfg.neutral_boss) do
	--     if v.scene_id == scene_id and v.boss_id == boss_id then
	--         return v
	--     end
	-- end
	if scene_id ~= nil and boss_id ~= nil then
		local cfg = self.neutral_boss_cfg_scene[scene_id]
		if cfg ~= nil then
			return cfg[boss_id][1]
		end
	end

	return nil
end


function BossData:GetBossFamilyFallList(boss_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.boss_family) do
	--     if v.bossID == boss_id then
	--         for i = 1, 10 do
	--             if v["show" .. i] ~= "" and v["show" .. i] > 0 then
	--                 table.insert(list, {item_id = v["show" .. i], num = 1, is_bind = 0})
	--             end
	--         end
	--     end
	-- end
	if boss_id ~= nil then
		local cfg = self.boss_family_cfg_boss[boss_id]
		if cfg ~= nil then
			for i = 1, 10 do
				if cfg["show" .. i] ~= "" and cfg["show" .. i] > 0 then
					table.insert(list, {item_id = cfg["show" .. i], num = 1, is_bind = 0})
				end
			end            
		end
	end
	return list
end

function BossData:GetMikuBossFallList(boss_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.miku_boss) do
	--     if v.bossID == boss_id then
	--         for i = 1, 10 do
	--             list[i] = {item_id = v["show" .. i], num = 1, is_bind = 0}
	--         end
	--     end
	-- end
	if boss_id ~= nil then
		local cfg = self.miku_boss_cfg_boss[boss_id]
		if cfg ~= nil then
			for i = 1, 10 do
				list[i] = {item_id = cfg["show" .. i], num = 1, is_bind = 0}
			end
		end
	end
	return list
end

function BossData:GetNeutralBossFallList(boss_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.neutral_boss) do
	--     if v.boss_id == boss_id then
	--         for i = 1, 10 do
	--             list[i] = {item_id = v["show" .. i], num = 1, is_bind = 0}
	--         end
	--     end
	-- end
	local cfg = self.neutral_boss_cfg_boss[boss_id]
	if cfg ~= nil then
		for i = 1, 10 do
			list[i] = {item_id = cfg["show" .. i], num = 1, is_bind = 0}
		end
	end
	return list
end

function BossData:GetBossFamilyListClient()
	return self.boss_family_cfg.boss_family_client
end

--获取下一boss之家场景
function BossData:GetNextBossFamilyScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.boss_family_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.boss_family_client[i + 1] then
				return self.boss_family_cfg.boss_family_client[i + 1].scene_id
			end
			break
		end
	end
	return nil
end

function BossData:GetBossSingleInfo(list ,scene_id, boss_id)
	for k,v in pairs(list) do
		if v.scene_id == scene_id and v.bossID == boss_id then
			return v
		end
	end
end

function BossData:SetCurInfo(scene_id, boss_id)
	self.boss_scene_id = scene_id
	self.boss_id = boss_id
end

function BossData:GetIsSetCurInfo()
	if self.boss_scene_id ~= nil and self.boss_id ~= nil and 
		self.boss_scene_id ~= 0 and self.boss_id ~= 0 then
		return true
	end
	return false
end

function BossData:GetCurBossInfo(enter_type)
	if enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY then
		return self:GetBossSingleInfo(self.boss_family_cfg.boss_family, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_MIKU then
		return self:GetBossSingleInfo(self.boss_family_cfg.miku_boss, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_DABAO then
		return self:GetBossSingleInfo(self.boss_family_cfg.dabao_boss, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE then
		return self:GetBossSingleInfo(self.active_boss_cfg, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL then
		return self:GetBossSingleInfo(self.boss_family_cfg.neutral_boss, self.boss_scene_id, self.boss_id)
	elseif enter_type == BOSS_ENTER_TYPE.TYPE_BOSS_BABY then
		return self:GetBossSingleInfo(self.baby_boss_cfg.scene_cfg, self.boss_scene_id, self.boss_id)
	end
end

--获取上一boss之家场景
function BossData:GetUpperBossFamilyScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.boss_family_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.boss_family_client[i - 1] then
				return self.boss_family_cfg.boss_family_client[i - 1].scene_id
			end
			break
		end
	end
	return nil
end

function BossData:GetMikuBossListClient()
	return self.boss_family_cfg.miku_boss_client
end

function BossData:GetNeutralBossListClient()
	return self.boss_family_cfg.neutral_boss_client
end

function BossData:GetNeutralBossListCfg()
	return self.boss_family_cfg.neutral_boss
end

--获取下一秘窟场景
function BossData:GetNextMikuBossScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.miku_boss_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.miku_boss_client[i + 1] then
				return self.boss_family_cfg.miku_boss_client[i + 1].scene_id
			end
			break
		end
	end
	return nil
end

--获取上一秘窟场景
function BossData:GetUpperMikuBossScene(scene_id)
	for i,v in ipairs(self.boss_family_cfg.miku_boss_client) do
		if v.scene_id == scene_id then
			if self.boss_family_cfg.miku_boss_client[i - 1] then
				return self.boss_family_cfg.miku_boss_client[i - 1].scene_id
			end
			break
		end
	end
	return nil
end

function BossData:GetMikuBossMaxWeary()
	return self.boss_family_cfg.other[1].weary_upper_limit
end

function BossData:GetBossVipLismit(scene_id)
	-- for k,v in pairs(self.boss_family_cfg.enter_condition) do
	--     if v.scene_id == scene_id then
	--         return v.free_vip_level, v.cost_gold, v.need_item_id, v.need_item_num
	--     end
	-- end
	if scene_id ~= nil then
		local cfg = self.enter_condition_cfg[scene_id]
		if cfg ~= nil then
			return cfg.free_vip_level, cfg.cost_gold, cfg.need_item_id, cfg.need_item_num
		end
	end
	return 0, 0, 0, 0
end

function BossData:GetDabaoBossRewards(boss_id)
	local list = {}
	-- for k,v in pairs(self.boss_family_cfg.dabao_boss) do
	--     if v.bossID == boss_id then
	--         for i=1,8 do
	--             if v["show_item_id" .. i] then
	--                 table.insert(list, v["show_item_id" .. i])
	--             end
	--         end
	--         break
	--     end
	-- end
	if boss_id ~= nil then
		local cfg = self.dabao_boss_cfg_boss[boss_id]
		if cfg ~= nil then
			for i=1,8 do
				if cfg["show_item_id" .. i] then
					table.insert(list, cfg["show_item_id" .. i])
				end
			end           
		end
	end
	return list
end

function BossData:GetActiveBossRewards(boss_id)
	local list = {}
	-- for k,v in pairs(self.active_boss_cfg) do
	--     if v.bossID == boss_id then
	--         for i=1,8 do
	--             if v["show_item_id" .. i] then
	--                 table.insert(list, v["show_item_id" .. i])
	--             end
	--         end
	--         break
	--     end
	-- end

	if boss_id ~= nil then
		local cfg = self.active_boss_cfg_boss
		if cfg ~= nil then
			for i=1,8 do
				if cfg["show_item_id" .. i] then
					table.insert(list, cfg["show_item_id" .. i])
				end
			end            
		end
	end
	return list
end

function BossData:GetActiveSceneList()
	return self.active_boss_level_list
end

function BossData:GetDabaoBossClientCfg()
	return self.boss_family_cfg.dabao_boss_client
end

function BossData.IsWorldBossScene(scene_id)
	return scene_id == 200
end

function BossData.IsDabaoBossScene(scene_id)
	--return scene_id >= 9022 and scene_id <= 9029
	return false
end

function BossData.IsFamilyBossScene(scene_id)
	return scene_id >= 9000 and scene_id <= 9004
end

function BossData.IsMikuBossScene(scene_id)
	return scene_id >= 9010 and scene_id <= 9021
end

function BossData.IsKfBossScene(scene_id)
	return scene_id >= 9030 and scene_id <= 9033
end

function BossData.IsActiveBossScene(scene_id)
	return scene_id >= 9040 and scene_id <= 9044
end

function BossData.IsNeutralBossScene(scene_id)
	if scene_id == 2304 then 
		return false
	end
	return scene_id >= 2303 and scene_id <= 2308
end

function BossData.IsBabyBossScene(scene_id)
	return scene_id >= 9022 and scene_id <= 9024
end

function BossData:GetBossFamilyRemainEnemyCount(boss_list, scene_id)
	local count = 0
	for k,v in pairs(boss_list) do
		local next_refresh_time = self:GetFamilyBossRefreshTime(v, scene_id)
		if next_refresh_time <= TimeCtrl.Instance:GetServerTime() then
			count = count + 1
		end
	end
	return count
end

function BossData:GetBossFamilyIdList()
	local cfg = self:GetBossFamilyListClient()
	local id_list = {}
	for k,v in pairs(cfg) do
	   id_list[k] = {}
	   for m,n in pairs(self:GetBossFamilyList(v.scene_id)) do
		  id_list[k][#id_list[k] + 1] = n.bossID
	   end
	end
	return id_list
end

function BossData:GetBossMikuRemainEnemyCount(boss_list, scene_id)
	local count = 0
	for k,v in pairs(boss_list) do
		local next_refresh_time = self:GetMikuBossRefreshTime(v, scene_id)
		if next_refresh_time <= TimeCtrl.Instance:GetServerTime() then
			count = count + 1
		end
	end
	return count
end

function BossData:GetBossMikuIdList()
	local cfg = self:GetMikuBossListClient()
	local id_list = {}
	for k,v in pairs(cfg) do
	   id_list[k] = {}
	   for m,n in pairs(self:GetMikuBossList(v.scene_id)) do
		  id_list[k][#id_list[k] + 1] = n.bossID
	   end
	end
	return id_list
end

function BossData:GetBossNeutralIdList()
	local cfg = self:GetNeutralBossListClient()
	local id_list = {}
	for k,v in pairs(cfg) do
	   id_list[k] = {}
	   for m,n in pairs(self:GetNeutralBossList(v.scene_id)) do
		  id_list[k][#id_list[k] + 1] = n.bossID
	   end
	end
	return id_list
end

-- function BossData:GetDaBaoBossCfg()
--     return self.dabao_boss_cfg
-- end

-- function BossData:GetActiveBossCfg()
--     return self.active_boss_cfg
-- end


function BossData.IsBossScene()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsDabaoBossScene(scene_id)
	or BossData.IsFamilyBossScene(scene_id)
	or BossData.IsMikuBossScene(scene_id)
	or BossData.IsWorldBossScene(scene_id)
	or BossData.IsKfBossScene(scene_id)
	or BossData.IsActiveBossScene(scene_id)
	or BossData.IsBabyBossScene(scene_id) then
		return true
	end
	return false
end


function BossData:GetCanGoAttack()
	local scene_id = Scene.Instance:GetSceneId()
	if BossData.IsDabaoBossScene(scene_id)
	or BossData.IsFamilyBossScene(scene_id)
	or BossData.IsMikuBossScene(scene_id)
	or BossData.IsWorldBossScene(scene_id)
	or BossData.IsKfBossScene(scene_id)
	or BossData.IsActiveBossScene(scene_id)
	or BossData.IsBabyBossScene(scene_id) then
		return false
	end
	return true
end

function BossData:GetCanToSceneLevel(scene)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	-- for k,v in pairs(self.boss_family_cfg.enter_condition) do
	--     if v.scene_id == scene then
	--         return v.min_lv <= level, v.min_lv
	--     end
	-- end

	if scene ~= nil then
		local cfg = self.enter_condition_cfg[scene]
		if cfg ~= nil then
			return cfg.min_lv <= level, cfg.min_lv
		end
	end

	return true, nil
end

function BossData:GetFamilyBossCanGoByVip(scene_id)
	local limit_vip = self:GetBossVipLismit(scene_id)
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	return limit_vip <= my_vip
end

function BossData:GetBossHuDunScale(boss_id)
	for k,v in pairs(self.worldboss_auto.worldboss_list) do
		if boss_id == v.bossID then
			return v.scale
		end
	end
end

function BossData:GetMiKuRedPoint()
	if not OpenFunData.Instance:CheckIsHide("miku_boss") then return false end
	local pi_lao = self.boss_family_cfg.other[1].weary_upper_limit - self.miku_boss_info.miku_boss_weary
	if pi_lao <= 0 then
		return false
	end
	for k,v in pairs(self:GetMikuBossListClient()) do
		local can_go = self:GetCanToSceneLevel(v.scene_id)
		if can_go then
			if self.miku_boss_info.boss_list[v.scene_id] then
				for m,n in pairs(self.miku_boss_info.boss_list[v.scene_id]) do
					if n.status > 0 then
						return true
					end
				end
			end
		end
	end
	return false
end

function BossData:GetDaBaoRedPoint()
	if not OpenFunData.Instance:CheckIsHide("dabao_boss") then return false end
	if self.dabao_enter_count < 1 then
		return true
	else
		return false
	end
end

function BossData:GetActiveRedPoint()
	if not OpenFunData.Instance:CheckIsHide("active_boss") then return false end
	for k,v in pairs(self.active_boss_level_list) do
		if self:CanGoActiveBoss(v) then
			return true
		end
	end
	return false
end

--福利boss红点
function BossData:GetWelfareRedPoint()
	local boss_id = self:GetBossCfg()[0].bossID
	if boss_id then 
		local boss_info = self:GetWorldBossInfoById(boss_id)
		if boss_info and boss_info.status == 1 then
			return true
		end
	end
	return false
end

-- 定时boss是否有红点点击
function BossData:SetFamilyCheck(bool)
	self.is_check_family = bool
end

function BossData:GetFamilyCheck()
	return self.is_check_family or false
end

-- 定时boss红点
function BossData:GetFamilyRedPoint()
	if ClickOnceRemindList[RemindName.BossFamilyRemind] and ClickOnceRemindList[RemindName.BossFamilyRemind] == 0 then
		return false
	end
	for k,v in pairs (self:GetBossFamilyListClient()) do
		local can_go = self:GetFamilyBossCanGoByVip(v.scene_id) and self:GetCanToSceneLevel(v.scene_id)
		if can_go then
			if self.family_boss_list.boss_list[v.scene_id] then
				for m,n in pairs(self.family_boss_list.boss_list[v.scene_id]) do
					if n.status > 0 then
						return true
					end
				end
			end
		end
	end
	return false
end

function BossData:GetBossSceneList(boss_id)
	if boss_id == nil then return false end

	if self.boss_family_cfg_boss[boss_id] ~= nil or
		self.miku_boss_cfg_boss[boss_id] ~= nil or
		self.neutral_boss_cfg_boss[boss_id] ~= nil then
		return true
	end
	return false
end

function BossData:GetNeutralBossSceneList(boss_id)
	if boss_id == nil then
		return 
	end

	return self.neutral_boss_cfg_boss[boss_id]
end

-- 福利boss
function BossData:SetCommonActivityInfo(protocol)
	self.world_boss_activity.common_activity_type = protocol.common_activity_type
	self.world_boss_activity.status = protocol.status
	self.world_boss_activity.param_1 = protocol.param_1
end

function BossData:GetCommonActivityInfo()
	return self.world_boss_activity
end

function BossData:SetActtackNeutralBoss(boss_id, scene_id)
	self.atk_neutral_boss_id = boss_id
	self.atk_neutral_scene_id = scene_id
end

function BossData:GetActtackNeutralBoss()
	return self.atk_neutral_boss_id, self.atk_neutral_scene_id
end

function BossData:CheckIsCanEnterFuLi(check_id)
	local scene_id = Scene.Instance:GetSceneId() or 0
	local is_can = true

	if check_id ~= nil then
		if not BossData.IsWorldBossScene(check_id) then
			return is_can
		end
	end

	if BossData.IsDabaoBossScene(scene_id)
	or BossData.IsFamilyBossScene(scene_id)
	or BossData.IsMikuBossScene(scene_id)
	or BossData.IsKfBossScene(scene_id)
	or BossData.IsActiveBossScene(scene_id)
	or BossData.IsBabyBossScene(scene_id) then
		is_can = false
	end

	return is_can
end

----------------------宝宝BOSS--------------------------------
function BossData:SetBossBabyAllInfo(protocol)
	self.boss_baby_all_info.boss_count = protocol.boss_count
	self.boss_baby_all_info.boss_info_list = protocol.boss_info_list

	self:NotifyEventChange(BossData.BABY_BOSS)
end

function BossData:SetBossBabyInfo(protocol)
	local key = nil
	if self.boss_baby_all_info.boss_info_list == nil then
		self.boss_baby_all_info.boss_info_list = {}
		self.boss_baby_all_info.boss_info_list[1] = protocol.boss_info
	else
		for k,v in pairs(self.boss_baby_all_info.boss_info_list) do
			if v ~= nil and v.scene_id == protocol.boss_info.scene_id and v.boss_id == protocol.boss_info.boss_id then
				key = k
				break
			end
		end
	end

	if key ~= nil then
		self.boss_baby_all_info.boss_info_list[key] = protocol.boss_info
	end

	self:NotifyEventChange(BossData.BABY_BOSS)
end

function BossData:SetBossBabyRoleInfo(protocol)
	self.boss_baby_role_info.angry_value = protocol.angry_value
	self.boss_baby_role_info.kick_time = protocol.kick_time
end

function BossData:GetBossBabyRoleInfo()
	return self.boss_baby_role_info or {}
end

function BossData:GetBossBabyInfo(scene_id)
	local all_data = {}

	local info = self.boss_baby_all_info.boss_info_list
	if scene_id == nil or info == nil then
		return all_data
	end

	for k,v in pairs(info) do
		if v ~= nil and v.scene_id == scene_id then
			local data = {}
			data.next_refresh_time = v.next_refresh_time
			data.status = v.next_refresh_time <= 0 and 1 or 0
			data.boss_id = v.boss_id
			table.insert(all_data, data)
		end
	end

	return all_data
end

function BossData:GetBossBabyList(select_scene_id)
	local data = {}
	if select_scene_id == nil then
		return data
	end

	return self.baby_boss_list_scene[select_scene_id] or {}
end

function BossData:GetBossBabyOtherCfg(str)
	if str == nil then
		return
	end

	return self.baby_boss_cfg.other[1][str]
end

function BossData:GetBossBabyFallList(select_boss_id)
	local data = {}
	if select_boss_id == nil then
		return data
	end

	return self.baby_boss_list_boss[select_boss_id] or {}
end

function BossData:GetBossBabyLayerLimit(layer)
	if layer == nil then
		return {}
	end

	return self.baby_layer_limit[layer] or {}
end

function BossData:GetBossBabyLayerCfg()
	return self.baby_layer_limit
end

function BossData:GetBossBabyRefreshTime(boss_id, scene_id)
	local timer, status = 0
	if boss_id == nil or scene_id == nil then
		return timer, status
	end

	local boss_count = self.boss_baby_all_info.boss_count
	if boss_count == nil or boss_count == 0 then
		return timer, status
	end

	local boss_list = self.boss_baby_all_info.boss_info_list
	if boss_list ~= nil then
		for k,v in pairs(boss_list) do
			if v ~= nil and v.boss_id == boss_id and v.scene_id == scene_id then
				timer = v.next_refresh_time or 0
				status = v.next_refresh_time == 0 and 1 or 0
				break
			end
		end
	end

	return timer, status
end

function BossData:CheckIsBabyBoss(boss_id)
	local is_baby_boss = false
	if boss_id == nil then
		return is_baby_boss
	end

	if self.baby_boss_list_boss[boss_id] ~= nil then
		is_baby_boss = true
	end	

	return is_baby_boss
end

function BossData:CheckIsCanAck()
	local is_can = true

	if self.boss_baby_role_info == nil then
		is_can = false
	else
		local angry = self.boss_baby_role_info.angry_value or 0
		local limit = self:GetBossBabyOtherCfg("angry_value_limit") or 0
		if angry >= limit then
			is_can = false
		end
	end

	return is_can
end