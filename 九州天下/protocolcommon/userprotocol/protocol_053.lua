-------------------温泉---------------------------------
-- 温泉里玩家信息
SCHotspringPlayerInfo =  SCHotspringPlayerInfo or BaseClass(BaseProtocolStruct)
function SCHotspringPlayerInfo:__init()
	self.msg_type = 5352
end

function SCHotspringPlayerInfo:Decode()
	self.popularity = MsgAdapter.ReadInt()			--玩家人气值
	self.partner_id = MsgAdapter.ReadUInt()
	self.server_id = MsgAdapter.ReadUInt()
	self.partner_uid = self.partner_id + (self.server_id * (2 ^ 32))
	self.give_free_times = MsgAdapter.ReadShort()	--已发送的免费次数
	self.swinsuit = MsgAdapter.ReadShort()
	self.role_id = MsgAdapter.ReadUInt()
	self.plat_id = MsgAdapter.ReadUInt()
	self.uuid = self.role_id + (self.plat_id * (2 ^ 32))
	self.partner_obj_id = MsgAdapter.ReadUShort()
	self.question_right_count = MsgAdapter.ReadChar()
	self.question_wrong_count = MsgAdapter.ReadChar()
	self.curr_score = MsgAdapter.ReadInt()
	self.total_exp = MsgAdapter.ReadInt()
end


-- 温泉玩家排名信息
SCHotspringRankInfo =  SCHotspringRankInfo or BaseClass(BaseProtocolStruct)
function SCHotspringRankInfo:__init()
	self.msg_type = 5353
end

function SCHotspringRankInfo:Decode()
	self.popularity = MsgAdapter.ReadInt()
	self.rank = MsgAdapter.ReadInt()
	self.is_open = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	local rank_count = MsgAdapter.ReadInt()
	self.rank_list = {}
	for i = 1, rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].role_id = MsgAdapter.ReadUInt()
		self.rank_list[i].server_id = MsgAdapter.ReadUInt()
		self.rank_list[i].uuid = self.rank_list[i].role_id + (self.rank_list[i].server_id * (2 ^ 32))
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].popularity = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end


-- 请求送礼物
CSHotspringGivePresent =  CSHotspringGivePresent or BaseClass(BaseProtocolStruct)
function CSHotspringGivePresent:__init()
	self.msg_type = 5300
	self.opera_id = 0
	self.server_id = 0
	self.present_id = 0
	self.is_use_gold = 0
	self.is_role_id = 0
end

function CSHotspringGivePresent:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.opera_id)
	MsgAdapter.WriteUInt(self.server_id)
	MsgAdapter.WriteInt(self.present_id)
	MsgAdapter.WriteShort(self.is_use_gold)
	MsgAdapter.WriteShort(self.is_role_id)
end


-- 添加伙伴请求
CSHSAddPartnerReq =  CSHSAddPartnerReq or BaseClass(BaseProtocolStruct)
function CSHSAddPartnerReq:__init()
	self.msg_type = 5301
	self.obj_id = 0
	self.is_yi_jian = 0
end

function CSHSAddPartnerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUShort(self.obj_id)
	MsgAdapter.WriteShort(self.is_yi_jian)
end


-- 询问被添加伙伴的对象
SCHSAddPartnerReqRoute =  SCHSAddPartnerReqRoute or BaseClass(BaseProtocolStruct)
function SCHSAddPartnerReqRoute:__init()
	self.msg_type = 5354
end

function SCHSAddPartnerReqRoute:Decode()
	self.req_gamename = MsgAdapter.ReadStrN(32)
	self.req_user_id = MsgAdapter.ReadLL()
	self.req_avatar = MsgAdapter.ReadChar()
	self.req_sex = MsgAdapter.ReadChar()
	self.req_prof = MsgAdapter.ReadChar()
	self.req_camp = MsgAdapter.ReadChar()
	self.req_level = MsgAdapter.ReadInt()
	self.req_avatar_key_big = MsgAdapter.ReadUInt()
	self.req_avatar_key_small = MsgAdapter.ReadUInt()
end


-- 被添加伙伴对象处理邀请伙伴请求
CSHSAddPartnerRet =  CSHSAddPartnerRet or BaseClass(BaseProtocolStruct)
function CSHSAddPartnerRet:__init()
	self.msg_type = 5302
	self.req_opera_id = 0
	self.req_server_id = 0
	self.req_gamename = ""
	self.is_accept = 0
	self.reserved = 0
	self.req_sex = 0
	self.req_prof = 0
end

function CSHSAddPartnerRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteUInt(self.req_opera_id)
	MsgAdapter.WriteUInt(self.req_server_id)
	MsgAdapter.WriteStrN(self.req_gamename, 32)
	MsgAdapter.WriteChar(self.is_accept)
	MsgAdapter.WriteChar(self.reserved)
	MsgAdapter.WriteChar(self.req_sex)
	MsgAdapter.WriteChar(self.req_prof)
end


-- 取消伙伴请求
CSHSDeleteParter =  CSHSDeleteParter or BaseClass(BaseProtocolStruct)
function CSHSDeleteParter:__init()
	self.msg_type = 5303
end

function CSHSDeleteParter:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


-- 接收伙伴信息
SCHSSendPartnerInfo =  SCHSSendPartnerInfo or BaseClass(BaseProtocolStruct)
function SCHSSendPartnerInfo:__init()
	self.msg_type = 5350
end

function SCHSSendPartnerInfo:Decode()
	self.partner_id = MsgAdapter.ReadUInt()
	self.server_id = MsgAdapter.ReadUInt()
	self.partner_uid = self.partner_id + (self.server_id * (2 ^ 32))
	self.partner_obj_id = MsgAdapter.ReadUShort()
end

-- 接收经验信息
SCHSAddExpInfo =  SCHSAddExpInfo or BaseClass(BaseProtocolStruct)
function SCHSAddExpInfo:__init()
	self.msg_type = 5351
end

function SCHSAddExpInfo:Decode()
	self.add_exp_total = MsgAdapter.ReadInt()
	self.add_addition = MsgAdapter.ReadInt()
end

local function DecodeShuangXiuInfo()
	local t = {}
	t.role_obj_id1 = MsgAdapter.ReadUShort()
	t.role_obj_id2 = MsgAdapter.ReadUShort()
	return t
end

-- 接收双修信息
SCHSShuangxiuInfo =  SCHSShuangxiuInfo or BaseClass(BaseProtocolStruct)
function SCHSShuangxiuInfo:__init()
	self.msg_type = 5355
end

function SCHSShuangxiuInfo:Decode()
	self.role_1_obj_id = MsgAdapter.ReadUShort()
	self.role_1_partner_obj_id = MsgAdapter.ReadUShort()
	self.role_2_obj_id = MsgAdapter.ReadUShort()
	self.role_2_partner_obj_id = MsgAdapter.ReadUShort()
end
-------------------温泉end---------------------------------

-- 获取答题排名信息
SCHSQARankInfo = SCHSQARankInfo or BaseClass(BaseProtocolStruct)

function SCHSQARankInfo:__init()
	self.msg_type = 5356
	self.self_score = 0
	self.self_rank = 0
	self.is_finish = 0
	self.reserve_1 = 0
	self.reserve_2 = 0
	self.RANK_NUM = 100
	self.rank_count = 0
	self.rank_list = {}
end

function SCHSQARankInfo:Decode()
	self.rank_list = {}
	self.self_score = MsgAdapter.ReadInt()
	self.self_rank = MsgAdapter.ReadInt()
	self.is_finish = MsgAdapter.ReadChar()
	self.reserve_1 = MsgAdapter.ReadChar()
	self.reserve_2 = MsgAdapter.ReadShort()
	self.rank_count = MsgAdapter.ReadInt()
	for i = 1, self.rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uuid = MsgAdapter.ReadLL()
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].score = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

-- 获取答题内容
SCHSQAQuestionBroadcast = SCHSQAQuestionBroadcast or BaseClass(BaseProtocolStruct)

function SCHSQAQuestionBroadcast:__init()
	self.msg_type = 5357
	self.curr_question_begin_time = 0
	self.curr_question_end_time = 0
	self.next_question_start_time = 0			-- 下一题开始时间
	self.broadcast_question_total = 0
	self.curr_question_id = 0
	self.is_exchange = 0
	self.curr_question_str = ""
	self.curr_answer0_desc_str = ""
	self.curr_answer1_desc_str = ""
end

function SCHSQAQuestionBroadcast:Decode()
	self.curr_question_begin_time = MsgAdapter.ReadUInt()
	self.curr_question_end_time = MsgAdapter.ReadUInt()
	self.next_question_start_time = MsgAdapter.ReadUInt()
	self.broadcast_question_total = MsgAdapter.ReadShort()
	self.curr_question_id = MsgAdapter.ReadShort()
	self.is_exchange = MsgAdapter.ReadInt()
	self.curr_question_str = MsgAdapter.ReadStrN(128)
	self.curr_answer0_desc_str = MsgAdapter.ReadStrN(128)
	self.curr_answer1_desc_str = MsgAdapter.ReadStrN(128)
end

--请求答题榜首的信息
CSHSQAFirstPosReq = CSHSQAFirstPosReq or BaseClass(BaseProtocolStruct)
function CSHSQAFirstPosReq:__init()
	self.msg_type = 5304
