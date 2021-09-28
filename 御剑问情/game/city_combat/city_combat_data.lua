CityCombatData = CityCombatData or BaseClass()

CityCombatData.RevivieTime = 15					--复活时间

function CityCombatData:__init()
	if CityCombatData.Instance then
		print_error("[CityCombatData] Attemp to create a singleton twice !")
	end
	CityCombatData.Instance = self

	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self.time_cfg = ActivityData.Instance:GetClockActivityByID(6)
	end, 0)
	self.self_info = {
		is_shousite = 0,
		zhangong = 0,
		rank_list = {},
	}
	self.cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto")
	self.hefu_cfg = ConfigManager.Instance:GetAutoConfig("combineserveractivity_auto")
	self.global_info = {
		is_finish = 0,
		is_pochen = 0,
		is_poqiang = 0,
		cu_def_guild_time = 0,
		shou_guild_id = 0,
		shou_guild_name = "",
		shou_totem_level = 0,
		rank_list = {},
		po_cheng_times = 0,
	}

	self.win_times = 0

	self.luck_user_namelist = {}
	self.tw_user_namelist = {}
	self.gb_user_namelist = {}
	self.qxld_user_namelist = {}

	self.owner_role_info = nil
	self.lover_info = nil
	self.lover_uid = nil
end

function CityCombatData:__delete()
	self:RemoveDelayTime()
	self.ower_info = nil
	CityCombatData.Instance = nil
end

function CityCombatData:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function CityCombatData:GetDefenceGulidID()
	if self.global_info ~= nil then
		return self.global_info.shou_guild_id
	end
end

--特权叠加次数
function CityCombatData:SetHefuFirstInfo(protocol)
	self.win_times = protocol.win_times
end

function CityCombatData:SetZhanChangLuckInfo(protocol)
	self.luck_user_namelist = protocol
end

function CityCombatData:SetTWLuckInfo(protocol)
	self.tw_user_namelist = protocol
end

function CityCombatData:SetGBLuckInfo(protocol)
	self.gb_user_namelist = protocol
end

function CityCombatData:SetQXLDLuckInfo(protocol)
	self.qxld_user_namelist = protocol
end

function CityCombatData:GetTeQuanLevel()
	return self.win_times
end

function CityCombatData:GetHefuCfg()
	return self.hefu_cfg or nil
end

function CityCombatData:GetZhanChangLuckInfoList()
	if next(self.luck_user_namelist) then
		return self.luck_user_namelist.luck_user_namelist
	end
	return nil
end
function CityCombatData:GetTWLuckInfoList()
	if next(self.tw_user_namelist) then
		return self.tw_user_namelist.luck_user_namelist
	end
	return nil
end
function CityCombatData:GetGBLuckInfoList()
	if next(self.gb_user_namelist) then
		return self.gb_user_namelist.luck_user_namelist
	end
	return nil
end
function CityCombatData:GetQXLDLuckInfoList()
	if next(self.qxld_user_namelist) then
		return self.qxld_user_namelist.luck_user_namelist
	end
	return nil
end

function CityCombatData:GetZhanChangRewardTime()
	if next(self.luck_user_namelist) then
		return self.luck_user_namelist.next_lucky_timestamp
	end
	return 0
end
function CityCombatData:GetTWRewardTime()
	if next(self.tw_user_namelist) then
		return self.tw_user_namelist.next_lucky_timestamp
	end
	return 0
end
function CityCombatData:GetGBRewardTime()
	if next(self.gb_user_namelist) then
		return self.gb_user_namelist.next_lucky_timestamp
	end
	return 0
end
function CityCombatData:GetQXLDRewardTime()
	if next(self.qxld_user_namelist) then
		return self.qxld_user_namelist.next_lucky_timestamp
	end
	return 0
end

function CityCombatData:GetIsPoQiang()
	return self.global_info.is_poqiang
end

function CityCombatData:GetIsPoChen()
	return self.global_info.po_cheng_times
end

