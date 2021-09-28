FuBenData = FuBenData or BaseClass()

FuBenDataExpItemId = {
	ItemId = 90050
}


local PHASE_FB_MAX_LEVEL = 10
local FLUSH_REDPOINT_CD = 600

TeamFuBenOperateType = {
	REQ_ROOM_LIST = 1,				-- 请求房间列表
	CREATE_ROOM = 2,				-- 创建房间
	JOIN_ROOM = 3,					-- 加入指定房间
	START_ROOM = 4,					-- 开始房间
	EXIT_ROOM = 5,					-- 退出房间
	CHANGE_MODE = 6,				-- 选择模式
	KICK_OUT = 7,					-- T人
	ENTER_AFFIRM = 8,				-- 准备
}

FuBenTeamType = {
	TEAM_TYPE_DEFAULT = 0,					-- 默认组队
	TEAM_TYPE_YAOSHOUJITANG = 1,			-- 妖兽祭坛副本
	TEAM_TYPE_TEAM_TOWERDEFEND = 2,			-- 组队塔防副本
	TEAM_TYPE_TEAM_MIGONGXIANFU = 3,		-- 迷宫仙府副本
	TEAM_TYPE_TEAM_EQUIP_FB = 4,			-- 组队装备副本
	TEAM_TYPE_TEAM_DAILY_FB = 5,			-- 日常经验副本
	TEAM_TYPE_EQUIP_TEAM_FB = 6,			-- 组队副本(须臾幻境)
}

TeamFuBenMode = {
	TEAM_FB_MODE_EASY = 0,                  -- 简单
    TEAM_FB_MODE_NORMAL = 1,                -- 普通
    TEAM_FB_MODE_HARD = 2,                  -- 困难
    TEAM_FB_MAX_MODE = 3,
}

TOWER_DEFEND_NOTIFY_REASON = {
	DEFAULT = 0,
	INIT = 1,
	NEW_WAVE_START = 2,
	}

--通过1152协议,param_1 发章节数,param_2 发关卡等级
PUSH_FB_TYPE = {
	PUSH_FB_TYPE_NORMAL = 0,                -- 普通推图副本
	PUSH_FB_TYPE_HARD = 1,			        -- 精英推图副本
}
function FuBenData:__init()
	if FuBenData.Instance ~= nil then
		print_error("[FuBenData] Attemp to create a singleton twice !")
		return
	end
	FuBenData.Instance = self
	self.phase_info_list = {}
	self.story_info_list = {}
	self.tower_info_list = {}
	self.exp_info_list = {}
	self.vip_info_list = {}
	self.vip_pass_flag = 0
	self.pick_item_info = {}
	self.exp_fb_info = {}
	self.tuitu_all_info_list = {}

	self.exp_red_point_cd = 0
	self.tower_red_point_cd = 0

	self.quality_enter_count = 0
	self.quality_buy_count = 0

	self.many_fb_user_count = 0
	self.many_fb_user_info = {}
	self.team_equip_fb_pass_flag = 0
	self.team_equip_fb_day_count = 0
	self.team_equip_fb_day_buy_count = 0
	self.fb_scene_logic_info = {}
	self.select_many_fuben_layer = 0

	self.challenge_all_info = {}
	self.challenge_fb_info = {}
	self.pass_layer_info = {}
	self.have_enter_challenge = false
	self.push_show_index = 0
	self.enter_count = 0

	-- 推图副本内容
	self.tuitu_fb_result_info = {}
	self.push_fb_info_list = {}

	self.fb_list = {
		team_type = 0,
		room_list = {},
		count = 0,
	}

	self.enter_affirm_info = {
		team_type = 0,
		mode = 0,
		layer = 0,
	}

	-- 副本iconview 右边BOSS数据缓存
	self.cache_diff_time_list = {}
	self.cache_monster_id_list = {}
	self.cache_monster_flush_info_list = {}
	self.cache_monster_icon_enable_list = {}
	self.cache_monster_icon_gray_list = {}

	self.tower_defend_role_info = {}
	self.tower_defend_auto_reward_info = {}
	self.tower_defend_fb_info = {}
	self.tower_defend_drop_info = {}

	self.has_remind_list = {}

	self.max_pata_pass_level = 0
	self.is_new_level = false

	local challengefb_cfg = ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto") or {}
	self.challenge_buycost_cfg = challengefb_cfg.buy_cost

	RemindManager.Instance:Register(RemindName.FuBenSingle, BindTool.Bind(self.GetFubenRedmind, self))
	RemindManager.Instance:Register(RemindName.BeStrength, BindTool.Bind(self.GetBeStrengthRedmind, self))
end

function FuBenData:GetTuituFbCfg()
	if not self.tuitu_fb_cfg then
		self.tuitu_fb_cfg = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto")
	end
	return self.tuitu_fb_cfg
end

function FuBenData:GetTuituFbInfoCfg()
	if not self.tuitu_fb_info_cfg then
		self.tuitu_fb_info_cfg = ListToMap(self:GetTuituFbCfg().fb_info, "fb_type", "chapter", "level")
	end
	return self.tuitu_fb_info_cfg
end

function FuBenData:__delete()
	RemindManager.Instance:UnRegister(RemindName.FuBenSingle)
	RemindManager.Instance:UnRegister(RemindName.BeStrength)
	self.tuitu_all_info_list = nil

	FuBenData.Instance = nil
	self.phase_info_list = {}
	self.story_info_list = {}
	self.tower_info_list = {}
	self.exp_info_list = {}
	self.vip_info_list = {}
	self.fb_scene_logic_info = {}
	self.tuitu_fb_result_info = {}
	self.push_fb_info_list = {}

	self.exp_red_point_cd = 0
	self.tower_red_point_cd = 0
	self.enter_count = 0
end

-- 进入副本返回的信息
function FuBenData:SetFBSceneLogicInfo(info_list)
	print_log("返回进入副本信息",info_list.total_boss_num, info_list.total_allmonster_num
		,os.date("%X", os.time(os.date("*t", info_list.time_out_stamp))), info_list.kill_boss_num, info_list.kill_allmonster_num, info_list.is_pass, info_list.is_finish,
		info_list.param1)
	self.fb_scene_logic_info = info_list
end

function FuBenData:GetFBSceneLogicInfo()
	return self.fb_scene_logic_info
end

function FuBenData:SetFBSceneLogicTime(time)
	self.fb_scene_logic_info.time_out_stamp = time
end

function FuBenData:ClearFBSceneLogicInfo()
	self.fb_scene_logic_info = {}
end

function FuBenData:SetFbPickItemInfo(item_list)
	self.pick_item_info = item_list
end

function FuBenData:GetFbPickItemInfo()
	local list = self.pick_item_info
	self.pick_item_info = {}
	return list
end

function FuBenData:GetFbInspirePrice()
	return self.daily_fb_cfg
end

-- 剧情副本
function FuBenData:GetStoryFBLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("storyfbconfig_auto").fb_list
end

function FuBenData:GetStoryFBPageCfg()
	return ConfigManager.Instance:GetAutoConfig("storyfbconfig_auto").section_list
end

function FuBenData:MaxStoryFB()
	return #ConfigManager.Instance:GetAutoConfig("storyfbconfig_auto").fb_list
end

function FuBenData:GetExpFBCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto")
end

function FuBenData:SetStoryFBInfo(info_list)
	self.story_info_list = info_list
end

function FuBenData:GetStoryFBInfo()
	return self.story_info_list
end

function FuBenData:ClearStoryFBInfo()
	self.story_info_list = {}
end

-- 勇者之塔
function FuBenData:GetTowerFBLevelCfg()
	local list = {}

	if self.patafb_level_cfg then
		return self.patafb_level_cfg
	end

	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").levelcfg) do
		list[v.level] = v
	end

	self.patafb_level_cfg = list

	return list
