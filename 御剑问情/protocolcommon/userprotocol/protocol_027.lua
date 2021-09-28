-- 结婚-婚宴 宾客祝福
SCHunyanGuestBless = SCHunyanGuestBless or BaseClass(BaseProtocolStruct)
function SCHunyanGuestBless:__init()
	self.msg_type = 2701

	self.uid = 0
	self.name = ""
	self.length = ""
	self.chat_msg = {}
end

function SCHunyanGuestBless:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStrN(32)
	self.length = MsgAdapter.ReadInt()
	self.chat_msg = MsgAdapter.ReadStrN(self.length)
end

--发送福利信息
SCWelfareInfo = SCWelfareInfo or BaseClass(BaseProtocolStruct)
function SCWelfareInfo:__init()
	self.msg_type = 2706
	self.sign_in_days = 0
end

function SCWelfareInfo.DailyFindRewardItem()
	local stu = {}
	stu.find_type = MsgAdapter.ReadShort()
	stu.role_level = MsgAdapter.ReadShort()
	stu.find_times = MsgAdapter.ReadShort()
	stu.reserve_sh = MsgAdapter.ReadShort()

	stu.exp = MsgAdapter.ReadLL()
	stu.bind_coin = MsgAdapter.ReadInt()
	stu.honor = MsgAdapter.ReadInt()
	stu.guild_gongxian = MsgAdapter.ReadInt()

	stu.gold_need = MsgAdapter.ReadInt()
	stu.coin_need = MsgAdapter.ReadInt()

	stu.item_count = MsgAdapter.ReadInt()
	stu.item_list = {}
	local ITEM_MAX_COUNT = 8
	for i = 1, ITEM_MAX_COUNT do
		local itemvo = {}
		itemvo.item_id = MsgAdapter.ReadUShort()
		itemvo.is_bind = MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		itemvo.num = MsgAdapter.ReadInt()
		if i <= stu.item_count then
			table.insert(stu.item_list, itemvo)
		end
	end
	return stu
end
function SCWelfareInfo:Decode()
	self.notify_reson = MsgAdapter.ReadInt()
	self.offline_timestamp = MsgAdapter.ReadInt()						-- 离线小时
	self.offline_exp = MsgAdapter.ReadLL()								-- 离线经验
	self.offline_mojing = MsgAdapter.ReadInt()							-- 离线魔晶
	local old_sign_flag = self.sign_in_days
	self.sign_in_days = MsgAdapter.ReadUInt()							-- 签到奖励标记
	self.change_sign_flag = self.sign_in_days - old_sign_flag
	self.sign_in_reward_mark = MsgAdapter.ReadUInt()						-- 签到奖励标记(无用)
	self.activity_find_flag = MsgAdapter.ReadUInt()						-- 活动找回标记
	self.activity_join_flag = MsgAdapter.ReadUInt()						-- 活动参与标记
	self.auto_activity_flag = MsgAdapter.ReadUInt()						-- 活动委托标记
	self.today_online_time = MsgAdapter.ReadUInt()						-- 在线时间
	self.old_online_reward_mark = self.online_reward_mark or 0			-- 记录原本的在线奖励标记
	self.online_reward_mark = MsgAdapter.ReadUInt()						-- 在线奖励标记
	self.chongzhi_flag = MsgAdapter.ReadChar()							-- 签到充值信息
	self.continuous_sign_in_days = MsgAdapter.ReadChar()				-- 连续签到
	self.sign_in_today_times = MsgAdapter.ReadChar()					-- 签到天数
	local list_num = MsgAdapter.ReadChar()
	self.happy_tree_level = MsgAdapter.ReadInt()

	self.happy_tree_growth_val_list = {}
	for i = 1, GameEnum.MAX_GROWTH_VALUE_GET_TYPE do
		if i <= list_num then
			self.happy_tree_growth_val_list[i] = MsgAdapter.ReadShort()
		else
			MsgAdapter.ReadShort()
		end
	end

	self.happy_tree_reward = MsgAdapter.ReadShort()
	self.chongjihaoli_reward_mark = MsgAdapter.ReadShort()				--冲击豪礼领取标记
	self.total_happy_tree_growth_val = MsgAdapter.ReadInt()
	self.accmulation_signin_days = MsgAdapter.ReadInt()					-- 累计签到天数


	local list_count = #(WelfareData.Instance:GetLevelRewardCfg())
	self.chongjihaoji_record_list = {}									--冲级豪礼全服剩余数量列表
	for i = 1, GameEnum.MAX_CHONGJIHAOLI_RECORD_COUNT do
		if i <= list_count then
			table.insert(self.chongjihaoji_record_list, MsgAdapter.ReadInt())
		else
			MsgAdapter.ReadInt()
		end
	end

	self.daily_find_count = MsgAdapter.ReadInt()
	self.daily_find_list = {}											-- 日常任务找回
	for i = 1, self.daily_find_count do
		local cell = SCWelfareInfo.DailyFindRewardItem()
		table.insert(self.daily_find_list, cell)
	end
