

--挂机场景中有多少个BOSS处于已刷新状态
SCGuajiBossCount  = SCGuajiBossCount  or BaseClass(BaseProtocolStruct)
function SCGuajiBossCount:__init()
	self.msg_type = 8510
end

function SCGuajiBossCount:Decode()
	self.boss_count_list = {}
	for i = 1, GameEnum.GUAJI_SCENE_COUNT do
		self.boss_count_list[i] = MsgAdapter.ReadShort()		--挂机Boss个数
	end
	self.reserve_ch = MsgAdapter.ReadShort()
end

--请求挂机场景中BOSS状态
CSGetGuajiBossCount = CSGetGuajiBossCount or BaseClass(BaseProtocolStruct)
function CSGetGuajiBossCount:__init()
	self.msg_type = 8511
	self.scene_id_list = {}
	self.reserve_ch = 0
end

function CSGetGuajiBossCount:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	for i = 1, GameEnum.GUAJI_SCENE_COUNT do
		MsgAdapter.WriteShort(self.scene_id_list[i])
	end
	MsgAdapter.WriteShort(self.reserve_ch)
end

--挂机场景中适合自己挂机的地图BOSS处于已刷新状态
SCGuajiBossRefresh  = SCGuajiBossRefresh  or BaseClass(BaseProtocolStruct)
function SCGuajiBossRefresh:__init()
	self.msg_type = 8513
end

function SCGuajiBossRefresh:Decode()
 	self.scene_id = MsgAdapter.ReadShort()
 	self.boss_id = MsgAdapter.ReadUShort()
end

-- 护国之力数据
SCHuguozhiliInfo = SCHuguozhiliInfo or BaseClass(BaseProtocolStruct)
function SCHuguozhiliInfo:__init()
	self.msg_type = 8514
end

function SCHuguozhiliInfo:Decode()
	self.today_die_times = MsgAdapter.ReadInt()
	self.today_active_times = MsgAdapter.ReadInt()
	self.active_buff_timestamp = MsgAdapter.ReadUInt()
end

-- 请求使用护国之力
CSHuguozhiliReq = CSHuguozhiliReq or BaseClass(BaseProtocolStruct)
function CSHuguozhiliReq:__init()
	self.msg_type = 8515
	self.opera_type = 0
end

function CSHuguozhiliReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
end

------------------------------- 神器 begin -------------------------
-- 请求神兵和宝甲操作类型
CSShenqiOperaReq = CSShenqiOperaReq or BaseClass(BaseProtocolStruct)
function CSShenqiOperaReq:__init()
	self.msg_type = 8530
end

function CSShenqiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
	MsgAdapter.WriteInt(self.param_2)
	MsgAdapter.WriteInt(self.param_3)
end

-- 返回神器所有信息
SCShenqiAllInfo = SCShenqiAllInfo or BaseClass(BaseProtocolStruct)
function SCShenqiAllInfo:__init()
	self.msg_type = 8535
end