end

function FuBenData:MaxTowerFB()
	return #ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").levelcfg
end

function FuBenData:SetTowerFBInfo(protocol)
	self.tower_info_list = protocol
	if protocol.pass_level > self.max_pata_pass_level then
		self.max_pata_pass_level = protocol.pass_level
		self.is_new_level = true
	else
		self.is_new_level = false
	end
end

function FuBenData:GetTowerFBInfo()
	return self.tower_info_list or {}
end

function FuBenData:ClearTowerFBInfo()
	self.tower_info_list = {}
end

--获得爬塔魔戒配置
function FuBenData:GetTowerMojieCfg()
	if not self.tower_mojie_cfg then
		self.tower_mojie_cfg = ConfigManager.Instance:GetAutoConfig("mojie_skill_config_auto")
	end
	return self.tower_mojie_cfg
end
--爬塔称号
-- function FuBenData:GetSpecialRewardLevel(level)
-- 	local level = level or self.tower_info_list.pass_level
-- 	if not level then return end
-- 	for k, v in pairs(self:GetTowerFBLevelCfg()) do
-- 		if v.title_id > 0 and level < v.level then
-- 			return v
-- 		end
-- 	end
-- 	return nil
-- end
--根据当前通过的层数获得特殊层数奖励配置
function FuBenData:GetSpecialRewardItemCfg()
	local level = self.tower_info_list.pass_level
	for k, v in pairs(self:GetTowerFBLevelCfg()) do
		if next(v.show_item_list) and level < v.level then
			return v
		end
	end
	return nil
end

--爬塔魔戒，获取下一个能获得的魔戒cfg，返回nil表示已获得所有魔戒
function FuBenData:GetNextRewardTowerMojieCfg()
	if not self.tower_info_list then return nil end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	for k, v in pairs(cfg) do 
		if v.pata_layer > level then
			return v
		end
	end
	return nil 
end

-- 爬塔魔戒，判断当前是否是可以获得魔戒的层数
function FuBenData:GetIsMojieLayer()
	if CheckInvalid(self.tower_info_list) then return false end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	for k, v in pairs(cfg) do 
		if v.pata_layer == level and self.is_new_level then
			return true
		end
	end
	return false
end

function FuBenData:GetCurMojie()
	if CheckInvalid(self.tower_info_list) then return nil end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	for k, v in pairs(cfg) do 
		if v.pata_layer == level then
			return v
		end
	end
	return nil
end

--根据技能ID获得技能参数
function FuBenData:GetSkillParamById(skill_id)
	local cfg  = self:GetTowerMojieCfg().skill_cfg
	if cfg then
		for k, v in pairs(cfg) do 
			if v.skill_id == skill_id then
				return {v.param_0, v.param_1, v.param_2, v.param_3}
			end
		end
	end
	return {0, 0, 0, 0}
end

function FuBenData:GetSkillDesc(skill_id)
	local skill_cfg = self:GetSkillParamById(skill_id)
	local desc = string.format(Language.FubenTower.TowerMoJieSkillDes[skill_id + 1], skill_cfg[1], skill_cfg[2], skill_cfg[3], skill_cfg[4])
	return desc
end

--获取所有爬塔魔戒的信息
function FuBenData:GetMoJieAllInfo()
	local active_cfg = self:GetTowerMojieCfg().active_cfg
	local skill_cfg  = self:GetTowerMojieCfg().skill_cfg
	local all_info = {}
	for k,v in pairs(active_cfg) do
		local info = {skill_id = v.skill_id, pata_layer = v.pata_layer}
		info.skill_param = self:GetSkillParamById(v.skill_id)
		table.insert(all_info, info)
	end
	return all_info
end

--获取已激活的所有魔戒ID
function FuBenData:GetCurActiveTowerMojieId()
	if not self.tower_info_list then return nil end
	local level = self.tower_info_list.pass_level  --当前爬塔层数
	local cfg = self:GetTowerMojieCfg().active_cfg --爬塔魔戒激活配置
	local result = {}
	for k, v in pairs(cfg) do 
		if v.pata_layer > level then
			return result
		end
		table.insert(result, v.skill_id)
	end
	return result
end

--获取激活魔戒的数目
function FuBenData:GetActiveTowerMojieNumber()
	return #self:GetCurActiveTowerMojieId() or 0
end

--判断所给Id的魔戒是否激活，返回true表示该爬塔魔戒已经激活
function FuBenData:GetIsActiveById(id)
	if id == nil then return false end
	local active_table = self:GetCurActiveTowerMojieId()
	if active_table and next(active_table) then
		for k,v in pairs(active_table) do
			if id == v then
				return true
			end
		end
	end
	return false
end

--获取魔戒数目
function FuBenData:GetMoJieCount()
	return #(self:GetTowerMojieCfg().active_cfg)
end

-- 爬塔副本通关最高层，扫荡全部层数奖励
function FuBenData:GetTowerFbSaoDangAllReward()
	local reward_cfg = {}
	local temp_list = {}
	local temp_cfg = nil
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").levelcfg) do
		temp_cfg = v.normal_reward[0]
		if temp_cfg then
			if not temp_list[temp_cfg.item_id] then
				temp_list[temp_cfg.item_id] = {item_id = temp_cfg.item_id, num = temp_cfg.num, is_bind = temp_cfg.is_bind}
			elseif temp_list[temp_cfg.item_id].is_bind == temp_cfg.is_bind then	-- 绑定类型一样
				temp_list[temp_cfg.item_id].num = temp_list[temp_cfg.item_id].num + temp_cfg.num
			elseif temp_list[temp_cfg.item_id].is_bind ~= temp_cfg.is_bind and temp_list[temp_cfg.item_id] then	-- 绑定类型不一样
				temp_list[temp_cfg.item_id.."_0"] = {item_id = temp_cfg.item_id, num = temp_cfg.num, is_bind = temp_cfg.is_bind}
			end
		end
	end
	for k, v in pairs(temp_list) do
		table.insert(reward_cfg, v)
	end

	return reward_cfg
end

function FuBenData:SetExpFbInfo(protocol)
	if self.exp_fb_info == nil then
		self.exp_fb_info = {}
	end
	self.exp_fb_info.time_out_stamp = protocol.time_out_stamp
	self.exp_fb_info.scene_type = protocol.scene_type
	self.exp_fb_info.is_finish = protocol.is_finish
	self.exp_fb_info.guwu_times = protocol.guwu_times
	self.exp_fb_info.team_member_num = protocol.team_member_num
	self.exp_fb_info.exp = protocol.exp
	self.exp_fb_info.wave = protocol.wave
	self.exp_fb_info.kill_allmonster_num = protocol.kill_allmonster_num
	self.exp_fb_info.start_time = protocol.start_time
end

function FuBenData:OnSCDailyFBRoleInfo(protocol)
	if self.exp_fb_info == nil then
		self.exp_fb_info = {}
	end
	self.exp_fb_info.expfb_today_pay_times = protocol.expfb_today_pay_times --今天购买次数
	self.exp_fb_info.expfb_today_enter_times = protocol.expfb_today_enter_times --今天进入次数
	self.exp_fb_info.last_enter_fb_time = protocol.last_enter_fb_time --最后一次进入时间
	self.exp_fb_info.max_exp = protocol.max_exp --最大经验
	self.exp_fb_info.max_wave = protocol.max_wave --最大波数
end

function FuBenData:GetExpFBInfo()
	return self.exp_fb_info or {}
end

function FuBenData:ClearExpFBInfo()
	-- self.exp_info_list = {}
end

function FuBenData:GetExpPotionCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").dailyfb[0] or {}
end

function FuBenData:GetExpFBOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").exp_other_cfg[1]
end