end

--活跃度信息
SCActiveDegreeInfo = SCActiveDegreeInfo or BaseClass(BaseProtocolStruct)
function SCActiveDegreeInfo:__init()
	self.msg_type = 2707
	self.total_degree = 0
	self.reward_flags = {}
	self.degree_list = {}
end

function SCActiveDegreeInfo:Decode()
	local old_total_degree = self.total_degree
	self.total_degree = MsgAdapter.ReadInt()
	self.is_change = (self.total_degree - old_total_degree) > 0			--记录是否有改变

	self.activedegree_fetch_flag_low = MsgAdapter.ReadUInt()
	self.activedegree_fetch_flag_high = MsgAdapter.ReadUInt()

	self.reward_flags = {}
	for i = 1, COMMON_CONSTS.ACTIVEDEGREE_REWARD_ITEM_MAX_NUM do
		self.reward_flags[i] = MsgAdapter.ReadChar()  -- 0 未领取 1.已领取
	end

	self.degree_list = {}
	for i = 0, (COMMON_CONSTS.ACTIVEDEGREE_MAX_TYPE - 1) do
		self.degree_list[i] = MsgAdapter.ReadChar()
	end

	self.reward_on_day_flag_list = {}
	for i = 1, 8 do
		self.reward_on_day_flag_list[i] = MsgAdapter.ReadChar()
	end
end

--开服活动信息下发
SCOpenGameActivityInfo = SCOpenGameActivityInfo or BaseClass(BaseProtocolStruct)
function SCOpenGameActivityInfo:__init()
	self.msg_type = 2718
end

function SCOpenGameActivityInfo:Decode()
	-- self.open_act_vo = {}
	-- self.open_act_vo.oga_chongzhi_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_xiannv_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_mount_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_stone_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_tuan_monthcard_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_tuan_vip_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_tuan_xunbao_reward_flag = MsgAdapter.ReadInt()
	-- self.open_act_vo.oga_shen_fangju_reward_flag = MsgAdapter.ReadInt()

	-- self.open_act_vo.total_chongzhi = MsgAdapter.ReadInt()
	-- self.open_act_vo.total_xiannv_level = MsgAdapter.ReadInt()
	-- local actual_grade = MsgAdapter.ReadInt()
	-- local grade = ConfigManager.Instance:GetAutoConfig("mount_auto").grade[actual_grade] --坐骑实际阶数显示阶数不同，无比的蛋疼
	-- if nil ~= grade then
	-- 	self.open_act_vo.mount_grade = grade.show_grade
	-- end
	-- self.open_act_vo.total_stone_level = MsgAdapter.ReadInt()
	-- self.open_act_vo.tuan_monthcard_num = MsgAdapter.ReadInt()
	-- self.open_act_vo.tuan_xunbao_num = MsgAdapter.ReadInt()
	-- self.open_act_vo.guild_kill_world_count = MsgAdapter.ReadInt()
	-- self.open_act_vo.shen_fangju_count = MsgAdapter.ReadInt()

	-- self.open_act_vo.tuan_viplevel_numlist = {}
	-- local max_vip_lv = VipData.Instance:GetMaxVIPLevel()
	-- for i=0, max_vip_lv do
	-- 	local viplevel_num = MsgAdapter.ReadInt()
	-- 	if i >= 1 then
	-- 		table.insert(self.open_act_vo.tuan_viplevel_numlist, viplevel_num)
	-- 	end
	-- end

