-- Boss悬赏
SCRABossXuanshangInfo = SCRABossXuanshangInfo or BaseClass(BaseProtocolStruct)
function SCRABossXuanshangInfo:__init()
	self.msg_type = 8720
end

function SCRABossXuanshangInfo:Decode()
	self.cur_phase = MsgAdapter.ReadChar()							-- 当前阶段
	self.phase_can_reward_flag = MsgAdapter.ReadChar()				-- 阶段任务奖励可拿取标记
	MsgAdapter.ReadShort()		
	self.task_reward_flag_list = {}									-- 阶段任务奖励标记列表（奖励为1表示该任务已完成）			
	for i = 0, GameEnum.RA_BOSS_XUANSHANG_MAX_PHASE_NUM - 1 do
		self.task_reward_flag_list[i] = MsgAdapter.ReadInt()
	end
end

-- 充值大大回馈信息
SCChongzhidahuikuiInfo = SCChongzhidahuikuiInfo or BaseClass(BaseProtocolStruct)
function SCChongzhidahuikuiInfo:__init()
	self.msg_type = 8721
	self.is_first_chongzhi = 0
end

function SCChongzhidahuikuiInfo:Decode()
	self.is_first_chongzhi = MsgAdapter.ReadChar()						-- 是否第一次充值
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.chongzhi_num = MsgAdapter.ReadInt()							-- 充值金额
	self.fetch_flag = MsgAdapter.ReadInt()								-- 拿取标记
end

--战事目标
SCRAWarGoalInfo = SCRAWarGoalInfo or BaseClass(BaseProtocolStruct)
function SCRAWarGoalInfo:__init()
	self.msg_type = 8722
end

function SCRAWarGoalInfo:Decode()
	self.task_progress_list = {}
	local RA_WAR_GOAL_TYPE_MAX_NUM = 8 									--战事目标任务类型最大数
	for i=1,RA_WAR_GOAL_TYPE_MAX_NUM do
		self.task_progress_list[i] = MsgAdapter.ReadChar()				--任务进度标记
	end
	self.final_reward_can_fetch_flag = MsgAdapter.ReadChar()			--终极奖励可领取标记
	self.final_reward_fetch_flag = MsgAdapter.ReadChar()				--终极奖励领取标记
	self.task_fetch_reward_flag = MsgAdapter.ReadShort()				--已领取奖励标记
end

--每日国事
SCRADailyNationWarInfo = SCRADailyNationWarInfo or BaseClass(BaseProtocolStruct)
function SCRADailyNationWarInfo:__init()
	self.msg_type = 8723
end

function SCRADailyNationWarInfo:Decode()
	self.daily_nation_war_info_list = {}
	for i = 0, GameEnum.RA_DAILY_NATION_WAR_NUM_MAX do
		local data = {}
		data.param_1 = MsgAdapter.ReadShort()			--参数1：保存名次、职位等
		data.param_2 = MsgAdapter.ReadShort()			--特殊参数：在抢皇帝时记录输赢阵营信息
		data.is_fetch = MsgAdapter.ReadChar()			--是否已经拿取过奖励
		MsgAdapter.ReadChar()
		MsgAdapter.ReadShort()
		self.daily_nation_war_info_list[i] = data
	end
end


SCRAChujunGiftInfo = SCRAChujunGiftInfo or BaseClass(BaseProtocolStruct)
function SCRAChujunGiftInfo:__init()
	self.msg_type = 8724
end

function SCRAChujunGiftInfo:Decode()
	self.crown_prince_info_list = {}
	self.muster_timestamp_list = {}
	for i = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		local data = {}
		data.uid = MsgAdapter.ReadInt()									--储君玩家id
		data.next_invalid_timestamp = MsgAdapter.ReadUInt()				--下次开启时间
		data.is_complete_kill_boss = MsgAdapter.ReadChar()				--是否完成击杀boss，0未完成 1已完成
		data.is_fetch_kill_boss_reward = MsgAdapter.ReadChar()			--是否拿取击杀boss的奖励
		data.is_complete_kill_flag = MsgAdapter.ReadChar()				--是否完成国旗任务
		data.is_fetch_kill_flag_reward = MsgAdapter.ReadChar()			--国旗任务奖励是否领取
		self.crown_prince_info_list[i] = data
	end

	for i = 0, CAMP_TYPE.CAMP_TYPE_MAX - 1 do
		self.muster_timestamp_list[i] = MsgAdapter.ReadUInt()			--下次可召集时间戳列表
	end
