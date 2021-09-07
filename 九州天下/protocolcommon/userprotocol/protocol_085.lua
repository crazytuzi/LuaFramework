----------------------------------------美人-------------------------
--美人-通用请求
CSBeautyCommonReq = CSBeautyCommonReq or BaseClass(BaseProtocolStruct)
function CSBeautyCommonReq:__init()
	self.msg_type = 8500
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSBeautyCommonReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end

--美人全部信息
SCBeautyBaseInfo = SCBeautyBaseInfo or BaseClass(BaseProtocolStruct)
function SCBeautyBaseInfo:__init()
	self.msg_type = 8520
	self.cur_used_seq = 0						-- 当前出战的美人
	self.cur_huanhua_seq = 0					-- 当前使用的幻化seq
	self.has_chanmian = 0						-- 是否缠绵过
	self.can_heti = 0							-- 是否可以合体
	self.task_complete_flag = 0					-- 任务完成标记（美人心愿）
	self.task_type_flag = 0						-- 今日需要完成的任务类型标记
	self.xinji_skill_set_active_flag = 0		-- 心计组合技能激活标记
	self.next_can_free_draw_time = 0			-- 下一次可以免费抽的时间
	self.free_draw_times = 0					-- 今日免费抽的次数
end

function SCBeautyBaseInfo:Decode()
	self.cur_used_seq = MsgAdapter.ReadChar()
	self.cur_huanhua_seq = MsgAdapter.ReadChar()		
	self.has_chanmian = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.task_complete_flag = MsgAdapter.ReadUInt()
	self.task_type_flag = MsgAdapter.ReadUInt()
	self.task_reward_fetch_flag = MsgAdapter.ReadUInt()
	self.xinji_skill_set_active_flag = MsgAdapter.ReadUInt()
	self.next_can_free_draw_time = MsgAdapter.ReadUInt()
	self.free_draw_times = MsgAdapter.ReadShort()
	self.today_beauty_seq = MsgAdapter.ReadShort() 	-- 今日美人索引（大于等于100为幻化美人，偏移100）
	self.today_kill_num = MsgAdapter.ReadInt()		-- 今日击杀的玩家数
	self.today_camp_jungong = MsgAdapter.ReadInt()	-- 今日获取的军功数
	self.draw_times = MsgAdapter.ReadInt()			-- 抽奖次数
	self.one_more_draw_times = MsgAdapter.ReadInt()	-- 再来一次的次数
	
	self.beauty_heti_flag_low = MsgAdapter.ReadInt()		-- 美人合体标记高位
	self.beauty_heti_flag_high = MsgAdapter.ReadInt()		-- 美人合体标记低位

	self.huanhua_heti_flag_low = MsgAdapter.ReadInt()	-- 幻化合体标记高位
	self.huanhua_heti_flag_high = MsgAdapter.ReadInt()	-- 幻化合体标记低位

end

--美人信息
SCBeautyItemInfo = SCBeautyItemInfo or BaseClass(BaseProtocolStruct)
function SCBeautyItemInfo:__init()
	self.msg_type = 8521
	self.beauty_item_list = {}
end

function SCBeautyItemInfo:Decode()
	local beauty_item_count = MsgAdapter.ReadInt()
	for i=1, beauty_item_count do
		self.beauty_item_list[i] = {}
		self.beauty_item_list[i].is_active = MsgAdapter.ReadChar()		--是否已激活
		self.beauty_item_list[i].grade = MsgAdapter.ReadChar()			--阶
		self.beauty_item_list[i].is_active_shenwu = MsgAdapter.ReadChar()	--是否已激活神武
		MsgAdapter.ReadChar()
		self.beauty_item_list[i].upgrade_val = MsgAdapter.ReadInt()		--进阶值
		self.beauty_item_list[i].level_val = MsgAdapter.ReadInt()				-- 缠绵进阶值
		self.beauty_item_list[i].level = MsgAdapter.ReadInt()						-- 缠绵阶
	end
end

--美人-技能触发
SCBeautySkillTrigger = SCBeautySkillTrigger or BaseClass(BaseProtocolStruct)
function SCBeautySkillTrigger:__init()
	self.msg_type = 8522
	self.obj_id = 0
	self.skill_type = 0
	self.is_exist = 0

end

function SCBeautySkillTrigger:Decode()
	self.obj_id = MsgAdapter.ReadUShort()						--美人所属的角色
	self.skill_type = MsgAdapter.ReadShort()					--触发的技能类型
	self.is_exist = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadUInt()
	self.param2 = MsgAdapter.ReadUInt()