----------------------------------------use down
	self.open_act_vo = {}
	self.open_act_vo.oga_capability_reward_flag = MsgAdapter.ReadInt()		-- 战斗力奖励标记
	self.open_act_vo.oga_rolelevel_reward_flag = MsgAdapter.ReadInt()		--开服活动 等级奖励领取标记
	self.open_act_vo.oga_puton_equipment_reward_flag = MsgAdapter.ReadInt() --装备收集奖励标记
	self.open_act_vo.oga_buy_equipmentgift_flag = MsgAdapter.ReadInt()		--购买装备礼包标记

	-- self.open_act_vo.oga_kill_boss_reward_flag = MsgAdapter.ReadInt()		-- 开服活动 杀BOSS奖励标记
	-- self.open_act_vo.oga_kill_boss_flag = MsgAdapter.ReadLL()				-- 开服活动 杀boss标记

	self.open_act_vo.total_chongzhi = MsgAdapter.ReadInt()					--累计充值数
	self.open_act_vo.puton_equipment_act_flag = MsgAdapter.ReadInt()		--装备收集激活标记

	self.open_act_vo.oga_putonequipment_fetch_times = {}	--全服收集装备领取奖励数量
	for i=0,31 do
		self.open_act_vo.oga_putonequipment_fetch_times[i] = MsgAdapter.ReadShort()
	end

	self.open_act_vo.oga_capability_fetch_times = {}		--全服战力冲刺领取奖励数量
	for i=0,31 do
		self.open_act_vo.oga_capability_fetch_times[i] = MsgAdapter.ReadShort()
	end

	self.open_act_vo.oga_rolelevel_fetch_times = {}			--全服等级冲刺领取奖励数量
	for i=0,31 do
		self.open_act_vo.oga_rolelevel_fetch_times[i] = MsgAdapter.ReadShort()
	end
end

-- 投资计划
SCTouZiJiHuaInfo = SCTouZiJiHuaInfo or BaseClass(BaseProtocolStruct)
function SCTouZiJiHuaInfo:__init()
	self.msg_type = 2720
	self.active_plan_0 = 0
	self.active_plan_1 = 0
	self.active_plan_2 = 0
	self.new_plan_first_reward_flag = 0
	self.plan_0_reward_flag = 0
	self.plan_1_reward_flag = 0
	self.plan_2_reward_flag = 0
	self.active_highest_plan = -1

	self.buy_time = 0
	self.reward_flag = 0
	self.vip_reward_flag = 0
	self.reward_gold_bind_flag = 0
	self.list_len = 0
	self.foundation_reward_times = {}
end

function SCTouZiJiHuaInfo:Decode()
	self.foundation_reward_times = {}
	self.active_plan_0 = MsgAdapter.ReadChar()
	self.active_plan_1 = MsgAdapter.ReadChar()
	self.active_plan_2 = MsgAdapter.ReadChar()
	self.new_plan_first_reward_flag = MsgAdapter.ReadChar()
	self.plan_0_reward_flag = MsgAdapter.ReadShort()
	self.plan_1_reward_flag = MsgAdapter.ReadShort()
	self.plan_2_reward_flag = MsgAdapter.ReadShort()
	self.active_highest_plan = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()

	self.buy_time = MsgAdapter.ReadUInt() 			--月卡投资购买时间
	self.reward_flag = MsgAdapter.ReadInt() 		--普通奖励标记
	self.vip_reward_flag = MsgAdapter.ReadInt() 	--vip奖励标记
	self.reward_gold_bind_flag = MsgAdapter.ReadInt() --月卡投资奖励标志

	self.list_len = MsgAdapter.ReadInt()
	for i = 1, 12 do
		if self.list_len >= i then
			self.foundation_reward_times[i] = MsgAdapter.ReadChar()
		else
			MsgAdapter.ReadChar()
		end
	end
end

SCTotalLoginDays = SCTotalLoginDays or BaseClass(BaseProtocolStruct)
function SCTotalLoginDays:__init()
	self.msg_type = 2727
	self.total_login_day = 0
end

function SCTotalLoginDays:Decode()
	self.total_login_day = MsgAdapter.ReadInt()
end

