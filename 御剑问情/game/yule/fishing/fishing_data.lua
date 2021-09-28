FishingData = FishingData or BaseClass()

FISH_POOL_QUERY_TYPE = {
	FISH_POOL_QUERY_TYPE_ALL_INFO = 0,							-- 所有信息
	FISH_POOL_QUERY_TYPE_RAISE_INFO = 1,						-- 放养信息
	FISH_POOL_QUERY_TYPE_WORLD_GENERAL_INFO = 2,				-- 世界玩家简要信息
	FISH_POOL_QUERY_TYPE_STEAL_GENERAL_INFO = 3,				-- 偷鱼者简要信息
	FISH_POOL_UP_FISH_QUALITY = 4,								-- 请求升级鱼品质
	FISH_POOL_BUY_FANG_FISH_TIMES = 5,							-- 购买放鱼次数
}

FISH_TYPE = {
	NORMAL_FISH = 0,
	PROTECT_FISH = 1,
	NOT_FISH = 2,
}

STEAL_TYPE = {
	FAIL = 0,				--失败
	SUCC = 1,				--成功
	REFRESH = 2,			--刷新信息
}

FishingData.FISH_QUALITY_COUNT = 4										-- 鱼的品质数
FishingData.FISH_POOL_COUNT_MAX = 100									-- 获取世界玩家鱼池数量最大数
FishingData.FISH_POOL_BE_TEAL_FISH_UID_MAX = 50							-- 记录偷自己鱼的玩家的最大数

function FishingData:__init()
	if FishingData.Instance ~= nil then
		print_error("[FishingData] attempt to create singleton twice!")
		return
	end
	FishingData.Instance = self

	local all_fish_cfg = ConfigManager.Instance:GetAutoConfig("lingchibuyu_auto")
	self.fish_other_cfg = all_fish_cfg.other[1]												--其他信息
	self.fish_quality_cfg = all_fish_cfg.fish_quality 										--鱼的品质
	self.buy_fang_fish_times_cfg = all_fish_cfg.buy_fang_fish_times 						--购买放鱼次数列表
	self.buy_bullet_cfg = all_fish_cfg.buy_bullet 											--购买子弹次数列表
	self.skip_cfg = all_fish_cfg.skip_cfg

	self.bullet_buy_times = 0
	self.bullet_buy_num = 0
	self.bullet_consume_num = 0
	self.today_fang_fish_times = 0
	self.today_buy_fang_fish_tims = 0
	self.fish_pond_uid = 0

	RemindManager.Instance:Register(RemindName.Fishing_CanGet, BindTool.Bind(self.CalcCanGetRedPoint, self))
	RemindManager.Instance:Register(RemindName.Fishing_BeSteal, BindTool.Bind(self.CalcBeStealRedPoint, self))
	RemindManager.Instance:Register(RemindName.Fishing_CanSteal, BindTool.Bind(self.CalcCanStealRedPoint, self))
end

function FishingData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Fishing_CanGet)
	RemindManager.Instance:UnRegister(RemindName.Fishing_BeSteal)
	RemindManager.Instance:UnRegister(RemindName.Fishing_CanSteal)
	FishingData.Instance = nil
end

--计算可收获可养红点
function FishingData:CalcCanGetRedPoint()
	local flag = 0
	if nil == self.my_fish_list then
		return flag
	end

	--先判断是否可养鱼
	local fang_fish_time = self.my_fish_list.fang_fish_time
	if fang_fish_time <= 0 then
		if self:GetFarmFishTimes() > 0 then
			--有可养鱼次数
			flag = 1
		end
	end

	if flag == 0 and fang_fish_time > 0 then
		--再判断是否可收获
		local fish_info = FishingData.Instance:GetFishInfoByQuality(self.my_fish_list.fish_quality)
		if nil == fish_info then
			return flag
		end
		local need_times = fish_info.need_time
		local server_time = TimeCtrl.Instance:GetServerTime()
		if server_time - fang_fish_time > need_times then
			flag = 1
		end
	end

	return flag
end

--计算被偷红点
function FishingData:CalcBeStealRedPoint()
	local flag = 0
	if nil == self.my_fish_list then
		return flag
	end

	if self.is_check_be_steal then
		return flag
	end

	if self:GetLeftBulletNum() <= 0 then
		return flag
	end

	if self.have_new_be_steal_record then
		flag = 1
	end

	return flag
end

function FishingData:SetIsCheckBeSteal(state)
	self.is_check_be_steal = state
end

function FishingData:GetIsCheckBeSteal()
	return self.is_check_be_steal
