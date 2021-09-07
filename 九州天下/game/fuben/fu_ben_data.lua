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
	TEAM_TYPE_TEAM_MIGONGXIANFU = 2,		-- 迷宫仙府副本
	TEAM_TYPE_TEAM_EQUIP_FB = 3,			-- 组队装备副本
	TEAM_TYPE_TEAM_DAILY_FB = 4,			-- 日常经验副本
	TEAM_TYPE_TEAM_TOWERDEFEND = 5,			-- 组队塔防副本
	TEAM_TYPE_EQUIP_TEAM_FB = 6,			-- 组队副本(须臾幻境)
}

--param_1 发章节数,param_2 发关卡等级
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

	self.exp_red_point_cd = 0
	self.tower_red_point_cd = 0

	self.many_fb_user_count = 0
	self.many_fb_user_info = {}
	self.team_equip_fb_pass_flag = 0
	self.team_equip_fb_day_count = 0
	self.team_equip_fb_day_buy_count = 0
	self.fb_scene_logic_info = {}

	self.select_many_fuben_layer = 0

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

	self.kill_num_list = {}

	self.team_special_info = {
		is_over = 0,
		is_passed = 0,
		can_jump = 0,
		is_first_passed = 1,
	}


	-- 推图副本内容
	self.push_show_index = 0
	self.tuitu_fb_result_info = {}
	self.push_fb_info_list = {}
	local tuitu_fb_cfg = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto")
	self.tuitu_fb_info_cfg = ListToMap(tuitu_fb_cfg.fb_info, "fb_type", "chapter", "level")

	RemindManager.Instance:Register(RemindName.FuBenSingle, BindTool.Bind(self.GetFubenRedmind, self))
	RemindManager.Instance:Register(RemindName.BeStrength, BindTool.Bind(self.GetBeStrengthRedmind, self))
	RemindManager.Instance:Register(RemindName.FBPush1, BindTool.Bind(self.GetPush1Redmind, self))
	RemindManager.Instance:Register(RemindName.FBPush2, BindTool.Bind(self.GetPush2Redmind, self))

	self.star_reward_cfg = ListToMapList(self:GetPushFBStarReward(), "chapter","seq")

	self.tower_defend_role_info = {}
	self.tower_defend_fb_info = {}
	self.tower_defend_drop_info = {}

	--掉落物结算
	self.drop_count = 0
	self.drop_item_list = {}

	self.is_first_open_conmmon_view = false
	self.is_show_common_red = {}
end

function FuBenData:__delete()
	RemindManager.Instance:UnRegister(RemindName.FuBenSingle)
	RemindManager.Instance:UnRegister(RemindName.BeStrength)
	RemindManager.Instance:UnRegister(RemindName.FBPush1)
	RemindManager.Instance:UnRegister(RemindName.FBPush2)
	
	FuBenData.Instance = nil
	self.phase_info_list = {}
	self.story_info_list = {}
	self.tower_info_list = {}
	self.exp_info_list = {}
	self.vip_info_list = {}
	self.fb_scene_logic_info = {}

	self.exp_red_point_cd = 0
	self.tower_red_point_cd = 0

	self.tuitu_fb_result_info = {}
	self.push_fb_info_list = {}
	self.is_show_common_red = {}
	self.is_first_open_conmmon_view = false
end

-- 进入副本返回的信息
function FuBenData:SetFBSceneLogicInfo(info_list)
	self.fb_scene_logic_info = info_list
	self:SetKillNumList(info_list)
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

function FuBenData:SetKillNumList(info_list)
	self.kill_num_list[info_list.param1] = info_list.kill_boss_num ~= 0 and info_list.kill_boss_num or info_list.kill_allmonster_num
end

function FuBenData:GetKillNumList()
	return self.kill_num_list
end

function FuBenData:ClearKillInfo()
	self.kill_num_list = {}
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

-- 爬塔副本奖励
function FuBenData:GetTowerDayRewardCfg()
	return ConfigManager.Instance:GetAutoConfig("patafbconfig_auto").daily_level_reward
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
end