--称号拥有者信息
SCTitleOwnerInfo = SCTitleOwnerInfo or BaseClass(BaseProtocolStruct)
function SCTitleOwnerInfo:__init()
	self.msg_type = 2728
	self.xianjiezhizhun_owner_uid = 0
	self.xianjiezhizhun_owner_name = ""
	self.junlintianxia_owner_uid = 0
	self.junlintianxia_owner_name = ""
	self.qingshihongyan_owner_uid = 0
	self.qingshihongyan_owner_name = ""
	self.fengliutitang_owner_uid = 0
	self.fengliutitang_owner_name = ""
	self.guosetianxiang_owner_uid = 0
	self.guosetianxiang_owner_name = ""
	self.kunlunzhanshen_owner_uid = 0
	self.kunlunzhanshen_owner_name = ""
	self.penglaizhanshen_owner_uid = 0
	self.penglaizhanshen_owner_name = ""
	self.cangqiongzhanshen_owner_uid = 0
	self.cangqiongzhanshen_owner_name = ""
	self.wangchengchengzhu_owner_uid = 0
	self.wangchengchengzhu_owner_name = ""
	self.zuiqiangxianmeng_owner_uid = 0
	self.zuiqiangxianmeng_owner_name = ""
	self.weizhencangqiong_onwer_uid = 0
	self.weizhencangqiong_owner_name = ""
	self.bosshunter_owner_uid = 0
	self.bosshunter_owner_name = ""
	self.tianxiawushuang_owner_uid = 0
	self.tianxiawushuang_owner_name = ""
	self.xiongbatianxia_owner_uid = 0
	self.xiongbatianxia_owner_name = ""
end

function SCTitleOwnerInfo:Decode()
	self.xianjiezhizhun_owner_uid = MsgAdapter.ReadInt()
	self.xianjiezhizhun_owner_name = MsgAdapter.ReadStrN(32)
	self.junlintianxia_owner_uid = MsgAdapter.ReadInt()
	self.junlintianxia_owner_name = MsgAdapter.ReadStrN(32)
	self.qingshihongyan_owner_uid = MsgAdapter.ReadInt()
	self.qingshihongyan_owner_name = MsgAdapter.ReadStrN(32)
	self.fengliutitang_owner_uid = MsgAdapter.ReadInt()
	self.fengliutitang_owner_name = MsgAdapter.ReadStrN(32)
	self.guosetianxiang_owner_uid = MsgAdapter.ReadInt()
	self.guosetianxiang_owner_name = MsgAdapter.ReadStrN(32)
	self.kunlunzhanshen_owner_uid = MsgAdapter.ReadInt()
	self.kunlunzhanshen_owner_name = MsgAdapter.ReadStrN(32)
	self.penglaizhanshen_owner_uid = MsgAdapter.ReadInt()
	self.penglaizhanshen_owner_name = MsgAdapter.ReadStrN(32)
	self.cangqiongzhanshen_owner_uid = MsgAdapter.ReadInt()
	self.cangqiongzhanshen_owner_name = MsgAdapter.ReadStrN(32)
	self.wangchengchengzhu_owner_uid = MsgAdapter.ReadInt()
	self.wangchengchengzhu_owner_name = MsgAdapter.ReadStrN(32)
	self.zuiqiangxianmeng_owner_uid = MsgAdapter.ReadInt()
	self.zuiqiangxianmeng_owner_name = MsgAdapter.ReadStrN(32)
	self.weizhencangqiong_onwer_uid = MsgAdapter.ReadInt()
	self.weizhencangqiong_owner_name = MsgAdapter.ReadStrN(32)
	self.bosshunter_owner_uid = MsgAdapter.ReadInt()
	self.bosshunter_owner_name = MsgAdapter.ReadStrN(32)
	self.tianxiawushuang_owner_uid = MsgAdapter.ReadInt()
	self.tianxiawushuang_owner_name = MsgAdapter.ReadStrN(32)
	self.xiongbatianxia_owner_uid = MsgAdapter.ReadInt()
	self.xiongbatianxia_owner_name = MsgAdapter.ReadStrN(32)
end

-- 结婚者进入场景
SCSpecialParamChange = SCSpecialParamChange or BaseClass(BaseProtocolStruct)
function SCSpecialParamChange:__init()
	self.msg_type = 2729
	self.obj_id = 0
	self.reserve_sh = 0
	self.param = 0
end

function SCSpecialParamChange:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.reserve_sh = MsgAdapter.ReadShort()
	self.param = MsgAdapter.ReadInt()
end

-- 发起求婚
CSMarryReq = CSMarryReq or BaseClass(BaseProtocolStruct)
function CSMarryReq:__init()
	self.msg_type = 2778
	self.marry_type = 0
	self.target_uid = 0