function SCShenqiAllInfo:Decode()
	self.shenbing_image_flag_low = MsgAdapter.ReadUInt() or 0			-- 神兵形象激活标记
	self.shenbing_image_flag_high = MsgAdapter.ReadUInt() or 0			-- 神兵形象激活标记
	self.shenbing_texiao_flag_low = MsgAdapter.ReadUInt() or 0			-- 神兵特效激活标记
	self.shenbing_texiao_flag_high = MsgAdapter.ReadUInt() or 0			-- 神兵特效激活标记
	self.baojia_image_flag_low = MsgAdapter.ReadUInt() or 0			-- 宝甲形象激活标记
	self.baojia_image_flag_high = MsgAdapter.ReadUInt() or 0			-- 宝甲形象激活标记
	self.baojia_texiao_flag_low = MsgAdapter.ReadUInt() or 0			-- 宝甲特效激活标记
	self.baojia_texiao_flag_high = MsgAdapter.ReadUInt() or 0		-- 宝甲特效激活标记

	self.shenbing_cur_image_id = MsgAdapter.ReadChar()		-- 当前使用神兵形象id
	self.shenbing_cur_texiao_id = MsgAdapter.ReadChar()		-- 当前使用神兵特效id
	self.baojia_cur_image_id = MsgAdapter.ReadChar()		-- 当前使用宝甲形象id
	self.baojia_cur_texiao_id = MsgAdapter.ReadChar()		-- 当前使用宝甲特效id

	self.shenbing_list = {}									-- 神兵列表
	for i = 0,GameEnum.SHENQI_SUIT_NUM_MAX - 1 do 			-- 对应神兵的下标，总共64种神兵,SHENQI_SUIT_NUM_MAX = 64
		local vo = {}
		vo.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()

		vo.quality_list = {}								-- 神兵的部位的最大个数
		for j = 1, GameEnum.SHENQI_PART_TYPE_MAX do 	-- SHENQI_PART_TYPE_MAX = 4
			vo.quality_list[j] = MsgAdapter.ReadChar()
		end
		self.shenbing_list[i] = vo
	end
	-- table.remove(self.shenbing_list, 1)		--第一个不需要使用，直接从表内剔除

	self.baojia_list = {}									-- 宝甲列表
	for i = 0, GameEnum.SHENQI_SUIT_NUM_MAX - 1 do
		local vo = {}
		vo.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()

		vo.quality_list = {}
		for j = 1, GameEnum.SHENQI_PART_TYPE_MAX do
			vo.quality_list[j] = MsgAdapter.ReadChar()
		end
		self.baojia_list[i] = vo
	end
	-- table.remove(self.baojia_list, 1)		--第一个不需要使用，直接从表内剔除
end

-- 返回单个神器信息
SCShenqiSingleInfo = SCShenqiSingleInfo or BaseClass(BaseProtocolStruct)
function SCShenqiSingleInfo:__init()
	self.msg_type = 8536
end

function SCShenqiSingleInfo:Decode()
	self.info_type = MsgAdapter.ReadShort()						-- 神器信息类型
	self.item_index = MsgAdapter.ReadShort()					-- 神器信息对应下标

	self.shenqi_item = {}										-- 神器单个信息
	self.shenqi_item.level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.shenqi_item.exp = MsgAdapter.ReadInt()
	self.shenqi_item.quality_list = {}

	for i = 1, GameEnum.SHENQI_PART_TYPE_MAX do
		self.shenqi_item.quality_list[i] = MsgAdapter.ReadChar()
	end
end

 -- 神器特效信息
SCShenqiImageInfo = SCShenqiImageInfo or BaseClass(BaseProtocolStruct)
function SCShenqiImageInfo:__init()
	self.msg_type = 8537
end

function SCShenqiImageInfo:Decode()
	self.info_type = MsgAdapter.ReadShort()						-- 神器信息类型
	self.cur_use_imgage_id = MsgAdapter.ReadChar()				-- 当前使用形象id
	self.cur_use_texiao_id = MsgAdapter.ReadChar()				-- 当前使用特效id


	self.image_active_flag_low = MsgAdapter.ReadUInt()				-- 形象激活标记
	self.image_active_flag_high = MsgAdapter.ReadUInt()				-- 形象激活标记

	self.texiao_active_flag_low = MsgAdapter.ReadUInt()				-- 特效激活标记
	self.texiao_active_flag_high = MsgAdapter.ReadUInt()				-- 特效激活标记
end

-- 神器材料分解结果
SCShenqiDecomposeResult = SCShenqiDecomposeResult or BaseClass(BaseProtocolStruct)
function SCShenqiDecomposeResult:__init()
	self.msg_type = 8538
end

function SCShenqiDecomposeResult:Decode()
	self.item_count = MsgAdapter.ReadInt()

	self.item_list = {}
	for i = 1, self.item_count do
		local vo = {}
		vo.item_id = MsgAdapter.ReadInt()
		vo.num = MsgAdapter.ReadShort()
		vo.is_bind = MsgAdapter.ReadChar()
		vo.reserve_ch = MsgAdapter.ReadChar()
		self.item_list[i] = vo
	end
end

--------------------神器end-------------------------