function FuBenData:GetExpPayTimeByVipLevel(vip_level)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_vip_pay_time) do
		if vip_level == v.vip_level then
			return v.pay_time
		end
	end
	return 0
end

function FuBenData:GetExpVipLevelByPayTime(pay_time)
	for k,v in ipairs(ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_vip_pay_time) do
		if pay_time == v.pay_time then
			return v.vip_level
		end
	end
	return 0
end

function FuBenData:SetYsjtTeamFbSceneLogicInfo(protocol)
	if self.yaoshou_fb_info==nil then
		self.yaoshou_fb_info = {}
	end
	self.yaoshou_fb_info.time_out_stamp = protocol.time_out_stamp
	self.yaoshou_fb_info.scene_type = protocol.scene_type
	self.yaoshou_fb_info.is_finish = protocol.is_finish
	self.yaoshou_fb_info.is_pass = protocol.is_pass
	self.yaoshou_fb_info.is_active_leave_fb = protocol.is_active_leave_fb
	self.yaoshou_fb_info.pass_wave = protocol.pass_wave
	self.yaoshou_fb_info.kill_boss_num = protocol.kill_boss_num
	self.yaoshou_fb_info.pass_time_s = protocol.pass_time_s
	self.yaoshou_fb_info.mode = protocol.mode
	self.yaoshou_fb_info.boss_attr_type = protocol.boss_attr_type
	self.yaoshou_fb_info.role_attrs = protocol.role_attrs

end

function FuBenData:GetYsjtTeamFbSceneLogicInfo()
	return self.yaoshou_fb_info
end

function FuBenData:GetYsjtTeamFbCfg()
	return ConfigManager.Instance:GetAutoConfig("yaoshoujitanteamfbconfig_auto").monster
end

function FuBenData:GetMonsterCfg()
	return ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
end

function FuBenData:GetYsjtTeamFbMonsterName(mode, wave)
	local monster_id = self:GetYsjtTeamFbMonsterId(mode, wave)
	local monster_cfg = self:GetMonsterCfg()[monster_id] or {}
	local monster_name = monster_cfg.name or ""

	return monster_name
end

function FuBenData:GetYsjtTeamFbMonsterId(mode, wave)
	local monster_id = 0
	for k,v in pairs(self:GetYsjtTeamFbCfg()) do
		if v.mode == mode and v.wave == wave then
			monster_id = v.monster_id
			break
		end
	end
	return monster_id
end

function FuBenData:GetExpNextPayMoney(has_buy_times)
	local cfg = self:GetExpFBCfg().expfb_reset
	local next_buy_times = has_buy_times + 1
	for k,v in pairs(cfg) do
		if next_buy_times == v.reset_time then
			return v.need_gold
		end
	end
	return 0
end

function FuBenData:GetExpMaxPayTime()
	local cfg = self:GetExpFBCfg().expfb_vip_pay_time
	local max_pay_time = 0
	for k,v in pairs(cfg) do
		if v.pay_time > max_pay_time then
			max_pay_time = v.pay_time
		end
	end
	return max_pay_time
end

function FuBenData:GetExpMaxVipLevel()
	local cfg = self:GetExpFBCfg().expfb_vip_pay_time
	local max_vip_level = 0
	for k,v in pairs(cfg) do
		if v.vip_level > max_vip_level then
			max_vip_level = v.vip_level
		end
	end
	return max_vip_level
end

function FuBenData:GetExpFBLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_wave
end

function FuBenData:MaxExpFB()
	return #ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_wave
end

function FuBenData:GetRewardWave()
	local list = {}
	for k, v in pairs(self:GetExpFBLevelCfg()) do
		if v.has_first_reward == 1 then
			table.insert(list, v.wave)
		end
	end
	return list
end

function FuBenData:GetExpCurReward(wave)
	local wave = wave or self.exp_info_list.expfb_fetch_reward_wave or 0
	for k, v in pairs(self:GetExpFBLevelCfg()) do
		if v.has_first_reward == 1 and v.wave > wave then
			return v
		end
	end
	return nil
end

function FuBenData:GetExpRewardByWave(wave)
	if not wave then return end
	for k, v in pairs(self:GetExpFBLevelCfg()) do
		if v.wave == wave then
			return v
		end
	end
	return nil
end

function FuBenData:GetExpFbResetGold(reset_times)
	if not reset_times then return 0 end

	local cfg = ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").expfb_reset or {}
	for k, v in pairs(cfg) do
		if reset_times == v.reset_time then
			return v.need_gold
		end
	end
	return 0
end

function FuBenData:GetExpPayTimes()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.expfb_today_pay_times or 0
	end
	return 0
end

function FuBenData:GetExpEnterTimes()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.expfb_today_enter_times or 0
	end
	return 0
end

function FuBenData:GetExpLastTimes()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.last_enter_fb_time or 0
	end
	return 0
end

function FuBenData:GetSCDailyFBRoleInfo()
	return self.num_buy_list or 0
end

function FuBenData:GetBagRewardNum()
	local cfg = ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").exp_other_cfg[1].item_stuff or {}
	return ItemData.Instance:GetItemNumInBagById(cfg.item_id)
end

-- 阶段副本
function FuBenData:GetPhaseFBLevelCfg()
	return ConfigManager.Instance:GetAutoConfig("phasefb_auto").fb_list
end

function FuBenData:MaxPhaseFB()
	return #ConfigManager.Instance:GetAutoConfig("phasefb_auto").fb_list
end

function FuBenData:SetPhaseFBInfo(info_list)
	self.phase_info_list = info_list
end

function FuBenData:GetPhaseFBInfo()
	return self.phase_info_list
end

function FuBenData:ClearPhaseFBInfo()
	self.phase_info_list = {}
end

function FuBenData:GetCurFbCfgByIndex(index)
	local role_level = PlayerData.Instance:GetRoleLevel()
	for k, v in pairs(self:GetPhaseFBLevelCfg()) do
		if index == v.fb_index then
			return v
		end
	end
	return nil
end

function FuBenData:SortPhaseFB()
	local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
	local copy_table = {}
	local is_active = false
	for k, v in pairs(self:GetPhaseFBLevelCfg()) do
		local data = {}

		if v.fun_name == "" then
			local game_vo = GameVoManager.Instance:GetMainRoleVo()
			is_active = game_vo.level >= v.role_level
		else
			local is_fun_open = OpenFunData.Instance:CheckIsHide(v.fun_name)
			is_active = is_fun_open
		end

		data.today_times = self.phase_info_list[v.fb_index] and self.phase_info_list[v.fb_index].today_times or 0
		data.active = is_active and 1 or 0
		data.can_chongzhi = chong_zhi_count >= data.today_times and 1 or 0
		data.can_challenge = data.today_times == 0 and 1 or 0
		data.fb_index = v.fb_index

		table.insert(copy_table, data)
	end

	table.sort(copy_table, function(a, b)
		if a.active ~= b.active then
			return a.active > b.active
		end
		if a.can_challenge ~= b.can_challenge then
			return a.can_challenge > b.can_challenge
		end
		if a.can_chongzhi ~= b.can_chongzhi then
			return a.can_chongzhi > b.can_chongzhi
		end
		if a.role_level ~= b.role_level then
			return a.role_level < b.role_level
		end
		return a.fb_index < b.fb_index
	end)

	local cfg_list = {}
	local no_active_num = 0
	for k, v in pairs(copy_table) do
		-- if no_active_num >= 1 then
		-- 	break
		-- end
		table.insert(cfg_list, v)
		-- if v.active == 0 then
		-- 	no_active_num = no_active_num + 1
		-- end
	end

	return cfg_list
end