end

function CSMarryReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.marry_type)
	MsgAdapter.WriteUInt(self.target_uid)
end

-- 求婚回复
CSMarryRet = CSMarryRet or BaseClass(BaseProtocolStruct)
function CSMarryRet:__init()
	self.msg_type = 2779

	self.marry_type = 0
	self.req_uid = 0
	self.is_accept = 0
end

function CSMarryRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.marry_type)
	MsgAdapter.WriteInt(self.req_uid)
	MsgAdapter.WriteInt(self.is_accept)
end

-- 投资奖励领取
CSFetchTouZiJiHuaReward = CSFetchTouZiJiHuaReward or BaseClass(BaseProtocolStruct)
function CSFetchTouZiJiHuaReward:__init()
	self.msg_type = 2780
	self.plan_type = 0
	self.seq = 0
end

function CSFetchTouZiJiHuaReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.plan_type)
	MsgAdapter.WriteShort(self.seq)
end

--投资计划投资
CSTouzijihuaActive = CSTouzijihuaActive or BaseClass(BaseProtocolStruct)
function CSTouzijihuaActive:__init()
	self.msg_type = 2786
	self.plan_type = 0
	self.reserve_sh = 0
end

function CSTouzijihuaActive:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.plan_type)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--新投资计划投资
CSNewTouzijihuaOperate = CSNewTouzijihuaOperate or BaseClass(BaseProtocolStruct)
function CSNewTouzijihuaOperate:__init()
	self.msg_type = 2787
	self.operate_type = 0
	self.param = 0
end

function CSNewTouzijihuaOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.operate_type)
	MsgAdapter.WriteShort(self.param)
end

--发送小喇叭
CSSpeaker = CSSpeaker or BaseClass(BaseProtocolStruct)
function CSSpeaker:__init()
	self.msg_type = 2750
	self.content_type = 0
	self.speaker_type = 0
	self.is_auto_buy = 0
	self.speaker_msg = ""
end

function CSSpeaker:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.content_type)
	MsgAdapter.WriteChar(self.speaker_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.is_auto_buy)
	MsgAdapter.WriteStr(self.speaker_msg)
end

--获取离线经验
CSGetOfflineExp = CSGetOfflineExp or BaseClass(BaseProtocolStruct)
function CSGetOfflineExp:__init()
	self.msg_type = 2751
	self.type = 0											-- 获取类型 DAILYFIND_GET_TYPE
end

function CSGetOfflineExp:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.type)
end

--补给信息返回
SCSupplyInfo = SCSupplyInfo or BaseClass(BaseProtocolStruct)
function SCSupplyInfo:__init()
	self.msg_type = 2726
	self.supply_type_max = 2
end

function SCSupplyInfo:Decode()
	self.supply_list = {}
	for i=1, self.supply_type_max do
		self.supply_list[i] = {}
		self.supply_list[i].supply_left_value = MsgAdapter.ReadInt()
		self.supply_list[i].supply_range_per = MsgAdapter.ReadInt()
	end
end

--vip等级奖励礼包领取请求
CSFetchVipLevelReward = CSFetchVipLevelReward or BaseClass(BaseProtocolStruct)
function CSFetchVipLevelReward:__init()
	self.msg_type = 2769
	self.seq = 0
end

function CSFetchVipLevelReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.seq)
	MsgAdapter.WriteShort(0)
end

--vip周奖励礼包领取请求
CSFetchVipWeekReward = CSFetchVipWeekReward or BaseClass(BaseProtocolStruct)
function CSFetchVipWeekReward:__init()
	self.msg_type = 6615
end

function CSFetchVipWeekReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--评价别人(点赞)
CSEvaluateRole = CSEvaluateRole or BaseClass(BaseProtocolStruct)
function CSEvaluateRole:__init()
	self.msg_type = 2771
	self.uid = 0
	self.rank_type = 0
	self.reserve_sh = 0
end

function CSEvaluateRole:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.uid)
	MsgAdapter.WriteShort(self.rank_type)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--请求服务器购买气血和体力
CSSupplyBuyItem = CSSupplyBuyItem or BaseClass(BaseProtocolStruct)
function CSSupplyBuyItem:__init()
	self.msg_type = 2772
	self.supply_type = 0
	self.index = 0
	self.is_use_no_bind_gold = 0
	self.reserver_1 = 0
	self.reserve_2 = 0