-- function CityCombatData:GetTotalLeftTime()
-- 	local end_time = ActivityData.Instance:GetActivityStatuByType(6).next_time
-- 	return end_time - TimeCtrl.Instance:GetServerTime()
-- end

--设置城主信息
function CityCombatData:SetCityOwnerInfo(protocol)
	self.ower_info = protocol
end

--设置个人信息
function CityCombatData:SetSelfInfo(protocol)
	self.self_info = protocol
end

--攻城战全局信息
function CityCombatData:SetGlobalInfo(protocol)
	if protocol.is_poqiang == 1 then
		if self.global_info ~= nil then
			if self.global_info.is_poqiang == 0 then
				--破墙
				if self.self_info.is_shousite == 1 then
					TipsCtrl.Instance:ShowSystemMsg(Language.CityCombat.WallBreakDefSide)
				else
					TipsCtrl.Instance:ShowSystemMsg(Language.CityCombat.WallBreakAtkSide)
				end
			end
		end
	end
	if protocol.is_pochen == 1 then
		if self.global_info ~= nil then
			if self.global_info.is_pochen == 0 then
				--破城
				-- CityCombatCtrl.Instance:PoChengReset()
			end
		end
	end
	self.global_info = TableCopy(protocol)
end

function CityCombatData:GetShouGuildTotemLevel()
	if self.global_info then
		return self.global_info.shou_totem_level or 1
	else
		return 1
	end
end

--获取城墙是否已破
function CityCombatData:GetwallIsDestroy()
	return self.global_info.is_poqiang == 1
end

--获攻城战全局信息
function CityCombatData:GetGlobalInfo()
	return self.global_info
end

function CityCombatData:CheckIsIn(n, n1, n2)
	local max_n = n1
	local min_n = n2
	if n1 < n2 then
		max_n = n2
		min_n = n1
	end
	if n > min_n and n < max_n then
		return true
	else
		return false
	end
end

--检查是否在资源区
function CityCombatData:CheckIsInResourceZone(x, y)
	local data = self.cfg.other[1]
	local x_in = self:CheckIsIn(x, data.resource_zuo_xia_x, data.resource_you_shang_x)
	if not x_in then
		return false
	else
		local y_in = self:CheckIsIn(y, data.resource_zuo_xia_y, data.resource_you_shang_y)
		return y_in
	end
end

--检查自己当前是否在城门外
function CityCombatData:CheckSelfIsInResZone()
	local main_role = Scene.Instance:GetMainRole()
	local self_x, self_y = main_role:GetLogicPos()
	local is_in = self:CheckIsInResourceZone(self_x, self_y)
	return is_in
end

--检查是否能移动到该坐标
function CityCombatData:GetIsCanMove(x, y)
	local range = 10
	local data = self.cfg.other[1]
	local target_x = data.relive1_x
	local target_y = data.relive1_y
	if self.self_info.is_shousite == 0 then
		target_x = data.relive2_x
		target_y = data.relive2_y
	end
	local x_in = self:CheckIsIn(x, target_x - range, target_x + range)
	if not x_in then
		return true
	else
		local y_in = self:CheckIsIn(y, target_y - range, target_y + range)
		return not y_in
	end
end

--获取传送阵名字
function CityCombatData:GetDorrName()
	return self.cfg.other[1].door_name
end

--获取城主信息
function CityCombatData:GetCityOwnerInfo()
	return self.ower_info
end

--获取个人信息
function CityCombatData:GetSelfInfo()
	return self.self_info
end