function FuBenData:GetPhaseFbResetGold(fb_index, reset_times)
	if not fb_index or not reset_times then return 0 end

	local cfg = ConfigManager.Instance:GetAutoConfig("phasefb_auto").expfb_reset or {}
	for k, v in pairs(cfg) do
		if v.fb_index == fb_index and reset_times == v.reset_time then
			return v.need_gold
		end
	end
	return 0
end

-- VIP副本
function FuBenData:GetVipFBLevelCfg()
	local cfg = {}
	for k, v in pairs(ConfigManager.Instance:GetAutoConfig("vipfbconfig_auto").levelcfg) do
		cfg[v.level] = v
	end
	return cfg
end

function FuBenData:MaxVipFB()
	return #ConfigManager.Instance:GetAutoConfig("vipfbconfig_auto").levelcfg
end

function FuBenData:SetVipFBInfo(protocol)
	self.vip_info_list = protocol.info_list
	self.vip_pass_flag = protocol.is_pass_flag
end

function FuBenData:GetVipFBInfo()
	return self.vip_info_list
end

function FuBenData:ClearVipFBInfo()
	self.vip_info_list = {}
end

function FuBenData:GetVipFBIsPass(index)
	if not index then return false end

	local bit_list = bit:d2b(self.vip_pass_flag)
	for k, v in pairs(bit_list) do
		if v == 1 and (32 - k) == index then
			return true
		end
	end

	return false
end

function FuBenData:IsShowPhaseFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_phase") then
		return false
	end

	if self.has_remind_list[TabIndex.fb_phase] then
		return false
	end

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k, v in pairs(self.phase_info_list) do
		for k2, v2 in pairs(self:GetPhaseFBLevelCfg()) do
			if v2.fb_index == k and v.today_times <= 0 and v2.role_level <= role_level and (k + 1) <= self:MaxPhaseFB() then
				return true
			end
		end
	end
	return false
end

function FuBenData:GetExpFBTime()
	return self:GetExpFBOtherCfg().time_limit or 0
end

function FuBenData:IsShowExpFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_exp") then
		return false
	end

	if self.has_remind_list[TabIndex.fb_exp] then
		return false
	end

	if self:GetExpPayTimes() + self:GetExpFBOtherCfg().day_times - self:GetExpEnterTimes() > 0 then
		return true
	end
	return false
	-- if nil == next(self.exp_info_list) then return end

	-- if self.exp_info_list.expfb_today_wave < self.exp_info_list.expfb_pass_wave then
	-- 	return true
	-- end

	-- for k, v in pairs(self:GetRewardWave()) do
	-- 	if self.exp_info_list.expfb_pass_wave >= v and self.exp_info_list.expfb_fetch_reward_wave < v then
	-- 		return true
	-- 	end
	-- end

	-- if math.floor(self.exp_red_point_cd - Status.NowTime) > 0 then
	-- 	return false
	-- end

	-- local cur_cfg = self:GetExpRewardByWave(self.exp_info_list.expfb_today_wave + 1)
	-- local fight_power = GameVoManager.Instance:GetMainRoleVo().capability
	-- if cur_cfg then
	-- 	return cur_cfg.capability <= fight_power
	-- end

	-- return false
end

function FuBenData:IsShowStoryFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_story") then
		return false
	end

	local role_level = PlayerData.Instance:GetRoleLevel()
	for k, v in pairs(self.story_info_list) do
		if v.today_times <= 0 and self:GetStoryFBLevelCfg()[k + 1] and
		self:GetStoryFBLevelCfg()[k + 1].role_level <= role_level and k < self:MaxStoryFB() then
			return true
		end
	end
	return false
end

function FuBenData:IsShowVipFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_vip") then
		return false
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self.vip_info_list) do
		if v.today_times <= 0 and self:GetVipFBLevelCfg()[k] and self:GetVipFBLevelCfg()[k].enter_level <= vo.vip_level then
			return true
		end
	end
	return false
end

function FuBenData:IsShowTowerFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_tower") then
		return false
	end

	if self.has_remind_list[TabIndex.fb_tower] then
		return false
	end

	if nil ==  next(self.tower_info_list) then return end

	if self.tower_info_list.today_level < self.tower_info_list.pass_level then
		return true
	end

	if self:IsPowerTowerRedPoint() then
		return true
	end
	return false
end

function FuBenData:IsPowerTowerRedPoint()
	if math.floor(self.tower_red_point_cd - Status.NowTime) > 0 then
		return false
	end

	if nil ==  next(self.tower_info_list) then return end
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local tower_cfg = self:GetTowerFBLevelCfg()
	if tower_cfg[self.tower_info_list.today_level + 1] then
		if capability >= tower_cfg[self.tower_info_list.today_level + 1].capability then
			return true
		end
	end
	return false
end

function FuBenData:PowerTowerCanChallange()
	if not OpenFunData.Instance:CheckIsHide("fb_tower") or nil ==  next(self.tower_info_list) then
		return false
	end
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local tower_cfg = self:GetTowerFBLevelCfg()
	if tower_cfg[self.tower_info_list.today_level + 1] then
		if capability >= tower_cfg[self.tower_info_list.today_level + 1].capability then
			return true
		end
	end
	return false
end

function FuBenData:GetBeStrengthRedmind()
	local num = 0
	if self:PowerTowerCanChallange() then
		num = num + 1
	end
	if GuaJiTaData.Instance:RuneTowerCanChallange() then
		num = num + 1
	end
	if RemindManager.Instance:GetRemind(RemindName.CoolChat) > 0 then
		num = num + 1
	end
	if RuneData.Instance:GetBagHaveRuneGift() > 0 then
		num = num + 1
	end

	if PackageData.Instance:CheckBagBatterEquip() ~= 0 then
		num = num + 1
	end

	if self:GetIsCanPushCommonFb(PUSH_FB_TYPE.PUSH_FB_TYPE_HARD) then
		num = num + 1
	end

	--封神殿
	if GodTemplePataData.Instance:CanChallange() then
		num = num + 1
	end

	return num
end

function FuBenData:IsShowKuafuFbRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_many_people") then
		return false
	end

	local total_count = self:GetManyFbTotalCount() or 0
	return self.team_equip_fb_day_count < total_count
end

function FuBenData:GetFubenRedmind()
	return self:IsShowFubenRedPoint() and 1 or 0
end

function FuBenData:IsShowFubenRedPoint()
	-- if self:IsShowPhaseFBRedPoint() or self:IsShowExpFBRedPoint() or self:IsShowQualityFBRedPoint() or self:IsShowGuardFBRedPoint() or
	-- 	self:IsShowVipFBRedPoint() or self:IsShowTowerFBRedPoint() or self:IsShowKuafuFbRedPoint() or self:GetPushAllRed() or self:IsShowStoryFBRedPoint() then
	if self:IsShowPhaseFBRedPoint() or self:IsShowExpFBRedPoint() or self:IsShowQualityFBRedPoint() or self:IsShowGuardFBRedPoint() or
		self:IsShowTowerFBRedPoint() or self:GetPushRed(1) or self:IsShowTeamFbRedPoint() then
		return true
	end
	return false
end

function FuBenData:SetHasRemind(index)
	if index == TabIndex.fb_phase and self:IsShowPhaseFBRedPoint() then
		self.has_remind_list[index] = true
	elseif index == TabIndex.fb_exp and self:IsShowExpFBRedPoint() then
		self.has_remind_list[index] = true
	elseif index == TabIndex.fb_quality and self:IsShowQualityFBRedPoint() then
		self.has_remind_list[index] = true
	elseif index == TabIndex.fb_guard and self:IsShowGuardFBRedPoint() then
		self.has_remind_list[index] = true
	elseif index == TabIndex.fb_tower and self:IsShowTowerFBRedPoint() then
		self.has_remind_list[index] = true
	elseif index == TabIndex.fb_push_special and self:GetPushRed(1) then
		self.has_remind_list[index] = true
	elseif index == TabIndex.fb_team and self:IsShowTeamFbRedPoint() then
		self.has_remind_list[index] = true
	end