end

function CSHSQAFirstPosReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--返回题榜首的位置
SCHSQASendFirstPos = SCHSQASendFirstPos or BaseClass(BaseProtocolStruct)
function SCHSQASendFirstPos:__init()
	self.msg_type = 5358
	self.pos_x = 0
	self.pos_y = 0
end

function SCHSQASendFirstPos:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	MsgAdapter.ReadShort()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

-- 玩家答题请求
CSHSQAAnswerReq = CSHSQAAnswerReq or BaseClass(BaseProtocolStruct)

function CSHSQAAnswerReq:__init()
	self.msg_type = 5305
	self.is_use_item = 0
	self.choose = 0
end

function CSHSQAAnswerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.is_use_item)
	MsgAdapter.WriteShort(self.choose)
end

-- 玩家回答结果
SCHSQAnswerResult = SCHSQAnswerResult or BaseClass(BaseProtocolStruct)

function SCHSQAnswerResult:__init()
	self.msg_type = 5359
	self.result = 0
	self.right_result = 0
end

function SCHSQAnswerResult:Decode()
	self.result = MsgAdapter.ReadInt()
	self.right_result = MsgAdapter.ReadInt()
end

-- 玩家请求使用变身卡
CSHSQAUseCardReq = CSHSQAUseCardReq or BaseClass(BaseProtocolStruct)

function CSHSQAUseCardReq:__init()
	self.msg_type = 5306
	self.target_uid = 0
end

function CSHSQAUseCardReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
end

---------------------------合G16-----------------------
-- 发送答题内容
SCQuestionBroadcast = SCQuestionBroadcast or BaseClass(BaseProtocolStruct)

function SCQuestionBroadcast:__init()
	self.msg_type = 5380
	self.question_type = 0
	self.cur_question_id = 0
	self.cur_question_str = ""
	self.cur_answer_desc_1 = ""
	self.cur_answer_desc_2 = ""
	self.cur_answer_desc_3 = ""
	self.cur_answer_desc_4 = ""
	self.reserve = 0
end

function SCQuestionBroadcast:Decode()
	self.question_type = MsgAdapter.ReadShort()
	self.cur_question_id = MsgAdapter.ReadShort()

	self.cur_question_str = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_1 = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_2 = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_3 = MsgAdapter.ReadStrN(128)
	self.cur_answer_desc_4 = MsgAdapter.ReadStrN(128)

	self.cur_question_begin_time = MsgAdapter.ReadUInt()
	self.cur_question_end_time = MsgAdapter.ReadUInt()
	self.next_question_begin_time = MsgAdapter.ReadUInt()
end

-- 玩家答题请求
CSQuestionAnswerReq = CSQuestionAnswerReq or BaseClass(BaseProtocolStruct)

function CSQuestionAnswerReq:__init()
	self.msg_type = 5381
	self.answer_type = 0
	self.choose = 0
end

function CSQuestionAnswerReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.answer_type)
	MsgAdapter.WriteShort(self.choose)
end

-- 发送玩家回答结果
SCQuestionAnswerResult = SCQuestionAnswerResult or BaseClass(BaseProtocolStruct)

function SCQuestionAnswerResult:__init()
	self.msg_type = 5382
	self.result = 0
	self.right_result = 0
end

function SCQuestionAnswerResult:Decode()
	self.answer_type = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	self.result = MsgAdapter.ReadShort()
	self.right_result = MsgAdapter.ReadShort()
end

-- 公会答题排名信息
SCQuestionGuildRankInfo = SCQuestionGuildRankInfo or BaseClass(BaseProtocolStruct)
function SCQuestionGuildRankInfo:__init()
	self.msg_type = 5383
	self.rank_list = {}
end

function SCQuestionGuildRankInfo:Decode()
	self.rank_list = {}
	local rank_count = MsgAdapter.ReadInt()
	for i=1,rank_count do
		self.rank_list[i] = {}
		self.rank_list[i].uid = MsgAdapter.ReadInt()
		self.rank_list[i].right_answer_num = MsgAdapter.ReadInt()
		self.rank_list[i].name = MsgAdapter.ReadStrN(32)
	end
end

--发送玩家回答结果
SCQuestionRightAnswerNum = SCQuestionRightAnswerNum or BaseClass(BaseProtocolStruct)
function SCQuestionRightAnswerNum:__init()
	self.msg_type = 5384
	self.world_right_answer_num = 0
	self.guild_right_answer_num = 0
end

function SCQuestionRightAnswerNum:Decode()
	self.world_right_answer_num = MsgAdapter.ReadInt()
	self.guild_right_answer_num = MsgAdapter.ReadInt()
end

----------------------end--------------------------