function FuBenData:GetTowerFBInfo()
	return self.tower_info_list or {}
end

function FuBenData:ClearTowerFBInfo()
	self.tower_info_list = {}
end

function FuBenData:GetSpecialRewardLevel(level)
	local level = level or self.tower_info_list.pass_level
	if not level then return end
	for k, v in pairs(self:GetTowerFBLevelCfg()) do
		if v.title_id > 0 and level < v.level then
			return v
		end
	end
	return nil
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
	self.exp_fb_info.expfb_today_pay_times = protocol.expfb_today_pay_times 		--今天购买次数
	self.exp_fb_info.expfb_today_enter_times = protocol.expfb_today_enter_times 	--今天进入次数
	self.exp_fb_info.last_enter_fb_time = protocol.last_enter_fb_time 				--最后一次进入时间
	self.exp_fb_info.max_exp = protocol.max_exp 		--最大经验
	self.exp_fb_info.max_wave = protocol.max_wave 		--最大波数
end

function FuBenData:GetExpFBInfo()
	if self.fb_scene_logic_info==nil then return end
	return self.fb_scene_logic_info or {}
end

function FuBenData:ClearExpFBInfo()
	-- self.exp_info_list = {}
end

function FuBenData:GetExpDailyFb()
	return ConfigManager.Instance:GetAutoConfig("dailyfbconfig_auto").dailyfb
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
	local role_level = PlayerData.Instance:GetRoleLevel()
	local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
	local copy_table = {}
	for k, v in pairs(self:GetPhaseFBLevelCfg()) do
		local data = {}
		data.today_times = self.phase_info_list[v.fb_index] and self.phase_info_list[v.fb_index].today_times or 0
		data.active = role_level >= v.role_level and 0 or 1
		data.can_chongzhi = chong_zhi_count >= data.today_times and 1 or 0
		data.can_challenge = data.today_times == 0 and 1 or 0
		data.fb_index = v.fb_index
		data.free_times = v.free_times - self.phase_info_list[v.fb_index].today_times <= 0 and 1 or 0
		-- data.chong_zhi_num = chong_zhi_count - math.abs(v.free_times - self.phase_info_list[v.fb_index].today_times) == 0 and 1 or 0
		data.chong_zhi_num = (chong_zhi_count + v.free_times - self.phase_info_list[v.fb_index].today_times) == 0 and 1 or 0
		table.insert(copy_table, data)
	end

	SortTools.SortAsc(copy_table ,"active", "free_times", "chong_zhi_num" , "fb_index")
	local cfg_list = {}
	local no_active_num = 0
	for k, v in pairs(copy_table) do
		if no_active_num >= 1 then
			break
		end
		table.insert(cfg_list, v)
		if v.active == 1 then
			no_active_num = no_active_num + 1
		end
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

	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	for k, v in pairs(self.phase_info_list) do
		for k2, v2 in pairs(self:GetPhaseFBLevelCfg()) do
			local data = self:GetCurFbCfgByIndex(v2.fb_index)
			local free_time = 0
			if data ~= nil and data.free_times then
				free_time = data.free_times
			end

			--if v2.fb_index == k and v.today_times <= 0 and v2.role_level <= role_level and (k + 1) <= self:MaxPhaseFB() then
			if v2.fb_index == k and free_time - v.today_times > 0 and v2.role_level <= role_level and (k + 1) <= self:MaxPhaseFB() then
				return true
			end

			if ClickOnceRemindList[RemindName.FuBenAdvance] == 1 then
				local cz_data = self:ChongZhiFbNum()
				if cz_data ~= nil and cz_data[v2.fb_index + 1] ~= nil then
					local chong_zhi_num = cz_data[v2.fb_index + 1].chong_zhi_num
					if chong_zhi_num ~= nil and v.today_times - free_time - chong_zhi_num < 0 then
						return true
					end
				end
			end
		end
	end

	return false
end

