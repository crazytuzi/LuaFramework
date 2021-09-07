GoldHuntData = GoldHuntData or BaseClass()

GOLD_HUNT_OPERA_TYPE =
{
	OPERA_TYPE_QUERY_INFO = 0,			-- 请求活动的信息
	OPERA_REFRESH = 1,					-- 换矿请求
	OPERA_GATHER = 2,					-- 挖矿请求
	OPERA_FETCH_SERVER_REWARD = 3,		-- 领取全服奖励请求
	OPERA_EXCHANGE_REWARD = 4,			-- 兑换锦囊
	OPERA_TYPE_MAX = 5,
}

GoldHuntData.GOLD_HUNT_ID = 2111--趣味挖矿编号为2111

function GoldHuntData:__init()
	if GoldHuntData.Instance then
		print_error("[GoldHuntData] Attemp to create a singleton twice !")
	end
	GoldHuntData.Instance = self
	self.hunt_info = {}
	self.open_day = -1
	self.other_cfg_index = 1 --其他配置中的索引(根据开服天数)
	self.open_day_event = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SetOpenDay, self))
	RemindManager.Instance:Register(RemindName.GOLDHUNT, BindTool.Bind(self.GetGoldHuntRemind, self))
end

function GoldHuntData:__delete()
	if self.open_day_event then
		GlobalEventSystem:UnBind(self.open_day_event)
		self.open_day_event = nil
	end
	RemindManager.Instance:UnRegister(RemindName.GOLDHUNT)
	GoldHuntData.Instance = nil
end

function GoldHuntData:SetOpenDay(open_day)
	self.open_day = open_day
	self.other_cfg_index = self:GetIndexByOpenDayFormOtherCfg(open_day)
end

function GoldHuntData:GetOpenDay()
	return self.open_day
end

function GoldHuntData:OnSCRAMineAllInfo(protocol)
	self.hunt_info.total_refresh_times = protocol.total_refresh_times               --全服刷矿次数
	self.hunt_info.role_refresh_times = protocol.role_refresh_times 				--玩家刷矿次数
	self.hunt_info.lover_refresh_times = protocol.lover_refresh_times
	self.hunt_info.free_gather_times = protocol.free_gather_times					--剩余免费挖次数
	self.hunt_info.next_refresh_time = protocol.next_refresh_time					--下一次系统自动刷矿时间
	self.hunt_info.reward_begin_index = protocol.reward_begin_index					--礼包领取起始下标
	self.hunt_info.reward_end_index = protocol.reward_end_index						--礼包领取结束下标
	self.hunt_info.gather_count_list = protocol.gather_count_list     				--当前挖到的矿石数 RA_MINE_MAX_TYPE_COUNT = 12
	self.hunt_info.mine_cur_type_list = protocol.mine_cur_type_list					--当前矿场的矿石,RA_MINE_MAX_REFRESH_COUNT = 8
	self.hunt_info.cur_reward_fetch_list = bit:d2b(protocol.cur_reward_fetch_flag)  --当前全服礼包领取标记
	self.hunt_info.person_hunt_count = 0  											--个人猎取次数
	for k,v in pairs(self.hunt_info.gather_count_list) do
		self.hunt_info.person_hunt_count = self.hunt_info.person_hunt_count + v
	end
end

function GoldHuntData:GetHuntInfo()
	return self.hunt_info
end

function GoldHuntData:GetActivityCfg()
	if self.active_cfg == nil then
		self.active_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	end
	return self.active_cfg
end