--获取下一战功奖励
function CityCombatData:GetNextZhanGongReward()
	for k,v in pairs(self.cfg.zhangong_reward) do
		if v.zhangong > self.self_info.zhangong then
			return v
		end
	end
	return self.cfg.zhangong_reward[#self.cfg.zhangong_reward]
end

--获取攻城战奖励
function CityCombatData:GetCityCombatRewards()
	local rewards = {}
	for i=1,10 do
		local reward = self.time_cfg["reward_item"..i]
		if reward ~= nil then
			table.insert(rewards, reward)
		else
			break
		end
	end
	return rewards
end

--获取是否攻击方
function CityCombatData:GetIsAtkSide()
	return (self.self_info.is_shousite == 0)
end

function CityCombatData:GetMainSide()
	return self.self_info.is_shousite
end

--获取攻城战开启时间
function CityCombatData:GetCityCombatOpenTime()
	local day = Split(self.time_cfg.open_day, ":")
	local day_text = ""
	if #day >= 7 then
		day_text = Language.Activity.EveryDay
	else
		day_text = Language.Activity.WeekDay
		for k,v in pairs(day) do
			day_text = day_text..Language.Common.NumToChs[tonumber(v)]
			if k < #day then
				day_text = day_text.."、"
			end
		end
	end
	day_text = day_text.." "..self.time_cfg.open_time.."-"..self.time_cfg.end_time

	return day_text
end

--获取时间/公会排行榜
function CityCombatData:GetTimeRankList()
	local list = {}
	for i=1,#self.global_info.rank_list do
		local rank_list_data = self.global_info.rank_list[i]
		local data = {}
		data.name = rank_list_data.guild_name
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		data.is_self = (main_role_vo.guild_id == rank_list_data.guild_id)
		data.value = rank_list_data.shouchen_time
		list[i] = data
	end
	return list
end

--获取功勋/个人排行榜
function CityCombatData:GetZhanGongRankList()
	local list = {}
	for i=1,#self.self_info.rank_list do
		local rank_list_data = self.self_info.rank_list[i]
		local data = {}
		data.name = rank_list_data.name
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		data.is_self = (main_role_vo.role_id == rank_list_data.id)
		data.value = rank_list_data.zhangong
		list[i] = data
	end
	return list
end

--获取旗帜信息
function CityCombatData:GetFlagInfo()
	local data = {}
	data.id = self.cfg.other[1].boss2_id
	data.x = self.cfg.other[1].boos2_x
	data.y = self.cfg.other[1].boos2_y
	return data
end

--获取传送阵的位置
function CityCombatData:GetTransDoor()
	return self.cfg.other[1].goalkeeping_x, self.cfg.other[1].goalkeeping_y
end

--获取旗帜位置
function CityCombatData:GetFlagPosXY()
	if self.global_info.is_poqiang == 1 then
		return self.cfg.other[1].boos2_x, self.cfg.other[1].boos2_y
	else
		if self:GetIsAtkSide() then
			return self.cfg.other[1].boos1_x, self.cfg.other[1].boos1_y
		end
		local wall_info = self:GetWallInfo()
		if self:CheckSelfIsInResZone() then
			return wall_info.x, wall_info.y
		else
			return self:GetTransDoor()
		end
	end
end

--获取城墙
function CityCombatData:GetWallInfo()
	local data = {}
	data.id = self.cfg.other[1].boss1_id
	data.x = self.cfg.other[1].boos1_x
	data.y = self.cfg.other[1].boos1_y
	return data
end

--当前守方公会是否在排行榜
function CityCombatData:IsCurrentDefGuildInRank()
	for i=1,#self.global_info.rank_list do
		if self.global_info.rank_list[i].guild_id == self.global_info.shou_guild_id then
			return true
		end
	end
end

--重置排行榜
function CityCombatData:ReSetRank(new_time)
	local rank_list = self.global_info.rank_list
	for i=1,#rank_list do
		if rank_list[i].guild_id == self.global_info.shou_guild_id then
			rank_list[i].shouchen_time = new_time
			if rank_list[i-1] ~= nil and new_time > rank_list[i-1].shouchen_time then
				self:DoReSetRank()
				return true
			end
		end
	end
end

function CityCombatData:DoReSetRank()
	local rank_list = self.global_info.rank_list
	for i=1,#rank_list do
		if rank_list[i+1] ~= nil then
			if rank_list[i].shouchen_time < rank_list[i+1].shouchen_time then
				rank_list[i], rank_list[i+1] = rank_list[i+1], rank_list[i]
			end
		end
	end
end

function CityCombatData:GetOtherConfig()
	return self.cfg.other[1]
end

-- 判断当前场景是否攻城战地图
function CityCombatData:GetCurSceneIsGongChengZhan()
	local cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto")
	local cur_scene = Scene.Instance:GetSceneId()
	return cfg.other[1].scene_id == cur_scene
end

-- 拿到守方的旗帜信息
function CityCombatData:GetGongChengZhanFaltCfg(lv)
	local cfg = ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").qizhi_level
	-- local def_gulid_id = CityCombatData.Instance:GetDefenceGulidID()
	-- local guild_info = GuildData.Instance:GetGuildInfoById(def_gulid_id)
	return cfg[lv + 1]
end

function CityCombatData:GetWorshipScenIdAndPosXYAndRang()
	if nil == self.cfg or nil == self.cfg.other or nil == self.cfg.other[1] then
		return -1, -1, -1, -1
	end

	local cfg = self.cfg.other[1]
	return (cfg.worship_scene_id or -1), (cfg.worship_pos_x or -1), (cfg.worship_pos_y or -1), (cfg.worship_range or -1)
end

function CityCombatData:GetWorshipStatuePosParam()
	if nil == self.cfg or nil == self.cfg.other or nil == self.cfg.other[1] then
		return -1, -1, -1
	end

	local cfg = self.cfg.other[1]
	return (cfg.statue_pos_x or -1), (cfg.statue_pos_y or -1), (cfg.statue_rotation or -1)
end

function CityCombatData:GetWorshipCfgNum()
	if nil == self.cfg or nil == self.cfg.other or nil == self.cfg.other[1] then
		return 0
	end

	return self.cfg.other[1].worship_click_time or 0
end

function CityCombatData:GetCityCombatFashion()
	if nil == self.cfg or nil == self.cfg.other or nil == self.cfg.other[1] then
		return 0
	end

	return self.cfg.other[1].shizhuang_index or 0
end

function CityCombatData:GetGuildCallCost()
	if nil == self.cfg or nil == self.cfg.sos_cfg or nil == self.self_info then
		return -1, -1
	end

	local sos_times = self.self_info.sos_times or 0
	local cfg = self.cfg.sos_cfg[sos_times + 1]
	if nil ~= cfg then
		return cfg.times or -1, cfg.cost or -1
	end

	return -1, -1
end

function CityCombatData:GetGuildCallLeftTimes()
	if nil == self.cfg or nil == self.cfg.sos_cfg or nil == self.self_info then
		return 0
	end

	local sos_times = self.self_info.sos_times or 0
	local max_count = #self.cfg.sos_cfg

	return math.max(max_count - sos_times, 0)
end

function CityCombatData:GetWorshipGatherTime()
	if nil == self.cfg or nil == self.cfg.other or nil == self.cfg.other[1] then
		return 0
	end

	return self.cfg.other[1].worship_gather_time or 0
end

function CityCombatData:SetGCZWorshipInfo(protocol)
	self.worship_times = protocol.worship_times
	self.next_worship_timestamp = protocol.next_worship_timestamp
	self.next_interval_addexp_timestamp = protocol.next_interval_addexp_timestamp
end

function CityCombatData:GetGCZWorshipInfo()
	return self.worship_times, self.next_worship_timestamp, self.next_interval_addexp_timestamp
end

function CityCombatData:SetCityOwnerRoleInfo(role_info)
	self.owner_role_info = TableCopy(role_info)
	self.lover_uid = role_info.lover_uid
end

function CityCombatData:GetCityOwnerRoleInfo()
	return self.owner_role_info
end

function CityCombatData:SetLoverRoleInfo(role_info)
	self.lover_info = TableCopy(role_info)
end

function CityCombatData:GetLoverRoleInfo()
	return self.lover_info
end

function CityCombatData:GetCityOwnerLoverRoleId()
	return self.lover_uid
end

function CityCombatData:ClearCityOwnerInfo()
	self.owner_role_info = nil
	self.lover_info = nil
	self.lover_uid = nil
end