end

function FuBenData:IsShowTeamFbRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_team") then
		return false
	end

	if self.has_remind_list[TabIndex.fb_team] then
		return false
	end

	local flag = TeamFbData.Instance:CheckRedPoint()
	return flag
end

function FuBenData:SetRedPointCd(str_param)
	if str_param == "exp" then
		self.exp_red_point_cd = Status.NowTime + FLUSH_REDPOINT_CD
	elseif str_param == "tower" then
		self.tower_red_point_cd = Status.NowTime + FLUSH_REDPOINT_CD
	end
end

function FuBenData:GetInSpireDamage()
	if self.exp_fb_info ~= nil then
		return self.exp_fb_info.guwu_times * (self:GetExpFBCfg().exp_other_cfg[1].buff_add_gongji_per/100)
	end
	return 0
end

------------------------------------------组队装备副本--------------------------------------------------------------
-- 组队装备副本配置表
function FuBenData:GetManyConfig()
	if not self.many_config then
		self.many_config = ConfigManager.Instance:GetAutoConfig("team_equip_fb_auto")
	end
	return self.many_config
end

function FuBenData:GetRoomInfo()
	local layer = 0
	local scene_id = Scene.Instance:GetSceneId() or 0
	local config = self:GetManyConfig()
	if config then
		local fb_config = config.fb_config
		if fb_config then
			for k,v in pairs(fb_config) do
				if v.scene_id == scene_id then
					layer = v.layer
					break
				end
			end
		end
	end
	return layer
end

function FuBenData:GetConfigByLayer(layer)
	local config = self:GetManyConfig()
	if config then
		local fb_config = config.fb_config
		if fb_config then
			for k,v in pairs(fb_config) do
				if v.layer == layer then
					return v
				end
			end
		end
	end
end

function FuBenData:GetShowConfigByLayer(layer)
	local config = self:GetManyConfig()
	if config then
		local show_message = config.show_message
		if show_message then
			return show_message[layer]
		end
	end
end

function FuBenData:GetCrossFBCount()
	local config = self:GetManyConfig()
	local count = 0
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local no_active_count = 0
	if config then
		local list = config.fb_config
		table.sort(list, function(a, b)
			return a.layer < b.layer
		end)

		for k,v in pairs(list) do
			if no_active_count >= 1 then
				break
			end
			if v.level_limit <= level then
				count = count + 1
			else
				no_active_count = no_active_count + 1
			end
		end
	end
	return count + no_active_count
end

function FuBenData:GetManyFBCount()
	return self.team_equip_fb_day_count
end

function FuBenData:GetManyFBMaxCount()
	local count = 0
	local config = self:GetManyConfig()
	if config then
		count = config.other[1].max_count or 0
	end
	return count
end

function FuBenData:GetMoJingByLayer(layer)
	local mojing = 0
	local config = self:GetConfigByLayer(layer)
	if config then
		mojing = config.mojing or 0
	end
	return mojing
end

function FuBenData:SetManyFbInfo(protocol)
	self.many_fb_user_count = protocol.user_count
	self.many_fb_user_info = protocol.user_info
end

function FuBenData:GetManyFbInfo()
	return {user_count = self.many_fb_user_count, user_info = self.many_fb_user_info}
end

function FuBenData:SetTeamEquipFbDropCountInfo(protocol)
	self.team_equip_fb_pass_flag = protocol.team_equip_fb_pass_flag
	self.team_equip_fb_day_count = protocol.team_equip_fb_day_count
	self.team_equip_fb_day_buy_count = protocol.team_equip_fb_day_buy_count
end

function FuBenData:GetManyFbTotalCount()
	local max_count = self:GetManyFBMaxCount() or 0
	return max_count + self.team_equip_fb_day_buy_count
end

function FuBenData:GetManyFbPrice()
	local price = 0
	local config = self:GetManyConfig()
	if config then
		local buy_times_cost = config.buy_times_cost or {}
		for i = #buy_times_cost, 1, -1 do
			price = buy_times_cost[i].gold_cost
			if buy_times_cost[i].buytimes <= self.team_equip_fb_day_buy_count then
				break
			end
		end
	end
	return price
end

-- 得到组队装备副本加成
function FuBenData:GetManyFbValueByNum(num)
	local value = 0
	local config = self:GetManyConfig()
	if config then
		for k,v in pairs(config.team_drop) do
			if v.team_num == num then
				value = v.drop
				break
			end
		end
	end
	return value
end

-- 得到组队装备副本购买次数
function FuBenData:GetManyFbBuyCountByVip(vip_level)
	local count = 0
	local vip_config = VipData.Instance:GetVipLevelCfg()
    if vip_config then
        local vip_box_info = vip_config[VIPPOWER.TEAM_EQUIP_COUNT]
        if vip_box_info then
            count = vip_box_info["param_" .. vip_level]
        end
    end
    return count
end

function FuBenData:GetManyFbBuyCount()
	return self.team_equip_fb_day_buy_count
end

--记录选择的组队装备副本层级
function FuBenData:SetSelectFuBenLayer(layer)
	self.select_many_fuben_layer = layer
end

function FuBenData:GetSelectFuBenLayer()
	return self.select_many_fuben_layer
end

function FuBenData:SetTeamFbRoomList(protocol)
	self.fb_list.count = protocol.count
	self.fb_list.team_type = protocol.team_type
	self.fb_list.room_list = protocol.room_list
end

function FuBenData:GetTeamFbRoomList()
	return self.fb_list
end

function FuBenData:SetTeamFbRoomEnterAffirm(protocol)
	self.enter_affirm_info.team_type = protocol.team_type
	self.enter_affirm_info.mode = protocol.mode
	self.enter_affirm_info.layer = protocol.layer
end

function FuBenData:GetTeamFbRoomEnterAffirm()
	return self.enter_affirm_info
end

--------------- FBIconView  --------------
function FuBenData:SaveMonsterDiffTime(diff_time, index)
	index = index or 1
	self.cache_diff_time_list[index] = diff_time
end

function FuBenData:SaveMonsterInfo(monster_id, index)
	index = index or 1
	self.cache_monster_id_list[index] = monster_id
end

function FuBenData:SaveShowMonsterHadFlush(enable, flush_text, index)
	index = index or 1
	self.cache_monster_flush_info_list[index] = {}
	self.cache_monster_flush_info_list[index].enable = enable
	self.cache_monster_flush_info_list[index].flush_text = flush_text
end

function FuBenData:SaveMonsterIconState(enable, index)
	index = index or 1
	self.cache_monster_icon_enable_list[index] = enable
end

function FuBenData:SaveMonsterIconGray(enable, index)
	index = index or 1
	self.cache_monster_icon_gray_list[index] = enable
end

function FuBenData:GetMonsterDiffTimeCache()
	return self.cache_diff_time_list
end

function FuBenData:GetMonsterInfoCache()
	return self.cache_monster_id_list
end

function FuBenData:GetShowMonsterHadFlushCache()
	return self.cache_monster_flush_info_list
end

function FuBenData:GetMonsterIconStateCache()
	return self.cache_monster_icon_enable_list
end

function FuBenData:GetMonsterIconGrayCache()
	return self.cache_monster_icon_gray_list
end

function FuBenData:ClearFBIconCache()
	self.cache_diff_time_list = {}
	self.cache_monster_id_list = {}
	self.cache_monster_flush_info_list = {}
	self.cache_monster_icon_enable_list = {}
	self.cache_monster_icon_gray_list = {}
end

function FuBenData:GetChallengCfgByLevel(level)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		if level == v.level then
			return v
		end
	end
	return nil
end