end

------------------------- 升星助力 begin ------------------------------------
-- 升星助力的请求
CSGetShengxingzhuliInfoReq = CSGetShengxingzhuliInfoReq or BaseClass(BaseProtocolStruct)
function CSGetShengxingzhuliInfoReq:__init()
	self.msg_type = 8700
end

function CSGetShengxingzhuliInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 升星助力的回复
SCGetShengxingzhuliInfoAck = SCGetShengxingzhuliInfoAck or BaseClass(BaseProtocolStruct)
function SCGetShengxingzhuliInfoAck:__init()
	self.msg_type = 8701
end

function SCGetShengxingzhuliInfoAck:Decode()
	self.fetch_stall = MsgAdapter.ReadInt()									-- 是否已经领取今日份奖励
	self.chognzhi_today = MsgAdapter.ReadInt()								-- 今天氪的金
	self.func_level = MsgAdapter.ReadInt()									-- 对应系统的等级
	self.func_type = MsgAdapter.ReadInt()									-- 对应的系统
	self.is_max_level = MsgAdapter.ReadInt()								-- 对应系统是否最高级，0表示不是最高级,1表示是最高级
	self.max_stall = MsgAdapter.ReadInt()
end

-- 请求领取升星助力的奖励
CSGetShengxingzhuliRewardReq = CSGetShengxingzhuliRewardReq or BaseClass(BaseProtocolStruct)
function CSGetShengxingzhuliRewardReq:__init()
	self.msg_type = 8710
end

function CSGetShengxingzhuliRewardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


------------------直升丹---------------------------------
-- 购买信息
SCUpgradeCardBuyInfo =  SCUpgradeCardBuyInfo or BaseClass(BaseProtocolStruct)
function SCUpgradeCardBuyInfo:__init()
	self.msg_type = 8712
	self.activity_id = 0
	self.grade = 0 				-- 当前阶数
	self.is_already_buy = 0 	--  0 没有购  1已经购买
end

function SCUpgradeCardBuyInfo:Decode()
	self.activity_id = MsgAdapter.ReadShort()
	self.grade = MsgAdapter.ReadShort()
	self.is_already_buy = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
end

--购买请求
CSUpgradeCardBuyReq = CSUpgradeCardBuyReq or BaseClass(BaseProtocolStruct)
function CSUpgradeCardBuyReq:__init()
	self.msg_type = 8713
	self.activity_id = 0
	self.item_id = 0
end

function CSUpgradeCardBuyReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.activity_id)
	MsgAdapter.WriteUShort(self.item_id)
end

------------------------- 升星助力 end --------------------------------------
---------神格掌控--------------------
-- 神格操作请求
CSShengeSystemReq = CSShengeSystemReq or BaseClass(BaseProtocolStruct)
function CSShengeSystemReq:__init()
	self.msg_type = 8730
	self.info_type = 0
	self.param1 = 0
	self.param2 = 0
	self.param3 = 0
	self.param4 = 0
	self.index_count = 0
	self.virtual_index_list = {}
end

function CSShengeSystemReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.info_type)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
	MsgAdapter.WriteShort(self.param3)
	MsgAdapter.WriteUInt(self.param4)

	MsgAdapter.WriteInt(self.index_count)
	for i = 1, self.index_count do
		MsgAdapter.WriteInt(self.virtual_index_list[i])
	end
end

-- 神格信息
SCShengeSystemBagInfo = SCShengeSystemBagInfo or BaseClass(BaseProtocolStruct)
function SCShengeSystemBagInfo:__init()
	self.msg_type = 8731
end

function SCShengeSystemBagInfo:Decode()
	self.info_type = MsgAdapter.ReadChar()
	self.param1 = MsgAdapter.ReadChar()
	self.count = MsgAdapter.ReadShort()
	self.param3 = MsgAdapter.ReadUInt()

	self.bag_list = {}
	for i = 0, self.count - 1 do
		local vo = {}
		vo.quality = MsgAdapter.ReadChar()
		vo.type = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadUChar()
		vo.index = MsgAdapter.ReadUChar()
		self.bag_list[i] = vo
	end

end

--神格掌控
SCShengeZhangkongInfo = SCShengeZhangkongInfo or BaseClass(BaseProtocolStruct)
function SCShengeZhangkongInfo:__init()
	self.msg_type = 8732