end

function CSSupplyBuyItem:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.supply_type)
	MsgAdapter.WriteInt(self.index)
	MsgAdapter.WriteInt(self.is_use_no_bind_gold)
	MsgAdapter.WriteInt(self.reserver_1)
	MsgAdapter.WriteInt(self.reserve_2)
end

--请求服务器修改自动补给百分比
CSSupplySetRecoverRangePer = CSSupplySetRecoverRangePer or BaseClass(BaseProtocolStruct)
function CSSupplySetRecoverRangePer:__init()
	self.msg_type = 2773
	self.supply_type = 0
	self.recover_range_per = 0
end

function CSSupplySetRecoverRangePer:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.supply_type)
	MsgAdapter.WriteInt(self.recover_range_per)
end

--请求领取签到奖励 2756
CSWelfareSignInReward = CSWelfareSignInReward or BaseClass(BaseProtocolStruct)

function CSWelfareSignInReward:__init()
	self.msg_type = 2756
	self.request_type = 0
	self.part = 0
	self.is_quick_sign = 0
end

function CSWelfareSignInReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.request_type)
	MsgAdapter.WriteShort(self.part)
	MsgAdapter.WriteInt(self.is_quick_sign)				--是否一键补签
end

--签到找回 2757
CSWelfareSignInFindBack = CSWelfareSignInFindBack or BaseClass(BaseProtocolStruct)

function CSWelfareSignInFindBack:__init()
	self.msg_type = 2757
	self.day = 0
	self.reserve_sh = 0
end

function CSWelfareSignInFindBack:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.day)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--领取福利升级奖励
CSWelfareUplevelReward = CSWelfareUplevelReward or BaseClass(BaseProtocolStruct)
function CSWelfareUplevelReward:__init()
	self.msg_type = 2755
	self.seq = 0
	self.reserve_sh = 0
end

function CSWelfareUplevelReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.seq)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--领取七天登录活动奖励 2754
CSFetchSevenDayLoginReward = CSFetchSevenDayLoginReward or BaseClass(BaseProtocolStruct)

function CSFetchSevenDayLoginReward:__init()
	self.msg_type = 2754
	self.fetch_day = -1
end

function CSFetchSevenDayLoginReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.fetch_day)
end

--七天登录奖励信息 2721
SCSevenDayLoginRewardInfo = SCSevenDayLoginRewardInfo or BaseClass(BaseProtocolStruct)

function SCSevenDayLoginRewardInfo:__init()
	self.msg_type = 2721
end

function SCSevenDayLoginRewardInfo:Decode()
	self.notify_reason = MsgAdapter.ReadInt()						-- 通知原因(1、领取了七天登录奖励)
	self.account_total_login_daycount = MsgAdapter.ReadInt()		-- 一生累计登录天数
	self.seven_day_login_fetch_reward_mark = MsgAdapter.ReadInt()	-- 七天累计登录奖励领取标记
end

--领取活跃度奖励
CSActiveFetchReward = CSActiveFetchReward or BaseClass(BaseProtocolStruct)
function CSActiveFetchReward:__init()
	self.msg_type = 2767
end

function CSActiveFetchReward:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.operate_type)
	MsgAdapter.WriteInt(self.param)
end

--领取日常找回
CSGetDailyFindWelfare = CSGetDailyFindWelfare or BaseClass(BaseProtocolStruct)
function CSGetDailyFindWelfare:__init()
	self.msg_type = 2753
	self.dailyfind_type = 0
	self.get_type = 0
	self.reserved = 0
end

function CSGetDailyFindWelfare:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteChar(self.dailyfind_type)
	MsgAdapter.WriteChar(self.get_type)
	MsgAdapter.WriteShort(self.reserved)
end

-- 日常找回单项变更
SCDailyFindItemChange = SCDailyFindItemChange or BaseClass(BaseProtocolStruct)
function SCDailyFindItemChange:__init()
	self.msg_type = 2711

	self.dailyfind_type = 0
	self.result = 0
	self.reserved = 0
end

function SCDailyFindItemChange:Decode()
	self.dailyfind_type = MsgAdapter.ReadChar()
	self.result = MsgAdapter.ReadChar()
	self.reserved = MsgAdapter.ReadShort()
end

