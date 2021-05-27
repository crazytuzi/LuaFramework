WangChengZhengBaData = WangChengZhengBaData or BaseClass()

function WangChengZhengBaData:__init()
	if WangChengZhengBaData.Instance then
		ErrorLog("[WangChengZhengBaData] Attemp to create a singleton twice !")
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	WangChengZhengBaData.Instance = self

	self.sign_up_guild_name_list = {}
end

function WangChengZhengBaData:__delete()
	WangChengZhengBaData.Instance = nil
end

WangChengZhengBaData.GloryDataChangeEvent = "glory_data_change_event"
WangChengZhengBaData.ApplyDataChangeEvent = "apply_data_change_event"
WangChengZhengBaData.RewardDataChangeEvent = "reward_data_change_event"
WangChengZhengBaData.SbkWarStateDataChangeEvent = "sbk_war_state_data_change_event"

--------------------------------------
-- 协议
--------------------------------------

-- 获取攻城行会列表
function WangChengZhengBaData:SetGongChengGuildList(protocol)
	self.gong_cheng_guild_list = {}
	self.gong_cheng_guild_list.is_sign_up = protocol.is_sign_up
	self.gong_cheng_guild_list.day = protocol.day
	self.gong_cheng_guild_list.sign_up_guild_name = protocol.sign_up_guild_name
	self.gong_cheng_guild_list.sign_up_guild_num = protocol.sign_up_guild_num
	self.gong_cheng_guild_list.sign_up_guild_list = protocol.sign_up_guild_list

	self.sign_up_guild_name_list = self.gong_cheng_guild_list.sign_up_guild_list or {}
	self:DispatchEvent(WangChengZhengBaData.ApplyDataChangeEvent)
end

-- 获取今天报名和明天报名的行会名字
function WangChengZhengBaData:SetSBKSignUpList(protocol)
	self.sbk_sign_up_list = {}
	self.sbk_sign_up_list.day_num = protocol.day_num
	self.sbk_sign_up_list.sing_up_data = protocol.sing_up_data

	self.sign_up_guild_name_list = self.sbk_sign_up_list.sing_up_data
		and self.sbk_sign_up_list.sing_up_data.guild_name_list or self.sign_up_guild_name_list
end

-- 下发沙巴克领取奖励信息
function WangChengZhengBaData:SetSBKRewardMsg(protocol)
	self.sbk_can_get_reward_mark = protocol.can_get_mark
	self:DispatchEvent(WangChengZhengBaData.RewardDataChangeEvent)
end

-- 下发沙巴克基本信息
function WangChengZhengBaData:SetSbkBaseMsg(protocol)
	self.sbk_base_msg_list = {}
	self.sbk_role_vo_list = {}
	self.sbk_base_msg_list.guild_name = protocol.guild_name
	-- self.sbk_base_msg_list.guild_main_mb_num = protocol.guild_main_mb_num
	self.sbk_base_msg_list.guild_main_mb_list = protocol.guild_main_mb_list

	local is_now_gc, is_over_gc = WangChengZhengBaData.GetIsNowGCOpen(true)
	if is_now_gc then
		self.sbk_base_msg_list.guild_main_mb_list = {}
	end
	self:DispatchEvent(WangChengZhengBaData.GloryDataChangeEvent)
end

function WangChengZhengBaData:GetSbkBaseMsg()
	return self.sbk_base_msg_list
end


-- 记录攻城胜利角色vo
function WangChengZhengBaData:SetSbkRoleVo(vo)
	if not self.sbk_base_msg_list or not self.sbk_base_msg_list.guild_main_mb_list then return end
	if not self.sbk_role_vo_list then self.sbk_role_vo_list = {} end
	for k,v in pairs(self.sbk_base_msg_list.guild_main_mb_list) do
		if v.role_name == vo.name and self.sbk_base_msg_list.guild_name == vo.guild_name then
			self.sbk_role_vo_list[k] = TableCopy(vo)
			break
		end
	end
	self:DispatchEvent(WangChengZhengBaData.GloryDataChangeEvent)
end