end

function SCShengeZhangkongInfo:Decode()
	self.zhangkong_list = {}
	for i = 0, 3 do
		local zk = {}
		zk.level =  MsgAdapter.ReadInt()
		zk.exp = MsgAdapter.ReadInt()
		self.zhangkong_list[i] = zk
	end
end

-- 掌控升级信息
SCZhangkongUplevelAllInfo = SCZhangkongUplevelAllInfo or BaseClass(BaseProtocolStruct)
function SCZhangkongUplevelAllInfo:__init()
	self.msg_type = 8733
	self.count = 0
	self.item_list = {}
end

function SCZhangkongUplevelAllInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.item_list = {}

	for i = 1 , self.count do
		local data = {}
		data.grid = MsgAdapter.ReadInt()
		data.level = MsgAdapter.ReadInt()
		data.exp = MsgAdapter.ReadInt()
		data.add_exp = MsgAdapter.ReadInt()

		self.item_list[i] = data
	end
end
---------神格掌控 end--------------------

------------------------结婚礼金排行--------------------------------------------------
SCRAMarryGiftInfo = SCRAMarryGiftInfo or BaseClass(BaseProtocolStruct)
function SCRAMarryGiftInfo:__init()
	self.msg_type = 8725
	self.cur_place = 0
	self.self_rank_place = 0
end

function SCRAMarryGiftInfo:Decode()
	self.cur_place = MsgAdapter.ReadInt()
	self.self_rank_place = MsgAdapter.ReadInt()
end

-- 幻装商城
SCRAMagicShopAllInfo = SCRAMagicShopAllInfo or BaseClass(BaseProtocolStruct)
function SCRAMagicShopAllInfo:__init()
	self.msg_type = 8726

	self.magic_shop_fetch_reward_flag = 0
	self.magic_shop_buy_flag = 0
	self.activity_day = 0
	self.magic_shop_chongzhi_value = 0
end

function SCRAMagicShopAllInfo:Decode()
	self.magic_shop_fetch_reward_flag = MsgAdapter.ReadChar()
	self.magic_shop_buy_flag = MsgAdapter.ReadChar()
	self.activity_day = MsgAdapter.ReadShort()
	self.magic_shop_chongzhi_value = MsgAdapter.ReadUInt()
end

-----------------------------------神格神躯---------------------------------------
-- 神格神躯信息
SCShengeShenquAllInfo = SCShengeShenquAllInfo or BaseClass(BaseProtocolStruct)
function SCShengeShenquAllInfo:__init()
	self.msg_type = 8734
end

function SCShengeShenquAllInfo:Decode()
	self.shenqu_list = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM - 1 do
		local shenqu_attr = {}
		for j = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM do
			local attr_info = {}
			for p = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM do
				local vo = {}
				vo.qianghua_times = MsgAdapter.ReadShort()
				vo.attr_point = MsgAdapter.ReadShort()
				vo.attr_value = MsgAdapter.ReadInt()
				attr_info[p] = vo
			end
			shenqu_attr[j] = attr_info
		end
		self.shenqu_list[i] = shenqu_attr
	end
	self.shenqu_history_max_cap = {}
	for i = 0, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_MAX_NUM - 1 do
		self.shenqu_history_max_cap[i] = MsgAdapter.ReadInt()
	end
end

-- 单个神格神躯信息
SCShengeShenquInfo = SCShengeShenquInfo or BaseClass(BaseProtocolStruct)
function SCShengeShenquInfo:__init()
	self.msg_type = 8735
end

function SCShengeShenquInfo:Decode()
	self.shenqu_id = MsgAdapter.ReadInt()
	self.shenqu_attr = {}
	for j = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_ATTR_MAX_NUM do
		local attr_info = {}
		for p = 1, GameEnum.SHENGE_SYSTEM_SHENGESHENQU_XILIAN_SLOT_MAX_NUM do
			local vo = {}
			vo.qianghua_times = MsgAdapter.ReadShort()
			vo.attr_point = MsgAdapter.ReadShort()
			vo.attr_value = MsgAdapter.ReadInt()
			attr_info[p] = vo
		end
		self.shenqu_attr[j] = attr_info
	end
	self.shenqu_history_max_cap = MsgAdapter.ReadInt()
end

-----------------------------------神格神躯  END---------------------------------------