--------------------------------------------------------------------------
-- 钓鱼通用请求
CSFishingOperaReq = CSFishingOperaReq or BaseClass(BaseProtocolStruct)
function CSFishingOperaReq:__init()
	self.msg_type = 9055
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSFishingOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 钓鱼用户信息
SCFishingUserInfo = SCFishingUserInfo or BaseClass(BaseProtocolStruct)
function SCFishingUserInfo:__init()
	self.msg_type = 9060
end

function SCFishingUserInfo:Decode()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))                -- 主角跨服id
	self.fishing_status = MsgAdapter.ReadChar()							-- 钓鱼状态


	self.special_status_flag = MsgAdapter.ReadUChar()					-- 特殊状态标记
	self.least_count_cfg_index = MsgAdapter.ReadChar()					-- 双倍积分配置索引
	self.is_fish_event = MsgAdapter.ReadChar()							-- 是否鱼上钩
	self.is_consumed_auto_fishing = MsgAdapter.ReadChar()				-- 是否消耗过元宝自动钓鱼
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.auto_pull_timestamp = MsgAdapter.ReadUInt()					-- 自动拉杆时间戳，没有触发事件则为0
	self.special_status_oil_end_timestamp = MsgAdapter.ReadUInt()		-- 特殊状态香油结束时间戳

	self.fish_num_list = {}												-- 当前钓上的各类鱼的数量
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list[i] = MsgAdapter.ReadInt()
	end

	self.gear_num_list = {}												-- 当前拥有的法宝数量
	for i = 1, GameEnum.FISHING_GEAR_MAX_COUNT do
		self.gear_num_list[i] = MsgAdapter.ReadInt()
	end

	self.steal_fish_count = MsgAdapter.ReadUInt()						-- 偷鱼次数
	self.be_stealed_fish_count = MsgAdapter.ReadUInt()					-- 被偷鱼次数
	self.buy_steal_count = MsgAdapter.ReadUInt()						-- 购买偷鱼次数

	self.news_count = MsgAdapter.ReadUInt()								-- 日志数量
	self.news_list = {}													-- 日志
	for i = 1, self.news_count do
		local vo = {}
		vo.news_type = MsgAdapter.ReadShort()							-- 钓鱼日志类型
		vo.fish_type = MsgAdapter.ReadShort()							-- 鱼种类
		vo.user_name = MsgAdapter.ReadStrN(32)							-- 玩家名字
		self.news_list[i] = vo
	end
end

-- 检查事件结果
SCFishingCheckEventResult = SCFishingCheckEventResult or BaseClass(BaseProtocolStruct)
function SCFishingCheckEventResult:__init()
	self.msg_type = 9061
end

function SCFishingCheckEventResult:Decode()
	self.event_type = MsgAdapter.ReadShort()
	self.param1 = MsgAdapter.ReadShort()
	self.param2 = MsgAdapter.ReadShort()
	self.param3 = MsgAdapter.ReadShort()

	-- 事件类型为EVENT_TYPE_GET_FISH：param1为鱼的类型，param2为鱼的数量
-- 		EVENT_TYPE_TREASURE,							// 破旧宝箱
-- 		EVENT_TYPE_YUWANG,								// 渔网
-- 		EVENT_TYPE_YUCHA,								// 渔叉
-- 		EVENT_TYPE_OIL,									// 香油
-- 		EVENT_TYPE_ROBBER,								// 盗贼
-- 		EVENT_TYPE_BIGFISH,								// 传说中的大鱼

	-- 事件类型为EVENT_TYPE_ROBBER: param1为被偷的鱼类型， param2为被偷数量
	-- 事件类型为EVENT_TYPE_BIGFISH: param1为的鱼类型， param2为数量
end

-- 钓鱼法宝使用结果
SCFishingGearUseResult = SCFishingGearUseResult or BaseClass(BaseProtocolStruct)
function SCFishingGearUseResult:__init()
	self.msg_type = 9062
end

function SCFishingGearUseResult:Decode()
	self.gear_type = MsgAdapter.ReadShort()								-- 使用法宝类型
	self.param1 = MsgAdapter.ReadShort()								-- 获得鱼的类型
	self.param2 = MsgAdapter.ReadShort()								-- 获得鱼的数量
	self.param3 = MsgAdapter.ReadShort()
end