function FuBenData:GetExpFBTime()
	-- return self:GetExpFBOtherCfg().time_limit or 0
end

function FuBenData:IsShowExpFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_exp") then
		return false
	end
	local day_num = FuBenData.Instance:GetExpDayCount()
	local exp_daily_fb = FuBenData.Instance:GetExpDailyFb()
	if exp_daily_fb[0] then
		if day_num >= exp_daily_fb[0].enter_day_times then
			day_num = exp_daily_fb[0].enter_day_times
		end

		local item_count = ItemData.Instance:GetItemNumInBagById(exp_daily_fb[0].enter_item_id)

		return exp_daily_fb[0].enter_day_times - day_num > 0 or item_count > 0
	end
	-- if self:GetExpPayTimes() + self:GetExpFBOtherCfg().day_times - self:GetExpEnterTimes() > 0 then
	-- 	return true
	-- end
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
	-- vip副本不要了
	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	-- for k, v in pairs(self.vip_info_list) do
	-- 	if v.today_times <= 0 and self:GetVipFBLevelCfg()[k] and self:GetVipFBLevelCfg()[k].enter_level <= vo.vip_level then
	-- 		return true
	-- 	end
	-- end
	return false
end

function FuBenData:IsShowTowerFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_tower") then
		return false
	end

	if nil ==  next(self.tower_info_list) then return false end
	if self.tower_info_list.pass_level == 200 then
		return false
	end

	if self.tower_info_list.today_level < self.tower_info_list.pass_level then
		return true
	end

	if self:IsPowerTowerRedPoint() then
		return true
	end
	return false
end

function FuBenData:IsPowerTowerRedPoint()
	-- if math.floor(self.tower_red_point_cd - Status.NowTime) > 0 then
	-- 	return false
	-- end

	if nil ==  next(self.tower_info_list) then return false end
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
	if not OpenFunData.Instance or not OpenFunData.Instance:CheckIsHide("fb_tower") or nil ==  next(self.tower_info_list) then
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
	if CoolChatData.Instance:GetCoolChatRedPoint() then
		num = num + 1
	end
	if RuneData.Instance:GetBagHaveRuneGift() then
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
	if not OpenFunData.Instance:CheckIsHide("fuben") then 
		return 0
	end

	return self:IsShowFubenRedPoint() and 1 or 0
end

function FuBenData:IsShowFubenRedPoint()
	if self:IsShowPhaseFBRedPoint() or self:IsShowExpFBRedPoint() or self:IsShowGuardFBRedPoint() or --or self:IsShowStoryFBRedPoint()
		--self:IsShowVipFBRedPoint() or self:IsShowTowerFBRedPoint() or self:IsShowKuafuFbRedPoint() then
		self:IsShowVipFBRedPoint() or self:IsShowTowerFBRedPoint() then
		return true
	end
	return false
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

function FuBenData:SetExpDayCount(num)
	self.expday_num = num
end

function FuBenData:GetExpDayCount()
	return self.expday_num
end

function FuBenData:GetTowerReward()
	local cur_censhu = TableCopy(self:GetTowerFBInfo())
	local tower_cfg = self:GetTowerDayRewardCfg()
	if cur_censhu.pass_level == 0 then
		cur_censhu.pass_level = 1
	end
	for i,v in ipairs(tower_cfg) do
		if cur_censhu.pass_level == v.level then
			return v 
		end
	end
end


function FuBenData:ChongZhiFbNum()
	local role_level = PlayerData.Instance:GetRoleLevel()
	local chong_zhi_count = VipData.Instance:GetFBSaodangCount(VIPPOWER.VAT_FB_PHASE_COUNT)
	local copy_table = {}
	for k, v in pairs(self:GetPhaseFBLevelCfg()) do
		local data = {}
		data.chong_zhi_num = chong_zhi_count - math.abs(v.free_times - self.phase_info_list[v.fb_index].today_times) -- == 0 and 1 or 0
		table.insert(copy_table, data)
	end
	return copy_table
end