-----------------------------------------宝藏猎人\地图寻宝---------------------------
SCRAMapHuntAllInfo = SCRAMapHuntAllInfo or BaseClass(BaseProtocolStruct)
function SCRAMapHuntAllInfo:__init()
	self.msg_type = 8727
end

function SCRAMapHuntAllInfo:Decode()
	self.route_info ={}
	self.route_info.route_index = MsgAdapter.ReadChar()
	self.route_info.route_active_flag = MsgAdapter.ReadChar()
	self.route_info.reserve_sh = MsgAdapter.ReadShort()
	self.route_info.city_list = {}
	for i=1,3 do
		self.route_info.city_list[i] = MsgAdapter.ReadChar()
	end
	self.route_info.city_fetch_flag = MsgAdapter.ReadChar()
	self.flush_times = MsgAdapter.ReadInt()
	self.next_flush_timestamp = MsgAdapter.ReadUInt()
	self.return_reward_fetch_flag = MsgAdapter.ReadShort()
	self.free_count = MsgAdapter.ReadShort()
	self.can_extern_reward = MsgAdapter.ReadInt()
end

-----------------------------------------每日累充---------------------------
SCChongzhidahuikui2Info = SCChongzhidahuikui2Info or BaseClass(BaseProtocolStruct)
function SCChongzhidahuikui2Info:__init()
	self.msg_type = 8728
	self.chongzhi_num = 0
	self.fetch_flag = 0
end

function SCChongzhidahuikui2Info:Decode()
	self.reserve_ch_list ={}
	self.is_first_chongzhi = MsgAdapter.ReadChar()
	for i=1,3 do
		self.reserve_ch_list[i] = MsgAdapter.ReadChar()
	end
	self.chongzhi_num = MsgAdapter.ReadInt()
	self.fetch_flag = MsgAdapter.ReadUInt()
end

---------------------------------始皇武库
SCSuperDailyTotalChongzhiInfo = SCSuperDailyTotalChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCSuperDailyTotalChongzhiInfo:__init()
	self.msg_type = 8729

	self.daily_chongzhi_num = 0
	self.fetch_times_list = {}
end

function SCSuperDailyTotalChongzhiInfo:Decode()
	self.daily_chongzhi_num = MsgAdapter.ReadInt()
	self.fetch_times_list = {}
	for i = 0, COMMON_CONSTS.RA_SUPER_DAILY_TOTAL_CHONGZHI_SEQ_MAX - 1 do
		self.fetch_times_list[i] = MsgAdapter.ReadChar()
	end
end

------------------------中秋任务奖励面板------------------------------------
SCRAActiveTaskExchangeInfo = SCRAActiveTaskExchangeInfo or BaseClass(BaseProtocolStruct)
function SCRAActiveTaskExchangeInfo:__init()
	self.msg_type = 8736
	self.active_degree = 0
	self.fetch_reward_flag = 0
end

function SCRAActiveTaskExchangeInfo:Decode()
	self.active_degree = MsgAdapter.ReadInt()
	self.fetch_reward_flag = MsgAdapter.ReadInt()
end

--------------------------中秋物品兑换面板----------------------
SCRAActiveItemExchangeInfo =  SCRAActiveItemExchangeInfo or BaseClass(BaseProtocolStruct)
function  SCRAActiveItemExchangeInfo:__init()
	self.msg_type = 8737
	self.num_list = {}
end

function  SCRAActiveItemExchangeInfo:Decode()
	self.num_list = {}
	
	for i = 0, EXCHANGE_SHOP_NUM_MAX.TYPE -1 do
		self.num_list[i] = self.num_list[i] or {}
		for j = 0, EXCHANGE_SHOP_NUM_MAX.INDEX -1 do
			self.num_list[i][j] = self.num_list[i][j] or {}
			self.num_list[i][j][0] = MsgAdapter.ReadShort()
			self.num_list[i][j][1] = MsgAdapter.ReadShort()
		end
	end
end

SCRATotalCharge5Info = SCRATotalCharge5Info or BaseClass(BaseProtocolStruct)
function SCRATotalCharge5Info:__init()
	self.msg_type = 8738
	self.total_charge_value = 0
	self.reward_has_fetch_flag = 0
end

function SCRATotalCharge5Info:Decode()
	self.total_charge_value = MsgAdapter.ReadInt()
	self.reward_has_fetch_flag = MsgAdapter.ReadInt()
end