SCFishingEventBigFish = SCFishingEventBigFish or BaseClass(BaseProtocolStruct)
function SCFishingEventBigFish:__init()
	self.msg_type = 9063
end

function SCFishingEventBigFish:Decode()
	self.owner_uid = MsgAdapter.ReadInt()								-- 拥有者role_id
end

-- 钓鱼队伍信息
SCFishingTeamMemberInfo = SCFishingTeamMemberInfo or BaseClass(BaseProtocolStruct)
function SCFishingTeamMemberInfo:__init()
	self.msg_type = 9064
end

function SCFishingTeamMemberInfo:Decode()
	self.member_count = MsgAdapter.ReadInt()							-- 队伍人数

	self.member_uid_1 = MsgAdapter.ReadInt()							-- 队伍玩家1 role_id
	self.least_count_cfg_index_1 = MsgAdapter.ReadInt()					-- 玩家1的双倍积分配置下标
	self.fish_num_list_1 = {}											-- 玩家1的鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list_1[i] = MsgAdapter.ReadInt()
	end

	self.member_uid_2 = MsgAdapter.ReadInt()							-- 队伍玩家2 role_id
	self.least_count_cfg_index_2 = MsgAdapter.ReadInt()					-- 玩家2的双倍积分配置下标
	self.fish_num_list_2 = {}											-- 玩家2的鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list_2[i] = MsgAdapter.ReadInt()
	end

	self.member_uid_3 = MsgAdapter.ReadInt()							-- 队伍玩家3 role_id
	self.least_count_cfg_index_3 = MsgAdapter.ReadInt()					-- 玩家3的双倍积分配置下标
	self.fish_num_list_3 = {}											-- 玩家3的鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
		self.fish_num_list_3[i] = MsgAdapter.ReadInt()
	end
end

-- 钓鱼信息
SCFishingFishInfo = SCFishingFishInfo or BaseClass(BaseProtocolStruct)
function SCFishingFishInfo:__init()
	self.msg_type = 9065
end

function SCFishingFishInfo:Decode()
	self.uid = MsgAdapter.ReadInt()										-- 玩家role_id
	self.least_count_cfg_index = MsgAdapter.ReadInt()					-- 双倍积分配置下标
	self.fish_num_list = {}												-- 鱼数量，以鱼类型左右数组下标

end

-- 钓鱼随机展示角色
SCFishingRandUserInfo = SCFishingRandUserInfo or BaseClass(BaseProtocolStruct)
function SCFishingRandUserInfo:__init()
	self.msg_type = 9066
end

function SCFishingRandUserInfo:Decode()
	self.user_count = MsgAdapter.ReadInt()								-- 玩家个数
	self.user_info_list = {}											-- 鱼数量，以鱼类型左右数组下标
	for i = 1, GameEnum.FISHING_RAND_ROLE_NUM do
		local vo = {}
		vo.uid = MsgAdapter.ReadInt()									-- 玩家role_id
		vo.user_name = MsgAdapter.ReadStrN(32)							-- 名字
		vo.prof = MsgAdapter.ReadShort()								-- 职业
		vo.least_count_cfg_index = MsgAdapter.ReadShort()				-- 双倍积分配置下标

		vo.fish_num_list = {}											-- 鱼数量，以鱼类型左右数组下标
		for j = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT do
			vo.fish_num_list[j] = MsgAdapter.ReadInt()
		end
		self.user_info_list[i] = vo
	end

end

-- 钓鱼积分信息
SCFishingScoreInfo = SCFishingScoreInfo or BaseClass(BaseProtocolStruct)
function SCFishingScoreInfo:__init()
	self.msg_type = 9067
end

function SCFishingScoreInfo:Decode()
	self.fishing_score = MsgAdapter.ReadInt()							-- 钓鱼积分
end

-- 钓鱼偷窃结果
SCFishingStealResult = SCFishingStealResult or BaseClass(BaseProtocolStruct)
function SCFishingStealResult:__init()
	self.msg_type = 9068
end

function SCFishingStealResult:Decode()
	self.is_succ = MsgAdapter.ReadShort()								-- 结果
	self.fish_type = MsgAdapter.ReadShort()								-- 获得鱼类型
	self.fish_num = MsgAdapter.ReadInt()								-- 获得鱼数量