-- 获取攻城胜利角色vo
function WangChengZhengBaData:GetSbkRoleVo(index)
	if not self.sbk_role_vo_list then return end
	return self.sbk_role_vo_list[index]
end


-- 记录沙巴克城战的状态
function WangChengZhengBaData:SetSbkWarState(protocol)
	if not protocol or not protocol.state then return end
	self.sbk_war_state = protocol.state
	self:DispatchEvent(WangChengZhengBaData.GloryDataChangeEvent)
	self:DispatchEvent(WangChengZhengBaData.SbkWarStateDataChangeEvent)
end




-- 获取参加攻城的行会数据
function WangChengZhengBaData:GetApplyGuildData()
	local guild_list = GuildData.Instance:GetGuildList()
	if not self.sign_up_guild_name_list or not guild_list then return end

	local date_t = WangChengZhengBaData.GetNextOpenTimeDate()
	local is_sp_reward = date_t and date_t.is_sp_reward or false
	local data = {}
	for k,v in pairs(guild_list) do
		if is_sp_reward then
			-- table.insert(data, v) 		-- 开服合服攻城
		else
			for k1,name in pairs(self.sign_up_guild_name_list) do
				if name == v.guild_name then
					table.insert(data, v)
				end
			end
		end
	end
	return data
end

-- 获取下一次攻城开启时间
function WangChengZhengBaData.GetNextOpenTimeDate(is_ignore_hour)
	local t_open_time = StdActivityCfg[DAILY_ACTIVITY_TYPE.GONG_CHENG] and StdActivityCfg[DAILY_ACTIVITY_TYPE.GONG_CHENG].tOpenTime
	if nil == t_open_time then
		return
	end
	local weeks_t = t_open_time and t_open_time.weeks
	local times_t = t_open_time and t_open_time.times and t_open_time.times[1]
	if not weeks_t or not times_t then return end

	local open_server_days = OtherData.Instance:GetOpenServerDays()
	local combind_server_days = OtherData.Instance:GetCombindDays()

	local is_sp_reward = false

	local now_weekday = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	local now_hour = tonumber(os.date("%H", TimeCtrl.Instance:GetServerTime()))
	local shift_day = 0
	if not now_weekday or not now_hour then return end

	local function get_next_weekday(now_wday)
		for i=1, #weeks_t do
			-- 活动开启后第一天不开启活动
			if (now_wday == weeks_t[i] and ((GuildConfig.SbkSignUpTime.openDay + 1) == open_server_days or (GuildConfig.SbkSignUpTime.combineDay + 1) == combind_server_days)) 
							or (now_wday + 1 == weeks_t[i] and  (open_server_days == GuildConfig.SbkSignUpTime.openDay or combind_server_days == GuildConfig.SbkSignUpTime.combineDay)) then
				if nil ~= weeks_t[i + 1] then
					return weeks_t[i + 1], false
				end
			else
				if now_wday <= weeks_t[i] then
					return weeks_t[i], false
				end
			end
		end
		return weeks_t[1], true
	end
	local next_weekday, is_circuit = get_next_weekday(now_weekday)
	shift_day = next_weekday - now_weekday + (is_circuit and 7 or 0)


	local open_shift_day = open_server_days - GuildConfig.SbkSignUpTime.openDay
	local combind_shift_day = combind_server_days - GuildConfig.SbkSignUpTime.combineDay
	if open_shift_day and open_shift_day <= 0 then
		local is_use = is_ignore_hour or (-open_shift_day ~= 0) or (times_t[3] and tonumber(times_t[3]) and now_hour < tonumber(times_t[3]))
		if is_use then
			shift_day = - open_shift_day
			is_sp_reward = true
		end
	end
	if combind_shift_day and combind_shift_day <= 0 and combind_shift_day > - GuildConfig.SbkSignUpTime.combineDay then
		local is_use = is_ignore_hour or (-combind_shift_day ~= 0) or (times_t[3] and tonumber(times_t[3]) and now_hour < tonumber(times_t[3]))
		if is_use then
			shift_day = - combind_shift_day
			is_sp_reward = true
		end
	end

	local next_s = TimeCtrl.Instance:GetServerTime() + shift_day * 24 * 60 * 60

	local date_t = {}
	date_t.month = os.date("%m",next_s)
	date_t.day = os.date("%d",next_s)
	date_t.weekday = tonumber(os.date("%w",next_s))
	date_t.hour_1 = times_t[1] or 20
	date_t.min_1 = times_t[2] or 0
	date_t.hour_2 = times_t[3] or 21
	date_t.min_2 = times_t[4] or 0
	date_t.is_sp_reward = is_sp_reward

	return date_t, next_s