--------推图副本--------------------
function FuBenData:GetPushFBChapterInfo(fb_type)
	if nil == self.tuitu_fb_info_cfg[fb_type] then
		return nil
	end
	return self.tuitu_fb_info_cfg[fb_type]
end

function FuBenData:GetPushFBLeveLInfo(fb_type, chapter, level)
	if nil == self.tuitu_all_info_list or self.tuitu_all_info_list.fb_info_list[fb_type + 1] == nil or
		self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[chapter + 1] == nil then
		return nil
	end
	return self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[chapter + 1].level_info_list[level + 1]
end

function FuBenData:GetPushFBStarReward()
	return ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").star_reward
end


function FuBenData:GetStarRewardList(chapter, seq)
	local chap_cfg = self.star_reward_cfg[chapter]
	if chap_cfg and chap_cfg[seq] then
		return chap_cfg[seq][1].reward
	end
	return nil
end

function FuBenData:GetPushFBOtherCfg()
	return ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").other[1]
end

function FuBenData:GetPushFbMaxChapter(fb_type)
	local list_cfg = self.tuitu_fb_info_cfg[fb_type]
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

function FuBenData:GetPushFBInfo(fb_type, chapter, level)
	if nil == self.tuitu_fb_info_cfg then return nil end
	if nil == self.tuitu_fb_info_cfg[fb_type] or
		nil == self.tuitu_fb_info_cfg[fb_type][chapter] then
		return nil
	end
	if level then
		return self.tuitu_fb_info_cfg[fb_type][chapter][level]
	end
	return self.tuitu_fb_info_cfg[fb_type][chapter]
end

function FuBenData:GetOneLevelIsPassAndThreeStar(fb_type, fb_chapter, level)
	if self.tuitu_all_info_list and
	 self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[fb_chapter + 1].level_info_list[level + 1].pass_star == 3 then
		return true
	end
	return false
end

function FuBenData:GetOneLevelIsPass(fb_type, fb_chapter, level)
	if self.tuitu_all_info_list and
	 self.tuitu_all_info_list.fb_info_list[fb_type + 1].chapter_info_list[fb_chapter + 1].level_info_list[level + 1].pass_star > 0 then
		return true
	end
	return false
end

function FuBenData:GetCanEnterPushFB(fb_type)
	local all_push_info = self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[fb_type + 1] or {}
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

function FuBenData:GetMaxLevelByTypeAndChapter(fb_type, fb_chapter)
	local max_level = 0
	if fb_type == 0 then
		local cfg = self.tuitu_fb_info_cfg[fb_type][fb_chapter]
		for k,v in pairs(cfg) do
			if v.level > max_level then
				max_level = v.level
			end
		end
	else
		local boss_cfg = self.tuitu_fb_info_cfg[fb_type]
		local max_chapter = 0
		if nil ~= self.tuitu_fb_info_cfg[fb_type] then
			for k,v in pairs(self.tuitu_fb_info_cfg[fb_type]) do
				if k > max_chapter then
					max_chapter = k
				end
			end
			if fb_chapter == max_chapter then
				return #self.tuitu_fb_info_cfg[fb_type][fb_chapter]
			else
				return 9999
			end
		end
	end
	return max_level
end

function FuBenData:StarCfgInfo(fb_type, chapter, level)
	local cur_level_cfg = self:GetPushFBInfo(fb_type, chapter, level)
	local star_info_cfg = {}
	if nil == cur_level_cfg then
		return star_info_cfg
	end

	for i = 1 , 3 do
		if cur_level_cfg["time_limit_" .. i .."_star"] then
			table.insert(star_info_cfg, cur_level_cfg["time_limit_" .. i .."_star"])
		end
	end
	return star_info_cfg
end

function FuBenData:GetPushFBChapterCfg(chapter)
	return ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").chapter[chapter]
end