function FuBenData:GetChallengStarInfo(level)
	local cfg = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		if level == v.level then
			cfg = v
			break
		end
	end
	local star_info = {}
	if next(cfg) then
		for i = 1 , 3 do
			if cfg["star_max_time_" .. i] then
				star_info[i] = cfg["star_max_time_" .. i]
			end
		end

	end
	return star_info
end

function FuBenData:GetChallengLayerCfgByLevelAndLayer(level, layer)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").levelcfg) do
		if level == v.level and layer == v.layer then
			return v
		end
	end
	return nil
end

function FuBenData:GetTotalLayerByLevel(level)
	local total_layer = 0
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").levelcfg) do
		if level == v.level then
			total_layer = total_layer + 1
		end
	end
	return total_layer
end

function FuBenData:GetChallengCfgLength()
	local lenghth = 0
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		lenghth = lenghth + 1
	end
	return lenghth
end

function FuBenData:GetChallengOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").buy_cost[1]
end

function FuBenData:GetChallengMaxOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").other[1]
end

function FuBenData:GetChallengCfgByLevel(level)
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("challengefbcfg_auto").chaptercfg) do
		if level == v.level then
			return v
		end
	end
	return nil
end

function FuBenData:GetCostGoldByTimes(buy_times)
	local cost = 0
	if nil == self.challenge_buycost_cfg then
		return cost
	end
	for k, v in ipairs(self.challenge_buycost_cfg) do
		if buy_times >= v.buy_times then
			cost = v.gold_cost
			break
		end
	end
	return cost
end

function FuBenData:SetChallengeFbInfo(protocol)
	self.challenge_all_info = protocol.level_list
	self.quality_enter_count = protocol.enter_count
	self.quality_buy_count = protocol.buy_count
	self.enter_count = protocol.enter_count or 0
end

function FuBenData:GetQualityEnterCount()
	return self.quality_enter_count
end

function FuBenData:GetQualityBuyCount()
	return self.quality_buy_count
end

function FuBenData:GetEnterCount()
	return self.enter_count
end

function FuBenData:GetOneLevelChallengeInfoByLevel(level)
	return self.challenge_all_info[level]
end

function FuBenData:SetHasEnterChallengeFb()
	self.have_enter_challenge = true
end

function FuBenData:IsShowGuardFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_guard") then
		return false
	end

	if self.has_remind_list[TabIndex.fb_guard] then
		return false
	end

	local info = self.tower_defend_role_info
	if nil == next(info) then return false end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
	if other_cfg.free_join_times + info.buy_join_times - info.join_times > 0 then
		return true
	end
	return false
end

function FuBenData:IsShowQualityFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_quality") then
		return false
	end

	if self.has_remind_list[TabIndex.fb_quality] then
		return false
	end

	local show_red_point = false
	local other_cfg = self:GetChallengMaxOtherCfg()
	if nil == other_cfg then
		return show_red_point
	end

	--判断是否有挑战次数
	local day_free_times = other_cfg.day_free_times
	local buy_times = self:GetQualityBuyCount()
	local total_times = day_free_times + buy_times
	local enter_times = self:GetQualityEnterCount()
	local left_times = total_times - enter_times
	if left_times > 0 then
		show_red_point = true
	end

	return show_red_point
end

function FuBenData:SetPassLayerInfo(protocol)
	self.pass_layer_info = protocol.info
	self.quality_fb_is_pass = self.pass_layer_info.is_pass 
end

function FuBenData:GetPassLayerInfo()
	return self.pass_layer_info
end

--ChallengeFB就是品质副本
function FuBenData:IsChallengeFBNeedDelayCreateDoor()
	return 1 ~= self.quality_fb_is_pass
end

function FuBenData:ClearChallengeFBPassResult()
	self.quality_fb_is_pass = 0
end

function FuBenData:GetChallengeFBPassResult()
	return self.quality_fb_is_pass or 0
end

function FuBenData:SetChallengeInfoList(protocol)
	self.challenge_fb_info = protocol.info
end

function FuBenData:GetChallengeInfoList()
	return self.challenge_fb_info
end

function FuBenData:GetCanEnterByLevel(level)
	if level < 1 then return true end
	local cfg = self:GetChallengCfgByLevel(level)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level < cfg.role_level then
		return false
	end
	local last_data = self:GetOneLevelChallengeInfoByLevel(level - 1)
	if last_data and last_data.is_pass ~= 1 then
		return false
	end
	return true
end

function FuBenData:IsCanShowQualityEnterByLevel(level)
	local fb_info = self:GetOneLevelChallengeInfoByLevel(level)
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local cur_layer = fb_info.fight_layer < 0 and 0 or fb_info.fight_layer
	local layer_cfg = self:GetChallengLayerCfgByLevelAndLayer(level, cur_layer)
	if capability < layer_cfg.zhanli then
		return false
	end
	return true
end

function FuBenData:GetQualityDefindIndex()
	if not OpenFunData.Instance:CheckIsHide("fb_quality") then
		return 0
	end
	local cur_flag = false
	local length = self:GetChallengCfgLength()
	for i = 0, length - 1 do
		local info = self:GetOneLevelChallengeInfoByLevel(i)
		cur_flag = self:GetCanEnterByLevel(i) and (info.state == 0 or info.state == 2) and self:IsCanShowQualityEnterByLevel(i)
		if not cur_flag then
			cur_flag = self:GetCanEnterByLevel(i) and (info.state == 0 or info.state == 2) and info.history_max_reward >= 3
		end
		if cur_flag then
			return i
		end
	end
	return 0
end

function FuBenData:SetTowerDefendRoleInfo(info)
	self.tower_defend_role_info.join_times = info.join_times
	self.tower_defend_role_info.buy_join_times = info.buy_join_times
	self.tower_defend_role_info.max_pass_level = info.max_pass_level
	self.tower_defend_role_info.auto_fb_free_times = info.auto_fb_free_times
	self.tower_defend_role_info.item_buy_join_times = info.item_buy_join_times
	self.tower_defend_role_info.personal_last_level_star = info.personal_last_level_star
end

function FuBenData:GetTowerDefendRoleInfo()
	return self.tower_defend_role_info
end

function FuBenData:GetCurTowerDefendLevel()
	return self.tower_defend_role_info.max_pass_level and self.tower_defend_role_info.max_pass_level + 1 or 0
end

function FuBenData:SetAutoFBRewardDetail2(info)
	self.tower_defend_auto_reward_info.fb_type = info.fb_type
	self.tower_defend_auto_reward_info.reward_coin = info.reward_coin
	self.tower_defend_auto_reward_info.reward_exp = info.reward_exp
	self.tower_defend_auto_reward_info.reward_xianhun = info.reward_xianhun
	self.tower_defend_auto_reward_info.reward_yuanli = info.reward_yuanli
	self.tower_defend_auto_reward_info.item_list = info.item_list
end

function FuBenData:SetTowerDefendInfo(info)
	self.tower_defend_fb_info.reason = info.reason
	self.tower_defend_fb_info.time_out_stamp = info.time_out_stamp
	self.tower_defend_fb_info.is_finish = info.is_finish
	self.tower_defend_fb_info.is_pass = info.is_pass
	self.tower_defend_fb_info.pass_time_s = info.pass_time_s
	self.tower_defend_fb_info.life_tower_left_hp = info.life_tower_left_hp
	self.tower_defend_fb_info.life_tower_left_maxhp = info.life_tower_left_maxhp
	self.tower_defend_fb_info.curr_wave = info.curr_wave
	self.tower_defend_fb_info.next_wave_refresh_time = info.next_wave_refresh_time
	self.tower_defend_fb_info.clear_wave_count = info.clear_wave_count
	self.tower_defend_fb_info.death_count = info.death_count
	self.tower_defend_fb_info.get_coin = info.get_coin
	self.tower_defend_fb_info.pick_drop_list = info.pick_drop_list