end

SCBeautyXinjiTypeInfo = SCBeautyXinjiTypeInfo or BaseClass(BaseProtocolStruct)
function SCBeautyXinjiTypeInfo:__init()
	self.msg_type = 8524
	self.type = 0
	self.skill_item_list = {}
end

function SCBeautyXinjiTypeInfo:Decode()	
	self.type = MsgAdapter.ReadInt()
	self.bless_val = MsgAdapter.ReadInt()
	self.active_max_slot = MsgAdapter.ReadInt()

	self.skill_item_list = {}
	for i=1,10 do
		local vo = {}
		vo.is_lock = MsgAdapter.ReadChar()	--是否已锁定
		vo.level = MsgAdapter.ReadChar()	--等级
		vo.seq = MsgAdapter.ReadShort()		--技能的seq
		MsgAdapter.ReadStrN(8)

		self.skill_item_list[i] = vo
	end
end

-- 合体属性
SCBeautyHetiAttrs = SCBeautyHetiAttrs or BaseClass(BaseProtocolStruct)
function SCBeautyHetiAttrs:__init()
	self.msg_type = 8525
end

function SCBeautyHetiAttrs:Decode()
	self.count = MsgAdapter.ReadInt()
	self.attr_list = {}

	for i=1,self.count do
		local vo = {}
		vo.attr_type = MsgAdapter.ReadInt()
		vo.attr_value = MsgAdapter.ReadInt()
		self.attr_list[i] = vo
	end
end

--幻化信息 8526
SCBeautyHuanhuaInfo = SCBeautyHuanhuaInfo or BaseClass(BaseProtocolStruct)
function SCBeautyHuanhuaInfo:__init()
	self.msg_type = 8526
end

function SCBeautyHuanhuaInfo:Decode()
	local huanhua_item_count = MsgAdapter.ReadInt()
	self.huanhua_item_list = {}
	local seq = 0
	for i=1,huanhua_item_count do
		local vo = {}
		vo.seq = seq
		vo.level = MsgAdapter.ReadInt()				--幻化等级
		vo.dating_times = MsgAdapter.ReadChar()		--今日已幻化次数
		vo.is_active_shenwu = MsgAdapter.ReadChar()	--是否激活神武
		MsgAdapter.ReadShort()
		self.huanhua_item_list[i] = vo
		seq = seq + 1
	end
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
	self.shenbing_image_flag = MsgAdapter.ReadLL()			-- 神兵形象激活标记
	self.shenbing_texiao_flag = MsgAdapter.ReadLL()			-- 神兵特效激活标记
	self.baojia_image_flag = MsgAdapter.ReadLL()			-- 宝甲形象激活标记
	self.baojia_texiao_flag = MsgAdapter.ReadLL()			-- 宝甲特效激活标记

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
		for j = 0, GameEnum.SHENQI_PART_TYPE_MAX - 1 do 	-- SHENQI_PART_TYPE_MAX = 4
			vo.quality_list[j] = MsgAdapter.ReadChar()
		end
		self.shenbing_list[i] = vo
	end

	self.baojia_list = {}									-- 宝甲列表
	for i = 0, GameEnum.SHENQI_SUIT_NUM_MAX - 1 do
		local vo = {}
		vo.level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		vo.exp = MsgAdapter.ReadInt()

		vo.quality_list = {}
		for j = 0, GameEnum.SHENQI_PART_TYPE_MAX - 1 do
			vo.quality_list[j] = MsgAdapter.ReadChar()
		end
		self.baojia_list[i] = vo
	end
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

	for i = 0, GameEnum.SHENQI_PART_TYPE_MAX - 1 do
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

	self.image_active_flag = MsgAdapter.ReadLL()				-- 形象激活标记
	self.texiao_active_flag = MsgAdapter.ReadLL()				-- 特效激活标记
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

------------------------------ 神器 end -----------------------------

--------------------------------------勾玉-------------------------------------------------
--勾玉信息请求
CSGetGouyuInfoReq = CSGetGouyuInfoReq or BaseClass(BaseProtocolStruct)
function CSGetGouyuInfoReq:__init()
	self.msg_type = 8550
end

function CSGetGouyuInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--勾玉首饰信息回复EUIPMENT_TYPE_MAX = 3
SCGouyuInfoAck = SCGouyuInfoAck or BaseClass(BaseProtocolStruct)
function SCGouyuInfoAck:__init()
	self.msg_type = 8551
	self.count = 0
	self.level_list = {}		-- 等级列表(下标0是勾玉等级，1是戒指等级以此类推)