--请求活动找回
CSWelfareActivityFind = CSWelfareActivityFind or BaseClass(BaseProtocolStruct)
function CSWelfareActivityFind:__init()
	self.msg_type = 2758
	self.find_type = 0
	self.is_free = 0 				--1是， 0否
	self.reserve_ch = 0
end

function CSWelfareActivityFind:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.find_type)
	MsgAdapter.WriteChar(self.is_free)
	MsgAdapter.WriteChar(self.reserve_ch)
end

-- 请求请求称号拥有者信息
CSTitleOwnerInfoReq = CSTitleOwnerInfoReq or BaseClass(BaseProtocolStruct)
function CSTitleOwnerInfoReq:__init()
	self.msg_type = 2781
end

function CSTitleOwnerInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求婚宴祝福
CSMarryHunyanBless = CSMarryHunyanBless or BaseClass(BaseProtocolStruct)
function CSMarryHunyanBless:__init()
	self.msg_type = 2783
	self.merry_uid = 0
	self.zhufu_type = 0
	self.contenttxt_len = 0
	self.contenttxt = ""
end

function CSMarryHunyanBless:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.merry_uid)
	MsgAdapter.WriteInt(self.zhufu_type)
	MsgAdapter.WriteInt(self.contenttxt_len)
	MsgAdapter.WriteStr(self.contenttxt)
end

-- 结婚婚宴操作请求
CSMarryHunyanOpera = CSMarryHunyanOpera or BaseClass(BaseProtocolStruct)
function CSMarryHunyanOpera:__init()
	self.msg_type = 2782
	self.opera_type = 0
	self.opera_param = 0
	self.invited_uid = 0
	self.content = ""
	self.opera_param1 = 0
	self.opera_param2 = 0
end

function CSMarryHunyanOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.invited_uid)
	MsgAdapter.WriteInt(self.opera_param)
	MsgAdapter.WriteInt(self.opera_param1)
	MsgAdapter.WriteInt(self.opera_param2)
	MsgAdapter.WriteStrN(self.content, self.opera_param)
end

-- 结婚进入婚宴
CSJoinHunyan = CSJoinHunyan or BaseClass(BaseProtocolStruct)
function CSJoinHunyan:__init()
	self.msg_type = 2784
	self.fb_key = 0
end

function CSJoinHunyan:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.fb_key)
end

--------修炼

MENTALITY_TYPE_MAX = 7

-- 收到所有元神信息
SCMentalityList = SCMentalityList or BaseClass(BaseProtocolStruct)
function SCMentalityList:__init()
	self.msg_type = 2700

	self.cd_next_time = 0
	self.curr_train_type = 0
	self.is_clear_cd = 0
	self.reserved_sh = 0
	self.mentality_list = {}
	self.wuxing_level_list = {}
end

function SCMentalityList:Decode()
	self.cd_next_time = MsgAdapter.ReadUInt()
	self.curr_train_type = MsgAdapter.ReadInt()
	self.is_clear_cd = MsgAdapter.ReadShort()
	self.reserved_sh = MsgAdapter.ReadShort()
	self.mentality_list = {}
	for i = 1, MENTALITY_TYPE_MAX do
		local mentality_info = {}
		mentality_info.mentality_level = MsgAdapter.ReadShort()		--元神列表
		mentality_info.gengu_level = MsgAdapter.ReadShort()
		mentality_info.gengu_max_level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		table.insert(self.mentality_list, mentality_info)
	end
	for i = 1, 5 do
		MsgAdapter.ReadShort()
	end
	for i = 0, GameEnum.MENTALITY_WUXING_MAX_COUNT - 1 do
		self.wuxing_level_list[i] = MsgAdapter.ReadShort()		--五行等级
	end
	self.shuxingdan_list = {}
	for i = 0, GameEnum.MENTALITY_SHUXINGDAN_MAX_TYPE - 1 do
		self.shuxingdan_list[i] = MsgAdapter.ReadUInt()
	end
end

-- 一键提升响应
SCMentalityYijianTishengAck = SCMentalityYijianTishengAck or BaseClass(BaseProtocolStruct)
function SCMentalityYijianTishengAck:__init()
	self.msg_type = 2714
	self.tisheng_count = 0
end

function SCMentalityYijianTishengAck:Decode()
	self.tisheng_count = MsgAdapter.ReadInt()
end