function GoldHuntData:GetRewardCfgList()
	local reward_cfg_list = self:GetActivityCfg().mine_reward
	local cfg = ActivityData.Instance:GetRandActivityConfig(reward_cfg_list, ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	return cfg
end

function GoldHuntData:GetRewardCfgCount()
	if self.reward_cfg_count == nil then
		self.reward_cfg_count = #self:GetRewardCfgList()
	end
	return self.reward_cfg_count
end

function GoldHuntData:GetHuntOtherCfg()
	if self.hunt_other_cfg == nil then
		self.hunt_other_cfg = self:GetActivityCfg().other
	end
	return self.hunt_other_cfg
end

--猎取信息配置
function GoldHuntData:GetHuntInfoCfg()
	local hunt_info_cfg = self:GetActivityCfg().mine_info
	local cfg = ActivityData.Instance:GetRandActivityConfig(hunt_info_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	return cfg
end

--猎取信息数量
function GoldHuntData:GetHuntInfoCfgCount()
	return #self:GetHuntInfoCfg()
end

--获得个人刷新最大次数
function GoldHuntData:GetPesonFlushCountCfg(index)
	return self:GetRewardCfgList()[index].total_refresh_times
end

--获得免费猎取最大次数
function GoldHuntData:GetMaxFreeHuntCountCfg()
	local other_cfg = self:GetHuntOtherCfg()
	if self.open_day == -1 then
		return other_cfg[1].mine_free_times
	end

	return other_cfg[self.other_cfg_index].mine_free_times
end

--获得猎取需要金额
function GoldHuntData:GetHuntPrice(type)
	local info_cfg = self:GetHuntInfoCfg()
	for k,v in ipairs(info_cfg) do
		if v.seq == type then
			return v.need_gold
		end
	end
	return 0
end

--获得猎物大小
function GoldHuntData:GetHuntScale(type)
	local info_cfg = self:GetHuntInfoCfg()
	for k,v in ipairs(info_cfg) do
		if v.seq == type then
			return v.scale
		end
	end
	return 1
end

function GoldHuntData:GetFlushPrice()
	local other_cfg = self:GetHuntOtherCfg()
	if self.open_day == -1 then
		return other_cfg[1].mine_free_times
	end
	return other_cfg[self.other_cfg_index].mine_refresh_gold
end

--通过open_days 返回other的索引
function GoldHuntData:GetIndexByOpenDayFormOtherCfg(open_day)
	local other_cfg = self:GetHuntOtherCfg()
	if open_day <= other_cfg[1].opengame_day then
		return 1
	end

	if open_day >= other_cfg[#other_cfg].opengame_day then
		return #other_cfg
	end

	for k,v in pairs(other_cfg) do
		if open_day < v.opengame_day then
			return k - 1
		end
	end

	return -1
end

function GoldHuntData:GetExchangeShowItems(index)
	local info_cfg = GoldHuntData.Instance:GetHuntInfoCfg()[index]
	if not info_cfg or not next(info_cfg) then
		return nil
	end
	local data = {}
	data.item_id = info_cfg.exchange_item.item_id
	data.num = info_cfg.exchange_item.num
	data.is_bind = info_cfg.exchange_item.is_bind
	return data
end

function GoldHuntData:GetFetchRewardFlag(seq)
	if not self.hunt_info.cur_reward_fetch_list then
		return 0
	end
	return self.hunt_info.cur_reward_fetch_list[32 - seq]
end

function GoldHuntData:GetIsCanRewardFlag(seq)
	local reward_cfg = self:GetRewardCfgList()

	local role_times =  self.hunt_info.role_refresh_times or 0
	local lover_times =  self.hunt_info.lover_refresh_times or 0
	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	local cru_vip = gamevo.vip_level
	local flag = role_times + lover_times >= reward_cfg[seq + 1].total_refresh_times and cru_vip >= seq + 1
	return (0 == self:GetFetchRewardFlag(seq) and flag)
end

function GoldHuntData:GetGoldHuntRemind()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	local remind_num = 0
	local reward_cfg = self:GetRewardCfgList()
	if self:CanExchange() then
		return 1
	end

	local role_times =  self.hunt_info.role_refresh_times or 0
	local lover_times =  self.hunt_info.lover_refresh_times or 0

	local gamevo = GameVoManager.Instance:GetMainRoleVo()
	local cru_vip = gamevo.vip_level

	for i,v in ipairs(reward_cfg) do
		 if is_open and role_times + lover_times >= v.total_refresh_times and 0 == self:GetFetchRewardFlag(i - 1) and cru_vip >= i then
		 	return 1 
		 end
	end
	return 0
end

function GoldHuntData:GetMineralInfo(index)
	local info_cfg = GoldHuntData.Instance:GetHuntInfoCfg()
	for i,v in ipairs(info_cfg) do
		if v.seq == index then
			return v.name
		end
	end
	return ""
end

function GoldHuntData:CanExchange()
	local info = self:GetHuntInfo().gather_count_list
	if not info then
		return
	end

	local exchang_cfg = self:GetHuntInfoCfg()
	for i,v in ipairs(exchang_cfg) do
		local count = info[i - 1]
		if count >= v.exchange_need_num then
			return true
		end
	end
	return false
end

function GoldHuntData:GetIsShowTip(type)
	local info_cfg = self:GetHuntInfoCfg()
	for k,v in ipairs(info_cfg) do
		if v.seq == type and v.is_broadcast == 1 then
			return true
		end
	end
	return false
end