function FuBenData:CanGetStarReward(chapter, seq)
	local data = self:GetTuituCommonFbInfo()
	if nil == data or chapter == nil or seq == nil then
		return false
	end
	local chapter_info_list = data.chapter_info_list
	if chapter_info_list == nil or chapter_info_list[chapter] == nil then
		return false
	end
	local total_star = chapter_info_list[chapter].total_star
	local star_reward_flag = chapter_info_list[chapter].star_reward_flag
	local bit_list = bit:d2b(star_reward_flag)
	local reward_cfg = self:GetPushFBAllReward(chapter - 1, seq)

	if next(reward_cfg) and total_star >= reward_cfg.star_num and 0 == bit_list[32 - seq] then
		return true
	end
	return false
end

function FuBenData:GetHasPassChapter(chapter)
	local data = self:GetTuituCommonFbInfo()
	if nil == data then
		return false
	end

	local chapter_info_list = data.chapter_info_list
	local total_star = chapter_info_list[chapter].total_star

	if total_star < 12 and chapter <= data.pass_chapter + 1 then
		return true
	end

	return false
end

function FuBenData:IsEnoughStar(chapter)
	local is_show = false
	for k,v in pairs(self.is_show_common_red) do 
		if v == 1 then
			is_show = true
		end
	end

	if is_show == false and self.is_first_open_conmmon_view ~= true then is_show = true end 

	if is_show == false then
		return false
	end

	local data = self:GetTuituCommonFbInfo()
	if nil == data then
		return false
	end

	local chapter_info_list = data.chapter_info_list
	if chapter == nil or chapter_info_list == nil or chapter_info_list[chapter] == nil then
		return false
	end

	local total_star = chapter_info_list[chapter].total_star

	if total_star < 12 then
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
	local reward_cfg_list = ConfigManager.Instance:GetAutoConfig("tuitu_fb_auto").star_reward
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
	local chap_cfg = self.star_reward_cfg[chapter]
	if chap_cfg and chap_cfg[seq] then
		return chap_cfg[seq][1]
	end
	return {}
end

function FuBenData:NextCanGetStarReward(chapter)
	local data = self:GetTuituCommonFbInfo()
	if nil == data then
		return {}
	end
	local chapter_info_list = data.chapter_info_list
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
	return self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[1] or nil
end

function FuBenData:GetTuituSpecialFbInfo()
	return self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[2] or nil
end

function FuBenData:SetTuituFbResultInfo(protocol)
	self.tuitu_fb_result_info = protocol
end

function FuBenData:GetTuituFbResultInfo()
	return self.tuitu_fb_result_info
end

function FuBenData:SetTuituFbSingleInfo(protocol)
	self.tuitu_fb_single_info = protocol
	if self.tuitu_all_info_list then
		local history_data = self:GetPushFBLeveLInfo(protocol.fb_type, protocol.chatper, protocol.level)
		if history_data ~= nil and history_data.pass_star ~= nil and history_data.pass_star <= 0 then
			self:SetPushFirstReward(true)
		else
			self:SetPushFirstReward(false)
		end


		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].today_join_times = protocol.today_join_times
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].buy_join_times = protocol.buy_join_times
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].pass_chapter = protocol.cur_chapter + 1
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].pass_level = protocol.cur_level + 1
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].total_star = protocol.total_star
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].star_reward_flag = protocol.star_reward_flag
		self.tuitu_all_info_list.fb_info_list[protocol.fb_type + 1].chapter_info_list[protocol.chatper + 1].level_info_list[protocol.level + 1] = protocol.layer_info
	end
end

function FuBenData:SetPushFirstReward(value)
	self.push_fb_first_flag = value
end

function FuBenData:GetPushFirstReward()
	return self.push_fb_first_flag or false
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
	return RemindManager.Instance:GetRemind(RemindName.FBPush1) > 0
	 or RemindManager.Instance:GetRemind(RemindName.FBPush2) > 0
	 or self:GetPushReWardRed()
end

function FuBenData:GetPush1Redmind()
	return self:GetPushRed(0) and 1 or 0
end

function FuBenData:GetPush2Redmind()
	return self:GetPushRed(1) and 1 or 0
end