end

function FuBenData:GetTowerDefendInfo()
	return self.tower_defend_fb_info
end

function FuBenData:SetFBDropInfo(info)
	self.tower_defend_drop_info.get_coin = info.get_coin
	self.tower_defend_drop_info.get_item_count = info.get_item_count
	self.tower_defend_drop_info.item_list = info.item_list
end

function FuBenData:GetTowerDefendChapterCfg(chapter)
	local level_scene_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").level_scene_cfg
	return level_scene_cfg[chapter]
end

function FuBenData:GetTowerWaveCfg(level)
	local wave_list = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").wave_list
	local cfg = {}
	for i,v in ipairs(wave_list) do
		if v.level == level then
			table.insert(cfg, v)
		end
	end
	return cfg
end

function FuBenData:GetTowerStarByDeath(count)
	local star_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").star_level
	for i = 2,3 do
		if count < star_cfg[2].death_count then
			star_count = 3
		elseif count < star_cfg[3].death_count then
			star_count = 2
		else
			star_count = 1
		end
	end
	return star_count
end

function FuBenData:GetTowerBuyCost(count)
	local buy_cost = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").buy_cost
	local cfg = {}
	for i,v in ipairs(buy_cost) do
		if v.buy_times == count then
			return v.gold_cost
		end
	end
	return buy_cost[#buy_cost].gold_cost
end

function FuBenData:GetTowerGuajiPos(chapter)
	local pos = {}
	pos.x = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").level_scene_cfg[chapter].guaji_pos_x
	pos.y = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").level_scene_cfg[chapter].guaji_pos_y
	return pos
end

function FuBenData:GetPushFBInfo(fb_type, chapter, level)
	if nil == self:GetTuituFbInfoCfg() then return end
	if nil == self:GetTuituFbInfoCfg()[fb_type] or
		nil == self:GetTuituFbInfoCfg()[fb_type][chapter] then
		return nil
	end
	if level then
		return self:GetTuituFbInfoCfg()[fb_type][chapter][level]
	end
	return self:GetTuituFbInfoCfg()[fb_type][chapter]
end

function FuBenData:StarCfgInfo(fb_type, chapter, level)
	local cur_level_cfg = self:GetPushFBInfo(fb_type, chapter, level)
	local star_info_cfg = {}
	for i = 1 , 3 do
		if cur_level_cfg["time_limit_" .. i .."_star"] then
			table.insert(star_info_cfg, cur_level_cfg["time_limit_" .. i .."_star"])
		end
	end
	return star_info_cfg
end

function FuBenData:GetPushFbMaxChapter(fb_type)
	local list_cfg = self:GetTuituFbInfoCfg()[fb_type]
	if nil == list_cfg then
		return 0
	end

	local max_chapter = 0
	for k, v in pairs(list_cfg) do
		if k > max_chapter then
			max_chapter = k
		end
	end

	return max_chapter
end

function FuBenData:GetMaxLevelByTypeAndChapter(fb_type, fb_chapter)
	local max_level = 0
	if fb_type == 0 then
		local cfg = self:GetTuituFbInfoCfg()[fb_type][fb_chapter]
		for k,v in pairs(cfg) do
			if v.level > max_level then
				max_level = v.level
			end
		end
	else
		local boss_cfg = self:GetTuituFbInfoCfg()[fb_type]
		local max_chapter = 0
		for k,v in pairs(self:GetTuituFbInfoCfg()[fb_type]) do
			if k > max_chapter then
				max_chapter = k
			end
		end
		if fb_chapter == max_chapter then
			return #self:GetTuituFbInfoCfg()[fb_type][fb_chapter]
		else
			return 9999
		end
	end
	return max_level
end

function FuBenData:GetCanEnterPushFB(fb_type)
	local all_push_info = self.tuitu_all_info_list.fb_info_list and self.tuitu_all_info_list.fb_info_list[fb_type + 1] or {}
	local buy_join_times = all_push_info.buy_join_times or 0
	local today_join_times = all_push_info.today_join_times or 0
	local free_join_times = 0
	if fb_type == 0 then
		free_join_times = self:GetPushFBOtherCfg().normal_free_join_times
	else
		free_join_times = self:GetPushFBOtherCfg().hard_free_join_times
	end
	local laft_join_times = buy_join_times - today_join_times + free_join_times
	return laft_join_times > 0
end

function FuBenData:GetOneLevelIsPass(fb_type, fb_chapter, level)
	if next(self.tuitu_all_info_list) and
	 self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[fb_chapter + 1].level_info_list[level + 1].pass_star > 0 then
		return true
	end
	return false
end

function FuBenData:GetOneLevelIsPassAndThreeStar(fb_type, fb_chapter, level)
	if next(self.tuitu_all_info_list) and
	 self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[fb_chapter + 1].level_info_list[level + 1].pass_star == 3 then
		return true
	end
	return false
end

function FuBenData:GetPushFBChapterInfo(fb_type)
	if nil == self:GetTuituFbInfoCfg()[fb_type] then
		return nil
	end
	return self:GetTuituFbInfoCfg()[fb_type]
end

function FuBenData:GetPushFBLeveLInfo(fb_type, chapter, level)
	if nil == self.tuitu_all_info_list.fb_info_list or self.tuitu_all_info_list.fb_info_list[fb_type + 1] == nil or
		self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[chapter + 1] == nil then
		return nil
	end
	return self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[chapter + 1].level_info_list[level + 1]
end

function FuBenData:GetPushFBStarReward()
	return self:GetTuituFbCfg().star_reward
end


function FuBenData:GetStarRewardList(chapter, seq)
	local cfg = self:GetPushFBStarReward()
	for k,v in pairs(cfg) do
		if v.chapter == chapter and seq == v.seq then
			return v.reward
		end
	end
	return nil
end

function FuBenData:GetPushFBOtherCfg()
	return self:GetTuituFbCfg().other[1]
end

function FuBenData:GetPushFBChapterCfg(chapter)
	return self:GetTuituFbCfg().chapter[chapter]
end

function FuBenData:CanGetStarReward(chapter, seq)
	local chapter_info_list = self:GetTuituCommonFbInfo().chapter_info_list
	local total_star = chapter_info_list[chapter].total_star
	local star_reward_flag = chapter_info_list[chapter].star_reward_flag
	local bit_list = bit:d2b(star_reward_flag)
	local reward_cfg = self:GetPushFBAllReward(chapter - 1, seq)
	if next(reward_cfg) and total_star >= reward_cfg.star_num and 0 == bit_list[32 - seq] then
		return true
	end
	return false
end

function FuBenData:OnPushFbFetchShowStarRewardSucc(protocol)
	self.push_fb_fecth_star_reward_info = protocol
end

function FuBenData:GetPushFbFetchShowStarReward()
	local chapter = self.push_fb_fecth_star_reward_info.chapter
	local seq = self.push_fb_fecth_star_reward_info.seq

	local fecth_reward_list = {}
	local reward_cfg_list = self:GetTuituFbCfg().star_reward
	for i = #reward_cfg_list, 1, -1 do
		local reward_cfg = reward_cfg_list[i]
		if reward_cfg.chapter == chapter
			and reward_cfg.seq == seq then
			for k,v in pairs(reward_cfg.reward) do
				table.insert(fecth_reward_list, v)
			end

			break
		end
	end

	return fecth_reward_list
end

function FuBenData:GetPushFBAllReward(chapter, seq)
	for k,v in pairs(self:GetPushFBStarReward()) do
		if v.chapter == chapter and v.seq == seq then
			return v
		end
	end
	return {}
end

function FuBenData:NextCanGetStarReward(chapter)
	local chapter_info_list = self:GetTuituCommonFbInfo().chapter_info_list
	local total_star = chapter_info_list[chapter].total_star
	local reward_chapter_list = {}
	local next_reward_list = {}
	for k,v in pairs(self:GetPushFBStarReward()) do
		if v.chapter == chapter - 1 then
			table.insert(reward_chapter_list, v)
		end
	end
	for k,v in pairs(reward_chapter_list) do
		if v.star_num > total_star then
			next_reward_list = v
			break
		end
	end
	if not next(next_reward_list) then
		next_reward_list = reward_chapter_list[4]
	end
	return next_reward_list
end

function FuBenData:SetTuituFbInfo(protocol)
	self.tuitu_all_info_list = protocol
end

function FuBenData:GetTuituCommonFbInfo()
	return self.tuitu_all_info_list.fb_info_list and self.tuitu_all_info_list.fb_info_list[1]
end

function FuBenData:GetTuituSpecialFbInfo()
	return self.tuitu_all_info_list.fb_info_list and self.tuitu_all_info_list.fb_info_list[2]
end

function FuBenData:SetTuituFbResultInfo(protocol)
	self.tuitu_fb_result_info = protocol
end

function FuBenData:GetTuituFbResultInfo()
	return self.tuitu_fb_result_info
end

function FuBenData:SetTuituFbSingleInfo(protocol)
	self.tuitu_fb_single_info = protocol
	if next(self.tuitu_all_info_list) then
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].today_join_times = protocol.today_join_times
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].buy_join_times = protocol.buy_join_times
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].total_star = protocol.total_star
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].star_reward_flag = protocol.star_reward_flag
	end