end

--计算可偷红点
function FishingData:CalcCanStealRedPoint()
	-- 点击后就消失，忽略原本逻辑，到达时间后回复原本逻辑,策划需求
	if ClickOnceRemindList[RemindName.Fishing_CanSteal] and ClickOnceRemindList[RemindName.Fishing_CanSteal] == 0 then
		return 0
	end

	local flag = 0
	if nil == self.my_fish_list then
		return flag
	end

	if self:GetLeftBulletNum() > 0 then
		flag = 1
	end

	return flag
end

--刷新鱼的品质
function FishingData:RefreshFishQuailty(quality)
	if nil == self.my_fish_list then
		return
	end

	self.my_fish_list.fish_quality = quality
end

--设置我自己的鱼池数据
function FishingData:SetMyFishList(protocol)
	self.my_fish_list = {}
	self.my_fish_list.owner_uid = protocol.owner_uid
	self.my_fish_list.fish_quality = protocol.fish_quality
	self.my_fish_list.fish_num = protocol.fish_num
	self.my_fish_list.fang_fish_time = protocol.fang_fish_time
end

function FishingData:GetMyFishList()
	return self.my_fish_list
end

--设置当前的鱼池数据
function FishingData:SetNowFishList(fish_list)
	if nil == fish_list then
		return
	end
	-- print_error("设置当前的鱼池数据", fish_list)
	self.now_fish_list = {}
	self.now_fish_list.owner_uid = fish_list.owner_uid
	self.now_fish_list.owner_name = fish_list.owner_name or ""
	self.now_fish_list.fish_quality = fish_list.fish_quality
	self.now_fish_list.fish_num = fish_list.fish_num
	self.now_fish_list.fang_fish_time = fish_list.fang_fish_time
	self.now_fish_list.is_fake_pool = fish_list.is_fake_pool or 0
end

function FishingData:GetNowFishList()
	return self.now_fish_list
end

function FishingData:FishPoolChange(protocol)
	if protocol.is_steal_succ == STEAL_TYPE.REFRESH then
		--需要刷新数据
		if nil ~= self.now_fish_list then
			self.now_fish_list.fish_num = protocol.fish_num
			self.now_fish_list.fish_quality = protocol.fish_quality
		end
	end
end

--设置自己的鱼池普通信息
function FishingData:SetCommonInfo(normal_info)
	self.bullet_buy_times = normal_info.bullet_buy_times						--已购买子弹次数
	self.bullet_buy_num = normal_info.bullet_buy_num							--已购买子弹数量
	self.bullet_consume_num = normal_info.bullet_consume_num					--已消耗子弹数量
	self.today_fang_fish_times = normal_info.today_fang_fish_times				--今天养鱼的次数
	self.today_buy_fang_fish_tims = normal_info.today_buy_fang_fish_tims		--今天购买养鱼的次数
end

function FishingData:GetOtherCfg()
	return self.fish_other_cfg
end

--获取守卫鱼数量
function FishingData:GetProtectFishNum()
	if nil == self.fish_other_cfg then
		return 0
	end
	return self.fish_other_cfg.init_guard_fish_num
end

function FishingData:GetTodayBulletBuyTimes()
	return self.bullet_buy_times
end

function FishingData:GetTodayFarmFishBuyTimes()
	return self.today_buy_fang_fish_tims
end

--判断是否可以购买养鱼次数
function FishingData:CanBuyFarmFishTimes()
	if nil == self.fish_other_cfg then
		return false
	end

	local max_times = self.fish_other_cfg.today_buy_fang_fish_times_limit
	if self.today_buy_fang_fish_tims >= max_times then
		return false
	end

	return true
end

--判断是否可以购买子弹
function FishingData:CanBuyBulletTimes()
	if nil == self.fish_other_cfg then
		return false
	end

	local max_times = self.fish_other_cfg.day_buy_bullet_limit_times
	if self.bullet_buy_times >= max_times then
		return false
	end

	return true
end

--根据鱼的品质获取鱼的信息
function FishingData:GetFishInfoByQuality(quality)
	local fish_info = nil
	if nil == self.fish_quality_cfg then
		return fish_info
	end

	for _, v in ipairs(self.fish_quality_cfg) do
		if quality == v.quality then
			fish_info = v
			break
		end
	end
	return fish_info
end

--根据购买养鱼次数获取需要消耗的钻石数
function FishingData:GetGoldByBuyFangFishTimes(times)
	local gold = 0
	if nil == self.buy_fang_fish_times_cfg then
		return gold
	end

	for _, v in ipairs(self.buy_fang_fish_times_cfg) do
		if times == v.buy_fang_fish_count then
			gold = v.gold
			break
		end
	end
	return gold