function FuBenData:GetPushRed(fb_type)
	local special_open = OpenFunData.Instance:CheckIsHide("fb_push_special")
	if not special_open then
		return false
	end

	if self.tuitu_all_info_list == nil or self.tuitu_all_info_list.fb_info_list == nil then
		return false
	end
	
	local all_push_info = self.tuitu_all_info_list and self.tuitu_all_info_list.fb_info_list[fb_type + 1] or {}
	local buy_join_times = all_push_info.buy_join_times or 0
	local today_join_times = all_push_info.today_join_times or 0
	local FirstLevelIsPass = self:GetOneLevelIsPassBySpecial(1, 0, 0)
	local free_join_times = 0

	if fb_type == 0 then
		free_join_times = self:GetPushFBOtherCfg().normal_free_join_times
	elseif fb_type == 1 then
		if special_open == false or not FirstLevelIsPass then
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
	if not OpenFunData.Instance:CheckIsHide("fb_push_special") then
		return false
	end
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
			-- elseif self:GetHasPassChapter(i) then
			-- 	return true
			else
				if self:IsEnoughStar(i) then
					return true
				end
			end
		end
	end
	return false
end

function FuBenData:GetOneLevelIsPassBySpecial(fb_type, fb_chapter, level)
	local cur_level_cfg = self:GetPushFBInfo(fb_type, fb_chapter, level)
	if self.tuitu_all_info_list and cur_level_cfg and
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
	if not OpenFunData.Instance:CheckIsHide("fb_push") or self.tuitu_all_info_list == nil or nil == next(self.tuitu_all_info_list) then
		return false
	end
	local capability = GameVoManager.Instance:GetMainRoleVo().capability
	local push_cfg = self:GetPushFBInfo(fb_type, self.tuitu_all_info_list.fb_info_list[fb_type + 1].pass_chapter, self.tuitu_all_info_list.fb_info_list[fb_type + 1].pass_level)
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

function FuBenData:SetOpenCommonView()
	self.is_first_open_conmmon_view = true
end

-- 1为有红点，2为已点击过
function FuBenData:SetShowRedPoint(chapter_item_index, is_show)
	self.is_show_common_red[chapter_item_index] = is_show
	if is_show == 2 then
		FuBenCtrl:FlushCommonView()
	end
end

function FuBenData:GetShowRedPoint(chapter_item_index)
	return self.is_show_common_red[chapter_item_index]
end
--------推图副本 end--------------------


----------------------------------------
-----------个人塔防begin----------------

function FuBenData:SetTowerDefendRoleInfo(info)
	self.tower_defend_role_info.join_times = info.join_times
	self.tower_defend_role_info.buy_join_times = info.buy_join_times
	self.tower_defend_role_info.max_pass_level = info.max_pass_level
	self.tower_defend_role_info.auto_fb_free_times = info.auto_fb_free_times
	self.tower_defend_role_info.item_buy_join_times = info.item_buy_join_times
	self.tower_defend_role_info.personal_last_level_star = info.personal_last_level_star
end

function FuBenData:SetTowerIsWarning(state)
	self.tower_is_warning = state
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

function FuBenData:SetFBDropInfo(info)
	self.tower_defend_drop_info.get_coin = info.get_coin
	self.tower_defend_drop_info.get_item_count = info.get_item_count
	self.tower_defend_drop_info.item_list = info.item_list
end

function FuBenData:GetTowerDefendRoleInfo()
	return self.tower_defend_role_info
end

function FuBenData:GetCurTowerDefendLevel()
	return self.tower_defend_role_info.max_pass_level and self.tower_defend_role_info.max_pass_level + 1 or 0
end

function FuBenData:GetTowerDefendInfo()
	return self.tower_defend_fb_info
end

function FuBenData:GetTowerDefendChapterCfg(chapter)
	local level_scene_cfg = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").level_scene_cfg
	return level_scene_cfg[chapter]
end

function FuBenData:GetTowerDefendOtherCfg()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").other[1]
	return other_cfg
end