end

-- 钓鱼广播
SCFishingGetFishBrocast = SCFishingGetFishBrocast or BaseClass(BaseProtocolStruct)
function SCFishingGetFishBrocast:__init()
	self.msg_type = 9069
end

function SCFishingGetFishBrocast:Decode()
	self.uid = MsgAdapter.ReadInt()										-- 获得鱼的玩家role_id
	self.get_fish_type = MsgAdapter.ReadInt()							-- 获得鱼类型
end

-- 钓鱼积分榜信息
SCCrossFishingScoreRankList = SCCrossFishingScoreRankList or BaseClass(BaseProtocolStruct)
function SCCrossFishingScoreRankList:__init()
	self.msg_type = 9070
end

function SCCrossFishingScoreRankList:Decode()
	-- self.self_rank = MsgAdapter.ReadInt()								-- 自己的排行名次，未上榜为-1
	-- self.self_rank_item = {}											-- 自己的信息
	-- fish_rank_item(self.self_rank_item)

	self.fish_rank_count = MsgAdapter.ReadInt()							-- 排行榜个数
	self.fish_rank_list = {}
	for i = 1, self.fish_rank_count do
		self.fish_rank_list[i] = {}
		self.fish_rank_list[i].rank_index = i							-- 排名
		self.fish_rank_list[i].user_name = MsgAdapter.ReadStrN(32)		-- 名字
		self.fish_rank_list[i].role_id = MsgAdapter.ReadUInt()
		self.fish_rank_list[i].plat_id = MsgAdapter.ReadUInt()
		self.fish_rank_list[i].uid = self.fish_rank_list[i].role_id + (self.fish_rank_list[i].plat_id * (2 ^ 32))	-- 玩家id
		self.fish_rank_list[i].total_score = MsgAdapter.ReadInt()		-- 总积分
	end
end

-- 钓鱼积分信息 (新增钓鱼积分协议，以前的积分协议在钓鱼场景不适用了可以不用了)
SCFishingScoreStageInfo = SCFishingScoreStageInfo or BaseClass(BaseProtocolStruct)
function SCFishingScoreStageInfo:__init()
	self.msg_type = 9071
end

function SCFishingScoreStageInfo:Decode()
	self.cur_score_stage = MsgAdapter.ReadInt()							-- 当前阶段
	self.fishing_score = MsgAdapter.ReadInt()							-- 当前钓鱼积分
end

-- 钓鱼状态改变广播
SCFishingStatusNotify = SCFishingStatusNotify or BaseClass(BaseProtocolStruct)
function SCFishingStatusNotify:__init()
	self.msg_type = 9072
end

function SCFishingStatusNotify:Decode()
	self.obj_id = MsgAdapter.ReadInt()									-- 玩家的obj_id
	self.status = MsgAdapter.ReadInt()									-- 玩家状态 ： FISHING_STATUS_WAITING ： 钓鱼状态 FISHING_STATUS_CAST ： 抛竿  FISHING_STATUS_PULLED：拉杆
end

--被偷鱼信息
SCFishingStealInfo = SCFishingStealInfo or BaseClass(BaseProtocolStruct)
function SCFishingStealInfo:__init()
	self.msg_type = 9073
end

function SCFishingStealInfo:Decode()
	self.cur_score_stage = MsgAdapter.ReadStrN(32)							-- 盗贼名字
	self.be_stolen_name = MsgAdapter.ReadStrN(32)							-- 被偷名字
	self.fish_type = MsgAdapter.ReadShort()									-- 被偷鱼类型
	self.fish_num = MsgAdapter.ReadShort()									-- 被偷鱼的数量
end

-- 钓鱼确认结果信息
SCFishingConfirmResult = SCFishingConfirmResult or BaseClass(BaseProtocolStruct)
function SCFishingConfirmResult:__init()
	self.msg_type = 9074
end

function SCFishingConfirmResult:Decode()
	self.confirm_type = MsgAdapter.ReadShort()
    self.short_param_1 = MsgAdapter.ReadUShort()
    self.param_2 = MsgAdapter.ReadShort()
    self.param_3 = MsgAdapter.ReadShort()
end