end

-- 获取是否攻城中
function WangChengZhengBaData.GetIsNowGCOpen(is_advance)
	local next_date_t, next_s = WangChengZhengBaData.GetNextOpenTimeDate(true)
	if not next_date_t or not next_s then return false end
	local server_s = TimeCtrl.Instance:GetServerTime()
	local advance_min = 10 		-- 提前10分钟

	local function get_date_s(hour_tag, min_tag, next_s)
		if not tonumber(next_s) then return end
		local next_s_hour = tonumber(os.date("%H",next_s))
		local next_s_min = tonumber(os.date("%M",next_s))
		local shift_hour = hour_tag - next_s_hour - 1
		local shift_min = min_tag - next_s_min + 60
		return next_s + (shift_hour * 60 * 60) + (shift_min * 60)
	end

	local s_1 = get_date_s(next_date_t.hour_1, next_date_t.min_1, next_s)
	local s_2 = get_date_s(next_date_t.hour_2, next_date_t.min_2, next_s)
	if not s_1 or not s_2 then return false end

	return (server_s >= (is_advance and (s_1 - advance_min * 60) or s_1)) and (server_s < s_2), server_s >= s_2
end

-- 获取今天是否攻城日
function WangChengZhengBaData.GetIsTodayGC()
	local date_t, next_s = WangChengZhengBaData.GetNextOpenTimeDate(true)
	local server_s = TimeCtrl.Instance:GetServerTime()
	local now_date_t = {}
	now_date_t.month = os.date("%m",server_s)
	now_date_t.day = os.date("%d",server_s)
	now_date_t.weekday = tonumber(os.date("%w",server_s))

	return date_t and now_date_t.month == date_t.month and now_date_t.day == date_t.day and now_date_t.weekday == date_t.weekday
end

-- 获取下次攻城战时间字符串
function WangChengZhengBaData.GetNextOpenTimeDateStr()
	local date_t = WangChengZhengBaData.GetNextOpenTimeDate()
	if nil == date_t or not date_t.month or not date_t.day or not date_t.weekday then return end
	
	local weekday = date_t.weekday == 0 and 7 or date_t.weekday
	return string.format(Language.WangChengZhengBa.DateStr, date_t.month, date_t.day, Language.Common.CHNWeekDays[weekday],
		date_t.hour_1 or "20", date_t.min_1 or "00", date_t.hour_2 or "21", date_t.min_2 or "00")
end

-- -- 获取奖励数据
-- function WangChengZhengBaData.GetSBKRewardsData()
-- 	local cfg = SbkAward and SbkAward.guildAward
-- 	if not cfg or not cfg.firstAward or not cfg.normalAward then return end

-- 	local date_t = WangChengZhengBaData.GetNextOpenTimeDate(true)
-- 	local is_sp_reward = date_t and date_t.is_sp_reward or false