function FuBenData:GetTowerWaveCfg(level)
	local wave_list = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").wave_list
	local cfg = {}
	for i,v in ipairs(wave_list) do
		if v.level == level then
			table.insert(cfg, v)
		end
	end
	return cfg
end

function FuBenData:GetTowerBuyCost(count)
	local buy_cost = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").buy_cost
	local cfg = {}
	for i,v in ipairs(buy_cost) do
		if v.buy_times == count then
			return v.gold_cost
		end
	end
	return buy_cost[#buy_cost].gold_cost
end

function FuBenData:IsShowGuardFBRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_person_guard") then
		return false
	end
	local info = self.tower_defend_role_info
	if nil == next(info) then return false end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefend_auto").other[1]
	if other_cfg.free_join_times - info.join_times > 0 then
		return true
	end
	return false
end
-------------个人塔防end----------------
----------------------------------------

--掉落物结算
function FuBenData:GetFBDropCount(info)
	self.drop_count = info.get_item_count
	self.drop_item_list = info.item_list
end

function FuBenData:GetFBDropItemList()
	return self.drop_item_list
end

-- 获取是否可鼓舞
function FuBenData:GetIsGetGuWu()
	local daily_fb_cfg = FuBenData.Instance:GetExpDailyFb()
	local buff_info = FightData.Instance:GetMainRoleEffectList()
	--两种buff
	if next(buff_info) and #buff_info < 2 then
		return true
	end
	if next(buff_info) then
		for k,v in pairs(buff_info) do
			if v.effect_type == FIGHT_EFFECT_TYPE.ATTRBUFF and v.merge_layer < (daily_fb_cfg[0].fb_guwu_gongji_max_per / 10) then
				return true
			elseif v.effect_type == FIGHT_EFFECT_TYPE.OTHER and v.merge_layer < (daily_fb_cfg[0].fb_guwu_exp_max_per / 10) then
				return true
			end
		end
	else
		return true
	end

	return false
end


--须臾幻境 组队
function FuBenData:GetTeamSpecialCfg()
	if not self.huanjing_config then
		self.huanjing_config = ConfigManager.Instance:GetAutoConfig("fbequip_auto")
	end
	return self.huanjing_config
end

function FuBenData:GetMonsterCfg()
	if not self.monster_cfg then
		self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
	end
	return self.monster_cfg 
end

function FuBenData:GetTeamSpecialCfglen()
	local team_layer_list = self:GetTeamSpecialCfg().team_layer_list
	return #team_layer_list
end

function FuBenData:GetTeamSpecialInfo(flag, scene_id)
	local huanjing_config = self:GetTeamSpecialCfg()
	local personal_layer_list = huanjing_config.personal_layer_list
	local team_layer_list = huanjing_config.team_layer_list
	local layer_list = personal_layer_list
	if flag ~= 0 then
		layer_list = team_layer_list
	end
	for k,v in pairs(layer_list) do
		if scene_id == v.scene_id then
			return v
		end
	end
	return nil
end

--组队多人塔防
function FuBenData:GetTeamTowerWaveNum()
	local wave_list = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").team_wave_list or {}
	local cfg = wave_list[#wave_list]
	if nil ~= cfg then
		return cfg.wave + 1
	end
	return 0
end

function FuBenData:IsShowTeamFbRedPoint()
	if not OpenFunData.Instance:CheckIsHide("fb_many_people") then
		return false
	end

	local flag = TeamFbData.Instance:CheckRedPoint()
	return flag
end


function FuBenData:IsOpenTeamFb()
	local flag = TeamFbData.Instance:IsOpenTeamFb()

	return flag or false
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

function FuBenData:SetTeamSpecialResult(protocol)
	self.team_special_info.is_over = protocol.is_over
	self.team_special_info.is_passed = protocol.is_passed
	self.team_special_info.can_jump = protocol.can_jump
	self.team_special_info.is_first_passed = protocol.is_first_passed
end

function FuBenData:GetTeamSpecialResult()
	return self.team_special_info
end