end

function SCGouyuInfoAck:Decode()
	self.count = MsgAdapter.ReadShort()
	for i=0,2 do
		self.level_list[i] = MsgAdapter.ReadShort()
	end
end

--勾玉升级请求
CSGouyuUplevelReq = CSGouyuUplevelReq or BaseClass(BaseProtocolStruct)
function CSGouyuUplevelReq:__init()
	self.msg_type = 8560		
	self.equipment_type = 0
end

function CSGouyuUplevelReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.equipment_type)
end

-- --勾玉升级回复
SCGouyuUplevelAck = SCGouyuUplevelAck or BaseClass(BaseProtocolStruct)
function SCGouyuUplevelAck:__init()
	self.msg_type = 8561
	self.equipment_type = 0
	self.is_succ = 0				-- 是否升级成功
	self.gouyu_level = 0			-- 勾玉的等级
end

function SCGouyuUplevelAck:Decode()
	self.equipment_type = MsgAdapter.ReadShort()
	self.is_succ = MsgAdapter.ReadShort()
	self.gouyu_level = MsgAdapter.ReadInt()
end

--------------------------------------------------------------------------
-- 钓鱼通用请求
CSFishingOperaReq = CSFishingOperaReq or BaseClass(BaseProtocolStruct)
function CSFishingOperaReq:__init()
	self.msg_type = 8570
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
	self.msg_type = 8580
end

function SCFishingUserInfo:Decode()
	self.uuid = MsgAdapter.ReadLL()										-- 主角跨服id
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
	self.msg_type = 8581
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
	self.msg_type = 8582
end

function SCFishingGearUseResult:Decode()
	self.gear_type = MsgAdapter.ReadShort()								-- 使用法宝类型
	self.param1 = MsgAdapter.ReadShort()								-- 获得鱼的类型
	self.param2 = MsgAdapter.ReadShort()								-- 获得鱼的数量
	self.param3 = MsgAdapter.ReadShort()
end

SCFishingEventBigFish = SCFishingEventBigFish or BaseClass(BaseProtocolStruct)
function SCFishingEventBigFish:__init()
	self.msg_type = 8583
end

function SCFishingEventBigFish:Decode()
	self.owner_uid = MsgAdapter.ReadInt()								-- 拥有者role_id
end

-- 钓鱼队伍信息
SCFishingTeamMemberInfo = SCFishingTeamMemberInfo or BaseClass(BaseProtocolStruct)
function SCFishingTeamMemberInfo:__init()
	self.msg_type = 8584
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
	self.msg_type = 8585
end

function SCFishingFishInfo:Decode()
	self.uid = MsgAdapter.ReadInt()										-- 玩家role_id
	self.least_count_cfg_index = MsgAdapter.ReadInt()					-- 双倍积分配置下标
	self.fish_num_list = {}												-- 鱼数量，以鱼类型左右数组下标

end

-- 钓鱼随机展示角色
SCFishingRandUserInfo = SCFishingRandUserInfo or BaseClass(BaseProtocolStruct)
function SCFishingRandUserInfo:__init()
	self.msg_type = 8586
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
	self.msg_type = 8587
end

function SCFishingScoreInfo:Decode()
	self.fishing_score = MsgAdapter.ReadInt()							-- 钓鱼积分
end

-- 钓鱼偷窃结果
SCFishingStealResult = SCFishingStealResult or BaseClass(BaseProtocolStruct)
function SCFishingStealResult:__init()
	self.msg_type = 8588
end

function SCFishingStealResult:Decode()
	self.is_succ = MsgAdapter.ReadShort()								-- 结果
	self.fish_type = MsgAdapter.ReadShort()								-- 获得鱼类型
	self.fish_num = MsgAdapter.ReadInt()								-- 获得鱼数量

end

-- 钓鱼广播
SCFishingGetFishBrocast = SCFishingGetFishBrocast or BaseClass(BaseProtocolStruct)
function SCFishingGetFishBrocast:__init()
	self.msg_type = 8589
end

function SCFishingGetFishBrocast:Decode()
	self.uid = MsgAdapter.ReadInt()										-- 获得鱼的玩家role_id
	self.get_fish_type = MsgAdapter.ReadInt()							-- 获得鱼类型
end

