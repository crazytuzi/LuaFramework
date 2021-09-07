
-- 服务器时间返回
SCTimeAck = SCTimeAck or BaseClass(BaseProtocolStruct)
function SCTimeAck:__init()
	self.msg_type = 9001

	self.server_time = 0
	self.server_real_start_time = 0
	self.open_days = 0
	self.server_real_combine_time = 0
end

function SCTimeAck:Decode()
	self.server_time = MsgAdapter.ReadUInt()
	self.server_real_start_time = MsgAdapter.ReadUInt()
	self.open_days = MsgAdapter.ReadInt()
	self.server_real_combine_time = MsgAdapter.ReadUInt()
end

-- 请求服务器时间
CSTimeReq = CSTimeReq or BaseClass(BaseProtocolStruct)
function CSTimeReq:__init()
	self.msg_type = 9051
end

function CSTimeReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

SCDisconnectNotice = SCDisconnectNotice or BaseClass(BaseProtocolStruct)
function SCDisconnectNotice:__init()
	self.msg_type = 9003
end

function SCDisconnectNotice:Decode()
	self.reason = MsgAdapter.ReadInt()
end


-------------------- 结婚
-- 结婚操作 9010 
CSMarryOperate = CSMarryOperate or BaseClass(BaseProtocolStruct)
function CSMarryOperate:__init()
	self.msg_type = 9010
end

function CSMarryOperate:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.ope_type)
	MsgAdapter.WriteInt(self.param1)
end

-- 结婚操作回馈 9011
SCMarryRetInfo = SCMarryRetInfo or BaseClass(BaseProtocolStruct)
function SCMarryRetInfo:__init()
	self.msg_type = 9011
end

function SCMarryRetInfo:Decode()
	self.ret_type = MsgAdapter.ReadInt()
	self.ret_val = MsgAdapter.ReadInt()
end

-- 婚宴状态切换通知 9012
SCHunyanStateInfo = SCHunyanStateInfo or BaseClass(BaseProtocolStruct)
function SCHunyanStateInfo:__init()
	self.msg_type = 9012
end

function SCHunyanStateInfo:Decode()
	self.state_type = MsgAdapter.ReadInt()
	self.next_state_timestamp = MsgAdapter.ReadUInt()
end

-- 情缘操作请求
CSQingYuanOperaReq = CSQingYuanOperaReq or BaseClass(BaseProtocolStruct)
function CSQingYuanOperaReq:__init()
	self.msg_type = 9013
	self.opera_type = 0
	self.param1 = 0
	self.param2 = 0
end

function CSQingYuanOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param1)
	MsgAdapter.WriteInt(self.param2)
end

-- 情缘信息
SCQingYuanAllInfo = SCQingYuanAllInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanAllInfo:__init()
	self.msg_type = 9014
	self.info_type = 0
	self.param_ch1 = 0
	self.param_ch2 = 0
	self.param_ch3 = 0
	self.param_ch4 = 0
	self.param2 = 0
	self.role_name = ""
end

function SCQingYuanAllInfo:Decode()
	self.info_type = MsgAdapter.ReadInt()
	self.param_ch1 = MsgAdapter.ReadChar()
	self.param_ch2 = MsgAdapter.ReadChar()
	self.param_ch3 = MsgAdapter.ReadChar()
	self.param_ch4 = MsgAdapter.ReadChar()
	self.param2 = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStrN(32)
end

-- 情缘婚礼信息
SCQingYuanWeddingAllInfo = SCQingYuanWeddingAllInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanWeddingAllInfo:__init()
	self.msg_type = 9015
	self.role_id = 0
	self.lover_role_id = 0
	self.wedding_type = 0
	self.has_invite_guests_num = 0
	self.can_invite_guest_num = 0
	self.wedding_yuyue_seq = 0
	self.count = 0

	self.guests_list = {}
end

function SCQingYuanWeddingAllInfo:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.lover_role_id = MsgAdapter.ReadInt()
	self.wedding_type = MsgAdapter.ReadChar()
	self.has_invite_guests_num = MsgAdapter.ReadChar()
	self.can_invite_guest_num = MsgAdapter.ReadChar()
	self.wedding_yuyue_seq = MsgAdapter.ReadChar()
	self.count = MsgAdapter.ReadInt()

	self.guests_list = {}
	for i = 1, self.count do
		self.guests_list[i] = {}
		self.guests_list[i].user_id = MsgAdapter.ReadInt()
		self.guests_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