end

function FuBenData:GetPushFbData()
	return self.push_fb_info_list
end

function FuBenData:SetPushFbData(fb_type, chapter, level)
	self.push_fb_info_list = {}
	self.push_fb_info_list.fb_type = fb_type
	self.push_fb_info_list.chapter = chapter
	self.push_fb_info_list.level = level
end

function FuBenData:GetPushAllRed()
	return self:GetPushRed(0) or self:GetPushRed(1) or self:GetPushReWardRed()
end

function FuBenData:GetPushRed(fb_type)
	-- 已经屏蔽了的功能
	if true then
		return false
	end
	local special_open = OpenFunData.Instance:CheckIsHide("fb_push_special")
	local all_push_info = self.tuitu_all_info_list.fb_info_list and self.tuitu_all_info_list.fb_info_list[fb_type + 1] or {}
	local buy_join_times = all_push_info.buy_join_times
	local today_join_times = all_push_info.today_join_times
	local FirstLevelIsPass = self:GetOneLevelIsPassBySpecial(1, 0, 0)
	local free_join_times = 0

	if fb_type == 0 then
		free_join_times = self:GetPushFBOtherCfg().normal_free_join_times
		if self:GetPushReWardRed() then
			return true
		end
	elseif fb_type == 1 then
		if special_open == false or not FirstLevelIsPass then
			return false
		end
		if self.has_remind_list[TabIndex.fb_push_special] then
			return false
		end
		free_join_times = self:GetPushFBOtherCfg().hard_free_join_times
	end
	local laft_join_times = buy_join_times - today_join_times + free_join_times
	if laft_join_times > 0 then
		return true
	end
	return false
end

function FuBenData:GetPushReWardRed()
	local common_fb_info = self:GetTuituCommonFbInfo()
	if nil == common_fb_info then
		return false
	end

	local cont = 4
	for i=1,common_fb_info.pass_chapter + 1 do
		if i == common_fb_info.pass_chapter + 1 then
			cont = common_fb_info.pass_level + 1
		end
		for k=1,cont do
			if self:CanGetStarReward(i, k - 1) then
				return true
			end
		end
	end
	return false
end

function FuBenData:GetOneLevelIsPassBySpecial(fb_type, fb_chapter, level)
	if 0 == fb_chapter and 0 == level then
		return true
	end

	local cur_level_cfg = self:GetPushFBInfo(fb_type, fb_chapter, level)
	if next(self.tuitu_all_info_list) and cur_level_cfg and
	 self.tuitu_all_info_list.fb_info_list[cur_level_cfg.need_pass_fb_type + 1].chapter_info_list[cur_level_cfg.need_pass_chapter + 1].level_info_list[cur_level_cfg.need_pass_level + 1].pass_star > 0 then
		return true
	end
	return false
end

function FuBenData:SetShowPushIndex(index)
	self.push_show_index = index
end

function FuBenData:GetShowPushIndex()
	return self.push_show_index
end

function FuBenData:GetIsCanPushCommonFb(fb_type)
	if not OpenFunData.Instance:CheckIsHide("fb_push") or nil == next(self.tuitu_all_info_list) then
		return false
	end
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local push_cfg = self:GetPushFBInfo(fb_type, self.tuitu_all_info_list.fb_info_list[fb_type].pass_chapter, self.tuitu_all_info_list.fb_info_list[fb_type].pass_level)
	if push_cfg then
		if capability >= push_cfg.capability then
			if fb_type == PUSH_FB_TYPE.PUSH_FB_TYPE_HARD and
				not(self:GetOneLevelIsPass(push_cfg.need_pass_fb_type, push_cfg.need_pass_chapter, push_cfg.need_pass_level)) then
				return false
			end
			return true
		end
	end
	return false
end

function FuBenData:SetTowerIsWarning(state)
	self.tower_is_warning = state
end

function FuBenData:GetTowerIsWarning()
	return self.tower_is_warning
end

function FuBenData:GetTeamSpecialCfg(flag, scene_id)
	local personal_layer_list = ConfigManager.Instance:GetAutoConfig("fbequip_auto").personal_layer_list
	local team_layer_list = ConfigManager.Instance:GetAutoConfig("fbequip_auto").team_layer_list
	local layer_list = personal_layer_list
	if flag == 0 then
		layer_list = personal_layer_list
	else
		layer_list = team_layer_list
	end
	for k,v in pairs(layer_list) do
		if scene_id == v.scene_id then
			return v
		end
	end
	return nil
end

function FuBenData:GetTeamSpecialCfglen()
	local team_layer_list = ConfigManager.Instance:GetAutoConfig("fbequip_auto").team_layer_list
	return #team_layer_list or 0
end

function FuBenData:SetTeamSpecialResult(protocol)
	self.team_special_info = protocol
	self.team_special_is_passed = protocol.is_passed
end

function FuBenData:ClearTeamSpecialResult()
	self.team_special_is_passed = nil
end

function FuBenData:GetTeamSpecialIsPass()
	return self.team_special_is_passed
end

function FuBenData:GetTeamSpecialResultInfo()
	return self.team_special_info
end

function FuBenData:IsTeamSpecialNeedDelayCreateDoor()
	return 0 == self.team_special_is_passed
end

function FuBenData:SetTeamSpecialInfo(protocol)
	self.tuitu_all_info_list = protocol
end

function FuBenData:SetTeamSpecialTotalPassExp(protocol)
	self.tuitu_all_info_list = protocol
end

function FuBenData:GetTeamSpecialResult()
	return self.can_jump
end

function FuBenData:GetNextSceneDoor()
	local scene_id = Scene.Instance:GetSceneId()
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id) or {}
	local scene_doors = nil
	for k, v in pairs(scene_config.doors) do
		if v.id == scene_id + 1 then
			scene_doors = v
			break
		end
		scene_doors = v
	end
	return scene_doors
end

function FuBenData:GetTeamTowerWaveNum()
	local wave_list = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").team_wave_list or {}
	local cfg = wave_list[#wave_list]
	if nil ~= cfg then
		return cfg.wave + 1
	end
	return 0
end

function FuBenData:IsShowSlaughterDeveil()
	-- tag
	return false
end