-- 钓鱼积分榜信息
SCCrossFishingScoreRankList = SCCrossFishingScoreRankList or BaseClass(BaseProtocolStruct)
function SCCrossFishingScoreRankList:__init()
	self.msg_type = 8590
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
		self.fish_rank_list[i].server_id = MsgAdapter.ReadUInt()
		self.fish_rank_list[i].uid = self.fish_rank_list[i].role_id + (self.fish_rank_list[i].server_id * (2 ^ 32))
		self.fish_rank_list[i].total_score = MsgAdapter.ReadInt()		-- 总积分
	end
end

-- 钓鱼积分信息 (新增钓鱼积分协议，以前的积分协议在钓鱼场景不适用了可以不用了)
SCFishingScoreStageInfo = SCFishingScoreStageInfo or BaseClass(BaseProtocolStruct)
function SCFishingScoreStageInfo:__init()
	self.msg_type = 8591
end

function SCFishingScoreStageInfo:Decode()
	self.cur_score_stage = MsgAdapter.ReadInt()							-- 当前阶段
	self.fishing_score = MsgAdapter.ReadInt()							-- 当前钓鱼积分
end

-- 钓鱼状态改变广播
SCFishingStatusNotify = SCFishingStatusNotify or BaseClass(BaseProtocolStruct)
function SCFishingStatusNotify:__init()
	self.msg_type = 8592
end

function SCFishingStatusNotify:Decode()
	self.obj_id = MsgAdapter.ReadInt()									-- 玩家的obj_id
	self.status = MsgAdapter.ReadInt()									-- 玩家状态 ： FISHING_STATUS_WAITING ： 钓鱼状态 FISHING_STATUS_CAST ： 抛竿  FISHING_STATUS_PULLED：拉杆
end

--被偷鱼信息
SCFishingStealInfo = SCFishingStealInfo or BaseClass(BaseProtocolStruct)
function SCFishingStealInfo:__init()
	self.msg_type = 8593
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
	self.msg_type = 8594
end

function SCFishingConfirmResult:Decode()
	self.confirm_type = MsgAdapter.ReadShort()
    self.short_param_1 = MsgAdapter.ReadUShort()
    self.param_2 = MsgAdapter.ReadShort()
    self.param_3 = MsgAdapter.ReadShort()
end

-- 名将请求
CSGreateSoldierOpera = CSGreateSoldierOpera or BaseClass(BaseProtocolStruct)
function CSGreateSoldierOpera:__init()
	self.msg_type = 8595
	self.req_type = 0
	self.param_1 = 0
	self.param_2 = 0
	self.param_3 = 0
end

function CSGreateSoldierOpera:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	
	MsgAdapter.WriteUShort(self.req_type)
	MsgAdapter.WriteUShort(self.param_1)
	MsgAdapter.WriteUShort(self.param_2)
	MsgAdapter.WriteUShort(self.param_3)
end

---------------------------------情缘圣地----------------------------------
--情缘圣地操作请求
CSQingYuanShengDiOperaReq = CSQingYuanShengDiOperaReq or BaseClass(BaseProtocolStruct)
function CSQingYuanShengDiOperaReq:__init()
	self.msg_type = 8395
	self.opera_type = 0
	self.param = 0
end

function CSQingYuanShengDiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param)
end

-- 情缘圣地任务信息
SCQingYuanShengDiTaskInfo = SCQingYuanShengDiTaskInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanShengDiTaskInfo:__init()
	self.msg_type = 8396
end

function SCQingYuanShengDiTaskInfo:Decode()
	self.is_fetched_task_other_reward = MsgAdapter.ReadChar()
	self.lover_is_all_task_complete = MsgAdapter.ReadChar()
	self.task_count = MsgAdapter.ReadShort()
	self.task_info_list = {}
	for i=1, self.task_count do
		local vo = {}
		vo.task_id = MsgAdapter.ReadUShort()
		vo.is_fetched_reward = MsgAdapter.ReadChar()
		vo.reserve = MsgAdapter.ReadChar()
		vo.param = MsgAdapter.ReadInt()
		vo.index = i - 1
		self.task_info_list[i] = vo
	end
end

SCQingYuanShengDiBossInfo = SCQingYuanShengDiBossInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanShengDiBossInfo:__init()
	self.msg_type = 8397
end

function SCQingYuanShengDiBossInfo:Decode()
	self.boss_count = MsgAdapter.ReadInt()
	self.boss_list = {}
	for i=1, self.boss_count do
		local vo = {}
		vo.boss_id = MsgAdapter.ReadInt()
		vo.pos_x = MsgAdapter.ReadUShort()
		vo.pos_y = MsgAdapter.ReadUShort()
		vo.next_refresh_time = MsgAdapter.ReadUInt()
		self.boss_list[i] = vo
	end
end