-- 祝福历史记录
SCWeddingBlessingRecordInfo = SCWeddingBlessingRecordInfo or BaseClass(BaseProtocolStruct)
function SCWeddingBlessingRecordInfo:__init()
	self.msg_type = 9016
	self.bless_max_record_num = 10
	self.count = 0
end

function SCWeddingBlessingRecordInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.bless_record_list = {}
	for i = 1, self.count do
		local vo = {}
		vo.role_name = MsgAdapter.ReadStrN(32)
		vo.to_role_name = MsgAdapter.ReadStrN(32)
		vo.bless_type = MsgAdapter.ReadInt()
		vo.param = MsgAdapter.ReadInt()
		vo.timestamp = MsgAdapter.ReadUInt()
		self.bless_record_list[self.count - i + 1] = vo		-- 从后往前储数据
	end
end

-- 申请者信息
SCWeddingApplicantInfo = SCWeddingApplicantInfo or BaseClass(BaseProtocolStruct)
function SCWeddingApplicantInfo:__init()
	self.msg_type = 9017
	self.guests_max_num = 30
	self.count = 0
end

function SCWeddingApplicantInfo:Decode()
	self.count = MsgAdapter.ReadInt()
	self.guests_list = {}
	for i = 1, self.count do
		self.guests_list[i] = {}
		self.guests_list[i].user_id = MsgAdapter.ReadInt()
		self.guests_list[i].role_name = MsgAdapter.ReadStrN(32)
	end
end

-- 当前婚礼信息
SCHunYanCurWeddingAllInfo = SCHunYanCurWeddingAllInfo or BaseClass(BaseProtocolStruct)
function SCHunYanCurWeddingAllInfo:__init()
	self.msg_type = 9018
end

function SCHunYanCurWeddingAllInfo:Decode()
	self.marryuser_list = {}
	for i = 1, 2 do
		local vo = {}
		vo.marry_uid = MsgAdapter.ReadInt()
		vo.marry_name = MsgAdapter.ReadStrN(32)
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.hongbao_count = MsgAdapter.ReadChar()			-- 发了多少次红包的数量
		vo.avatar_key_big = MsgAdapter.ReadInt()			-- long long avator_timestamp; 拆分成两个两个int型的
		vo.avatar_key_small = MsgAdapter.ReadInt()
		self.marryuser_list[i] = vo
	end

	self.cur_wedding_seq = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	self.wedding_index = MsgAdapter.ReadInt()
	self.count = MsgAdapter.ReadInt()
	self.guests_uid = {}
	for i= 1, self.count do
		self.guests_uid[i] = {}
		self.guests_uid[i].user_id = MsgAdapter.ReadInt()
	end
end

-- 婚礼玩家个人信息
SCWeddingRoleInfo = SCWeddingRoleInfo or BaseClass(BaseProtocolStruct)
function SCWeddingRoleInfo:__init()
	self.msg_type = 9019
	self.wedding_liveness = 0
	self.is_baitang = 0
	self.is_in_red_bag_fulsh_time = 0
	self.banquet_has_gather_num = 0
	self.cur_turn_has_gather_red_bag = 0
	self.total_exp = 0
end

function SCWeddingRoleInfo:Decode()
	self.wedding_liveness = MsgAdapter.ReadShort()				-- 热度
	self.is_baitang = MsgAdapter.ReadChar()						-- 是否拜堂
	self.is_in_red_bag_fulsh_time = MsgAdapter.ReadChar()		-- 是否在红包刷新时间
	self.banquet_has_gather_num = MsgAdapter.ReadShort()		-- 已经采集酒席的数量
	self.cur_turn_has_gather_red_bag = MsgAdapter.ReadShort()	-- 不同热度采集红包个数
	self.total_exp = MsgAdapter.ReadLL()						-- 婚宴中挂机获得的经验
end

-- 符文注灵（八卦祭炼）
SCRuneSystemZhulingRandResultInfo = SCRuneSystemZhulingRandResultInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemZhulingRandResultInfo:__init()
	self.msg_type = 9020
end

function SCRuneSystemZhulingRandResultInfo:Decode()
	self.index = MsgAdapter.ReadInt()
	self.zhuling_slot_bless = MsgAdapter.ReadInt()
end

SCRuneSystemZhulingAllInfo = SCRuneSystemZhulingAllInfo or BaseClass(BaseProtocolStruct)
function SCRuneSystemZhulingAllInfo:__init()
	self.msg_type = 9021
end