end

--根据购买子弹次数获取需要消耗的钻石数
function FishingData:GetGoldByBuyBulletTimes(times)
	local gold = 0
	if nil == self.buy_bullet_cfg then
		return gold
	end

	for _, v in ipairs(self.buy_bullet_cfg) do
		if times == v.bullet_count then
			gold = v.gold
			break
		end
	end
	return gold
end

--获取剩余的子弹数量
function FishingData:GetLeftBulletNum()
	local num = 0

	--先获取总的子弹数量
	local all_bullet_num = 0
	if nil ~= self.fish_other_cfg then
		all_bullet_num = self.fish_other_cfg.base_bullet_num + self.fish_other_cfg.give_bullet_per_buy * self.bullet_buy_times
	end
	--计算出剩余的子弹数量
	num = math.max(all_bullet_num - self.bullet_consume_num, 0)
	return num
end

--获取剩余的养鱼次数
function FishingData:GetFarmFishTimes()
	local times = 0

	--先获取总的养鱼次数
	local all_farm_fish_times = 0
	if nil ~= self.fish_other_cfg then
		all_farm_fish_times = self.fish_other_cfg.today_free_fang_fish_times + self.today_buy_fang_fish_tims
	end
	--计算出剩余的养鱼次数
	times = math.max(all_farm_fish_times - self.today_fang_fish_times, 0)
	return times
end

function FishingData:AddWaitDeleteList(info)
	if nil == self.wait_delete_list then
		self.wait_delete_list = {}
	end

	table.insert(self.wait_delete_list, info)
end

function FishingData:ClearWaitDeleteList()
	self.wait_delete_list = nil
end

function FishingData:GetWaitDeleteList()
	return self.wait_delete_list
end

--记录当前鱼塘归属者id
function FishingData:SetNowFishPondUid(uid)
	-- print_error("记录当前鱼塘归属者id", uid, GameVoManager.Instance:GetMainRoleVo().role_id)
	self.fish_pond_uid = uid
end

function FishingData:GetNowFishPondUid()
	return self.fish_pond_uid
end

function FishingData:SetWorldGeneralInfo(general_info)
	self.world_general_info = general_info
end

function FishingData:GetWorldGeneralInfo()
	return self.world_general_info
end

function FishingData.SortStealGeneralInfo(a, b)
	local order_a = 1000
	local order_b = 1000
	if a.is_fuchou < b.is_fuchou then
		order_a = order_a + 100
	elseif a.is_fuchou > b.is_fuchou then
		order_b = order_b + 100
	end

	if a.steal_fish_time > b.steal_fish_time then
		order_a = order_a + 10
	elseif a.steal_fish_time < b.steal_fish_time then
		order_b = order_b + 10
	end
	return order_a > order_b
end

function FishingData:SetStealGeneralInfo(general_info)
	self.have_new_be_steal_record = false
	-- if #general_info <= 0 then
	-- 	self.have_new_be_steal_record = false
	-- elseif nil == self.steal_general_info or #self.steal_general_info < #general_info then
	-- 	self.have_new_be_steal_record = true
	-- end
	self.steal_general_info = general_info
	table.sort(self.steal_general_info, FishingData.SortStealGeneralInfo)

	local server_times = TimeCtrl.Instance:GetServerTime()
	for i = #self.steal_general_info, 1, -1 do
		local record_info = self.steal_general_info[i]
		--先判断是否超过了3小时
		if server_times - record_info.steal_fish_time < 3600 * 3 then
			--再判断是否可复仇
			if record_info.is_fuchou == 0 then
				self.have_new_be_steal_record = true
				break
			end
		end
	end
end

function FishingData:GetStealGeneralInfoByQuailty(quality)
	local data = {}
	if nil == self.steal_general_info then
		return data
	end
	for _, v in ipairs(self.steal_general_info) do
		if v.be_steal_quality == quality then
			table.insert(data, v)
		end
	end
	return data
end

function FishingData:GetStealGeneralInfo()
	return self.steal_general_info
end

function FishingData:SetShouFishRewardInfo(protocol)
	self.shou_fish_reward_info = protocol.reward_info
end

function FishingData:GetShouFishRewardInfo()
	return self.shou_fish_reward_info
end
function FishingData:GetSkipCfgByType(quality)
	for i,v in ipairs(self.skip_cfg) do
		if v.quality == quality then
			return v
		end
	end
end