-- 	local data_list = {}
-- 	local reward_list = is_sp_reward and cfg.firstAward or cfg.normalAward
-- 	for k,v in pairs(reward_list) do
-- 		local data = {}
-- 		if WangChengZhengBaData.GetSBKRewardsVirtualIcon(k) then
-- 			data[1] = {item_id = WangChengZhengBaData.GetSBKRewardsVirtualIcon(k), num = 1, is_bind = 0, sp_effect_id = nil}
-- 		end
-- 		for i=1,#v do
-- 			local reward_t = v[i]
-- 			if reward_t and reward_t.type and reward_t.id then
-- 				local item_id = ItemData.GetVirtualItemId(reward_t.type) or reward_t.id
-- 				data[#data + 1] = {item_id = item_id, num = reward_t.count or 1, is_bind = reward_t.bind or 0, sp_effect_id = reward_t.effectId}
-- 			end
-- 		end

-- 		data_list[#data_list + 1] = {}
-- 		data_list[#data_list].reward_data = data
-- 		data_list[#data_list].index = k
-- 	end

-- 	return data_list
-- end

function WangChengZhengBaData:GetRewardIndex()
	if self.sbk_base_msg_list.guild_name ~= GuildData.Instance:GetGuildName() then
		return 5
	else
		if RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_TANGZHU_FIR) or RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_TANGZHU_SRC) or RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_TANGZHU_THI) or RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_TANGZHU_FOU) then
			return 3
		elseif RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_ASSIST_LEADER) then
			return 2
		elseif RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_LEADER) then
			return 1
		else
			return 4
		end
	end
end

-- 获取显示配置
function WangChengZhengBaData:GetShowConfig()
	if cc.FileUtils:getInstance():isFileExist("scripts/config/client/wang_cheng_zheng_ba_cfg.lua") then
		return ConfigManager.Instance:GetClientConfig("wang_cheng_zheng_ba_cfg")
	end
end

-- 获取奖励界面人物显示信息
function WangChengZhengBaData:GetRewardShowRoleData()
	local reward_role_data = {}
	clothes_id = self:GetRewardShowClothesId()
	weapon_id = self:GetRewardShowWeaponId()
	reward_role_data.role_res_id = ItemData.Instance:GetItemConfig(clothes_id).shape
	reward_role_data.wuqi_res_id = ItemData.Instance:GetItemConfig(weapon_id).shape
	return reward_role_data
end

-- 获取奖励界面称号id
function WangChengZhengBaData:GetRewardShowTitle()
	local cfg = self:GetShowConfig().LeaderPrivilege
	if not cfg then return end
	return cfg.sbkTitle.Title
end

-- 获取奖励界面时装id
function WangChengZhengBaData:GetRewardShowClothesId()
	local cfg = self:GetShowConfig().LeaderPrivilege
	if not cfg then return end
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in pairs(cfg.sbkClothes.Clothes) do
		if v.sex == sex then 
			return v.ClothesId
		end
	end
end

-- 获取奖励界面幻武id
function WangChengZhengBaData:GetRewardShowWeaponId()
	local cfg = self:GetShowConfig().LeaderPrivilege
	if not cfg then return end
	return cfg.sbkWeapon.WeaponId
end

-- 获取奖励界面奖励物品数据
function WangChengZhengBaData:GetRewardShowItemList()
	local reward_item_List = {}
	reward_item_List[1] = {item_id = 0, num = 1, is_bind = 0}
	reward_item_List[2] = {item_id = 0, num = 1, is_bind = 0}
	reward_item_List[3] = {item_id = 0, num = 1, is_bind = 0}
	reward_item_List[1].item_id = self:GetRewardShowTitle().item_id
	reward_item_List[2].item_id = self:GetRewardShowWeaponId()
	reward_item_List[3].item_id = self:GetRewardShowClothesId()
	return reward_item_List
end

function WangChengZhengBaData:GetRewardContent()
	local leader_cfg = self:GetShowConfig()

	return leader_cfg.SbkTips.RewardTips.Content
end

function WangChengZhengBaData.GetSBKRewardsVirtualIcon(index)
	local cfg = SbkAward and SbkAward.VirtualIcon
	if not cfg then return end
	for k,v in pairs(cfg) do
		if v.index and type(v.index) == "table" and v.headtitleItemId then
			for k1,v1 in pairs(v.index) do
				if index == v1 then return v.headtitleItemId end
			end
		end
	end
end

function WangChengZhengBaData:GetIsChangeNameColor()
	local gc_state = self.sbk_war_state
	local scene_id = Scene.Instance:GetSceneId()
	if gc_state == 1 and (scene_id == 4 or scene_id == 5) then
		return true
	end
	return false
end

function WangChengZhengBaData.GetGCNameColor(role_vo)
	return UInt2C3b(role_vo.name_color or 0)
end