function SCRuneSystemZhulingAllInfo:Decode()
	self.zhuling_slot_bless = MsgAdapter.ReadInt()
	self.run_zhuling_list = {}
	for i=1, GameEnum.RUNE_SYSTEM_SLOT_MAX_NUM do
		self.run_zhuling_list[i] = {}
		self.run_zhuling_list[i].grade = MsgAdapter.ReadInt()
		self.run_zhuling_list[i].zhuling_bless = MsgAdapter.ReadInt()
	end
end

-- 婚宴答题个人信息
SCHunyanQuestionUserInfo = SCHunyanQuestionUserInfo or BaseClass(BaseProtocolStruct)
function SCHunyanQuestionUserInfo:__init()
	self.msg_type = 9030
end

function SCHunyanQuestionUserInfo:Decode()
	self.user_info = {}
	self.user_info.question_count = MsgAdapter.ReadShort()			--题目总数量
	self.user_info.cur_question_idx = MsgAdapter.ReadShort()		--当前答题下标
	self.user_info.question_score = MsgAdapter.ReadInt()			--答题积分
	self.user_info.next_answer_timestamp = MsgAdapter.ReadUInt()	--下次可以答题的时间戳

	self.question_list = {}
	for i=1,self.user_info.question_count do
		local vo = {}
		vo.question_id = MsgAdapter.ReadShort()						--题目id
		vo.npc_pos_seq = MsgAdapter.ReadChar()						--npc_pos seq
		vo.answer_status = MsgAdapter.ReadChar()					--答题状态 1已答题 0未答题
		self.question_list[i] = vo
	end
end

-- 婚宴答题排行信息MAX_RANK_COUNT = 100
SCHunyanQuestionRankInfo = SCHunyanQuestionRankInfo or BaseClass(BaseProtocolStruct)
function SCHunyanQuestionRankInfo:__init()
	self.msg_type = 9031
end

function SCHunyanQuestionRankInfo:Decode()
	self.rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i=1,self.rank_count do
		local vo = {}
		vo.rank = i									--玩家排名
		vo.role_id = MsgAdapter.ReadInt()			--玩家id
		vo.name = MsgAdapter.ReadStrN(32)			--玩家名字
		vo.score = MsgAdapter.ReadInt()				--玩家积分
		vo.timestamp = MsgAdapter.ReadUInt()		--玩家上榜时间戳
		self.rank_list[i] = vo
	end
end

-- 婚宴答题对错返回
SCHunyanAnswerResult = SCHunyanAnswerResult or BaseClass(BaseProtocolStruct)
function SCHunyanAnswerResult:__init()
	self.msg_type = 9032
end

function SCHunyanAnswerResult:Decode()
	self.npc_seq = MsgAdapter.ReadShort()
	self.is_righ = MsgAdapter.ReadShort()
end

-- 奋起直追
CSFenqizhizhuiOperaReq = CSFenqizhizhuiOperaReq or BaseClass(BaseProtocolStruct)
function CSFenqizhizhuiOperaReq:__init()
	self.msg_type = 9040

	self.opera_type = 0
	self.param_1 = 0
end

function CSFenqizhizhuiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param_1)
end

SCFenqizhizhuiAllInfo = SCFenqizhizhuiAllInfo or BaseClass(BaseProtocolStruct)
function SCFenqizhizhuiAllInfo:__init()
	self.msg_type = 9045

	self.func_type = 0
	self.func_grade = 0
	self.func_is_max_grade = 0
	self.is_fetch = 0
	self.today_chongzhi_num = 0
end

function SCFenqizhizhuiAllInfo:Decode()
	self.func_type = MsgAdapter.ReadShort()															--	功能类型
	self.func_grade = MsgAdapter.ReadShort()														--	功能等级
	self.func_is_max_grade = MsgAdapter.ReadChar()													--	是否满级
	self.is_fetch = MsgAdapter.ReadChar()															--	是否拿取过
	MsgAdapter.ReadShort()																			--	保留
	self.today_chongzhi_num = MsgAdapter.ReadInt()													--	今日充值数
end


--一次性装备时装、坐骑、羽翼等结果
SCUseImagesAck = SCUseImagesAck or BaseClass(BaseProtocolStruct)
function SCUseImagesAck:__init()
	self.msg_type = 9000

	self.is_use_all_succ = 0
	self.is_use_index_succ = {}
	self.is_use_mount_succ = 0
	self.is_use_wing_succ = 0
end