-- 修炼元神请求
CSTrainMentality = CSTrainMentality or BaseClass(BaseProtocolStruct)
function CSTrainMentality:__init()
	self.msg_type = 2760
end

function CSTrainMentality:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--永久消除修炼CD请求
CSSpeedUpMentalityTrain = CSSpeedUpMentalityTrain or BaseClass(BaseProtocolStruct)
function CSSpeedUpMentalityTrain:__init()
	self.msg_type = 2762
end

function CSSpeedUpMentalityTrain:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--一键提升请求
CSMentalityYijianTisheng = CSMentalityYijianTisheng or BaseClass(BaseProtocolStruct)
function CSMentalityYijianTisheng:__init()
	self.msg_type = 2774
end

function CSMentalityYijianTisheng:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--  升级根骨
CSUpgradeMentalityGengu = CSUpgradeMentalityGengu or BaseClass(BaseProtocolStruct)
function CSUpgradeMentalityGengu:__init()
	self.msg_type = 2761
	self.type = 0
	self.use_protect_item = 0
	self.is_auto_buy = 0
end

function CSUpgradeMentalityGengu:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteInt(self.use_protect_item)
	MsgAdapter.WriteInt(self.is_auto_buy)
end

--请求清除当前CD
CSMentalityClearTrainCD = CSMentalityClearTrainCD or BaseClass(BaseProtocolStruct)
function CSMentalityClearTrainCD:__init()
	self.msg_type = 2777
end

function CSMentalityClearTrainCD:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


--仙尊卡
CSXianZunKaOperaReq = CSXianZunKaOperaReq or BaseClass(BaseProtocolStruct)
function CSXianZunKaOperaReq:__init()
	self.msg_type = 2731
end

function CSXianZunKaOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_req_type)
	MsgAdapter.WriteShort(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
end

-- 仙尊卡返回
SCXianZunKaAllInfo = SCXianZunKaAllInfo or BaseClass(BaseProtocolStruct)
function SCXianZunKaAllInfo:__init()
	self.msg_type = 2732
	self.forever_active_flag = 0
	self.first_active_reward_flag = 0
	self.daily_reward_fetch_flag = 0
	self.temporary_valid_end_timestamp_list = {}
end

function SCXianZunKaAllInfo:Decode()
	self.forever_active_flag = MsgAdapter.ReadShort()
	self.first_active_reward_flag = MsgAdapter.ReadChar()
	self.daily_reward_fetch_flag = MsgAdapter.ReadChar()
	self.temporary_valid_end_timestamp_list = {}
	for i=0, XIANZUNKA_TYPE_MAX - 1 do
		self.temporary_valid_end_timestamp_list[i] = MsgAdapter.ReadUInt()
	end
end


-------------------------------------黄金会员---------------------------------------------
--2730黄金会员操作请求
CSGoldVipOperaReq = CSGoldVipOperaReq or BaseClass(BaseProtocolStruct)
function CSGoldVipOperaReq:__init()
	self.msg_type = 2730
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSGoldVipOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.opera_type)
	MsgAdapter.WriteShort(0)
	MsgAdapter.WriteShort(self.param1)
	MsgAdapter.WriteShort(self.param2)
end


-- 2451黄金会员信息返回
SCGoldVipInfo = SCGoldVipInfo or BaseClass(BaseProtocolStruct)
function SCGoldVipInfo:__init()
	self.msg_type = 2451
	self.gold_vip_shop_counts_list = {}
	self.gold_vip_active_timestamp = 0
	self.day_score = 0
	self.shop_active_grade_flag = 0
	self.can_fetch_return_reward = 0
	self.is_not_first_fetch_return_reward = 0
end

function SCGoldVipInfo:Decode()
	for i=1,16 do
		self.gold_vip_shop_counts_list[i] = MsgAdapter.ReadChar()
	end
	self.gold_vip_active_timestamp = MsgAdapter.ReadUInt()	-- 激活时间戳
	self.day_score = MsgAdapter.ReadInt()					-- 每日积分
	self.shop_active_grade_flag = MsgAdapter.ReadChar()		-- 商店激活档次标记
	self.can_fetch_return_reward = MsgAdapter.ReadChar()	-- 能否领取返还奖励
	self.is_not_first_fetch_return_reward = MsgAdapter.ReadChar()	-- 是否不是第一次领取返还奖励
	MsgAdapter.ReadChar()
end