function SCUseImagesAck:Decode()
	self.is_use_all_succ = MsgAdapter.ReadInt()
	self.is_use_index_succ = {}
	for i = 1, GameEnum.SHIZHUANG_TYPE_MAX do
		self.is_use_index_succ[i] = MsgAdapter.ReadInt()
	end

	self.is_use_mount_succ = MsgAdapter.ReadInt()
	self.is_use_wing_succ = MsgAdapter.ReadInt()
end

--中秋活动 累计登陆
SCRALjdlAllInfo = SCRALjdlAllInfo or BaseClass(BaseProtocolStruct)
function SCRALjdlAllInfo:__init()
	self.msg_type = 9043

	self.cur_logindday = 0
	self.daily_reward = 0
	self.login_reward_flag = 0
end

function SCRALjdlAllInfo:Decode()
	self.cur_logindday = MsgAdapter.ReadChar()
	self.daily_reward = MsgAdapter.ReadChar()
	self.login_reward_flag = MsgAdapter.ReadUShort()
end

--玩家充值金额
SCTotalChongzhiInfo = SCTotalChongzhiInfo or BaseClass(BaseProtocolStruct)
function SCTotalChongzhiInfo:__init()
	self.msg_type = 9046
	self.total_chongzhi = 0
end

function SCTotalChongzhiInfo:Decode()
	self.total_chongzhi = MsgAdapter.ReadLL()
end

-- 头衔请求操作
CSHonourTitleReq = CSHonourTitleReq or BaseClass(BaseProtocolStruct)
function CSHonourTitleReq:__init()
	self.msg_type = 9048

	self.req_type = 0
	self.param = 0
end

function CSHonourTitleReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)

	MsgAdapter.WriteShort(self.req_type)
	MsgAdapter.WriteShort(self.param)
end

-- 头衔技能触发信息
SCHonourTitleTriggerSkillInfo = SCHonourTitleTriggerSkillInfo or BaseClass(BaseProtocolStruct)
function SCHonourTitleTriggerSkillInfo:__init()
	self.msg_type = 9049

	self.obj_id = 0						-- 角色objid
	self.skill_type = 0					-- 触发的技能类型
	self.is_exist = 0					-- 技能Buff是否还存在
	self.param1 = 0
	self.param2 = 0
end

function SCHonourTitleTriggerSkillInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.skill_type = MsgAdapter.ReadShort()
	self.is_exist = MsgAdapter.ReadInt()
	self.param1 = MsgAdapter.ReadUInt()
	self.param2 = MsgAdapter.ReadUInt()
end

-- 头衔所有信息
SCHonourTitleAllInfo = SCHonourTitleAllInfo or BaseClass(BaseProtocolStruct)
function SCHonourTitleAllInfo:__init()
	self.msg_type = 9044

	self.obj_id = 0
	self.title_level = 0
end

function SCHonourTitleAllInfo:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.title_level = MsgAdapter.ReadInt()
end



-- 防止卡死，强制脱离场景请求
CSFixStuckReq = CSFixStuckReq or BaseClass(BaseProtocolStruct)
function CSFixStuckReq:__init()
	self.msg_type = 9035
end

function CSFixStuckReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

-- 请求强制脱离场景服务端返回
SCFixStuckAck = SCFixStuckAck or BaseClass(BaseProtocolStruct)
function SCFixStuckAck:__init()
	self.msg_type = 9036
	self.status = 0
end

function SCFixStuckAck:Decode()
	self.status = MsgAdapter.ReadInt()  -- 0代表开始读条，1代表读条被打断，2代表成功
end

-----荣誉系统请求
CSCrossMedalReq = CSCrossMedalReq or BaseClass(BaseProtocolStruct)
function CSCrossMedalReq:__init()
	self.msg_type = 9041
	self.parm = 0
	self.reserve_sh = 0
end

function CSCrossMedalReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.param)
	MsgAdapter.WriteShort(self.reserve_sh)
end

--荣誉系统信息
SCCrossMedalInfo = SCCrossMedalInfo or BaseClass(BaseProtocolStruct)
function SCCrossMedalInfo:__init()
	self.msg_type = 9042
end

function SCCrossMedalInfo:Decode()
	self.uplevel = MsgAdapter.ReadShort()
	self.level = MsgAdapter.ReadShort()
    self.honour = MsgAdapter.ReadInt()
    self.add_gongji = MsgAdapter.ReadInt()
    self.add_hp = MsgAdapter.ReadInt()
    self.add_fangyu = MsgAdapter.ReadInt()
end
